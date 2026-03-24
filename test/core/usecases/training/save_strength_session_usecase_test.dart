import 'dart:io';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/running_repository.dart';
import 'package:fittrack/core/repositories/strength_entry_repository.dart';
import 'package:fittrack/core/repositories/swimming_repository.dart';
import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:fittrack/core/usecases/pr/check_and_record_pr_usecase.dart';
import 'package:fittrack/core/usecases/pr/rebuild_personal_records_usecase.dart';
import 'package:fittrack/core/usecases/training/save_strength_session_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test('save strength session persists entries and rebuilds PRs', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-save-strength-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final strengthRepo = StrengthEntryRepository(db);
      final trainingRepo = TrainingRepository(db, strengthEntries: strengthRepo);
      final exerciseId = await db.into(db.exercises).insert(
        const ExercisesCompanion(
          name: Value('测试深蹲'),
          category: Value('legs'),
          defaultSets: Value(3),
          defaultReps: Value(5),
          defaultWeight: Value(100),
          isCustom: Value(true),
        ),
      );

      final useCase = SaveStrengthSessionUseCase(
        db,
        trainingRepo,
        strengthRepo,
        RebuildPersonalRecordsUseCase(
          db,
          trainingRepo,
          strengthRepo,
          RunningRepository(db),
          SwimmingRepository(db),
        ),
      );

      final startTime = DateTime(2026, 3, 1, 8, 30);
      final sessionId = await useCase(
        SaveStrengthSessionParams(
          startTime: startTime,
          elapsedSeconds: 1800,
          intensity: 'high',
          note: '测试训练',
          exercises: [
            StrengthExerciseInput(
              exerciseId: exerciseId,
              exerciseName: '测试深蹲',
              defaultReps: 5,
              defaultWeight: 100,
              repsPerSet: const [5],
              weightPerSet: const [100],
              completedSets: const [true],
              rpeValues: const [8],
              restSecondsValues: const [120],
            ),
          ],
        ),
      );

      final session = await trainingRepo.getById(sessionId);
      final entries = await strengthRepo.getStrengthExercises(sessionId);
      final prs = await (db.select(db.personalRecords)
            ..orderBy([(p) => OrderingTerm.asc(p.recordType)]))
          .get();

      expect(session, isNotNull);
      expect(session!.type, 'strength');
      expect(session.durationMinutes, 30);
      expect(entries, hasLength(1));
      expect(entries.first.exerciseId, exerciseId);
      expect(entries.first.exerciseName, '测试深蹲');
      expect(prs, hasLength(2));
      expect(prs.map((pr) => pr.recordType), containsAll(<String>[
        PRType.strength1RM.value,
        PRType.strengthVolume.value,
      ]));

      final volumePr = prs.firstWhere(
        (pr) => pr.recordType == PRType.strengthVolume.value,
      );
      final oneRmPr = prs.firstWhere(
        (pr) => pr.recordType == PRType.strength1RM.value,
      );
      expect(volumePr.value, 500);
      expect(volumePr.achievedAt, startTime);
      expect(oneRmPr.value, greaterThan(100));
      expect(oneRmPr.achievedAt, startTime);

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}
