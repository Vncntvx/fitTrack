import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/exercise_repository.dart';
import 'package:fittrack/core/usecases/exercise/delete_exercise_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test(
    'delete exercise returns hasPrReferences when only personal records reference it',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'fittrack-delete-exercise-pr-',
      );
      final dbPath = path.join(tempDir.path, 'fittrack.db');

      try {
        final db = AppDatabase.native(path: dbPath);
        final repository = ExerciseRepository(db);
        final useCase = DeleteExerciseUseCase(repository);

        final exerciseId = await repository.createExercise(
          name: '测试推举',
          category: 'shoulders',
        );
        final sessionId = await db
            .into(db.trainingSessions)
            .insert(
              TrainingSessionsCompanion.insert(
                datetime: DateTime(2026, 3, 10, 8, 0),
                type: 'strength',
                durationMinutes: 35,
                intensity: 'moderate',
              ),
            );
        await db
            .into(db.personalRecords)
            .insert(
              PersonalRecordsCompanion(
                recordType: const Value('strength_1rm'),
                exerciseId: Value(exerciseId),
                value: const Value(60),
                unit: const Value('kg'),
                achievedAt: Value(DateTime(2026, 3, 10, 8, 0)),
                sessionId: Value(sessionId),
              ),
            );

        final result = await useCase(exerciseId);
        expect(result, DeleteExerciseResult.hasPrReferences);

        final exercise = await repository.getById(exerciseId);
        expect(exercise, isNotNull);

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );

  test('delete exercise returns notFound for missing exercise', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-delete-exercise-not-found-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final repository = ExerciseRepository(db);
      final useCase = DeleteExerciseUseCase(repository);

      final result = await useCase(999999);

      expect(result, DeleteExerciseResult.notFound);
      expect(await repository.getById(999999), isNull);

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}
