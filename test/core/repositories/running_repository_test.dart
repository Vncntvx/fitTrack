import 'dart:io';

import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/running_repository.dart';
import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test('monthly distance includes records on last day of month', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-running-monthly-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final trainingRepo = TrainingRepository(db);
      final runningRepo = RunningRepository(db);

      final inMonthSession = await trainingRepo.createTraining(
        datetime: DateTime(2026, 3, 31, 23, 59, 59),
        type: 'running',
        durationMinutes: 30,
        intensity: 'moderate',
      );
      await runningRepo.createRunningEntry(
        sessionId: inMonthSession,
        runType: 'tempo',
        distanceMeters: 5000,
        durationSeconds: 1500,
        avgPaceSeconds: 300,
      );

      final nextMonthSession = await trainingRepo.createTraining(
        datetime: DateTime(2026, 4, 1, 0, 0),
        type: 'running',
        durationMinutes: 20,
        intensity: 'light',
      );
      await runningRepo.createRunningEntry(
        sessionId: nextMonthSession,
        runType: 'easy',
        distanceMeters: 3000,
        durationSeconds: 1200,
        avgPaceSeconds: 400,
      );

      final monthlyDistance = await runningRepo.getMonthlyDistance(2026, 3);
      expect(monthlyDistance, 5000);

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}
