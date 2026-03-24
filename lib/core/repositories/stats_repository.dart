import 'package:drift/drift.dart';

import '../database/database.dart';
import '../usecases/stats/stats_models.dart';

/// 统计查询仓库
/// 使用 SQL 聚合函数进行高效统计计算
class StatsRepository {
  final AppDatabase _db;

  StatsRepository(this._db);

  // ==================== 总览统计 ====================

  /// 获取本周训练天数（使用 SQL COUNT DISTINCT）
  Future<int> countUniqueDaysThisWeek(DateTime weekStart) async {
    final normalizedWeekStart = _startOfDay(weekStart);
    final weekEnd = normalizedWeekStart.add(const Duration(days: 7));

    // 使用 SQL 聚合：COUNT(DISTINCT date)
    final query = _db.customSelect(
      "SELECT COUNT(DISTINCT date(datetime, 'unixepoch', 'localtime')) as count "
      'FROM training_sessions '
      'WHERE datetime >= ? AND datetime < ?',
      variables: [
        Variable.withDateTime(normalizedWeekStart),
        Variable.withDateTime(weekEnd),
      ],
      readsFrom: {_db.trainingSessions},
    );

    final result = await query.getSingle();
    return result.read<int>('count');
  }

  /// 获取本周总训练时长（使用 SQL SUM）
  Future<int> getWeeklyTotalMinutes(DateTime weekStart) async {
    final normalizedWeekStart = _startOfDay(weekStart);
    final weekEnd = normalizedWeekStart.add(const Duration(days: 7));

    final query = _db.selectOnly(_db.trainingSessions)
      ..addColumns([_db.trainingSessions.durationMinutes.sum()])
      ..where(
        _db.trainingSessions.datetime.isBiggerOrEqualValue(
              normalizedWeekStart,
            ) &
            _db.trainingSessions.datetime.isSmallerThanValue(weekEnd),
      );

    final result = await query.getSingle();
    return result.read(_db.trainingSessions.durationMinutes.sum()) ?? 0;
  }

  /// 获取当前连续训练天数
  /// 算法：从今天开始向前检查连续的训练日期
  Future<int> getCurrentStreak() async {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // 只查询最近 60 天的数据（连续天数不太可能超过 60）
    final recentDate = todayDate.subtract(const Duration(days: 60));

    // 使用 SQL 获取去重的日期列表
    final query = _db.customSelect(
      "SELECT DISTINCT date(datetime, 'unixepoch', 'localtime') as training_date "
      'FROM training_sessions '
      'WHERE datetime >= ? '
      'ORDER BY training_date DESC',
      variables: [Variable.withDateTime(recentDate)],
      readsFrom: {_db.trainingSessions},
    );

    final results = await query.get();
    if (results.isEmpty) return 0;

    // 解析日期并计算连续天数
    final uniqueDays = results
        .map((row) => row.read<String>('training_date'))
        .toSet();

    int streak = 0;
    String checkDate = _formatDate(todayDate);

    // 如果今天没有训练，从昨天开始检查
    if (!uniqueDays.contains(checkDate)) {
      final yesterday = todayDate.subtract(const Duration(days: 1));
      checkDate = _formatDate(yesterday);
    }

    while (uniqueDays.contains(checkDate)) {
      streak++;
      final nextDate = DateTime.parse(
        checkDate,
      ).subtract(const Duration(days: 1));
      checkDate = _formatDate(nextDate);
    }

    return streak;
  }

  /// 获取训练类型分布（使用 SQL GROUP BY）
  Future<Map<String, int>> getTypeDistribution() async {
    final query = _db.selectOnly(_db.trainingSessions)
      ..addColumns([_db.trainingSessions.type, _db.trainingSessions.id.count()])
      ..groupBy([_db.trainingSessions.type])
      ..orderBy([OrderingTerm.desc(_db.trainingSessions.id.count())]);

    final results = await query.get();
    return {
      for (final row in results)
        row.read(_db.trainingSessions.type)!: row.read(
          _db.trainingSessions.id.count(),
        )!,
    };
  }

  /// 获取最近训练会话
  Future<List<RecentSession>> getRecentSessions({int limit = 5}) async {
    final query = _db.select(_db.trainingSessions)
      ..orderBy([(t) => OrderingTerm.desc(t.datetime)])
      ..limit(limit);

    final results = await query.get();
    return results
        .map(
          (s) => RecentSession(
            id: s.id,
            type: s.type,
            durationMinutes: s.durationMinutes,
            datetime: s.datetime,
          ),
        )
        .toList();
  }

  // ==================== 跑步统计 ====================

  /// 获取周跑量（使用 SQL JOIN + SUM）
  Future<double> getWeeklyRunningDistance(DateTime weekStart) async {
    final normalizedWeekStart = _startOfDay(weekStart);
    final weekEnd = normalizedWeekStart.add(const Duration(days: 7));

    // 使用 JOIN 查询并聚合
    final query = _db.selectOnly(_db.runningEntries)
      ..join([
        innerJoin(
          _db.trainingSessions,
          _db.trainingSessions.id.equalsExp(_db.runningEntries.sessionId),
        ),
      ])
      ..addColumns([_db.runningEntries.distanceMeters.sum()])
      ..where(
        _db.trainingSessions.datetime.isBiggerOrEqualValue(
              normalizedWeekStart,
            ) &
            _db.trainingSessions.datetime.isSmallerThanValue(weekEnd),
      );

    final result = await query.getSingle();
    return result.read(_db.runningEntries.distanceMeters.sum()) ?? 0.0;
  }

  /// 获取月跑量（使用 SQL JOIN + SUM）
  Future<double> getMonthlyRunningDistance(int year, int month) async {
    final monthStart = DateTime(year, month, 1);
    final nextMonthStart = DateTime(year, month + 1, 1);

    final query = _db.selectOnly(_db.runningEntries)
      ..join([
        innerJoin(
          _db.trainingSessions,
          _db.trainingSessions.id.equalsExp(_db.runningEntries.sessionId),
        ),
      ])
      ..addColumns([_db.runningEntries.distanceMeters.sum()])
      ..where(
        _db.trainingSessions.datetime.isBiggerOrEqualValue(monthStart) &
            _db.trainingSessions.datetime.isSmallerThanValue(nextMonthStart),
      );

    final result = await query.getSingle();
    return result.read(_db.runningEntries.distanceMeters.sum()) ?? 0.0;
  }

  /// 获取周跑量趋势（最近 4 周）
  Future<List<WeeklyDistance>> getWeeklyRunningTrend() async {
    final now = DateTime.now();
    final currentWeekStart = _startOfWeek(now);
    final weekStarts = _buildRecentWeekStarts(currentWeekStart);
    final weekEnds = weekStarts
        .map((weekStart) => weekStart.add(const Duration(days: 7)))
        .toList();

    final query = _db.customSelect(
      '''
      SELECT
        CASE
          WHEN ts.datetime >= ? AND ts.datetime < ? THEN 0
          WHEN ts.datetime >= ? AND ts.datetime < ? THEN 1
          WHEN ts.datetime >= ? AND ts.datetime < ? THEN 2
          WHEN ts.datetime >= ? AND ts.datetime < ? THEN 3
        END AS week_index,
        SUM(re.distance_meters) AS total_distance
      FROM running_entries re
      INNER JOIN training_sessions ts ON ts.id = re.session_id
      WHERE ts.datetime >= ? AND ts.datetime < ?
      GROUP BY week_index
      ORDER BY week_index
      ''',
      variables: [
        for (int i = 0; i < weekStarts.length; i++) ...[
          Variable.withDateTime(weekStarts[i]),
          Variable.withDateTime(weekEnds[i]),
        ],
        Variable.withDateTime(weekStarts.first),
        Variable.withDateTime(weekEnds.last),
      ],
      readsFrom: {_db.runningEntries, _db.trainingSessions},
    );

    final rows = await query.get();
    final distanceByWeek = <int, double>{
      for (final row in rows)
        row.read<int>('week_index'): row.read<double>('total_distance'),
    };

    return List<WeeklyDistance>.generate(
      4,
      (index) => WeeklyDistance(
        label: '第${index + 1}周',
        distance: (distanceByWeek[index] ?? 0.0) / 1000, // 转换为公里
      ),
    );
  }

  /// 获取跑步类型分布（使用 SQL GROUP BY）
  Future<Map<String, int>> getRunTypeDistribution() async {
    final query = _db.selectOnly(_db.runningEntries)
      ..addColumns([_db.runningEntries.runType, _db.runningEntries.id.count()])
      ..groupBy([_db.runningEntries.runType])
      ..orderBy([OrderingTerm.desc(_db.runningEntries.id.count())]);

    final results = await query.get();
    return {
      for (final row in results)
        row.read(_db.runningEntries.runType)!: row.read(
          _db.runningEntries.id.count(),
        )!,
    };
  }

  /// 获取配速分布（使用 SQL 聚合）
  Future<Map<String, int>> getPaceDistribution() async {
    // 先获取配速数据
    final query = _db.selectOnly(_db.runningEntries)
      ..addColumns([
        _db.runningEntries.avgPaceSeconds,
        _db.runningEntries.id.count(),
      ])
      ..groupBy([_db.runningEntries.avgPaceSeconds]);

    final results = await query.get();

    // 初始化分布区间
    final distribution = <String, int>{
      '< 5:00': 0,
      '5:00-6:00': 0,
      '6:00-7:00': 0,
      '7:00-8:00': 0,
      '> 8:00': 0,
    };

    // 将配速分配到区间
    for (final row in results) {
      final pace = row.read(_db.runningEntries.avgPaceSeconds) ?? 0;
      final count = row.read(_db.runningEntries.id.count()) ?? 0;
      final paceMin = pace / 60;

      if (paceMin < 5) {
        distribution['< 5:00'] = distribution['< 5:00']! + count;
      } else if (paceMin < 6) {
        distribution['5:00-6:00'] = distribution['5:00-6:00']! + count;
      } else if (paceMin < 7) {
        distribution['6:00-7:00'] = distribution['6:00-7:00']! + count;
      } else if (paceMin < 8) {
        distribution['7:00-8:00'] = distribution['7:00-8:00']! + count;
      } else {
        distribution['> 8:00'] = distribution['> 8:00']! + count;
      }
    }

    return distribution;
  }

  // ==================== 游泳统计 ====================

  /// 获取周游量（使用 SQL JOIN + SUM）
  Future<double> getWeeklySwimmingDistance(DateTime weekStart) async {
    final normalizedWeekStart = _startOfDay(weekStart);
    final weekEnd = normalizedWeekStart.add(const Duration(days: 7));

    final query = _db.selectOnly(_db.swimmingEntries)
      ..join([
        innerJoin(
          _db.trainingSessions,
          _db.trainingSessions.id.equalsExp(_db.swimmingEntries.sessionId),
        ),
      ])
      ..addColumns([_db.swimmingEntries.distanceMeters.sum()])
      ..where(
        _db.trainingSessions.datetime.isBiggerOrEqualValue(
              normalizedWeekStart,
            ) &
            _db.trainingSessions.datetime.isSmallerThanValue(weekEnd),
      );

    final result = await query.getSingle();
    return result.read(_db.swimmingEntries.distanceMeters.sum()) ?? 0.0;
  }

  /// 获取月游量（使用 SQL JOIN + SUM）
  Future<double> getMonthlySwimmingDistance(int year, int month) async {
    final monthStart = DateTime(year, month, 1);
    final nextMonthStart = DateTime(year, month + 1, 1);

    final query = _db.selectOnly(_db.swimmingEntries)
      ..join([
        innerJoin(
          _db.trainingSessions,
          _db.trainingSessions.id.equalsExp(_db.swimmingEntries.sessionId),
        ),
      ])
      ..addColumns([_db.swimmingEntries.distanceMeters.sum()])
      ..where(
        _db.trainingSessions.datetime.isBiggerOrEqualValue(monthStart) &
            _db.trainingSessions.datetime.isSmallerThanValue(nextMonthStart),
      );

    final result = await query.getSingle();
    return result.read(_db.swimmingEntries.distanceMeters.sum()) ?? 0.0;
  }

  /// 获取周游量趋势（最近 4 周）
  Future<List<WeeklyDistance>> getWeeklySwimmingTrend() async {
    final now = DateTime.now();
    final currentWeekStart = _startOfWeek(now);
    final weekStarts = _buildRecentWeekStarts(currentWeekStart);
    final weekEnds = weekStarts
        .map((weekStart) => weekStart.add(const Duration(days: 7)))
        .toList();

    final query = _db.customSelect(
      '''
      SELECT
        CASE
          WHEN ts.datetime >= ? AND ts.datetime < ? THEN 0
          WHEN ts.datetime >= ? AND ts.datetime < ? THEN 1
          WHEN ts.datetime >= ? AND ts.datetime < ? THEN 2
          WHEN ts.datetime >= ? AND ts.datetime < ? THEN 3
        END AS week_index,
        SUM(se.distance_meters) AS total_distance
      FROM swimming_entries se
      INNER JOIN training_sessions ts ON ts.id = se.session_id
      WHERE ts.datetime >= ? AND ts.datetime < ?
      GROUP BY week_index
      ORDER BY week_index
      ''',
      variables: [
        for (int i = 0; i < weekStarts.length; i++) ...[
          Variable.withDateTime(weekStarts[i]),
          Variable.withDateTime(weekEnds[i]),
        ],
        Variable.withDateTime(weekStarts.first),
        Variable.withDateTime(weekEnds.last),
      ],
      readsFrom: {_db.swimmingEntries, _db.trainingSessions},
    );

    final rows = await query.get();
    final distanceByWeek = <int, double>{
      for (final row in rows)
        row.read<int>('week_index'): row.read<double>('total_distance'),
    };

    return List<WeeklyDistance>.generate(
      4,
      (index) => WeeklyDistance(
        label: '第${index + 1}周',
        distance: distanceByWeek[index] ?? 0.0,
      ),
    );
  }

  /// 获取泳姿分布（使用 SQL GROUP BY）
  Future<Map<String, int>> getStrokeDistribution() async {
    final query = _db.selectOnly(_db.swimmingEntries)
      ..addColumns([
        _db.swimmingEntries.primaryStroke,
        _db.swimmingEntries.id.count(),
      ])
      ..groupBy([_db.swimmingEntries.primaryStroke])
      ..orderBy([OrderingTerm.desc(_db.swimmingEntries.id.count())]);

    final results = await query.get();
    return {
      for (final row in results)
        row.read(_db.swimmingEntries.primaryStroke)!: row.read(
          _db.swimmingEntries.id.count(),
        )!,
    };
  }

  /// 获取近期配速数据
  Future<List<PaceData>> getRecentSwimmingPace({int limit = 7}) async {
    // 使用 JOIN 按时间排序
    final query = _db.selectOnly(_db.swimmingEntries)
      ..join([
        innerJoin(
          _db.trainingSessions,
          _db.trainingSessions.id.equalsExp(_db.swimmingEntries.sessionId),
        ),
      ])
      ..addColumns([
        _db.swimmingEntries.pacePer100m,
        _db.trainingSessions.datetime,
      ])
      ..orderBy([OrderingTerm.desc(_db.trainingSessions.datetime)])
      ..limit(limit);

    final results = await query.get();
    return results.asMap().entries.map((e) {
      return PaceData(
        label: '#${e.key + 1}',
        paceSeconds: e.value.read(_db.swimmingEntries.pacePer100m) ?? 0,
      );
    }).toList();
  }

  // ==================== 工具方法 ====================

  /// 格式化日期为 YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  DateTime _startOfWeek(DateTime date) {
    final day = _startOfDay(date);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  DateTime _startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  List<DateTime> _buildRecentWeekStarts(DateTime currentWeekStart) {
    return List<DateTime>.generate(
      4,
      (index) => currentWeekStart.subtract(Duration(days: (3 - index) * 7)),
    );
  }
}
