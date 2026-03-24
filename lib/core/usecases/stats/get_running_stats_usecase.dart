import '../base/usecase.dart';
import '../../repositories/stats_repository.dart';
import 'stats_models.dart';

/// 获取跑步统计 UseCase
/// 封装跑步统计的业务逻辑
class GetRunningStatsUseCase extends NoParamUseCase<RunningStats> {
  final StatsRepository _statsRepo;

  GetRunningStatsUseCase(this._statsRepo);

  @override
  Future<RunningStats> call() async {
    final now = DateTime.now();
    final weekStart = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final weeklyDistance = await _statsRepo.getWeeklyRunningDistance(weekStart);
    final monthlyDistance = await _statsRepo.getMonthlyRunningDistance(
      now.year,
      now.month,
    );
    final weeklyTrend = await _statsRepo.getWeeklyRunningTrend();
    final runTypeDistribution = await _statsRepo.getRunTypeDistribution();
    final paceDistribution = await _statsRepo.getPaceDistribution();

    return RunningStats(
      weeklyDistance: weeklyDistance,
      monthlyDistance: monthlyDistance,
      weeklyTrend: weeklyTrend,
      runTypeDistribution: runTypeDistribution,
      paceDistribution: paceDistribution,
    );
  }
}
