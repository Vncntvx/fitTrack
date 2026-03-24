import 'dart:io';

import 'package:drift/drift.dart';
import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/stats_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test(
    'stats repository returns zeroed overview metrics on empty database',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'fittrack-stats-repo-empty-',
      );
      final dbPath = path.join(tempDir.path, 'fittrack.db');

      try {
        final db = AppDatabase.native(path: dbPath);
        final repo = StatsRepository(db);
        final now = DateTime.now();
        final weekStart = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));

        expect(await repo.countUniqueDaysThisWeek(weekStart), 0);
        expect(await repo.getWeeklyTotalMinutes(weekStart), 0);
        expect(await repo.getCurrentStreak(), 0);
        expect(await repo.getTypeDistribution(), isEmpty);
        expect(await repo.getRecentSessions(), isEmpty);

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );

  test(
    'stats repository aggregates distinct days and totals from training sessions',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'fittrack-stats-repo-data-',
      );
      final dbPath = path.join(tempDir.path, 'fittrack.db');

      try {
        final db = AppDatabase.native(path: dbPath);
        final repo = StatsRepository(db);
        final now = DateTime.now();
        final weekStart = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));

        await db
            .into(db.trainingSessions)
            .insert(
              TrainingSessionsCompanion.insert(
                datetime: weekStart.add(const Duration(hours: 7)),
                type: 'running',
                durationMinutes: 35,
                intensity: 'moderate',
              ),
            );
        await db
            .into(db.trainingSessions)
            .insert(
              TrainingSessionsCompanion.insert(
                datetime: weekStart.add(const Duration(hours: 18)),
                type: 'strength',
                durationMinutes: 40,
                intensity: 'high',
              ),
            );
        await db
            .into(db.trainingSessions)
            .insert(
              TrainingSessionsCompanion.insert(
                datetime: weekStart.add(const Duration(days: 2, hours: 9)),
                type: 'swimming',
                durationMinutes: 55,
                intensity: 'moderate',
              ),
            );

        expect(await repo.countUniqueDaysThisWeek(weekStart), 2);
        expect(await repo.getWeeklyTotalMinutes(weekStart), 130);
        expect(await repo.getTypeDistribution(), {
          'swimming': 1,
          'strength': 1,
          'running': 1,
        });
        expect((await repo.getRecentSessions()).length, 3);

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );

  test('weekly trends keep exact week bucket semantics and labels', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-stats-repo-weekly-trend-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final repo = StatsRepository(db);

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final currentWeekStart = today.subtract(
        Duration(days: today.weekday - 1),
      );
      final weekStarts = List<DateTime>.generate(
        4,
        (index) => currentWeekStart.subtract(Duration(days: (3 - index) * 7)),
      );

      // 跑步：分别在第1/2/3周插入 1.2km / 0.8km / 2.5km，第4周无数据
      await _insertRunningSession(
        db,
        dateTime: weekStarts[0].add(const Duration(days: 1, hours: 8)),
        distanceMeters: 1200,
      );
      await _insertRunningSession(
        db,
        dateTime: weekStarts[1].add(const Duration(days: 2, hours: 9)),
        distanceMeters: 800,
      );
      await _insertRunningSession(
        db,
        dateTime: weekStarts[2].add(const Duration(days: 3, hours: 6)),
        distanceMeters: 2500,
      );
      // 边界验证：下一个周起点的数据不应计入最近4周
      await _insertRunningSession(
        db,
        dateTime: currentWeekStart.add(const Duration(days: 7, hours: 1)),
        distanceMeters: 9999,
      );

      // 游泳：分别在第1/3/4周插入 500m / 1500m / 1000m，第2周无数据
      await _insertSwimmingSession(
        db,
        dateTime: weekStarts[0].add(const Duration(days: 2, hours: 7)),
        distanceMeters: 500,
      );
      await _insertSwimmingSession(
        db,
        dateTime: weekStarts[2].add(const Duration(days: 4, hours: 10)),
        distanceMeters: 1500,
      );
      await _insertSwimmingSession(
        db,
        dateTime: weekStarts[3].add(const Duration(days: 5, hours: 6)),
        distanceMeters: 1000,
      );

      final runningTrend = await repo.getWeeklyRunningTrend();
      final swimmingTrend = await repo.getWeeklySwimmingTrend();
      final runningExpected = await Future.wait(
        weekStarts.map((weekStart) => repo.getWeeklyRunningDistance(weekStart)),
      );
      final swimmingExpected = await Future.wait(
        weekStarts.map(
          (weekStart) => repo.getWeeklySwimmingDistance(weekStart),
        ),
      );

      expect(runningTrend.map((e) => e.label).toList(), [
        '第1周',
        '第2周',
        '第3周',
        '第4周',
      ]);
      expect(runningTrend[0].distance, closeTo(1.2, 1e-9));
      expect(runningTrend[1].distance, closeTo(0.8, 1e-9));
      expect(runningTrend[2].distance, closeTo(2.5, 1e-9));
      expect(runningTrend[3].distance, closeTo(0.0, 1e-9));

      for (int i = 0; i < runningTrend.length; i++) {
        expect(
          runningTrend[i].distance,
          closeTo(runningExpected[i] / 1000, 1e-9),
        );
      }

      expect(swimmingTrend.map((e) => e.label).toList(), [
        '第1周',
        '第2周',
        '第3周',
        '第4周',
      ]);
      expect(swimmingTrend[0].distance, closeTo(500.0, 1e-9));
      expect(swimmingTrend[1].distance, closeTo(0.0, 1e-9));
      expect(swimmingTrend[2].distance, closeTo(1500.0, 1e-9));
      expect(swimmingTrend[3].distance, closeTo(1000.0, 1e-9));

      for (int i = 0; i < swimmingTrend.length; i++) {
        expect(swimmingTrend[i].distance, closeTo(swimmingExpected[i], 1e-9));
      }

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}

Future<void> _insertRunningSession(
  AppDatabase db, {
  required DateTime dateTime,
  required double distanceMeters,
}) async {
  final sessionId = await db
      .into(db.trainingSessions)
      .insert(
        TrainingSessionsCompanion.insert(
          datetime: dateTime,
          type: 'running',
          durationMinutes: 30,
          intensity: 'moderate',
        ),
      );
  await db
      .into(db.runningEntries)
      .insert(
        RunningEntriesCompanion.insert(
          sessionId: sessionId,
          runType: 'easy',
          distanceMeters: distanceMeters,
          durationSeconds: 1800,
          avgPaceSeconds: 300,
        ),
      );
}

Future<void> _insertSwimmingSession(
  AppDatabase db, {
  required DateTime dateTime,
  required double distanceMeters,
}) async {
  final sessionId = await db
      .into(db.trainingSessions)
      .insert(
        TrainingSessionsCompanion.insert(
          datetime: dateTime,
          type: 'swimming',
          durationMinutes: 30,
          intensity: 'moderate',
        ),
      );
  await db
      .into(db.swimmingEntries)
      .insert(
        SwimmingEntriesCompanion.insert(
          sessionId: sessionId,
          environment: 'pool',
          poolLengthMeters: const Value(25),
          primaryStroke: 'freestyle',
          distanceMeters: distanceMeters,
          durationSeconds: 1800,
          pacePer100m: 120,
        ),
      );
}
