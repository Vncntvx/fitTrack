import 'package:fittrack/core/repositories/stats_repository.dart';
import 'package:fittrack/core/usecases/stats/get_swimming_stats_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_builder.dart';
import '../../../helpers/test_db_helper.dart';

class _ThrowingSwimmingStatsRepository extends StatsRepository {
  _ThrowingSwimmingStatsRepository(super.db);

  @override
  Future<double> getWeeklySwimmingDistance(DateTime weekStart) {
    return Future<double>.error(StateError('forced swimming stats failure'));
  }
}

void main() {
  test(
    'returns aggregated swimming stats for current week and month',
    () async {
      await withTestDatabase(
        body: (db) async {
          final builder = TestDataBuilder(db);
          final now = DateTime.now();
          final anchor = DateTime(now.year, now.month, now.day, 12);

          await builder.addSwimmingSession(
            datetime: anchor.subtract(const Duration(hours: 1)),
            primaryStroke: 'freestyle',
            distanceMeters: 1200,
            durationSeconds: 1320,
            pacePer100m: 110,
          );
          await builder.addSwimmingSession(
            datetime: anchor.subtract(const Duration(hours: 2)),
            primaryStroke: 'breaststroke',
            distanceMeters: 800,
            durationSeconds: 1120,
            pacePer100m: 140,
          );

          final useCase = GetSwimmingStatsUseCase(StatsRepository(db));
          final result = await useCase();

          expect(result.weeklyDistance, closeTo(2000, 1e-6));
          expect(result.monthlyDistance, closeTo(2000, 1e-6));
          expect(result.weeklyTrend, hasLength(4));
          expect(result.weeklyTrend.last.distance, closeTo(2000, 1e-6));
          expect(result.strokeDistribution, {
            'freestyle': 1,
            'breaststroke': 1,
          });
          expect(result.recentPaceData, hasLength(2));
          expect(result.recentPaceData.first.label, '#1');
          expect(result.recentPaceData.first.paceSeconds, 110);
        },
      );
    },
  );

  test('returns boundary defaults on empty database', () async {
    await withTestDatabase(
      body: (db) async {
        final useCase = GetSwimmingStatsUseCase(StatsRepository(db));
        final result = await useCase();

        expect(result.weeklyDistance, 0);
        expect(result.monthlyDistance, 0);
        expect(result.weeklyTrend, hasLength(4));
        expect(result.weeklyTrend.every((item) => item.distance == 0), isTrue);
        expect(result.strokeDistribution, isEmpty);
        expect(result.recentPaceData, isEmpty);
      },
    );
  });

  test('propagates repository failures', () async {
    await withTestDatabase(
      body: (db) async {
        final useCase = GetSwimmingStatsUseCase(
          _ThrowingSwimmingStatsRepository(db),
        );

        await expectLater(useCase(), throwsA(isA<StateError>()));
      },
    );
  });
}
