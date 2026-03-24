import 'package:drift/drift.dart';
import '../database/database.dart';

/// 游泳记录 Repository
/// 提供游泳训练的 CRUD 操作和查询方法
class SwimmingRepository {
  final AppDatabase _db;

  SwimmingRepository(this._db);

  /// 创建游泳记录
  Future<int> createSwimmingEntry({
    required int sessionId,
    required String environment,
    int? poolLengthMeters,
    required String primaryStroke,
    required double distanceMeters,
    required int durationSeconds,
    required int pacePer100m,
    String? trainingType,
    String? equipment,
  }) async {
    return await _db
        .into(_db.swimmingEntries)
        .insert(
          SwimmingEntriesCompanion(
            sessionId: Value(sessionId),
            environment: Value(environment),
            poolLengthMeters: Value(poolLengthMeters),
            primaryStroke: Value(primaryStroke),
            distanceMeters: Value(distanceMeters),
            durationSeconds: Value(durationSeconds),
            pacePer100m: Value(pacePer100m),
            trainingType: Value(trainingType),
            equipment: Value(equipment),
          ),
        );
  }

  /// 根据ID获取游泳记录
  Future<SwimmingEntry?> getById(int id) async {
    return await (_db.select(
      _db.swimmingEntries,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// 根据会话ID获取游泳记录
  Future<SwimmingEntry?> getBySessionId(int sessionId) async {
    return await (_db.select(
      _db.swimmingEntries,
    )..where((s) => s.sessionId.equals(sessionId))).getSingleOrNull();
  }

  /// 获取所有游泳记录
  Future<List<SwimmingEntry>> getAll() async {
    return await _db.select(_db.swimmingEntries).get();
  }

  /// 监听所有游泳记录（响应式）
  Stream<List<SwimmingEntry>> watchAll() {
    return _db.select(_db.swimmingEntries).watch();
  }

  /// 监听指定会话ID的游泳记录（响应式）
  Stream<List<SwimmingEntry>> watchBySessionId(int sessionId) {
    return (_db.select(
      _db.swimmingEntries,
    )..where((e) => e.sessionId.equals(sessionId))).watch();
  }

  /// 更新游泳记录
  Future<bool> updateSwimmingEntry(
    int id, {
    String? environment,
    int? poolLengthMeters,
    String? primaryStroke,
    double? distanceMeters,
    int? durationSeconds,
    int? pacePer100m,
    String? trainingType,
    String? equipment,
  }) async {
    return await _db
        .update(_db.swimmingEntries)
        .replace(
          SwimmingEntriesCompanion(
            id: Value(id),
            environment: environment != null
                ? Value(environment)
                : const Value.absent(),
            poolLengthMeters: poolLengthMeters != null
                ? Value(poolLengthMeters)
                : const Value.absent(),
            primaryStroke: primaryStroke != null
                ? Value(primaryStroke)
                : const Value.absent(),
            distanceMeters: distanceMeters != null
                ? Value(distanceMeters)
                : const Value.absent(),
            durationSeconds: durationSeconds != null
                ? Value(durationSeconds)
                : const Value.absent(),
            pacePer100m: pacePer100m != null
                ? Value(pacePer100m)
                : const Value.absent(),
            trainingType: trainingType != null
                ? Value(trainingType)
                : const Value.absent(),
            equipment: equipment != null
                ? Value(equipment)
                : const Value.absent(),
          ),
        );
  }

  /// 删除游泳记录（级联删除分组数据）
  Future<bool> deleteSwimmingEntry(int id) async {
    return await _db.transaction(() async {
      // 先删除关联的分组记录
      await (_db.delete(
        _db.swimmingSets,
      )..where((s) => s.swimmingEntryId.equals(id))).go();

      // 然后删除主记录
      final deletedRows = await (_db.delete(
        _db.swimmingEntries,
      )..where((s) => s.id.equals(id))).go();

      return deletedRows > 0;
    });
  }

  /// 根据泳姿获取会话ID列表
  Future<List<int>> getSessionIdsByStroke(String stroke) async {
    final entries = await (_db.select(
      _db.swimmingEntries,
    )..where((s) => s.primaryStroke.equals(stroke))).get();
    return entries.map((e) => e.sessionId).toList();
  }

  /// 添加游泳分组
  Future<int> addSwimmingSet({
    required int swimmingEntryId,
    required String setType,
    String? description,
    required double distanceMeters,
    required int durationSeconds,
    int sortOrder = 0,
  }) async {
    return await _db
        .into(_db.swimmingSets)
        .insert(
          SwimmingSetsCompanion(
            swimmingEntryId: Value(swimmingEntryId),
            setType: Value(setType),
            description: Value(description),
            distanceMeters: Value(distanceMeters),
            durationSeconds: Value(durationSeconds),
            sortOrder: Value(sortOrder),
          ),
        );
  }

  /// 获取游泳分组
  Future<List<SwimmingSet>> getSets(int swimmingEntryId) async {
    return await (_db.select(_db.swimmingSets)
          ..where((s) => s.swimmingEntryId.equals(swimmingEntryId))
          ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
        .get();
  }

  /// 监听游泳分组（响应式）
  Stream<List<SwimmingSet>> watchSets(int swimmingEntryId) {
    return (_db.select(_db.swimmingSets)
          ..where((s) => s.swimmingEntryId.equals(swimmingEntryId))
          ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
        .watch();
  }

  /// 删除游泳分组
  Future<int> deleteSwimmingSet(int id) async {
    return await (_db.delete(
      _db.swimmingSets,
    )..where((s) => s.id.equals(id))).go();
  }

  /// 删除某条游泳记录的全部分组
  Future<int> deleteSetsByEntryId(int swimmingEntryId) async {
    return await (_db.delete(
      _db.swimmingSets,
    )..where((s) => s.swimmingEntryId.equals(swimmingEntryId))).go();
  }

  /// 获取周游泳距离
  Future<double> getWeeklyDistance(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final sessionIds =
        await (_db.select(_db.trainingSessions)
              ..where((t) => t.datetime.isBetweenValues(weekStart, weekEnd)))
            .map((t) => t.id)
            .get();
    final entries = await (_db.select(
      _db.swimmingEntries,
    )..where((s) => s.sessionId.isIn(sessionIds))).get();
    return entries.fold<double>(0, (sum, e) => sum + e.distanceMeters);
  }

  /// 获取月游泳距离
  Future<double> getMonthlyDistance(int year, int month) async {
    final monthStart = DateTime(year, month, 1);
    final nextMonthStart = DateTime(year, month + 1, 1);
    final sessionIds =
        await (_db.select(_db.trainingSessions)..where(
              (t) =>
                  t.datetime.isBiggerOrEqualValue(monthStart) &
                  t.datetime.isSmallerThanValue(nextMonthStart),
            ))
            .map((t) => t.id)
            .get();
    final entries = await (_db.select(
      _db.swimmingEntries,
    )..where((s) => s.sessionId.isIn(sessionIds))).get();
    return entries.fold<double>(0, (sum, e) => sum + e.distanceMeters);
  }

  /// 计算每100米配速（秒）
  static int calculatePacePer100m(int durationSeconds, double distanceMeters) {
    if (distanceMeters <= 0) return 0;
    return ((durationSeconds / distanceMeters) * 100).round();
  }

  /// 格式化配速为 mm:ss
  static String formatPace(int secondsPer100m) {
    final minutes = secondsPer100m ~/ 60;
    final seconds = secondsPer100m % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
