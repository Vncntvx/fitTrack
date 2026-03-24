import '../base/usecase.dart';
import '../stats/stats_models.dart';
import '../../repositories/settings_repository.dart';
import '../../repositories/stats_repository.dart';
import '../../repositories/training_repository.dart';

/// 今日概览查询参数
class GetTodayDashboardParams {
  const GetTodayDashboardParams({
    required this.referenceDate,
    this.recentLimit = 3,
  });

  final DateTime referenceDate;
  final int recentLimit;
}

/// 今日概览数据
class TodayDashboardData {
  const TodayDashboardData({
    required this.hasSessionToday,
    required this.daysCount,
    required this.minutesCount,
    required this.daysGoal,
    required this.minutesGoal,
    required this.recentSessions,
  });

  final bool hasSessionToday;
  final int daysCount;
  final int minutesCount;
  final int daysGoal;
  final int minutesGoal;
  final List<RecentSession> recentSessions;
}

/// 今日页聚合查询 Use Case
/// 统一协调今日状态、本周目标与最近记录，避免 UI 直接拼装仓库查询。
class GetTodayDashboardUseCase
    extends UseCase<TodayDashboardData, GetTodayDashboardParams> {
  GetTodayDashboardUseCase(
    this._trainingRepository,
    this._statsRepository,
    this._settingsRepository,
  );

  final TrainingRepository _trainingRepository;
  final StatsRepository _statsRepository;
  final SettingsRepository _settingsRepository;

  @override
  Future<TodayDashboardData> call(GetTodayDashboardParams params) async {
    final referenceDate = DateTime(
      params.referenceDate.year,
      params.referenceDate.month,
      params.referenceDate.day,
    );
    final nextDate = referenceDate.add(const Duration(days: 1));
    final weekStart = referenceDate.subtract(
      Duration(days: referenceDate.weekday - 1),
    );
    final todaySessions = await _trainingRepository.getByDateRange(
      referenceDate,
      nextDate,
    );
    final daysCount = await _statsRepository.countUniqueDaysThisWeek(weekStart);
    final minutesCount = await _statsRepository.getWeeklyTotalMinutes(
      weekStart,
    );
    final daysGoal = await _settingsRepository.getWeeklyDaysGoal();
    final minutesGoal = await _settingsRepository.getWeeklyMinutesGoal();
    final recentSessions = await _statsRepository.getRecentSessions(
      limit: params.recentLimit,
    );

    return TodayDashboardData(
      hasSessionToday: todaySessions.isNotEmpty,
      daysCount: daysCount,
      minutesCount: minutesCount,
      daysGoal: daysGoal,
      minutesGoal: minutesGoal,
      recentSessions: recentSessions,
    );
  }
}
