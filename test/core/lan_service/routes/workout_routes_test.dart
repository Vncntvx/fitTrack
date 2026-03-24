import 'dart:convert';
import 'dart:io';

import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/lan_service/routes/workout_routes.dart';
import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:shelf/shelf.dart';

void main() {
  test('createWorkout rejects specialized workout type', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-workout-route-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final handler = WorkoutApiHandler(db);

      final request = Request(
        'POST',
        Uri.parse('http://localhost/api/workouts'),
        body: jsonEncode({
          'datetime': DateTime(2026, 3, 1, 8, 0).toIso8601String(),
          'type': 'running',
          'durationMinutes': 30,
          'intensity': 'moderate',
        }),
      );

      final response = await handler.createWorkout(request);
      expect(response.statusCode, 400);
      final payload =
          jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      expect(payload['data'], isNull);
      expect(payload['error'], isA<Map<String, dynamic>>());
      expect(
        (payload['error'] as Map<String, dynamic>)['message'],
        contains('Unsupported type for this endpoint'),
      );
      expect(
        payload['message'],
        contains('Unsupported type for this endpoint'),
      );
      expect(payload['meta'], isNull);

      final sessions = await TrainingRepository(db).getAll();
      expect(sessions, isEmpty);

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}
