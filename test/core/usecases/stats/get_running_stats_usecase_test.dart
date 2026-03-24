import 'package:fittrack/core/repositories/stats_repository.dart';
import 'package:fittrack/core/usecases/stats/get_running_stats_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_builder.dart';
import '../../../helpers/test_db_helper.dart';

class _ThrowingRunningStatsRepository extends StatsRepository {
  _ThrowingRunningStatsRepository(super.db);

  @override
  Future<double> getWeeklyRunningDistance(DateTime weekStart) {
    return Future<double>.error(StateError('forced running stats failure'));
  }
}

void main() {
  test('returns aggregated running stats for current week and month', () async {
    await withTestDatabase(
      body: (db) async {
        final builder = TestDataBuilder(db);
        final now = DateTime.now();
        final anchor = DateTime(now.year, now.month, now.day, 12);

        await builder.addRunningSession(
          datetime: anchor.subtract(const Duration(hours: 1)),
          runType: 'easy',
          distanceMeters: 5000,
          durationSeconds: 1500,
          avgPaceSeconds: 300,
        );
        await builder.addRunningSession(
          datetime: anchor.subtract(const Duration(hours: 2)),
          runType: 'tempo',
          distanceMeters: 3000,
          durationSeconds: 1260,
          avgPaceSeconds: 420,
        );

        final useCase = GetRunningStatsUseCase(StatsRepository(db));
        final result = await useCase();

        expect(result.weeklyDistance, closeTo(8000, 1e-6));
        expect(result.monthlyDistance, closeTo(8000, 1e-6));
        expect(result.weeklyTrend, hasLength(4));
        expect(result.weeklyTrend.last.distance, closeTo(8, 1e-6));
        expect(result.runTypeDistribution, {'easy': 1, 'tempo': 1});
        expect(result.paceDistribution['5:00-6:00'], 1);
        expect(result.paceDistribution['7:00-8:00'], 1);
      },
    );
  });

  test('returns boundary defaults on empty database', () async {
    await withTestDatabase(
      body: (db) async {
        final useCase = GetRunningStatsUseCase(StatsRepository(db));
        final result = await useCase();

        expect(result.weeklyDistance, 0);
        expect(result.monthlyDistance, 0);
        expect(result.weeklyTrend, hasLength(4));
        expect(result.weeklyTrend.every((item) => item.distance == 0), isTrue);
        expect(result.runTypeDistribution, isEmpty);
        expect(result.paceDistribution, {
          '< 5:00': 0,
          '5:00-6:00': 0,
          '6:00-7:00': 0,
          '7:00-8:00': 0,
          '> 8:00': 0,
        });
      },
    );
  });

  test('propagates repository failures', () async {
    await withTestDatabase(
      body: (db) async {
        final useCase = GetRunningStatsUseCase(
          _ThrowingRunningStatsRepository(db),
        );

        await expectLater(useCase(), throwsA(isA<StateError>()));
      },
    );
  });
}
