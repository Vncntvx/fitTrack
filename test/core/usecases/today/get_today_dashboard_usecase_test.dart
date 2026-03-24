import 'package:fittrack/core/repositories/settings_repository.dart';
import 'package:fittrack/core/repositories/stats_repository.dart';
import 'package:fittrack/core/usecases/today/get_today_dashboard_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_builder.dart';
import '../../../helpers/test_db_helper.dart';

void main() {
  test(
    'today dashboard use case aggregates today status, goals and recent sessions',
    () async {
      await withTestDatabase(
        body: (db) async {
          final builder = TestDataBuilder(db);
          final settingsRepo = SettingsRepository(db);
          final useCase = GetTodayDashboardUseCase(
            builder.trainingRepo,
            StatsRepository(db),
            settingsRepo,
          );
          final referenceDate = DateTime(2026, 3, 5);
          final threeDaysAgo = referenceDate.subtract(const Duration(days: 3));

          await settingsRepo.updateWeeklyDaysGoal(4);
          await settingsRepo.updateWeeklyMinutesGoal(200);

          await builder.addTrainingSession(
            datetime: DateTime(
              referenceDate.year,
              referenceDate.month,
              referenceDate.day,
              8,
            ),
            type: 'running',
            durationMinutes: 35,
            intensity: 'moderate',
          );
          await builder.addTrainingSession(
            datetime: DateTime(
              threeDaysAgo.year,
              threeDaysAgo.month,
              threeDaysAgo.day,
              7,
            ),
            type: 'strength',
            durationMinutes: 50,
            intensity: 'high',
          );

          final result = await useCase(
            GetTodayDashboardParams(
              referenceDate: referenceDate,
              recentLimit: 3,
            ),
          );

          expect(result.hasSessionToday, isTrue);
          expect(result.daysGoal, 4);
          expect(result.minutesGoal, 200);
          expect(result.daysCount, 2);
          expect(result.minutesCount, 85);
          expect(result.recentSessions, hasLength(2));
          expect(result.recentSessions.first.type, 'running');
          expect(result.recentSessions.first.durationMinutes, 35);
        },
      );
    },
  );
}
