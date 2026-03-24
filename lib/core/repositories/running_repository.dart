import 'package:drift/drift.dart';
import '../database/database.dart';

/// 跑步记录 Repository
/// 提供跑步训练的 CRUD 操作和查询方法
class RunningRepository {
  final AppDatabase _db;

  RunningRepository(this._db);

  /// 创建跑步记录
  Future<int> createRunningEntry({
    required int sessionId,
    required String runType,
    required double distanceMeters,
    required int durationSeconds,
    required int avgPaceSeconds,
    int? bestPaceSeconds,
    int? avgHeartRate,
    int? maxHeartRate,
    int? avgCadence,
    int? maxCadence,
    double? elevationGain,
    double? elevationLoss,
    String? footwear,
    String? weatherJson,
  }) async {
    return await _db
        .into(_db.runningEntries)
        .insert(
          RunningEntriesCompanion(
            sessionId: Value(sessionId),
            runType: Value(runType),
            distanceMeters: Value(distanceMeters),
            durationSeconds: Value(durationSeconds),
            avgPaceSeconds: Value(avgPaceSeconds),
            bestPaceSeconds: Value(bestPaceSeconds),
            avgHeartRate: Value(avgHeartRate),
            maxHeartRate: Value(maxHeartRate),
            avgCadence: Value(avgCadence),
            maxCadence: Value(maxCadence),
            elevationGain: Value(elevationGain),
            elevationLoss: Value(elevationLoss),
            footwear: Value(footwear),
            weatherJson: Value(weatherJson),
          ),
        );
  }

  /// 根据ID获取跑步记录
  Future<RunningEntry?> getById(int id) async {
    return await (_db.select(
      _db.runningEntries,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  /// 根据会话ID获取跑步记录
  Future<RunningEntry?> getBySessionId(int sessionId) async {
    return await (_db.select(
      _db.runningEntries,
    )..where((r) => r.sessionId.equals(sessionId))).getSingleOrNull();
  }

  /// 获取所有跑步记录
  Future<List<RunningEntry>> getAll() async {
    return await _db.select(_db.runningEntries).get();
  }

  /// 监听所有跑步记录（响应式）
  Stream<List<RunningEntry>> watchAll() {
    return _db.select(_db.runningEntries).watch();
  }

  /// 监听指定会话ID的跑步记录（响应式）
  Stream<List<RunningEntry>> watchBySessionId(int sessionId) {
    return (_db.select(
      _db.runningEntries,
    )..where((e) => e.sessionId.equals(sessionId))).watch();
  }

  /// 更新跑步记录
  Future<bool> updateRunningEntry(
    int id, {
    String? runType,
    double? distanceMeters,
    int? durationSeconds,
    int? avgPaceSeconds,
    int? bestPaceSeconds,
    int? avgHeartRate,
    int? maxHeartRate,
    int? avgCadence,
    int? maxCadence,
    double? elevationGain,
    double? elevationLoss,
    String? footwear,
    String? weatherJson,
  }) async {
    // 构建更新用的 companion，只设置非 null 的字段
    final companion = RunningEntriesCompanion(
      id: Value(id),
      runType: runType != null ? Value(runType) : const Value.absent(),
      distanceMeters: distanceMeters != null
          ? Value(distanceMeters)
          : const Value.absent(),
      durationSeconds: durationSeconds != null
          ? Value(durationSeconds)
          : const Value.absent(),
      avgPaceSeconds: avgPaceSeconds != null
          ? Value(avgPaceSeconds)
          : const Value.absent(),
      bestPaceSeconds: bestPaceSeconds != null
          ? Value(bestPaceSeconds)
          : const Value.absent(),
      avgHeartRate: avgHeartRate != null
          ? Value(avgHeartRate)
          : const Value.absent(),
      maxHeartRate: maxHeartRate != null
          ? Value(maxHeartRate)
          : const Value.absent(),
      avgCadence: avgCadence != null ? Value(avgCadence) : const Value.absent(),
      maxCadence: maxCadence != null ? Value(maxCadence) : const Value.absent(),
      elevationGain: elevationGain != null
          ? Value(elevationGain)
          : const Value.absent(),
      elevationLoss: elevationLoss != null
          ? Value(elevationLoss)
          : const Value.absent(),
      footwear: footwear != null ? Value(footwear) : const Value.absent(),
      weatherJson: weatherJson != null
          ? Value(weatherJson)
          : const Value.absent(),
    );

    final rowsAffected = await (_db.update(
      _db.runningEntries,
    )..where((r) => r.id.equals(id))).write(companion);
    return rowsAffected > 0;
  }

  /// 删除跑步记录（级联删除分段数据）
  Future<bool> deleteRunningEntry(int id) async {
    return await _db.transaction(() async {
      // 先删除关联的分段记录
      await (_db.delete(
        _db.runningSplits,
      )..where((s) => s.runningEntryId.equals(id))).go();

      // 然后删除主记录
      final deletedRows = await (_db.delete(
        _db.runningEntries,
      )..where((r) => r.id.equals(id))).go();

      return deletedRows > 0;
    });
  }

  /// 添加分段记录
  Future<int> addRunningSplit({
    required int runningEntryId,
    required int splitNumber,
    required double distanceMeters,
    required int durationSeconds,
    required int paceSeconds,
    int? avgHeartRate,
    int? cadence,
    double? elevationGain,
    bool isManual = false,
  }) async {
    return await _db
        .into(_db.runningSplits)
        .insert(
          RunningSplitsCompanion(
            runningEntryId: Value(runningEntryId),
            splitNumber: Value(splitNumber),
            distanceMeters: Value(distanceMeters),
            durationSeconds: Value(durationSeconds),
            paceSeconds: Value(paceSeconds),
            avgHeartRate: Value(avgHeartRate),
            cadence: Value(cadence),
            elevationGain: Value(elevationGain),
            isManual: Value(isManual),
          ),
        );
  }

  /// 获取分段记录
  Future<List<RunningSplit>> getSplits(int runningEntryId) async {
    return await (_db.select(_db.runningSplits)
          ..where((s) => s.runningEntryId.equals(runningEntryId))
          ..orderBy([(s) => OrderingTerm.asc(s.splitNumber)]))
        .get();
  }

  /// 监听分段记录（响应式）
  Stream<List<RunningSplit>> watchSplits(int runningEntryId) {
    return (_db.select(_db.runningSplits)
          ..where((s) => s.runningEntryId.equals(runningEntryId))
          ..orderBy([(s) => OrderingTerm.asc(s.splitNumber)]))
        .watch();
  }

  /// 删除分段记录
  Future<int> deleteRunningSplit(int id) async {
    return await (_db.delete(
      _db.runningSplits,
    )..where((s) => s.id.equals(id))).go();
  }

  /// 删除某次跑步记录的全部分段
  Future<int> deleteSplitsByEntryId(int runningEntryId) async {
    return await (_db.delete(
      _db.runningSplits,
    )..where((s) => s.runningEntryId.equals(runningEntryId))).go();
  }

  /// 获取周跑量
  Future<double> getWeeklyDistance(DateTime weekStart) async {
    final weekEnd = weekStart.add(const Duration(days: 7));
    final sessionIds =
        await (_db.select(_db.trainingSessions)
              ..where((t) => t.datetime.isBetweenValues(weekStart, weekEnd)))
            .map((t) => t.id)
            .get();
    final entries = await (_db.select(
      _db.runningEntries,
    )..where((r) => r.sessionId.isIn(sessionIds))).get();
    return entries.fold<double>(0, (sum, e) => sum + e.distanceMeters);
  }

  /// 获取月跑量
  Future<double> getMonthlyDistance(int year, int month) async {
    final monthStart = DateTime(year, month, 1);
    final nextMonthStart = DateTime(year, month + 1, 1);
    final sessionIds =
        await (_db.select(_db.trainingSessions)
              ..where(
                (t) =>
                    t.datetime.isBiggerOrEqualValue(monthStart) &
                    t.datetime.isSmallerThanValue(nextMonthStart),
              ))
            .map((t) => t.id)
            .get();
    final entries = await (_db.select(
      _db.runningEntries,
    )..where((r) => r.sessionId.isIn(sessionIds))).get();
    return entries.fold<double>(0, (sum, e) => sum + e.distanceMeters);
  }

  /// 计算配速（秒/公里）
  static int calculatePace(int durationSeconds, double distanceMeters) {
    if (distanceMeters <= 0) return 0;
    return ((durationSeconds / distanceMeters) * 1000).round();
  }

  /// 格式化配速为 mm:ss
  static String formatPace(int secondsPerKm) {
    final minutes = secondsPerKm ~/ 60;
    final seconds = secondsPerKm % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
