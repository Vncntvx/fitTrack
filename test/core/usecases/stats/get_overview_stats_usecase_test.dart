import 'package:fittrack/core/repositories/stats_repository.dart';
import 'package:fittrack/core/usecases/stats/get_overview_stats_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_builder.dart';
import '../../../helpers/test_db_helper.dart';

class _ThrowingOverviewStatsRepository extends StatsRepository {
  _ThrowingOverviewStatsRepository(super.db);

  @override
  Future<int> countUniqueDaysThisWeek(DateTime weekStart) {
    return Future<int>.error(StateError('forced overview stats failure'));
  }
}

void main() {
  test('returns aggregated overview stats from repository queries', () async {
    await withTestDatabase(
      body: (db) async {
        final builder = TestDataBuilder(db);
        final statsRepo = StatsRepository(db);
        final useCase = GetOverviewStatsUseCase(statsRepo);
        final now = DateTime.now();
        final day = DateTime(now.year, now.month, now.day);
        final weekStart = day.subtract(Duration(days: day.weekday - 1));

        await builder.addTrainingSession(
          datetime: day.add(const Duration(hours: 8)),
          type: 'running',
          durationMinutes: 30,
        );
        await builder.addTrainingSession(
          datetime: day
              .subtract(const Duration(days: 1))
              .add(const Duration(hours: 7)),
          type: 'swimming',
          durationMinutes: 40,
        );
        await builder.addTrainingSession(
          datetime: weekStart.add(const Duration(days: 1, hours: 6)),
          type: 'cycling',
          durationMinutes: 25,
        );

        final result = await useCase();

        expect(
          result.weeklyCount,
          await statsRepo.countUniqueDaysThisWeek(weekStart),
        );
        expect(
          result.weeklyMinutes,
          await statsRepo.getWeeklyTotalMinutes(weekStart),
        );
        expect(result.currentStreak, await statsRepo.getCurrentStreak());
        expect(result.typeDistribution, await statsRepo.getTypeDistribution());
        expect(result.recentSessions, hasLength(3));
        expect(
          result.recentSessions.first.datetime.isAfter(
            result.recentSessions.last.datetime,
          ),
          isTrue,
        );
      },
    );
  });

  test('returns boundary defaults on empty database', () async {
    await withTestDatabase(
      body: (db) async {
        final useCase = GetOverviewStatsUseCase(StatsRepository(db));
        final result = await useCase();

        expect(result.weeklyCount, 0);
        expect(result.weeklyMinutes, 0);
        expect(result.currentStreak, 0);
        expect(result.typeDistribution, isEmpty);
        expect(result.recentSessions, isEmpty);
      },
    );
  });

  test('propagates repository failures', () async {
    await withTestDatabase(
      body: (db) async {
        final useCase = GetOverviewStatsUseCase(
          _ThrowingOverviewStatsRepository(db),
        );

        await expectLater(useCase(), throwsA(isA<StateError>()));
      },
    );
  });
}
