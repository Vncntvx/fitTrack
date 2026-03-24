import 'package:drift/drift.dart' show Value;
import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/usecases/pr/check_and_record_pr_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_db_helper.dart';

void main() {
  group('CheckStrengthPrUseCase', () {
    test('records new 1RM PR successfully', () async {
      await withTestDatabase(
        body: (db) async {
          final useCase = CheckStrengthPrUseCase(db);
          final sessionId = await _createSession(db, type: 'strength');

          final result = await useCase(
            CheckStrengthPrParams(
              exerciseName: '深蹲',
              weight: 100,
              reps: 5,
              sessionId: sessionId,
              prType: PRType.strength1RM,
            ),
          );

          expect(result.isNewPR, isTrue);
          expect(result.previousValue, isNull);
          expect(result.newValue, greaterThan(100));

          final rows = await _getPrsByType(db, PRType.strength1RM.value);
          expect(rows, hasLength(1));
          expect(rows.first.unit, 'kg');
          expect(rows.first.sessionId, sessionId);
        },
      );
    });

    test('does not record PR when calculated value is non-positive', () async {
      await withTestDatabase(
        body: (db) async {
          final useCase = CheckStrengthPrUseCase(db);
          final sessionId = await _createSession(db, type: 'strength');

          await db
              .into(db.personalRecords)
              .insert(
                PersonalRecordsCompanion(
                  recordType: Value(PRType.strength1RM.value),
                  value: const Value(120),
                  unit: const Value('kg'),
                  achievedAt: Value(DateTime(2026, 1, 1)),
                  sessionId: Value(sessionId),
                ),
              );

          final result = await useCase(
            CheckStrengthPrParams(
              exerciseName: '深蹲',
              weight: 0,
              reps: 5,
              sessionId: sessionId,
              prType: PRType.strength1RM,
            ),
          );

          expect(result.isNewPR, isFalse);
          expect(result.previousValue, 120);
          expect(result.newValue, 120);

          final rows = await _getPrsByType(db, PRType.strength1RM.value);
          expect(rows, hasLength(1));
          expect(rows.first.value, 120);
        },
      );
    });

    test('rolls back transaction when insert fails', () async {
      await withTestDatabase(
        body: (db) async {
          final useCase = CheckStrengthPrUseCase(db);
          final sessionId = await _createSession(db, type: 'strength');

          await db
              .into(db.personalRecords)
              .insert(
                PersonalRecordsCompanion(
                  recordType: Value(PRType.strength1RM.value),
                  value: const Value(130),
                  unit: const Value('kg'),
                  achievedAt: Value(DateTime(2026, 1, 2)),
                  sessionId: Value(sessionId),
                ),
              );

          await db.customStatement('''
CREATE TRIGGER fail_strength_pr_insert
BEFORE INSERT ON personal_records
WHEN NEW.record_type = '${PRType.strength1RM.value}'
BEGIN
  SELECT RAISE(ABORT, 'forced strength failure');
END;
''');

          await expectLater(
            useCase(
              CheckStrengthPrParams(
                exerciseName: '深蹲',
                weight: 150,
                reps: 1,
                sessionId: sessionId,
                prType: PRType.strength1RM,
              ),
            ),
            throwsA(anything),
          );

          final rows = await _getPrsByType(db, PRType.strength1RM.value);
          expect(rows, hasLength(1));
          expect(rows.first.value, 130);
        },
      );
    });
  });

  group('CheckRunningPrUseCase', () {
    test('records distance and pace PRs successfully', () async {
      await withTestDatabase(
        body: (db) async {
          final useCase = CheckRunningPrUseCase(db);
          final sessionId = await _createSession(db, type: 'running');

          final hasNewPr = await useCase(
            CheckRunningPrParams(
              distanceMeters: 2000,
              durationSeconds: 600,
              sessionId: sessionId,
              runType: 'tempo',
            ),
          );

          expect(hasNewPr, isTrue);

          final distanceRows = await _getPrsByType(
            db,
            PRType.runningDistance.value,
          );
          final paceRows = await _getPrsByType(db, PRType.runningPace.value);

          expect(distanceRows, hasLength(1));
          expect(distanceRows.first.value, 2000);
          expect(distanceRows.first.unit, 'meters');

          expect(paceRows, hasLength(1));
          expect(paceRows.first.value, 300);
          expect(paceRows.first.unit, 'seconds');
        },
      );
    });

    test('respects pace threshold boundaries', () async {
      await withTestDatabase(
        body: (db) async {
          final useCase = CheckRunningPrUseCase(db);
          final sessionId = await _createSession(db, type: 'running');

          final firstResult = await useCase(
            CheckRunningPrParams(
              distanceMeters: 900,
              durationSeconds: 300,
              sessionId: sessionId,
              runType: 'easy',
            ),
          );
          expect(firstResult, isTrue);

          final secondResult = await useCase(
            CheckRunningPrParams(
              distanceMeters: 0,
              durationSeconds: 300,
              sessionId: sessionId,
              runType: 'easy',
            ),
          );
          expect(secondResult, isFalse);

          final distanceRows = await _getPrsByType(
            db,
            PRType.runningDistance.value,
          );
          final paceRows = await _getPrsByType(db, PRType.runningPace.value);

          expect(distanceRows, hasLength(1));
          expect(distanceRows.first.value, 900);
          expect(paceRows, isEmpty);
        },
      );
    });

    test('rolls back both inserts when pace insert fails', () async {
      await withTestDatabase(
        body: (db) async {
          final useCase = CheckRunningPrUseCase(db);
          final sessionId = await _createSession(db, type: 'running');

          await db.customStatement('''
CREATE TRIGGER fail_running_pace_insert
BEFORE INSERT ON personal_records
WHEN NEW.record_type = '${PRType.runningPace.value}'
BEGIN
  SELECT RAISE(ABORT, 'forced running pace failure');
END;
''');

          await expectLater(
            useCase(
              CheckRunningPrParams(
                distanceMeters: 2500,
                durationSeconds: 900,
                sessionId: sessionId,
                runType: 'tempo',
              ),
            ),
            throwsA(anything),
          );

          final distanceRows = await _getPrsByType(
            db,
            PRType.runningDistance.value,
          );
          final paceRows = await _getPrsByType(db, PRType.runningPace.value);

          expect(distanceRows, isEmpty);
          expect(paceRows, isEmpty);
        },
      );
    });
  });

  group('CheckSwimmingPrUseCase', () {
    test('records distance and pace PRs successfully', () async {
      await withTestDatabase(
        body: (db) async {
          final useCase = CheckSwimmingPrUseCase(db);
          final sessionId = await _createSession(db, type: 'swimming');

          final hasNewPr = await useCase(
            CheckSwimmingPrParams(
              distanceMeters: 400,
              pacePer100m: 115,
              sessionId: sessionId,
              stroke: 'freestyle',
            ),
          );

          expect(hasNewPr, isTrue);

          final distanceRows = await _getPrsByType(
            db,
            PRType.swimmingDistance.value,
          );
          final paceRows = await _getPrsByType(db, PRType.swimmingPace.value);

          expect(distanceRows, hasLength(1));
          expect(distanceRows.first.value, 400);
          expect(distanceRows.first.unit, 'meters');

          expect(paceRows, hasLength(1));
          expect(paceRows.first.value, 115);
          expect(paceRows.first.unit, 'seconds');
        },
      );
    });

    test('respects swimming pace threshold boundaries', () async {
      await withTestDatabase(
        body: (db) async {
          final useCase = CheckSwimmingPrUseCase(db);
          final sessionId = await _createSession(db, type: 'swimming');

          final firstResult = await useCase(
            CheckSwimmingPrParams(
              distanceMeters: 80,
              pacePer100m: 120,
              sessionId: sessionId,
              stroke: 'freestyle',
            ),
          );
          expect(firstResult, isTrue);

          final secondResult = await useCase(
            CheckSwimmingPrParams(
              distanceMeters: 0,
              pacePer100m: 110,
              sessionId: sessionId,
              stroke: 'freestyle',
            ),
          );
          expect(secondResult, isFalse);

          final distanceRows = await _getPrsByType(
            db,
            PRType.swimmingDistance.value,
          );
          final paceRows = await _getPrsByType(db, PRType.swimmingPace.value);

          expect(distanceRows, hasLength(1));
          expect(distanceRows.first.value, 80);
          expect(paceRows, isEmpty);
        },
      );
    });

    test('rolls back both inserts when pace insert fails', () async {
      await withTestDatabase(
        body: (db) async {
          final useCase = CheckSwimmingPrUseCase(db);
          final sessionId = await _createSession(db, type: 'swimming');

          await db.customStatement('''
CREATE TRIGGER fail_swimming_pace_insert
BEFORE INSERT ON personal_records
WHEN NEW.record_type = '${PRType.swimmingPace.value}'
BEGIN
  SELECT RAISE(ABORT, 'forced swimming pace failure');
END;
''');

          await expectLater(
            useCase(
              CheckSwimmingPrParams(
                distanceMeters: 300,
                pacePer100m: 110,
                sessionId: sessionId,
                stroke: 'freestyle',
              ),
            ),
            throwsA(anything),
          );

          final distanceRows = await _getPrsByType(
            db,
            PRType.swimmingDistance.value,
          );
          final paceRows = await _getPrsByType(db, PRType.swimmingPace.value);

          expect(distanceRows, isEmpty);
          expect(paceRows, isEmpty);
        },
      );
    });
  });
}

Future<int> _createSession(AppDatabase db, {required String type}) {
  return db
      .into(db.trainingSessions)
      .insert(
        TrainingSessionsCompanion.insert(
          datetime: DateTime(2026, 3, 1, 8),
          type: type,
          durationMinutes: 30,
          intensity: 'moderate',
        ),
      );
}

Future<List<PersonalRecord>> _getPrsByType(AppDatabase db, String recordType) {
  return (db.select(
    db.personalRecords,
  )..where((p) => p.recordType.equals(recordType))).get();
}
