import 'package:fittrack/core/usecases/today/get_today_dashboard_usecase.dart';
import 'package:fittrack/core/repositories/settings_repository.dart';
import 'package:fittrack/core/repositories/stats_repository.dart';
import 'package:fittrack/core/database/database.dart';
import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_data_builder.dart';
import '../../../helpers/test_db_helper.dart';

void main() {
  test('today dashboard excludes next day session at boundary', () async {
    await withTestDatabase(
      body: (db) async {
        final builder = TestDataBuilder(db);

        final settings = builder.db.userSettings;
        await builder.db
            .into(settings)
            .insert(
              const UserSettingsCompanion(
                weeklyWorkoutDaysGoal: Value(4),
                weeklyWorkoutMinutesGoal: Value(200),
              ),
            );

        final day = DateTime(2026, 3, 5);
        await builder.addTrainingSession(
          datetime: DateTime(day.year, day.month, day.day, 23, 59, 59),
          type: 'running',
          durationMinutes: 30,
        );
        await builder.addTrainingSession(
          datetime: DateTime(day.year, day.month, day.day + 1, 0, 0),
          type: 'cycling',
          durationMinutes: 25,
        );

        final useCase = GetTodayDashboardUseCase(
          builder.trainingRepo,
          StatsRepository(builder.db),
          SettingsRepository(builder.db),
        );

        final result = await useCase(
          GetTodayDashboardParams(referenceDate: day, recentLimit: 5),
        );

        expect(result.hasSessionToday, isTrue);
        expect(result.daysCount, 2);
        expect(result.minutesCount, 55);
        expect(result.minutesGoal, 200);
        expect(result.daysGoal, 4);
        expect(result.recentSessions, hasLength(2));
        expect(result.recentSessions.first.type, 'cycling');
        expect(result.recentSessions.first.durationMinutes, 25);
        expect(result.recentSessions.last.type, 'running');
        expect(result.recentSessions.last.durationMinutes, 30);
      },
    );
  });

  test(
    'today dashboard returns hasSessionToday false when no session today',
    () async {
      await withTestDatabase(
        body: (db) async {
          final builder = TestDataBuilder(db);
          await builder.addTrainingSession(
            datetime: DateTime(2026, 3, 1, 8),
            type: 'cycling',
          );

          final useCase = GetTodayDashboardUseCase(
            builder.trainingRepo,
            StatsRepository(builder.db),
            SettingsRepository(builder.db),
          );
          final result = await useCase(
            GetTodayDashboardParams(referenceDate: DateTime(2026, 3, 2)),
          );

          expect(result.hasSessionToday, isFalse);
          expect(result.recentSessions, isNotEmpty);
        },
      );
    },
  );
}
