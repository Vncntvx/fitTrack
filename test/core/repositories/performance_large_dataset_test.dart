import 'dart:math';

import 'package:drift/drift.dart';
import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/stats_repository.dart';
import 'package:fittrack/core/usecases/stats/stats_models.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_db_helper.dart';

void main() {
  group('Repository performance benchmarks', () {
    test(
      'stats/running/swimming queries stay within practical CI budget on large dataset',
      () async {
        await withTestDatabase(
          body: (db) async {
            final random = Random(42);
            final today = DateTime.now();
            final referenceDay = DateTime(today.year, today.month, today.day);
            const totalSessions = 9000;
            const sessionIntervalHours = 2;
            const benchmarkRuns = 5;
            const medianBudgetMs = 2500;
            const worstBudgetMs = 4000;
            const expectedEachType = totalSessions ~/ 3;

            final sessions = List.generate(totalSessions, (index) {
              final type = switch (index % 3) {
                0 => 'running',
                1 => 'swimming',
                _ => 'cycling',
              };
              return TrainingSessionsCompanion.insert(
                datetime: referenceDay
                    .subtract(const Duration(days: 500))
                    .add(Duration(hours: index * sessionIntervalHours)),
                type: type,
                durationMinutes: 20 + random.nextInt(100),
                intensity: switch (index % 3) {
                  0 => 'light',
                  1 => 'moderate',
                  _ => 'high',
                },
              );
            });

            await db.batch((batch) {
              batch.insertAll(db.trainingSessions, sessions);
            });

            final insertedSessions = await (db.selectOnly(
              db.trainingSessions,
            )..addColumns([db.trainingSessions.id.count()])).getSingle();
            final sessionTotal =
                insertedSessions.read(db.trainingSessions.id.count()) ?? 0;
            expect(sessionTotal, totalSessions);

            final runningSessions = await (db.select(
              db.trainingSessions,
            )..where((t) => t.type.equals('running'))).get();
            final swimmingSessions = await (db.select(
              db.trainingSessions,
            )..where((t) => t.type.equals('swimming'))).get();
            expect(runningSessions.length, expectedEachType);
            expect(swimmingSessions.length, expectedEachType);

            final runningEntries = runningSessions.map((session) {
              final distance = 2500 + random.nextInt(17500);
              final durationSeconds = 720 + random.nextInt(5400);
              return RunningEntriesCompanion.insert(
                sessionId: session.id,
                runType: switch (session.id % 5) {
                  0 => 'easy',
                  1 => 'tempo',
                  2 => 'interval',
                  3 => 'lsd',
                  _ => 'recovery',
                },
                distanceMeters: distance.toDouble(),
                durationSeconds: durationSeconds,
                avgPaceSeconds: max(
                  180,
                  (durationSeconds / (distance / 1000)).round(),
                ),
              );
            }).toList();

            final swimmingEntries = swimmingSessions.map((session) {
              final distance = 600 + random.nextInt(4400);
              final durationSeconds = 480 + random.nextInt(4200);
              return SwimmingEntriesCompanion.insert(
                sessionId: session.id,
                environment: 'pool',
                poolLengthMeters: const Value(25),
                primaryStroke: switch (session.id % 4) {
                  0 => 'freestyle',
                  1 => 'breaststroke',
                  2 => 'backstroke',
                  _ => 'butterfly',
                },
                distanceMeters: distance.toDouble(),
                durationSeconds: durationSeconds,
                pacePer100m: max(
                  55,
                  ((durationSeconds / distance) * 100).round(),
                ),
              );
            }).toList();

            await db.batch((batch) {
              batch.insertAll(db.runningEntries, runningEntries);
              batch.insertAll(db.swimmingEntries, swimmingEntries);
            });

            final insertedRunning = await (db.selectOnly(
              db.runningEntries,
            )..addColumns([db.runningEntries.id.count()])).getSingle();
            final insertedSwimming = await (db.selectOnly(
              db.swimmingEntries,
            )..addColumns([db.swimmingEntries.id.count()])).getSingle();
            expect(
              insertedRunning.read(db.runningEntries.id.count()) ?? 0,
              runningSessions.length,
            );
            expect(
              insertedSwimming.read(db.swimmingEntries.id.count()) ?? 0,
              swimmingSessions.length,
            );

            final benchmarkDay = referenceDay.subtract(const Duration(days: 7));
            final weekStart = _startOfWeek(benchmarkDay);
            final year = benchmarkDay.year;
            final month = benchmarkDay.month;

            final repo = StatsRepository(db);

            Future<_StatsQuerySuiteResult> runQuerySuite() async {
              return _StatsQuerySuiteResult(
                uniqueDaysThisWeek: await repo.countUniqueDaysThisWeek(
                  weekStart,
                ),
                weeklyTotalMinutes: await repo.getWeeklyTotalMinutes(weekStart),
                currentStreak: await repo.getCurrentStreak(),
                typeDistribution: await repo.getTypeDistribution(),
                recentSessions: await repo.getRecentSessions(limit: 20),
                weeklyRunningDistance: await repo.getWeeklyRunningDistance(
                  weekStart,
                ),
                monthlyRunningDistance: await repo.getMonthlyRunningDistance(
                  year,
                  month,
                ),
                weeklyRunningTrend: await repo.getWeeklyRunningTrend(),
                runTypeDistribution: await repo.getRunTypeDistribution(),
                paceDistribution: await repo.getPaceDistribution(),
                weeklySwimmingDistance: await repo.getWeeklySwimmingDistance(
                  weekStart,
                ),
                monthlySwimmingDistance: await repo.getMonthlySwimmingDistance(
                  year,
                  month,
                ),
                weeklySwimmingTrend: await repo.getWeeklySwimmingTrend(),
                strokeDistribution: await repo.getStrokeDistribution(),
                recentSwimmingPace: await repo.getRecentSwimmingPace(limit: 20),
              );
            }

            final warmupResult = await runQuerySuite();
            _expectMeaningfulResults(
              warmupResult,
              expectedEachType: expectedEachType,
            );

            final elapsedMs = <int>[];
            _StatsQuerySuiteResult? lastResult;
            for (int i = 0; i < benchmarkRuns; i++) {
              final watch = Stopwatch()..start();
              lastResult = await runQuerySuite();
              watch.stop();
              elapsedMs.add(watch.elapsedMilliseconds);
            }

            expect(lastResult, isA<_StatsQuerySuiteResult>());
            _expectMeaningfulResults(
              lastResult!,
              expectedEachType: expectedEachType,
            );

            elapsedMs.sort();
            final medianMs = elapsedMs[elapsedMs.length ~/ 2];
            final worstMs = elapsedMs.last;

            expect(
              medianMs,
              lessThan(medianBudgetMs),
              reason: '大数据量查询中位耗时回归，median=${medianMs}ms, runs=$elapsedMs',
            );
            expect(
              worstMs,
              lessThan(worstBudgetMs),
              reason: '大数据量查询最慢耗时异常，worst=${worstMs}ms, runs=$elapsedMs',
            );
          },
        );
      },
    );
  });
}

DateTime _startOfWeek(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

void _expectMeaningfulResults(
  _StatsQuerySuiteResult result, {
  required int expectedEachType,
}) {
  expect(result.uniqueDaysThisWeek, greaterThan(0));
  expect(result.weeklyTotalMinutes, greaterThan(0));
  expect(result.currentStreak, greaterThanOrEqualTo(0));
  expect(result.typeDistribution['running'], expectedEachType);
  expect(result.typeDistribution['swimming'], expectedEachType);
  expect(result.typeDistribution['cycling'], expectedEachType);
  expect(result.recentSessions.length, 20);
  expect(result.weeklyRunningDistance, greaterThan(0));
  expect(result.monthlyRunningDistance, greaterThan(0));
  expect(result.weeklyRunningTrend.length, 4);
  expect(
    result.weeklyRunningTrend.fold<double>(
      0,
      (sum, item) => sum + item.distance,
    ),
    greaterThan(0),
  );
  expect(result.weeklySwimmingDistance, greaterThan(0));
  expect(result.monthlySwimmingDistance, greaterThan(0));
  expect(result.weeklySwimmingTrend.length, 4);
  expect(
    result.weeklySwimmingTrend.fold<double>(
      0,
      (sum, item) => sum + item.distance,
    ),
    greaterThan(0),
  );
  expect(_sumValues(result.runTypeDistribution), expectedEachType);
  expect(_sumValues(result.paceDistribution), expectedEachType);
  expect(_sumValues(result.strokeDistribution), expectedEachType);
  expect(result.recentSwimmingPace.length, 20);
}

int _sumValues(Map<String, int> map) {
  return map.values.fold(0, (sum, value) => sum + value);
}

class _StatsQuerySuiteResult {
  _StatsQuerySuiteResult({
    required this.uniqueDaysThisWeek,
    required this.weeklyTotalMinutes,
    required this.currentStreak,
    required this.typeDistribution,
    required this.recentSessions,
    required this.weeklyRunningDistance,
    required this.monthlyRunningDistance,
    required this.weeklyRunningTrend,
    required this.runTypeDistribution,
    required this.paceDistribution,
    required this.weeklySwimmingDistance,
    required this.monthlySwimmingDistance,
    required this.weeklySwimmingTrend,
    required this.strokeDistribution,
    required this.recentSwimmingPace,
  });

  final int uniqueDaysThisWeek;
  final int weeklyTotalMinutes;
  final int currentStreak;
  final Map<String, int> typeDistribution;
  final List<RecentSession> recentSessions;
  final double weeklyRunningDistance;
  final double monthlyRunningDistance;
  final List<WeeklyDistance> weeklyRunningTrend;
  final Map<String, int> runTypeDistribution;
  final Map<String, int> paceDistribution;
  final double weeklySwimmingDistance;
  final double monthlySwimmingDistance;
  final List<WeeklyDistance> weeklySwimmingTrend;
  final Map<String, int> strokeDistribution;
  final List<PaceData> recentSwimmingPace;
}
