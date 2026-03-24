import 'dart:convert';

import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/running_repository.dart';
import 'package:fittrack/core/repositories/strength_entry_repository.dart';
import 'package:fittrack/core/repositories/swimming_repository.dart';
import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:fittrack/core/usecases/pr/check_and_record_pr_usecase.dart';
import 'package:fittrack/core/usecases/pr/rebuild_personal_records_usecase.dart';
import 'package:fittrack/core/usecases/training/save_swimming_session_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_db_helper.dart';

void main() {
  test('creates swimming session details and rebuilds PRs', () async {
    await withTestDatabase(
      body: (db) async {
        final deps = _buildDependencies(db);

        final sessionId = await deps.useCase(
          SaveSwimmingSessionParams(
            startTime: DateTime(2026, 3, 1, 6, 30),
            environment: 'pool',
            poolLengthMeters: 25,
            primaryStroke: 'freestyle',
            distanceMeters: 1600,
            durationMinutes: 32,
            durationSeconds: 10,
            trainingType: 'interval',
            equipment: {'fins', 'snorkel'},
            note: '晨泳',
            sets: const [
              SwimmingSetInput(
                setType: 'warmup',
                distanceMeters: 400,
                durationSeconds: 520,
                description: '热身',
              ),
              SwimmingSetInput(
                setType: 'main',
                distanceMeters: 1200,
                durationSeconds: 1410,
                description: '主训练',
              ),
            ],
          ),
        );

        final session = await deps.trainingRepo.getById(sessionId);
        expect(session, isNotNull);
        expect(session!.type, 'swimming');
        expect(session.durationMinutes, 33);
        expect(session.intensity, 'high');
        expect(session.note, '晨泳');

        final entry = await deps.swimmingRepo.getBySessionId(sessionId);
        expect(entry, isNotNull);
        expect(entry!.environment, 'pool');
        expect(entry.distanceMeters, 1600);
        expect(entry.durationSeconds, 1930);
        expect(
          entry.pacePer100m,
          SwimmingRepository.calculatePacePer100m(1930, 1600),
        );

        final equipment = (jsonDecode(entry.equipment!) as List<dynamic>)
            .map((item) => item as String)
            .toSet();
        expect(equipment, {'fins', 'snorkel'});

        final sets = await deps.swimmingRepo.getSets(entry.id);
        expect(sets, hasLength(2));
        expect(sets.first.setType, 'warmup');
        expect(sets.first.sortOrder, 0);
        expect(sets.last.setType, 'main');
        expect(sets.last.sortOrder, 1);

        final prs =
            await (db.select(db.personalRecords)..where(
                  (p) => p.recordType.isIn([
                    PRType.swimmingDistance.value,
                    PRType.swimmingPace.value,
                  ]),
                ))
                .get();
        expect(prs.map((row) => row.recordType).toSet(), {
          PRType.swimmingDistance.value,
          PRType.swimmingPace.value,
        });

        final distancePr = prs.firstWhere(
          (row) => row.recordType == PRType.swimmingDistance.value,
        );
        final pacePr = prs.firstWhere(
          (row) => row.recordType == PRType.swimmingPace.value,
        );
        expect(distancePr.value, 1600);
        expect(
          pacePr.value,
          SwimmingRepository.calculatePacePer100m(1930, 1600).toDouble(),
        );
      },
    );
  });

  test('handles boundary values on create', () async {
    await withTestDatabase(
      body: (db) async {
        final deps = _buildDependencies(db);

        final sessionId = await deps.useCase(
          SaveSwimmingSessionParams(
            startTime: DateTime(2026, 3, 2, 6),
            environment: 'open_water',
            poolLengthMeters: null,
            primaryStroke: 'mixed',
            distanceMeters: 80,
            durationMinutes: 12,
            durationSeconds: 1,
            trainingType: null,
            equipment: const {},
            sets: const [
              SwimmingSetInput(
                setType: 'main',
                distanceMeters: 80,
                durationSeconds: 721,
              ),
            ],
          ),
        );

        final session = await deps.trainingRepo.getById(sessionId);
        expect(session, isNotNull);
        expect(session!.durationMinutes, 13);
        expect(session.intensity, 'moderate');

        final entry = await deps.swimmingRepo.getBySessionId(sessionId);
        expect(entry, isNotNull);
        expect(entry!.environment, 'open_water');
        expect(entry.poolLengthMeters, isNull);
        expect(entry.distanceMeters, 80);
        expect(entry.equipment, isNull);

        final sets = await deps.swimmingRepo.getSets(entry.id);
        expect(sets, hasLength(1));
        expect(sets.first.distanceMeters, 80);

        final distancePrs =
            await (db.select(db.personalRecords)..where(
                  (p) => p.recordType.equals(PRType.swimmingDistance.value),
                ))
                .get();
        final pacePrs = await (db.select(
          db.personalRecords,
        )..where((p) => p.recordType.equals(PRType.swimmingPace.value))).get();

        expect(distancePrs, hasLength(1));
        expect(distancePrs.first.value, 80);
        expect(pacePrs, isEmpty);
      },
    );
  });

  test('rolls back session, entry and sets when PR rebuild fails', () async {
    await withTestDatabase(
      body: (db) async {
        final deps = _buildDependencies(db);

        await db.customStatement('''
CREATE TRIGGER fail_swimming_pr_insert
BEFORE INSERT ON personal_records
WHEN NEW.record_type = '${PRType.swimmingDistance.value}'
BEGIN
  SELECT RAISE(ABORT, 'forced swimming save failure');
END;
''');

        await expectLater(
          deps.useCase(
            SaveSwimmingSessionParams(
              startTime: DateTime(2026, 3, 1, 6),
              environment: 'pool',
              poolLengthMeters: 25,
              primaryStroke: 'freestyle',
              distanceMeters: 1000,
              durationMinutes: 20,
              durationSeconds: 0,
              equipment: {'fins'},
              sets: const [
                SwimmingSetInput(
                  setType: 'main',
                  distanceMeters: 1000,
                  durationSeconds: 1200,
                ),
              ],
            ),
          ),
          throwsA(anything),
        );

        expect(await db.select(db.trainingSessions).get(), isEmpty);
        expect(await db.select(db.swimmingEntries).get(), isEmpty);
        expect(await db.select(db.swimmingSets).get(), isEmpty);
        expect(await db.select(db.personalRecords).get(), isEmpty);
      },
    );
  });
}

({
  SaveSwimmingSessionUseCase useCase,
  TrainingRepository trainingRepo,
  SwimmingRepository swimmingRepo,
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
    useCase: SaveSwimmingSessionUseCase(
      db,
      trainingRepo,
      swimmingRepo,
      prRebuilder,
    ),
    trainingRepo: trainingRepo,
    swimmingRepo: swimmingRepo,
  );
}
