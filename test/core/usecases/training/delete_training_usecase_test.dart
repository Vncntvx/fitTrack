import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/running_repository.dart';
import 'package:fittrack/core/repositories/strength_entry_repository.dart';
import 'package:fittrack/core/repositories/swimming_repository.dart';
import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:fittrack/core/usecases/pr/rebuild_personal_records_usecase.dart';
import 'package:fittrack/core/usecases/training/delete_training_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test(
    'delete training removes personal record references before session delete',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'fittrack-delete-training-',
      );
      final dbPath = path.join(tempDir.path, 'fittrack.db');

      try {
        final db = AppDatabase.native(path: dbPath);
        final strengthRepo = StrengthEntryRepository(db);
        final trainingRepo = TrainingRepository(
          db,
          strengthEntries: strengthRepo,
        );
        final runningRepo = RunningRepository(db);
        final swimmingRepo = SwimmingRepository(db);
        final prRebuilder = RebuildPersonalRecordsUseCase(
          db,
          trainingRepo,
          strengthRepo,
          runningRepo,
          swimmingRepo,
        );
        final useCase = DeleteTrainingUseCase(trainingRepo, db, prRebuilder);

        final sessionId = await trainingRepo.createTraining(
          datetime: DateTime(2026, 3, 20, 7, 30),
          type: 'running',
          durationMinutes: 40,
          intensity: 'moderate',
        );

        await db
            .into(db.personalRecords)
            .insert(
              PersonalRecordsCompanion(
                recordType: const Value('running_distance'),
                value: const Value(5000),
                unit: const Value('meters'),
                achievedAt: Value(DateTime(2026, 3, 20, 7, 30)),
                sessionId: Value(sessionId),
              ),
            );

        final result = await useCase(sessionId);
        expect(result, DeleteTrainingResult.success);

        final deletedSession = await trainingRepo.getById(sessionId);
        expect(deletedSession, isNull);

        final leftPrRows = await (db.select(
          db.personalRecords,
        )..where((p) => p.sessionId.equals(sessionId))).get();
        expect(leftPrRows, isEmpty);

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );

  test('delete training returns notFound for missing session', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-delete-training-not-found-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final strengthRepo = StrengthEntryRepository(db);
      final trainingRepo = TrainingRepository(
        db,
        strengthEntries: strengthRepo,
      );
      final runningRepo = RunningRepository(db);
      final swimmingRepo = SwimmingRepository(db);
      final prRebuilder = RebuildPersonalRecordsUseCase(
        db,
        trainingRepo,
        strengthRepo,
        runningRepo,
        swimmingRepo,
      );
      final useCase = DeleteTrainingUseCase(trainingRepo, db, prRebuilder);

      final result = await useCase(999999);

      expect(result, DeleteTrainingResult.notFound);
      expect(await trainingRepo.getAll(), isEmpty);

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}
