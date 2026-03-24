import 'package:drift/drift.dart';
import '../database/database.dart';

/// 动作库 Repository
/// 提供动作的 CRUD 操作和查询方法
class ExerciseRepository {
  final AppDatabase _db;

  ExerciseRepository(this._db);

  /// 获取所有动作
  Future<List<Exercise>> getAll() async {
    return await _db.select(_db.exercises).get();
  }

  /// 获取启用的动作
  Future<List<Exercise>> getEnabled() async {
    return await (_db.select(
      _db.exercises,
    )..where((e) => e.isEnabled.equals(true))).get();
  }

  /// 根据ID获取动作
  Future<Exercise?> getById(int id) async {
    return await (_db.select(
      _db.exercises,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  /// 按分类获取动作
  Future<List<Exercise>> getByCategory(String category) async {
    return await (_db.select(
          _db.exercises,
        )..where((e) => e.category.equals(category) & e.isEnabled.equals(true)))
        .get();
  }

  /// 搜索动作
  Future<List<Exercise>> search(String query) async {
    return await (_db.select(
      _db.exercises,
    )..where((e) => e.name.contains(query) & e.isEnabled.equals(true))).get();
  }

  /// 创建动作
  Future<int> createExercise({
    required String name,
    required String category,
    String movementType = 'compound',
    String? primaryMuscles,
    String? secondaryMuscles,
    int defaultSets = 3,
    int defaultReps = 10,
    double? defaultWeight,
    bool isCustom = true,
    String? description,
  }) async {
    return await _db
        .into(_db.exercises)
        .insert(
          ExercisesCompanion(
            name: Value(name),
            category: Value(category),
            movementType: Value(movementType),
            primaryMuscles: Value(primaryMuscles),
            secondaryMuscles: Value(secondaryMuscles),
            defaultSets: Value(defaultSets),
            defaultReps: Value(defaultReps),
            defaultWeight: Value(defaultWeight),
            isCustom: Value(isCustom),
            isEnabled: const Value(true),
            description: Value(description),
          ),
        );
  }

  /// 更新动作
  Future<bool> updateExercise(
    int id, {
    String? name,
    String? category,
    String? movementType,
    String? primaryMuscles,
    String? secondaryMuscles,
    int? defaultSets,
    int? defaultReps,
    double? defaultWeight,
    bool? isEnabled,
    String? description,
  }) async {
    return await _db
        .update(_db.exercises)
        .replace(
          ExercisesCompanion(
            id: Value(id),
            name: name != null ? Value(name) : const Value.absent(),
            category: category != null ? Value(category) : const Value.absent(),
            movementType: movementType != null
                ? Value(movementType)
                : const Value.absent(),
            primaryMuscles: primaryMuscles != null
                ? Value(primaryMuscles)
                : const Value.absent(),
            secondaryMuscles: secondaryMuscles != null
                ? Value(secondaryMuscles)
                : const Value.absent(),
            defaultSets: defaultSets != null
                ? Value(defaultSets)
                : const Value.absent(),
            defaultReps: defaultReps != null
                ? Value(defaultReps)
                : const Value.absent(),
            defaultWeight: defaultWeight != null
                ? Value(defaultWeight)
                : const Value.absent(),
            isEnabled: isEnabled != null
                ? Value(isEnabled)
                : const Value.absent(),
            description: description != null
                ? Value(description)
                : const Value.absent(),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  /// 获取动作的引用信息
  Future<ExerciseReferences> getReferences(int id) async {
    final strengthEntries = await (_db.select(
      _db.strengthExerciseEntries,
    )..where((e) => e.exerciseId.equals(id))).get();

    final templateExercises = await (_db.select(
      _db.templateExercises,
    )..where((e) => e.exerciseId.equals(id))).get();

    final personalRecords = await (_db.select(
      _db.personalRecords,
    )..where((record) => record.exerciseId.equals(id))).get();

    return ExerciseReferences(
      strengthEntryCount: strengthEntries.length,
      templateCount: templateExercises.length,
      prCount: personalRecords.length,
    );
  }

  /// 删除动作（仅删除记录，不检查引用）
  /// 业务逻辑（引用检查）已移至 DeleteExerciseUseCase
  Future<void> delete(int id) async {
    await (_db.delete(_db.exercises)..where((e) => e.id.equals(id))).go();
  }

  /// 禁用动作（软删除）
  Future<bool> disableExercise(int id) async {
    final exercise = await getById(id);
    if (exercise == null) return false;
    return await updateExercise(id, isEnabled: false);
  }

  /// 监听所有动作（响应式）
  Stream<List<Exercise>> watchAll() {
    return _db.select(_db.exercises).watch();
  }

  /// 按分类监听动作
  Stream<List<Exercise>> watchByCategory(String category) {
    return (_db.select(
          _db.exercises,
        )..where((e) => e.category.equals(category) & e.isEnabled.equals(true)))
        .watch();
  }
}

/// 动作引用信息
class ExerciseReferences {
  final int strengthEntryCount;
  final int templateCount;
  final int prCount;

  const ExerciseReferences({
    required this.strengthEntryCount,
    required this.templateCount,
    required this.prCount,
  });

  bool get hasReferences =>
      strengthEntryCount > 0 || templateCount > 0 || prCount > 0;
}
