import 'package:drift/drift.dart';
import '../database/database.dart';
import 'strength_entry_repository.dart';

/// 训练记录 Repository
/// 提供训练会话的 CRUD 操作和查询方法
class TrainingRepository {
  final AppDatabase _db;
  final StrengthEntryRepository _strengthEntries;

  TrainingRepository(this._db, {StrengthEntryRepository? strengthEntries})
    : _strengthEntries = strengthEntries ?? StrengthEntryRepository(_db);

  /// 创建训练记录
  Future<int> createTraining({
    required DateTime datetime,
    required String type,
    required int durationMinutes,
    required String intensity,
    String? note,
    bool isGoalCompleted = false,
    int? templateId,
  }) async {
    return await _db
        .into(_db.trainingSessions)
        .insert(
          TrainingSessionsCompanion(
            datetime: Value(datetime),
            type: Value(type),
            durationMinutes: Value(durationMinutes),
            intensity: Value(intensity),
            note: Value(note),
            isGoalCompleted: Value(isGoalCompleted),
            templateId: Value(templateId),
          ),
        );
  }

  /// 根据ID获取训练记录
  Future<TrainingSession?> getById(int id) async {
    return await (_db.select(
      _db.trainingSessions,
    )..where((w) => w.id.equals(id))).getSingleOrNull();
  }

  /// 获取所有训练记录
  Future<List<TrainingSession>> getAll() async {
    return await (_db.select(
      _db.trainingSessions,
    )..orderBy([(w) => OrderingTerm.desc(w.datetime)])).get();
  }

  /// 获取最近训练记录
  Future<List<TrainingSession>> getRecent({int limit = 3}) async {
    return await (_db.select(_db.trainingSessions)
          ..orderBy([(w) => OrderingTerm.desc(w.datetime)])
          ..limit(limit))
        .get();
  }

  /// 按日期范围获取记录
  Future<List<TrainingSession>> getByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    return await (_db.select(_db.trainingSessions)
          ..where((w) => w.datetime.isBetweenValues(start, end))
          ..orderBy([(w) => OrderingTerm.desc(w.datetime)]))
        .get();
  }

  /// 按类型获取记录
  Future<List<TrainingSession>> getByType(String type) async {
    return await (_db.select(_db.trainingSessions)
          ..where((w) => w.type.equals(type))
          ..orderBy([(w) => OrderingTerm.desc(w.datetime)]))
        .get();
  }

  /// 获取最近一次的同类型训练
  Future<TrainingSession?> getLastSession(String type) async {
    final sessions =
        await (_db.select(_db.trainingSessions)
              ..where((w) => w.type.equals(type))
              ..orderBy([(w) => OrderingTerm.desc(w.datetime)])
              ..limit(1))
            .get();
    return sessions.isNotEmpty ? sessions.first : null;
  }

  /// 获取模板对应的训练会话（按时间倒序）
  Future<List<TrainingSession>> getByTemplate(int templateId) async {
    return await (_db.select(_db.trainingSessions)
          ..where((w) => w.templateId.equals(templateId))
          ..orderBy([(w) => OrderingTerm.desc(w.datetime)]))
        .get();
  }

  /// 更新训练记录
  Future<bool> updateTraining(
    int id, {
    DateTime? datetime,
    String? type,
    int? durationMinutes,
    String? intensity,
    String? note,
    bool? isGoalCompleted,
    int? templateId,
  }) async {
    return await _db
        .update(_db.trainingSessions)
        .replace(
          TrainingSessionsCompanion(
            id: Value(id),
            datetime: datetime != null ? Value(datetime) : const Value.absent(),
            type: type != null ? Value(type) : const Value.absent(),
            durationMinutes: durationMinutes != null
                ? Value(durationMinutes)
                : const Value.absent(),
            intensity: intensity != null
                ? Value(intensity)
                : const Value.absent(),
            note: note != null ? Value(note) : const Value.absent(),
            isGoalCompleted: isGoalCompleted != null
                ? Value(isGoalCompleted)
                : const Value.absent(),
            templateId: templateId != null
                ? Value(templateId)
                : const Value.absent(),
          ),
        );
  }

  /// 删除训练记录（仅删除主表记录）
  /// 业务逻辑（级联删除）已移至 DeleteTrainingUseCase
  Future<int> deleteTraining(int id) async {
    return await (_db.delete(
      _db.trainingSessions,
    )..where((w) => w.id.equals(id))).go();
  }

  /// 监听所有记录（响应式）
  Stream<List<TrainingSession>> watchAll() {
    return _db.select(_db.trainingSessions).watch();
  }

  /// 监听指定类型的记录（响应式）
  Stream<List<TrainingSession>> watchByType(String type) {
    return (_db.select(_db.trainingSessions)
          ..where((w) => w.type.equals(type))
          ..orderBy([(w) => OrderingTerm.desc(w.datetime)]))
        .watch();
  }

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
    return _strengthEntries.addStrengthExercise(
      sessionId: sessionId,
      exerciseName: exerciseName,
      exerciseId: exerciseId,
      sets: sets,
      defaultReps: defaultReps,
      defaultWeight: defaultWeight,
      repsPerSet: repsPerSet,
      weightPerSet: weightPerSet,
      setCompleted: setCompleted,
      isWarmup: isWarmup,
      rpe: rpe,
      restSeconds: restSeconds,
      note: note,
      sortOrder: sortOrder,
    );
  }

  /// 获取训练记录的力量训练条目
  Future<List<StrengthExerciseEntry>> getStrengthExercises(
    int sessionId,
  ) async {
    return _strengthEntries.getStrengthExercises(sessionId);
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
    return _strengthEntries.updateStrengthExercise(
      id,
      exerciseName: exerciseName,
      exerciseId: exerciseId,
      sets: sets,
      defaultReps: defaultReps,
      defaultWeight: defaultWeight,
      repsPerSet: repsPerSet,
      weightPerSet: weightPerSet,
      setCompleted: setCompleted,
      isWarmup: isWarmup,
      rpe: rpe,
      restSeconds: restSeconds,
      note: note,
      sortOrder: sortOrder,
    );
  }

  /// 删除力量训练条目
  Future<int> deleteStrengthExercise(int id) async {
    return _strengthEntries.deleteStrengthExercise(id);
  }
}
