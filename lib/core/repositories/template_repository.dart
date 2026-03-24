import 'package:drift/drift.dart';
import '../database/database.dart';

/// 训练模板 Repository
/// 提供模板的 CRUD 操作和查询方法
class TemplateRepository {
  final AppDatabase _db;

  TemplateRepository(this._db);

  /// 获取所有模板
  Future<List<WorkoutTemplate>> getAll() async {
    return await _db.select(_db.workoutTemplates).get();
  }

  /// 获取最近更新的模板
  Future<List<WorkoutTemplate>> getRecent({int limit = 3}) async {
    return await (_db.select(_db.workoutTemplates)
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])
          ..limit(limit))
        .get();
  }

  /// 根据ID获取模板
  Future<WorkoutTemplate?> getById(int id) async {
    return await (_db.select(
      _db.workoutTemplates,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// 按类型获取模板
  Future<List<WorkoutTemplate>> getByType(String type) async {
    return await (_db.select(
      _db.workoutTemplates,
    )..where((t) => t.type.equals(type))).get();
  }

  /// 获取模板详情（包含动作）
  Future<TemplateDetail?> getTemplateDetail(int id) async {
    final template = await getById(id);
    if (template == null) return null;

    final exercises =
        await (_db.select(_db.templateExercises)
              ..where((e) => e.templateId.equals(id))
              ..orderBy([(e) => OrderingTerm.asc(e.sortOrder)]))
            .get();

    return TemplateDetail(template: template, exercises: exercises);
  }

  /// 创建模板
  Future<int> createTemplate({
    required String name,
    required String type,
    String? description,
    bool isDefault = false,
  }) async {
    return await _db
        .into(_db.workoutTemplates)
        .insert(
          WorkoutTemplatesCompanion(
            name: Value(name),
            type: Value(type),
            description: Value(description),
            isDefault: Value(isDefault),
          ),
        );
  }

  /// 添加模板动作
  Future<int> addTemplateExercise({
    required int templateId,
    int? exerciseId,
    required String exerciseName,
    required int sets,
    required int reps,
    double? weight,
    int sortOrder = 0,
  }) async {
    return await _db
        .into(_db.templateExercises)
        .insert(
          TemplateExercisesCompanion(
            templateId: Value(templateId),
            exerciseId: Value(exerciseId),
            exerciseName: Value(exerciseName),
            sets: Value(sets),
            reps: Value(reps),
            weight: Value(weight),
            sortOrder: Value(sortOrder),
          ),
        );
  }

  /// 批量添加模板动作
  /// 使用 batch 批量插入，避免 N+1 问题
  Future<void> addTemplateExercises(
    int templateId,
    List<TemplateExerciseData> exercises,
  ) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.templateExercises,
        exercises.asMap().entries.map((entry) {
          final i = entry.key;
          final e = entry.value;
          return TemplateExercisesCompanion(
            templateId: Value(templateId),
            exerciseId: Value(e.exerciseId),
            exerciseName: Value(e.exerciseName),
            sets: Value(e.sets),
            reps: Value(e.reps),
            weight: Value(e.weight),
            sortOrder: Value(i),
          );
        }).toList(),
      );
    });
  }

  /// 更新模板
  Future<bool> updateTemplate(
    int id, {
    String? name,
    String? type,
    String? description,
    bool? isDefault,
  }) async {
    return await _db
        .update(_db.workoutTemplates)
        .replace(
          WorkoutTemplatesCompanion(
            id: Value(id),
            name: name != null ? Value(name) : const Value.absent(),
            type: type != null ? Value(type) : const Value.absent(),
            description: description != null
                ? Value(description)
                : const Value.absent(),
            isDefault: isDefault != null
                ? Value(isDefault)
                : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  /// 更新模板动作
  Future<bool> updateTemplateExercise(
    int id, {
    int? exerciseId,
    String? exerciseName,
    int? sets,
    int? reps,
    double? weight,
    int? sortOrder,
  }) async {
    return await _db
        .update(_db.templateExercises)
        .replace(
          TemplateExercisesCompanion(
            id: Value(id),
            exerciseId: exerciseId != null
                ? Value(exerciseId)
                : const Value.absent(),
            exerciseName: exerciseName != null
                ? Value(exerciseName)
                : const Value.absent(),
            sets: sets != null ? Value(sets) : const Value.absent(),
            reps: reps != null ? Value(reps) : const Value.absent(),
            weight: weight != null ? Value(weight) : const Value.absent(),
            sortOrder: sortOrder != null
                ? Value(sortOrder)
                : const Value.absent(),
          ),
        );
  }

  /// 删除模板（会级联删除关联的模板动作）
  Future<int> deleteTemplate(int id) async {
    // 使用事务确保原子性：先删除动作，再删除模板
    return await _db.transaction<int>(() async {
      // 先删除关联的模板动作
      await (_db.delete(
        _db.templateExercises,
      )..where((e) => e.templateId.equals(id))).go();
      // 再删除模板
      final deletedRows = await (_db.delete(
        _db.workoutTemplates,
      )..where((t) => t.id.equals(id))).go();
      return deletedRows;
    });
  }

  /// 删除模板动作
  Future<int> deleteTemplateExercise(int id) async {
    return await (_db.delete(
      _db.templateExercises,
    )..where((e) => e.id.equals(id))).go();
  }

  /// 监听所有模板（响应式）
  Stream<List<WorkoutTemplate>> watchAll() {
    return _db.select(_db.workoutTemplates).watch();
  }

  /// 按类型监听模板
  Stream<List<WorkoutTemplate>> watchByType(String type) {
    return (_db.select(
      _db.workoutTemplates,
    )..where((t) => t.type.equals(type))).watch();
  }
}

/// 模板详情数据类
class TemplateDetail {
  final WorkoutTemplate template;
  final List<TemplateExercise> exercises;

  TemplateDetail({required this.template, required this.exercises});
}

/// 模板动作数据（用于批量添加）
class TemplateExerciseData {
  final int? exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final double? weight;

  TemplateExerciseData({
    this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weight,
  });
}
