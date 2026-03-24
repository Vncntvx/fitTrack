import '../base/usecase.dart';
import '../../repositories/stats_repository.dart';
import 'stats_models.dart';

/// 获取总览统计 UseCase
/// 封装总览统计的业务逻辑，使用 Future.wait 并行执行查询
class GetOverviewStatsUseCase extends NoParamUseCase<OverviewStats> {
  final StatsRepository _statsRepo;

  GetOverviewStatsUseCase(this._statsRepo);

  @override
  Future<OverviewStats> call() async {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    // 顺序执行查询，避免在部分平台上并发读取导致状态长时间停留在 loading。
    final weeklyCount = await _statsRepo.countUniqueDaysThisWeek(weekStart);
    final weeklyMinutes = await _statsRepo.getWeeklyTotalMinutes(weekStart);
    final currentStreak = await _statsRepo.getCurrentStreak();
    final typeDistribution = await _statsRepo.getTypeDistribution();
    final recentSessions = await _statsRepo.getRecentSessions(limit: 5);

    return OverviewStats(
      weeklyCount: weeklyCount,
      weeklyMinutes: weeklyMinutes,
      currentStreak: currentStreak,
      typeDistribution: typeDistribution,
      recentSessions: recentSessions,
    );
  }
}
