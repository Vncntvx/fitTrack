// 统计模块数据模型
// 用于封装各类统计查询结果

/// 周距离数据
class WeeklyDistance {
  final String label;
  final double distance;

  const WeeklyDistance({
    required this.label,
    required this.distance,
  });
}

/// 配速数据
class PaceData {
  final String label;
  final int paceSeconds;

  const PaceData({
    required this.label,
    required this.paceSeconds,
  });
}

/// 最近训练会话
class RecentSession {
  final int id;
  final String type;
  final int durationMinutes;
  final DateTime datetime;

  const RecentSession({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.datetime,
  });
}

/// 总览统计结果
class OverviewStats {
  final int weeklyCount;
  final int weeklyMinutes;
  final int currentStreak;
  final Map<String, int> typeDistribution;
  final List<RecentSession> recentSessions;

  const OverviewStats({
    required this.weeklyCount,
    required this.weeklyMinutes,
    required this.currentStreak,
    required this.typeDistribution,
    required this.recentSessions,
  });
}

/// 跑步统计结果
class RunningStats {
  final double weeklyDistance;
  final double monthlyDistance;
  final List<WeeklyDistance> weeklyTrend;
  final Map<String, int> runTypeDistribution;
  final Map<String, int> paceDistribution;

  const RunningStats({
    required this.weeklyDistance,
    required this.monthlyDistance,
    required this.weeklyTrend,
    required this.runTypeDistribution,
    required this.paceDistribution,
  });
}

/// 游泳统计结果
class SwimmingStats {
  final double weeklyDistance;
  final double monthlyDistance;
  final List<WeeklyDistance> weeklyTrend;
  final Map<String, int> strokeDistribution;
  final List<PaceData> recentPaceData;

  const SwimmingStats({
    required this.weeklyDistance,
    required this.monthlyDistance,
    required this.weeklyTrend,
    required this.strokeDistribution,
    required this.recentPaceData,
  });
}