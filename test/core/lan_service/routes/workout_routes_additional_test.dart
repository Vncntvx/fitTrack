import 'dart:convert';

import 'package:fittrack/core/lan_service/routes/workout_routes.dart';
import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';

import '../../../helpers/test_db_helper.dart';

Map<String, dynamic> _expectEnvelope(Map<String, dynamic> payload) {
  expect(payload, containsPair('data', anything));
  expect(payload, containsPair('error', anything));
  expect(payload, containsPair('message', anything));
  expect(payload, containsPair('meta', anything));
  return payload;
}

Map<String, dynamic> _expectErrorEnvelope(Map<String, dynamic> payload) {
  final envelope = _expectEnvelope(payload);
  expect(envelope['data'], isNull);
  expect(envelope['error'], isA<Map<String, dynamic>>());
  final error = envelope['error'] as Map<String, dynamic>;
  expect(error['message'], isA<String>());
  expect(error['code'], isA<String>());
  return envelope;
}

Map<String, dynamic> _expectSuccessEnvelope(Map<String, dynamic> payload) {
  final envelope = _expectEnvelope(payload);
  expect(envelope['error'], isNull);
  return envelope;
}

void main() {
  test('createWorkout validates required fields and duration', () async {
    await withTestDatabase(
      body: (db) async {
        final handler = WorkoutApiHandler(db);

        final missingDatetime = await handler.createWorkout(
          Request(
            'POST',
            Uri.parse('http://localhost/api/workouts'),
            body: jsonEncode({
              'type': 'cycling',
              'durationMinutes': 20,
              'intensity': 'light',
            }),
          ),
        );
        expect(missingDatetime.statusCode, 400);
        final missingPayload =
            jsonDecode(await missingDatetime.readAsString())
                as Map<String, dynamic>;
        final missingError = _expectErrorEnvelope(missingPayload);
        expect(
          (missingError['error'] as Map<String, dynamic>)['message'],
          contains('datetime is required'),
        );
        expect(missingError['message'], contains('datetime is required'));

        final missingType = await handler.createWorkout(
          Request(
            'POST',
            Uri.parse('http://localhost/api/workouts'),
            body: jsonEncode({
              'datetime': DateTime(2026, 3, 1, 8).toIso8601String(),
              'durationMinutes': 20,
              'intensity': 'light',
            }),
          ),
        );
        expect(missingType.statusCode, 400);
        final missingTypePayload =
            jsonDecode(await missingType.readAsString())
                as Map<String, dynamic>;
        final typeError = _expectErrorEnvelope(missingTypePayload);
        expect(
          (typeError['error'] as Map<String, dynamic>)['message'],
          contains('type is required'),
        );
        expect(typeError['message'], contains('type is required'));

        final invalidDuration = await handler.createWorkout(
          Request(
            'POST',
            Uri.parse('http://localhost/api/workouts'),
            body: jsonEncode({
              'datetime': DateTime(2026, 3, 1, 8).toIso8601String(),
              'type': 'cycling',
              'durationMinutes': 0,
              'intensity': 'moderate',
            }),
          ),
        );
        expect(invalidDuration.statusCode, 400);
        final durationPayload =
            jsonDecode(await invalidDuration.readAsString())
                as Map<String, dynamic>;
        final invalidDurationEnvelope = _expectErrorEnvelope(durationPayload);
        expect(
          (invalidDurationEnvelope['error'] as Map<String, dynamic>)['message'],
          contains('durationMinutes must be greater than 0'),
        );

        final missingIntensity = await handler.createWorkout(
          Request(
            'POST',
            Uri.parse('http://localhost/api/workouts'),
            body: jsonEncode({
              'datetime': DateTime(2026, 3, 1, 8).toIso8601String(),
              'type': 'cycling',
              'durationMinutes': 30,
            }),
          ),
        );
        expect(missingIntensity.statusCode, 400);
        final missingIntensityPayload =
            jsonDecode(await missingIntensity.readAsString())
                as Map<String, dynamic>;
        final missingIntensityEnvelope = _expectErrorEnvelope(
          missingIntensityPayload,
        );
        expect(
          (missingIntensityEnvelope['error']
              as Map<String, dynamic>)['message'],
          contains('intensity is required'),
        );
      },
    );
  });

  test(
    'createWorkout creates simple workout and getWorkoutById returns it',
    () async {
      await withTestDatabase(
        body: (db) async {
          final handler = WorkoutApiHandler(db);
          final createResponse = await handler.createWorkout(
            Request(
              'POST',
              Uri.parse('http://localhost/api/workouts'),
              body: jsonEncode({
                'datetime': DateTime(2026, 3, 2, 10).toIso8601String(),
                'type': 'cycling',
                'durationMinutes': 45,
                'intensity': 'moderate',
                'note': 'LAN create',
                'isGoalCompleted': true,
              }),
            ),
          );
          expect(createResponse.statusCode, 201);
          final createPayload =
              jsonDecode(await createResponse.readAsString())
                  as Map<String, dynamic>;
          final createEnvelope = _expectSuccessEnvelope(createPayload);
          expect(createEnvelope['message'], 'Created successfully');
          final id =
              (createEnvelope['data'] as Map<String, dynamic>)['id'] as int;
          expect(id, greaterThan(0));

          final getResponse = await handler.getWorkoutById(
            Request('GET', Uri.parse('http://localhost/api/workouts/$id')),
            '$id',
          );
          expect(getResponse.statusCode, 200);
          final getPayload =
              jsonDecode(await getResponse.readAsString())
                  as Map<String, dynamic>;
          final getEnvelope = _expectSuccessEnvelope(getPayload);
          expect(getEnvelope['message'], 'Fetched workout successfully');
          final workout = getEnvelope['data'] as Map<String, dynamic>;
          expect(workout['id'], id);
          expect(workout['type'], 'cycling');
          expect(workout['durationMinutes'], 45);
        },
      );
    },
  );

  test('getWorkoutById validates id and notFound semantics', () async {
    await withTestDatabase(
      body: (db) async {
        final handler = WorkoutApiHandler(db);

        final invalidIdResponse = await handler.getWorkoutById(
          Request(
            'GET',
            Uri.parse('http://localhost/api/workouts/not-a-number'),
          ),
          'not-a-number',
        );
        expect(invalidIdResponse.statusCode, 400);
        final invalidIdPayload =
            jsonDecode(await invalidIdResponse.readAsString())
                as Map<String, dynamic>;
        final invalidIdEnvelope = _expectErrorEnvelope(invalidIdPayload);
        expect(
          (invalidIdEnvelope['error'] as Map<String, dynamic>)['message'],
          'Invalid ID',
        );

        final notFoundResponse = await handler.getWorkoutById(
          Request('GET', Uri.parse('http://localhost/api/workouts/9999')),
          '9999',
        );
        expect(notFoundResponse.statusCode, 404);
        final notFoundPayload =
            jsonDecode(await notFoundResponse.readAsString())
                as Map<String, dynamic>;
        final notFoundEnvelope = _expectErrorEnvelope(notFoundPayload);
        expect(
          (notFoundEnvelope['error'] as Map<String, dynamic>)['message'],
          'Session not found',
        );
      },
    );
  });

  test('updateWorkout and deleteWorkout follow notFound semantics', () async {
    await withTestDatabase(
      body: (db) async {
        final handler = WorkoutApiHandler(db);

        final invalidUpdate = await handler.updateWorkout(
          Request(
            'PUT',
            Uri.parse('http://localhost/api/workouts/not-a-number'),
            body: jsonEncode({
              'datetime': DateTime(2026, 3, 3, 8).toIso8601String(),
              'type': 'cycling',
              'durationMinutes': 20,
              'intensity': 'light',
            }),
          ),
          'not-a-number',
        );
        expect(invalidUpdate.statusCode, 400);
        final invalidUpdatePayload =
            jsonDecode(await invalidUpdate.readAsString())
                as Map<String, dynamic>;
        final invalidUpdateEnvelope = _expectErrorEnvelope(
          invalidUpdatePayload,
        );
        expect(
          (invalidUpdateEnvelope['error'] as Map<String, dynamic>)['message'],
          'Invalid ID',
        );

        final updateMissing = await handler.updateWorkout(
          Request(
            'PUT',
            Uri.parse('http://localhost/api/workouts/9999'),
            body: jsonEncode({
              'datetime': DateTime(2026, 3, 3, 8).toIso8601String(),
              'type': 'cycling',
              'durationMinutes': 20,
              'intensity': 'light',
            }),
          ),
          '9999',
        );
        expect(updateMissing.statusCode, 404);
        final updateMissingPayload =
            jsonDecode(await updateMissing.readAsString())
                as Map<String, dynamic>;
        final updateMissingEnvelope = _expectErrorEnvelope(
          updateMissingPayload,
        );
        expect(
          (updateMissingEnvelope['error'] as Map<String, dynamic>)['message'],
          'Session not found',
        );

        final invalidDelete = await handler.deleteWorkout(
          Request(
            'DELETE',
            Uri.parse('http://localhost/api/workouts/not-a-number'),
          ),
          'not-a-number',
        );
        expect(invalidDelete.statusCode, 400);
        final invalidDeletePayload =
            jsonDecode(await invalidDelete.readAsString())
                as Map<String, dynamic>;
        final invalidDeleteEnvelope = _expectErrorEnvelope(
          invalidDeletePayload,
        );
        expect(
          (invalidDeleteEnvelope['error'] as Map<String, dynamic>)['message'],
          'Invalid ID',
        );

        final deleteMissing = await handler.deleteWorkout(
          Request('DELETE', Uri.parse('http://localhost/api/workouts/9999')),
          '9999',
        );
        expect(deleteMissing.statusCode, 404);
        final deleteMissingPayload =
            jsonDecode(await deleteMissing.readAsString())
                as Map<String, dynamic>;
        final deleteMissingEnvelope = _expectErrorEnvelope(
          deleteMissingPayload,
        );
        expect(
          (deleteMissingEnvelope['error'] as Map<String, dynamic>)['message'],
          'Session not found',
        );
      },
    );
  });

  test('updateWorkout rejects switching to specialized type', () async {
    await withTestDatabase(
      body: (db) async {
        final repo = TrainingRepository(db);
        final id = await repo.createTraining(
          datetime: DateTime(2026, 3, 5, 8),
          type: 'cycling',
          durationMinutes: 30,
          intensity: 'moderate',
        );

        final handler = WorkoutApiHandler(db);
        final response = await handler.updateWorkout(
          Request(
            'PUT',
            Uri.parse('http://localhost/api/workouts/$id'),
            body: jsonEncode({'type': 'running'}),
          ),
          '$id',
        );
        expect(response.statusCode, 400);
        final payload =
            jsonDecode(await response.readAsString()) as Map<String, dynamic>;
        final envelope = _expectErrorEnvelope(payload);
        expect(
          (envelope['error'] as Map<String, dynamic>)['message'],
          contains('Unsupported type for this endpoint'),
        );
      },
    );
  });

  test(
    'updateWorkout and deleteWorkout return success contract for existing workout',
    () async {
      await withTestDatabase(
        body: (db) async {
          final handler = WorkoutApiHandler(db);

          final createResponse = await handler.createWorkout(
            Request(
              'POST',
              Uri.parse('http://localhost/api/workouts'),
              body: jsonEncode({
                'datetime': DateTime(2026, 3, 6, 8).toIso8601String(),
                'type': 'cycling',
                'durationMinutes': 30,
                'intensity': 'moderate',
              }),
            ),
          );
          final createPayload =
              jsonDecode(await createResponse.readAsString())
                  as Map<String, dynamic>;
          final createEnvelope = _expectSuccessEnvelope(createPayload);
          final id =
              (createEnvelope['data'] as Map<String, dynamic>)['id'] as int;

          final updateResponse = await handler.updateWorkout(
            Request(
              'PUT',
              Uri.parse('http://localhost/api/workouts/$id'),
              body: jsonEncode({
                'durationMinutes': 60,
                'intensity': 'high',
                'note': 'updated in test',
              }),
            ),
            '$id',
          );
          expect(updateResponse.statusCode, 200);
          final updatePayload =
              jsonDecode(await updateResponse.readAsString())
                  as Map<String, dynamic>;
          final updateEnvelope = _expectSuccessEnvelope(updatePayload);
          expect(updateEnvelope['message'], 'Updated successfully');

          final getAfterUpdate = await handler.getWorkoutById(
            Request('GET', Uri.parse('http://localhost/api/workouts/$id')),
            '$id',
          );
          expect(getAfterUpdate.statusCode, 200);
          final updatedSession =
              _expectSuccessEnvelope(
                    jsonDecode(await getAfterUpdate.readAsString())
                        as Map<String, dynamic>,
                  )['data']
                  as Map<String, dynamic>;
          expect(updatedSession['durationMinutes'], 60);
          expect(updatedSession['intensity'], 'high');
          expect(updatedSession['note'], 'updated in test');

          final deleteResponse = await handler.deleteWorkout(
            Request('DELETE', Uri.parse('http://localhost/api/workouts/$id')),
            '$id',
          );
          expect(deleteResponse.statusCode, 200);
          final deletePayload =
              jsonDecode(await deleteResponse.readAsString())
                  as Map<String, dynamic>;
          final deleteEnvelope = _expectSuccessEnvelope(deletePayload);
          expect(deleteEnvelope['message'], 'Deleted successfully');

          final getAfterDelete = await handler.getWorkoutById(
            Request('GET', Uri.parse('http://localhost/api/workouts/$id')),
            '$id',
          );
          expect(getAfterDelete.statusCode, 404);
        },
      );
    },
  );

  test('getWorkouts and getStats return successful payloads', () async {
    await withTestDatabase(
      body: (db) async {
        final repo = TrainingRepository(db);
        await repo.createTraining(
          datetime: DateTime.now(),
          type: 'cycling',
          durationMinutes: 20,
          intensity: 'moderate',
        );
        await repo.createTraining(
          datetime: DateTime.now().subtract(const Duration(days: 1)),
          type: 'yoga',
          durationMinutes: 30,
          intensity: 'moderate',
        );

        final handler = WorkoutApiHandler(db);
        final workoutsResponse = await handler.getWorkouts(
          Request('GET', Uri.parse('http://localhost/api/workouts')),
        );
        expect(workoutsResponse.statusCode, 200);
        final workoutsPayload =
            jsonDecode(await workoutsResponse.readAsString())
                as Map<String, dynamic>;
        final workoutsEnvelope = _expectSuccessEnvelope(workoutsPayload);
        final workouts = workoutsEnvelope['data'] as List<dynamic>;
        expect(workoutsEnvelope['message'], 'Fetched workouts successfully');
        expect(workouts, hasLength(2));
        expect(workouts.first, isA<Map<String, dynamic>>());
        final firstWorkout = workouts.first as Map<String, dynamic>;
        expect(firstWorkout['id'], isA<int>());
        expect(firstWorkout['type'], isA<String>());

        final statsResponse = await handler.getStats(
          Request('GET', Uri.parse('http://localhost/api/workouts/stats')),
        );
        expect(statsResponse.statusCode, 200);
        final statsPayload =
            jsonDecode(await statsResponse.readAsString())
                as Map<String, dynamic>;
        final statsEnvelope = _expectSuccessEnvelope(statsPayload);
        expect(statsEnvelope['message'], 'Fetched workout stats successfully');
        final statsData = statsEnvelope['data'] as Map<String, dynamic>;
        expect(statsData['workoutDaysThisWeek'], isA<int>());
        expect(statsData['totalMinutesThisWeek'], isA<int>());
        expect(statsData['currentStreak'], isA<int>());
        expect(statsData['weeklyCount'], isA<int>());
        expect(statsData['weeklyMinutes'], isA<int>());
        expect(statsData['totalWorkouts'], 2);
        expect(statsData['totalMinutes'], 50);
        expect(statsData['avgIntensity'], isA<String>());
      },
    );
  });
}
