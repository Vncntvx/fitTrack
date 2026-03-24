import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:fittrack/core/usecases/training/save_workout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_db_helper.dart';

void main() {
  test('save workout creates supported simple type session', () async {
    await withTestDatabase(body: (db) async {
      final repository = TrainingRepository(db);
      final useCase = SaveWorkoutUseCase(repository);

      final result = await useCase(
        SaveWorkoutParams(
          datetime: DateTime(2026, 3, 10, 7, 30),
          type: 'cycling',
          durationMinutes: 40,
          intensity: 'moderate',
          note: 'morning ride',
          isGoalCompleted: true,
        ),
      );

      expect(result.$1, SaveWorkoutResult.success);
      expect(result.$2, isNotNull);

      final created = await repository.getById(result.$2!);
      expect(created, isNotNull);
      expect(created!.type, 'cycling');
      expect(created.durationMinutes, 40);
      expect(created.note, 'morning ride');
      expect(created.isGoalCompleted, isTrue);
    });
  });

  test('save workout update returns notFound when session does not exist', () async {
    await withTestDatabase(body: (db) async {
      final repository = TrainingRepository(db);
      final useCase = SaveWorkoutUseCase(repository);

      final result = await useCase(
        SaveWorkoutParams(
          sessionId: 999999,
          datetime: DateTime(2026, 3, 10, 7, 30),
          type: 'cycling',
          durationMinutes: 20,
          intensity: 'light',
        ),
      );

      expect(result.$1, SaveWorkoutResult.notFound);
      expect(result.$2, isNull);
    });
  });

  test('save workout updates existing simple session', () async {
    await withTestDatabase(body: (db) async {
      final repository = TrainingRepository(db);
      final useCase = SaveWorkoutUseCase(repository);
      final sessionId = await repository.createTraining(
        datetime: DateTime(2026, 3, 9, 8),
        type: 'walking',
        durationMinutes: 25,
        intensity: 'light',
        note: 'before update',
      );

      final result = await useCase(
        SaveWorkoutParams(
          sessionId: sessionId,
          datetime: DateTime(2026, 3, 9, 9),
          type: 'yoga',
          durationMinutes: 35,
          intensity: 'moderate',
          note: 'after update',
          isGoalCompleted: true,
        ),
      );

      expect(result.$1, SaveWorkoutResult.success);
      expect(result.$2, sessionId);

      final updated = await repository.getById(sessionId);
      expect(updated, isNotNull);
      expect(updated!.type, 'yoga');
      expect(updated.durationMinutes, 35);
      expect(updated.note, 'after update');
      expect(updated.isGoalCompleted, isTrue);
      expect(updated.datetime, DateTime(2026, 3, 9, 9));
    });
  });
}
