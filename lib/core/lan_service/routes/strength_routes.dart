import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import '../../database/database.dart';
import '../../repositories/running_repository.dart';
import '../../repositories/strength_entry_repository.dart';
import '../../repositories/swimming_repository.dart';
import '../../repositories/training_repository.dart';
import '../../usecases/pr/rebuild_personal_records_usecase.dart';
import '../response_helper.dart';

/// 力量训练详情 API 处理器
class StrengthApiHandler {
  final AppDatabase _db;

  StrengthApiHandler(this._db);

  RebuildPersonalRecordsUseCase _prRebuilder() {
    final strengthRepo = StrengthEntryRepository(_db);
    return RebuildPersonalRecordsUseCase(
      _db,
      TrainingRepository(_db, strengthEntries: strengthRepo),
      strengthRepo,
      RunningRepository(_db),
      SwimmingRepository(_db),
    );
  }

  /// 获取力量训练详情
  Future<Response> getBySession(Request request, String sessionId) async {
    try {
      final id = int.tryParse(sessionId);
      if (id == null) {
        return LanApiResponse.badRequest('Invalid session ID');
      }

      final entries =
          await (_db.select(_db.strengthExerciseEntries)
                ..where((e) => e.sessionId.equals(id))
                ..orderBy([(e) => OrderingTerm.asc(e.sortOrder)]))
              .get();

      return LanApiResponse.ok(
        data: entries.map(_entryToJson).toList(),
        message: 'Fetched strength entries successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 添加力量训练动作
  Future<Response> addEntry(Request request, String sessionId) async {
    try {
      final id = int.tryParse(sessionId);
      if (id == null) {
        return LanApiResponse.badRequest('Invalid session ID');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final entryId = await _db.transaction(() async {
        final insertedId = await _db
            .into(_db.strengthExerciseEntries)
            .insert(
              StrengthExerciseEntriesCompanion(
                sessionId: Value(id),
                exerciseId: Value(data['exerciseId'] as int?),
                exerciseName: Value(data['exerciseName'] as String),
                sets: Value(data['sets'] as int? ?? 3),
                defaultReps: Value(data['defaultReps'] as int? ?? 10),
                defaultWeight: Value(
                  (data['defaultWeight'] as num?)?.toDouble(),
                ),
                repsPerSet: Value(data['repsPerSet'] as String?),
                weightPerSet: Value(data['weightPerSet'] as String?),
                setCompleted: Value(data['setCompleted'] as String?),
                isWarmup: Value(data['isWarmup'] as bool? ?? false),
                rpe: Value(data['rpe'] as int?),
                restSeconds: Value(data['restSeconds'] as int?),
                note: Value(data['note'] as String?),
                sortOrder: Value(data['sortOrder'] as int? ?? 0),
              ),
            );
        await _prRebuilder().rebuildForTrainingType('strength');
        return insertedId;
      });

      return LanApiResponse.created(
        data: {'id': entryId},
        message: 'Entry added',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 更新力量训练动作
  Future<Response> updateEntry(Request request, String entryId) async {
    try {
      final id = int.tryParse(entryId);
      if (id == null) {
        return LanApiResponse.badRequest('Invalid entry ID');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final rowsAffected = await _db.transaction(() async {
        final affected =
            await (_db.update(
              _db.strengthExerciseEntries,
            )..where((e) => e.id.equals(id))).write(
              StrengthExerciseEntriesCompanion(
                exerciseName: data['exerciseName'] != null
                    ? Value(data['exerciseName'] as String)
                    : const Value.absent(),
                sets: data['sets'] != null
                    ? Value(data['sets'] as int)
                    : const Value.absent(),
                defaultReps: data['defaultReps'] != null
                    ? Value(data['defaultReps'] as int)
                    : const Value.absent(),
                defaultWeight: data['defaultWeight'] != null
                    ? Value((data['defaultWeight'] as num).toDouble())
                    : const Value.absent(),
                repsPerSet: data['repsPerSet'] != null
                    ? Value(data['repsPerSet'] as String)
                    : const Value.absent(),
                weightPerSet: data['weightPerSet'] != null
                    ? Value(data['weightPerSet'] as String)
                    : const Value.absent(),
                setCompleted: data['setCompleted'] != null
                    ? Value(data['setCompleted'] as String)
                    : const Value.absent(),
                isWarmup: data['isWarmup'] != null
                    ? Value(data['isWarmup'] as bool)
                    : const Value.absent(),
                rpe: data['rpe'] != null
                    ? Value(data['rpe'] as int)
                    : const Value.absent(),
                restSeconds: data['restSeconds'] != null
                    ? Value(data['restSeconds'] as int)
                    : const Value.absent(),
                note: data['note'] != null
                    ? Value(data['note'] as String)
                    : const Value.absent(),
              ),
            );
        if (affected > 0) {
          await _prRebuilder().rebuildForTrainingType('strength');
        }
        return affected;
      });

      if (rowsAffected == 0) {
        return LanApiResponse.notFound('Entry not found');
      }

      return LanApiResponse.ok(
        data: {'id': id},
        message: 'Updated successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 删除力量训练动作
  Future<Response> deleteEntry(Request request, String entryId) async {
    try {
      final id = int.tryParse(entryId);
      if (id == null) {
        return LanApiResponse.badRequest('Invalid entry ID');
      }

      final deleted = await _db.transaction(() async {
        final count = await (_db.delete(
          _db.strengthExerciseEntries,
        )..where((e) => e.id.equals(id))).go();
        if (count > 0) {
          await _prRebuilder().rebuildForTrainingType('strength');
        }
        return count;
      });

      if (deleted == 0) {
        return LanApiResponse.notFound('Entry not found');
      }

      return LanApiResponse.ok(
        data: {'id': id},
        message: 'Deleted successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 转换条目为 JSON
  Map<String, dynamic> _entryToJson(StrengthExerciseEntry entry) {
    return {
      'id': entry.id,
      'sessionId': entry.sessionId,
      'exerciseId': entry.exerciseId,
      'exerciseName': entry.exerciseName,
      'sets': entry.sets,
      'defaultReps': entry.defaultReps,
      'defaultWeight': entry.defaultWeight,
      'repsPerSet': entry.repsPerSet,
      'weightPerSet': entry.weightPerSet,
      'setCompleted': entry.setCompleted,
      'isWarmup': entry.isWarmup,
      'rpe': entry.rpe,
      'restSeconds': entry.restSeconds,
      'sortOrder': entry.sortOrder,
      'note': entry.note,
    };
  }
}
