import 'dart:io';

import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/strength_entry_repository.dart';
import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

class _FakeStrengthEntryRepository extends StrengthEntryRepository {
  _FakeStrengthEntryRepository(super.db);

  int addCalls = 0;

  @override
  Future<int> addStrengthExercise({
    required int sessionId,
    required String exerciseName,
    int? exerciseId,
    required int sets,
    int? defaultReps,
    double? defaultWeight,
    String? repsPerSet,
    String? weightPerSet,
    String? setCompleted,
    bool isWarmup = false,
    int? rpe,
    int? restSeconds,
    String? note,
    int sortOrder = 0,
  }) async {
    addCalls++;
    return 4242;
  }
}

void main() {
  test('delegates strength entry methods to collaborators', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-training-repo-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final fakeStrength = _FakeStrengthEntryRepository(db);
      final repository = TrainingRepository(
        db,
        strengthEntries: fakeStrength,
      );

      final entryId = await repository.addStrengthExercise(
        sessionId: 1,
        exerciseName: 'Bench Press',
        sets: 3,
      );

      expect(entryId, 4242);
      expect(fakeStrength.addCalls, 1);

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}