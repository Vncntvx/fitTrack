import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/running_repository.dart';
import 'package:fittrack/core/repositories/strength_entry_repository.dart';
import 'package:fittrack/core/repositories/swimming_repository.dart';
import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:fittrack/core/usecases/pr/check_and_record_pr_usecase.dart';
import 'package:fittrack/core/usecases/pr/rebuild_personal_records_usecase.dart';
import 'package:fittrack/core/usecases/training/save_running_session_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_db_helper.dart';

void main() {
  test('creates running session details and rebuilds PRs', () async {
    await withTestDatabase(
      body: (db) async {
        final deps = _buildDependencies(db);

        final sessionId = await deps.useCase(
          SaveRunningSessionParams(
            startTime: DateTime(2026, 3, 1, 7, 30),
            runType: 'tempo',
            distanceKm: 5.2,
            durationMinutes: 24,
            durationSeconds: 30,
            avgHeartRate: 156,
            maxHeartRate: 178,
            avgCadence: 172,
            elevationGain: 40,
            note: '晨跑',
            splits: const [
              RunningSplitInput(
                splitNumber: 1,
                distanceKm: 1,
                durationSeconds: 280,
                heartRate: 150,
                cadence: 170,
              ),
              RunningSplitInput(
                splitNumber: 2,
                distanceKm: 1,
                durationSeconds: 275,
                heartRate: 158,
                cadence: 174,
              ),
            ],
          ),
        );

        final session = await deps.trainingRepo.getById(sessionId);
        expect(session, isNotNull);
        expect(session!.type, 'running');
        expect(session.durationMinutes, 25);
        expect(session.intensity, 'moderate');
        expect(session.note, '晨跑');

        final runningEntry = await deps.runningRepo.getBySessionId(sessionId);
        expect(runningEntry, isNotNull);
        expect(runningEntry!.runType, 'tempo');
        expect(runningEntry.distanceMeters, 5200);
        expect(runningEntry.durationSeconds, 1470);
        expect(
          runningEntry.avgPaceSeconds,
          RunningRepository.calculatePace(1470, 5200),
        );

        final splits = await deps.runningRepo.getSplits(runningEntry.id);
        expect(splits, hasLength(2));
        expect(splits.first.splitNumber, 1);
        expect(splits.first.paceSeconds, 280);
        expect(splits.last.splitNumber, 2);
        expect(splits.last.paceSeconds, 275);

        final prs =
            await (db.select(db.personalRecords)..where(
                  (p) => p.recordType.isIn([
                    PRType.runningDistance.value,
                    PRType.runningPace.value,
                  ]),
                ))
                .get();
        expect(prs.map((row) => row.recordType).toSet(), {
          PRType.runningDistance.value,
          PRType.runningPace.value,
        });

        final distancePr = prs.firstWhere(
          (row) => row.recordType == PRType.runningDistance.value,
        );
        final pacePr = prs.firstWhere(
          (row) => row.recordType == PRType.runningPace.value,
        );
        expect(distancePr.value, 5200);
        expect(
          pacePr.value,
          RunningRepository.calculatePace(1470, 5200).toDouble(),
        );
      },
    );
  });

  test(
    'updates existing session and replaces old splits at boundaries',
    () async {
      await withTestDatabase(
        body: (db) async {
          final deps = _buildDependencies(db);

          final originalSessionId = await deps.useCase(
            SaveRunningSessionParams(
              startTime: DateTime(2026, 3, 1, 7),
              runType: 'easy',
              distanceKm: 2,
              durationMinutes: 12,
              durationSeconds: 0,
              splits: const [
                RunningSplitInput(
                  splitNumber: 1,
                  distanceKm: 1,
                  durationSeconds: 360,
                ),
                RunningSplitInput(
                  splitNumber: 2,
                  distanceKm: 1,
                  durationSeconds: 360,
                ),
              ],
            ),
          );

          final updatedSessionId = await deps.useCase(
            SaveRunningSessionParams(
              sessionId: originalSessionId,
              startTime: DateTime(2026, 3, 2, 7),
              runType: 'hill',
              distanceKm: 0.8,
              durationMinutes: 10,
              durationSeconds: 29,
              splits: const [
                RunningSplitInput(
                  splitNumber: 1,
                  distanceKm: 0.8,
                  durationSeconds: 509,
                ),
              ],
            ),
          );

          expect(updatedSessionId, originalSessionId);

          final session = await deps.trainingRepo.getById(updatedSessionId);
          expect(session, isNotNull);
          expect(session!.durationMinutes, 10);
          expect(session.intensity, 'moderate');

          final entry = await deps.runningRepo.getBySessionId(updatedSessionId);
          expect(entry, isNotNull);
          expect(entry!.runType, 'hill');
          expect(entry.distanceMeters, 800);

          final splits = await deps.runningRepo.getSplits(entry.id);
          expect(splits, hasLength(1));
          expect(splits.first.durationSeconds, 509);

          final runningDistancePrs =
              await (db.select(db.personalRecords)..where(
                    (p) => p.recordType.equals(PRType.runningDistance.value),
                  ))
                  .get();
          final runningPacePrs = await (db.select(
            db.personalRecords,
          )..where((p) => p.recordType.equals(PRType.runningPace.value))).get();
          expect(runningDistancePrs, hasLength(1));
          expect(runningDistancePrs.first.value, 800);
          expect(runningPacePrs, isEmpty);
        },
      );
    },
  );

  test('rolls back session, entry and splits when PR rebuild fails', () async {
    await withTestDatabase(
      body: (db) async {
        final deps = _buildDependencies(db);

        await db.customStatement('''
CREATE TRIGGER fail_running_pr_insert
BEFORE INSERT ON personal_records
WHEN NEW.record_type = '${PRType.runningDistance.value}'
BEGIN
  SELECT RAISE(ABORT, 'forced running save failure');
END;
''');

        await expectLater(
          deps.useCase(
            SaveRunningSessionParams(
              startTime: DateTime(2026, 3, 1, 7),
              runType: 'tempo',
              distanceKm: 5,
              durationMinutes: 25,
              durationSeconds: 0,
              splits: const [
                RunningSplitInput(
                  splitNumber: 1,
                  distanceKm: 1,
                  durationSeconds: 300,
                ),
              ],
            ),
          ),
          throwsA(anything),
        );

        expect(await db.select(db.trainingSessions).get(), isEmpty);
        expect(await db.select(db.runningEntries).get(), isEmpty);
        expect(await db.select(db.runningSplits).get(), isEmpty);
        expect(await db.select(db.personalRecords).get(), isEmpty);
      },
    );
  });
}

({
  SaveRunningSessionUseCase useCase,
  TrainingRepository trainingRepo,
  RunningRepository runningRepo,
})
_buildDependencies(AppDatabase db) {
  final strengthRepo = StrengthEntryRepository(db);
  final trainingRepo = TrainingRepository(db, strengthEntries: strengthRepo);
  final runningRepo = RunningRepository(db);
  final swimmingRepo = SwimmingRepository(db);
  final prRebuilder = RebuildPersonalRecordsUseCase(
    db,
    trainingRepo,
    strengthRepo,
    runningRepo,
    swimmingRepo,
  );

  return (
    useCase: SaveRunningSessionUseCase(
      db,
      trainingRepo,
      runningRepo,
      prRebuilder,
    ),
    trainingRepo: trainingRepo,
    runningRepo: runningRepo,
  );
}
