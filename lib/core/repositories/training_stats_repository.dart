import 'package:drift/drift.dart';

import '../database/database.dart';

/// 训练统计查询仓库
/// 聚合训练会话的统计指标查询逻辑
class TrainingStatsRepository {
  TrainingStatsRepository(this._db);

  final AppDatabase _db;

  /// 获取本周运动天数
  Future<int> countThisWeek() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final weekEndDate = weekStartDate.add(const Duration(days: 7));

    final result = await _db
        .customSelect(
          "SELECT COUNT(DISTINCT date(datetime, 'unixepoch', 'localtime')) AS day_count "
          'FROM training_sessions '
          'WHERE datetime >= ? AND datetime < ?',
          variables: [
            Variable.withDateTime(weekStartDate),
            Variable.withDateTime(weekEndDate),
          ],
          readsFrom: {_db.trainingSessions},
        )
        .getSingle();

    return result.read<int>('day_count');
  }

  /// 获取本周总时长（分钟）
  Future<int> totalMinutesThisWeek() async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );
    final weekEndDate = weekStartDate.add(const Duration(days: 7));

    final query = _db.selectOnly(_db.trainingSessions)
      ..addColumns([_db.trainingSessions.durationMinutes.sum()])
      ..where(
        _db.trainingSessions.datetime.isBetweenValues(
          weekStartDate,
          weekEndDate,
        ),
      );

    final result = await query.getSingle();
    return result.read(_db.trainingSessions.durationMinutes.sum()) ?? 0;
  }

  /// 获取当前连续天数（streak）
  /// 优化：只查询最近 60 天的数据，避免加载全部记录
  Future<int> currentStreak() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // 只查询最近 60 天的数据（连续天数不太可能超过 60）
    final recentDate = todayDate.subtract(const Duration(days: 60));

    final records =
        await (_db.select(_db.trainingSessions)
              ..where((w) => w.datetime.isBiggerOrEqualValue(recentDate))
              ..orderBy([(w) => OrderingTerm.desc(w.datetime)]))
            .get();

    if (records.isEmpty) return 0;

    // 提取唯一日期（使用 Set 去重）
    final uniqueDays = records.map((w) {
      final dt = w.datetime;
      return DateTime(dt.year, dt.month, dt.day);
    }).toSet();

    // 计算连续天数
    int streak = 0;
    DateTime checkDate = todayDate;

    // 如果今天没有训练，从昨天开始检查
    if (!uniqueDays.contains(checkDate)) {
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    while (uniqueDays.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// 获取最常做的运动类型
  /// 优化：使用 SQL GROUP BY 聚合，避免加载全部数据到内存
  Future<String?> mostFrequentType() async {
    // 使用 SQL GROUP BY 聚合，避免加载全部数据
    final query = _db.selectOnly(_db.trainingSessions)
      ..addColumns([_db.trainingSessions.type, _db.trainingSessions.id.count()])
      ..groupBy([_db.trainingSessions.type])
      ..orderBy([OrderingTerm.desc(_db.trainingSessions.id.count())])
      ..limit(1);

    final result = await query.getSingleOrNull();
    return result?.read(_db.trainingSessions.type);
  }
}
