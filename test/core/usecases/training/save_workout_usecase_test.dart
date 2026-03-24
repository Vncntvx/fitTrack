import 'dart:io';

import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:fittrack/core/usecases/training/save_workout_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test('save workout rejects specialized types', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-save-workout-type-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final repository = TrainingRepository(db);
      final useCase = SaveWorkoutUseCase(repository);

      final result = await useCase(
        SaveWorkoutParams(
          datetime: DateTime(2026, 3, 1, 10, 0),
          type: 'running',
          durationMinutes: 30,
          intensity: 'moderate',
        ),
      );
      expect(result.$1, SaveWorkoutResult.unsupportedType);
      expect(result.$2, isNull);
      expect(await repository.getAll(), isEmpty);

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });

  test(
    'save workout rejects updates for specialized existing session',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'fittrack-save-workout-update-type-',
      );
      final dbPath = path.join(tempDir.path, 'fittrack.db');

      try {
        final db = AppDatabase.native(path: dbPath);
        final repository = TrainingRepository(db);
        final useCase = SaveWorkoutUseCase(repository);

        final sessionId = await repository.createTraining(
          datetime: DateTime(2026, 3, 2, 9, 0),
          type: 'swimming',
          durationMinutes: 45,
          intensity: 'moderate',
          note: 'origin',
        );

        final result = await useCase(
          SaveWorkoutParams(
            sessionId: sessionId,
            datetime: DateTime(2026, 3, 3, 9, 0),
            type: 'cycling',
            durationMinutes: 50,
            intensity: 'high',
            note: 'updated',
          ),
        );
        expect(result.$1, SaveWorkoutResult.unsupportedType);
        expect(result.$2, isNull);

        final session = await repository.getById(sessionId);
        expect(session, isNotNull);
        expect(session!.type, 'swimming');
        expect(session.note, 'origin');

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );
}
