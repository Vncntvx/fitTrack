import 'dart:io';

import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/swimming_repository.dart';
import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test('monthly swimming distance includes records on last day of month', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-swimming-monthly-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final trainingRepo = TrainingRepository(db);
      final swimmingRepo = SwimmingRepository(db);

      final inMonthSession = await trainingRepo.createTraining(
        datetime: DateTime(2026, 3, 31, 23, 59, 30),
        type: 'swimming',
        durationMinutes: 40,
        intensity: 'moderate',
      );
      await swimmingRepo.createSwimmingEntry(
        sessionId: inMonthSession,
        environment: 'pool',
        poolLengthMeters: 50,
        primaryStroke: 'freestyle',
        distanceMeters: 2000,
        durationSeconds: 1800,
        pacePer100m: 90,
      );

      final nextMonthSession = await trainingRepo.createTraining(
        datetime: DateTime(2026, 4, 1, 0, 0),
        type: 'swimming',
        durationMinutes: 25,
        intensity: 'light',
      );
      await swimmingRepo.createSwimmingEntry(
        sessionId: nextMonthSession,
        environment: 'pool',
        poolLengthMeters: 25,
        primaryStroke: 'breaststroke',
        distanceMeters: 1000,
        durationSeconds: 1200,
        pacePer100m: 120,
      );

      final monthlyDistance = await swimmingRepo.getMonthlyDistance(2026, 3);
      expect(monthlyDistance, 2000);

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}
