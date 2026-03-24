import 'package:drift/drift.dart';

import '../database/database.dart';

/// 力量条目仓库
/// 管理力量训练子表的增删改查
class StrengthEntryRepository {
  StrengthEntryRepository(this._db);

  final AppDatabase _db;

  /// 添加力量训练条目
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
    return await _db
        .into(_db.strengthExerciseEntries)
        .insert(
          StrengthExerciseEntriesCompanion(
            sessionId: Value(sessionId),
            exerciseId: Value(exerciseId),
            exerciseName: Value(exerciseName),
            sets: Value(sets),
            defaultReps: Value(defaultReps ?? 10),
            defaultWeight: Value(defaultWeight),
            repsPerSet: Value(repsPerSet),
            weightPerSet: Value(weightPerSet),
            setCompleted: Value(setCompleted),
            isWarmup: Value(isWarmup),
            rpe: Value(rpe),
            restSeconds: Value(restSeconds),
            note: Value(note),
            sortOrder: Value(sortOrder),
          ),
        );
  }

  /// 获取会话下的力量训练条目
  Future<List<StrengthExerciseEntry>> getStrengthExercises(
    int sessionId,
  ) async {
    return await (_db.select(_db.strengthExerciseEntries)
          ..where((e) => e.sessionId.equals(sessionId))
          ..orderBy([(e) => OrderingTerm.asc(e.sortOrder)]))
        .get();
  }

  /// 更新力量训练条目
  Future<bool> updateStrengthExercise(
    int id, {
    String? exerciseName,
    int? exerciseId,
    int? sets,
    int? defaultReps,
    double? defaultWeight,
    String? repsPerSet,
    String? weightPerSet,
    String? setCompleted,
    bool? isWarmup,
    int? rpe,
    int? restSeconds,
    String? note,
    int? sortOrder,
  }) async {
    return await _db
        .update(_db.strengthExerciseEntries)
        .replace(
          StrengthExerciseEntriesCompanion(
            id: Value(id),
            exerciseName: exerciseName != null
                ? Value(exerciseName)
                : const Value.absent(),
            exerciseId: exerciseId != null
                ? Value(exerciseId)
                : const Value.absent(),
            sets: sets != null ? Value(sets) : const Value.absent(),
            defaultReps: defaultReps != null
                ? Value(defaultReps)
                : const Value.absent(),
            defaultWeight: defaultWeight != null
                ? Value(defaultWeight)
                : const Value.absent(),
            repsPerSet: repsPerSet != null
                ? Value(repsPerSet)
                : const Value.absent(),
            weightPerSet: weightPerSet != null
                ? Value(weightPerSet)
                : const Value.absent(),
            setCompleted: setCompleted != null
                ? Value(setCompleted)
                : const Value.absent(),
            isWarmup: isWarmup != null ? Value(isWarmup) : const Value.absent(),
            rpe: rpe != null ? Value(rpe) : const Value.absent(),
            restSeconds: restSeconds != null
                ? Value(restSeconds)
                : const Value.absent(),
            note: note != null ? Value(note) : const Value.absent(),
            sortOrder: sortOrder != null
                ? Value(sortOrder)
                : const Value.absent(),
          ),
        );
  }

  /// 删除力量训练条目
  Future<int> deleteStrengthExercise(int id) async {
    return await (_db.delete(
      _db.strengthExerciseEntries,
    )..where((e) => e.id.equals(id))).go();
  }
}
