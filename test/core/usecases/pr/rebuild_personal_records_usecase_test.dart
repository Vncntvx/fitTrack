import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/running_repository.dart';
import 'package:fittrack/core/repositories/strength_entry_repository.dart';
import 'package:fittrack/core/repositories/swimming_repository.dart';
import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:fittrack/core/usecases/pr/check_and_record_pr_usecase.dart';
import 'package:fittrack/core/usecases/pr/rebuild_personal_records_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_db_helper.dart';

void main() {
  test('rebuilds all PR types and removes stale personal records', () async {
    await withTestDatabase(
      body: (db) async {
        final deps = _buildDependencies(db);

        final strengthSessionId = await deps.trainingRepo.createTraining(
          datetime: DateTime(2026, 3, 1, 8),
          type: 'strength',
          durationMinutes: 40,
          intensity: 'high',
        );
        await deps.strengthRepo.addStrengthExercise(
          sessionId: strengthSessionId,
          exerciseName: '深蹲',
          sets: 2,
          defaultReps: 5,
          defaultWeight: 100,
          repsPerSet: jsonEncode([5, 3]),
          weightPerSet: jsonEncode([100.0, 110.0]),
          setCompleted: jsonEncode([true, true]),
        );

        final runningSessionId = await deps.trainingRepo.createTraining(
          datetime: DateTime(2026, 3, 2, 7),
          type: 'running',
          durationMinutes: 30,
          intensity: 'moderate',
        );
        await deps.runningRepo.createRunningEntry(
          sessionId: runningSessionId,
          runType: 'tempo',
          distanceMeters: 3000,
          durationSeconds: 900,
          avgPaceSeconds: 300,
        );

        final swimmingSessionId = await deps.trainingRepo.createTraining(
          datetime: DateTime(2026, 3, 3, 6),
          type: 'swimming',
          durationMinutes: 35,
          intensity: 'moderate',
        );
        await deps.swimmingRepo.createSwimmingEntry(
          sessionId: swimmingSessionId,
          environment: 'pool',
          poolLengthMeters: 25,
          primaryStroke: 'freestyle',
          distanceMeters: 400,
          durationSeconds: 480,
          pacePer100m: 120,
        );

        await db
            .into(db.personalRecords)
            .insert(
              PersonalRecordsCompanion(
                recordType: Value(PRType.runningDistance.value),
                value: const Value(9999),
                unit: const Value('meters'),
                achievedAt: Value(DateTime(2020, 1, 1)),
                sessionId: Value(runningSessionId),
              ),
            );

        await deps.useCase();

        final prs = await db.select(db.personalRecords).get();
        expect(prs.any((row) => row.value == 9999), isFalse);
        expect(
          prs.map((row) => row.recordType).toSet(),
          containsAll(<String>{
            PRType.strength1RM.value,
            PRType.strengthVolume.value,
            PRType.runningDistance.value,
            PRType.runningPace.value,
            PRType.swimmingDistance.value,
            PRType.swimmingPace.value,
          }),
        );

        final volumePr = prs.firstWhere(
          (row) => row.recordType == PRType.strengthVolume.value,
        );
        expect(volumePr.value, 830);

        final runningDistancePr = prs.firstWhere(
          (row) => row.recordType == PRType.runningDistance.value,
        );
        expect(runningDistancePr.value, 3000);

        final swimmingDistancePr = prs.firstWhere(
          (row) => row.recordType == PRType.swimmingDistance.value,
        );
        expect(swimmingDistancePr.value, 400);
      },
    );
  });

  test('ignores unsupported training type in targeted rebuild', () async {
    await withTestDatabase(
      body: (db) async {
        final deps = _buildDependencies(db);
        final sessionId = await deps.trainingRepo.createTraining(
          datetime: DateTime(2026, 3, 1, 8),
          type: 'running',
          durationMinutes: 30,
          intensity: 'moderate',
        );

        await db
            .into(db.personalRecords)
            .insert(
              PersonalRecordsCompanion(
                recordType: Value(PRType.runningDistance.value),
                value: const Value(5000),
                unit: const Value('meters'),
                achievedAt: Value(DateTime(2026, 3, 1, 8)),
                sessionId: Value(sessionId),
              ),
            );

        await deps.useCase.rebuildForTrainingType('cycling');

        final prs = await db.select(db.personalRecords).get();
        expect(prs, hasLength(1));
        expect(prs.first.recordType, PRType.runningDistance.value);
        expect(prs.first.value, 5000);
      },
    );
  });

  test('rolls back clear-and-rebuild when rebuild fails midway', () async {
    await withTestDatabase(
      body: (db) async {
        final deps = _buildDependencies(db);

        final existingSessionId = await deps.trainingRepo.createTraining(
          datetime: DateTime(2026, 3, 1, 8),
          type: 'running',
          durationMinutes: 30,
          intensity: 'moderate',
        );
        await db
            .into(db.personalRecords)
            .insert(
              PersonalRecordsCompanion(
                recordType: Value(PRType.runningDistance.value),
                value: const Value(7777),
                unit: const Value('meters'),
                achievedAt: Value(DateTime(2026, 3, 1, 8)),
                sessionId: Value(existingSessionId),
              ),
            );

        final strengthSessionId = await deps.trainingRepo.createTraining(
          datetime: DateTime(2026, 3, 2, 8),
          type: 'strength',
          durationMinutes: 40,
          intensity: 'high',
        );
        await deps.strengthRepo.addStrengthExercise(
          sessionId: strengthSessionId,
          exerciseName: '深蹲',
          sets: 1,
          defaultReps: 5,
          defaultWeight: 100,
          repsPerSet: jsonEncode([5]),
          weightPerSet: jsonEncode([100.0]),
          setCompleted: jsonEncode([true]),
        );

        final runningSessionId = await deps.trainingRepo.createTraining(
          datetime: DateTime(2026, 3, 3, 7),
          type: 'running',
          durationMinutes: 25,
          intensity: 'moderate',
        );
        await deps.runningRepo.createRunningEntry(
          sessionId: runningSessionId,
          runType: 'tempo',
          distanceMeters: 2000,
          durationSeconds: 600,
          avgPaceSeconds: 300,
        );

        await db.customStatement('''
CREATE TRIGGER fail_running_pace_rebuild
BEFORE INSERT ON personal_records
WHEN NEW.record_type = '${PRType.runningPace.value}'
BEGIN
  SELECT RAISE(ABORT, 'forced rebuild failure');
END;
''');

        await expectLater(deps.useCase(), throwsA(anything));

        final prs = await db.select(db.personalRecords).get();
        expect(prs, hasLength(1));
        expect(prs.first.recordType, PRType.runningDistance.value);
        expect(prs.first.value, 7777);
      },
    );
  });
}

({
  RebuildPersonalRecordsUseCase useCase,
  TrainingRepository trainingRepo,
  StrengthEntryRepository strengthRepo,
  RunningRepository runningRepo,
  SwimmingRepository swimmingRepo,
})
_buildDependencies(AppDatabase db) {
  final strengthRepo = StrengthEntryRepository(db);
  final trainingRepo = TrainingRepository(db, strengthEntries: strengthRepo);
  final runningRepo = RunningRepository(db);
  final swimmingRepo = SwimmingRepository(db);
  final useCase = RebuildPersonalRecordsUseCase(
    db,
    trainingRepo,
    strengthRepo,
    runningRepo,
    swimmingRepo,
  );

  return (
    useCase: useCase,
    trainingRepo: trainingRepo,
    strengthRepo: strengthRepo,
    runningRepo: runningRepo,
    swimmingRepo: swimmingRepo,
  );
}
