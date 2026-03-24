import '../base/usecase.dart';
import '../../repositories/stats_repository.dart';
import 'stats_models.dart';

/// 获取游泳统计 UseCase
/// 封装游泳统计的业务逻辑
class GetSwimmingStatsUseCase extends NoParamUseCase<SwimmingStats> {
  final StatsRepository _statsRepo;

  GetSwimmingStatsUseCase(this._statsRepo);

  @override
  Future<SwimmingStats> call() async {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final weeklyDistance = await _statsRepo.getWeeklySwimmingDistance(
      weekStart,
    );
    final monthlyDistance = await _statsRepo.getMonthlySwimmingDistance(
      now.year,
      now.month,
    );
    final weeklyTrend = await _statsRepo.getWeeklySwimmingTrend();
    final strokeDistribution = await _statsRepo.getStrokeDistribution();
    final recentPaceData = await _statsRepo.getRecentSwimmingPace(limit: 7);

    return SwimmingStats(
      weeklyDistance: weeklyDistance,
      monthlyDistance: monthlyDistance,
      weeklyTrend: weeklyTrend,
      strokeDistribution: strokeDistribution,
      recentPaceData: recentPaceData,
    );
  }
}
