import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/router/routes/routes.dart';
import '../../core/providers/usecase_providers.dart';
import '../../core/usecases/stats/stats_models.dart';
import '../../core/usecases/today/get_today_dashboard_usecase.dart';
import '../../shared/layout/app_responsive.dart';
import '../../shared/workout/workout_type_catalog.dart';
import '../../shared/widgets/async_value_widget.dart';
import '../../shared/widgets/material3/m3_card.dart';

/// 今日页面
/// 行动型首页，显示今日概览、目标进度和快速操作
class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTime.now();
    final referenceDate = DateTime(today.year, today.month, today.day);
    final layout = AppResponsive.of(context);
    final dashboardQuery = todayDashboardProvider(
      referenceDate: referenceDate,
      recentLimit: 3,
    );
    final dashboardAsync = ref.watch(dashboardQuery);

    return Scaffold(
      appBar: AppBar(
        title: _buildAppBarTitle(referenceDate),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardQuery);
        },
        child: AsyncValueWidget<TodayDashboardData>(
          asyncValue: dashboardAsync,
          retryAction: () => ref.invalidate(dashboardQuery),
          dataBuilder: (dashboard) => ListView(
            padding: EdgeInsets.all(layout.pagePadding),
            children: [
              // 今日状态卡片
              _buildTodayStatus(context, dashboard.hasSessionToday),
              SizedBox(height: layout.cardSpacing),

              // 本周目标进度
              _buildWeeklyProgress(context, dashboard),
              SizedBox(height: layout.cardSpacing),

              // 快速开始
              _buildQuickStart(context),
              SizedBox(height: layout.cardSpacing),

              // 最近记录
              _buildRecentSessions(context, dashboard.recentSessions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBarTitle(DateTime date) {
    final weekdayFormat = DateFormat('EEEE', 'zh_CN');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('今日'),
        Text(
          weekdayFormat.format(date),
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
        ),
      ],
    );
  }

  /// 今日状态卡片
  Widget _buildTodayStatus(BuildContext context, bool hasSessionToday) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: hasSessionToday
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasSessionToday
                    ? colorScheme.primary.withValues(alpha: 0.2)
                    : colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasSessionToday ? Icons.check_circle : Icons.circle_outlined,
                size: 28,
                color: hasSessionToday
                    ? colorScheme.primary
                    : colorScheme.outline,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasSessionToday ? '今日已完成' : '今日未记录',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: hasSessionToday
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    hasSessionToday ? '继续保持，加油！' : '点击下方开始今天的训练',
                    style: TextStyle(
                      fontSize: 14,
                      color: hasSessionToday
                          ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 本周目标进度
  Widget _buildWeeklyProgress(BuildContext context, TodayDashboardData dashboard) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '本周目标',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildProgressRing(
                    context,
                    label: '运动天数',
                    current: dashboard.daysCount,
                    goal: dashboard.daysGoal,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildProgressRing(
                    context,
                    label: '运动时长',
                    current: dashboard.minutesCount,
                    goal: dashboard.minutesGoal,
                    unit: '分钟',
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressRing(
    BuildContext context, {
    required String label,
    required int current,
    required int goal,
    String unit = '',
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = goal > 0 ? (current / goal).clamp(0.0, 1.0) : 0.0;

    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation(color),
                  strokeCap: StrokeCap.round,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(progress * 100).round()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          '$current/$goal$unit',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.outline,
          ),
        ),
      ],
    );
  }

  /// 快速开始
  Widget _buildQuickStart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final types = [
      ('strength', '力量训练', Icons.fitness_center),
      ('running', '跑步', Icons.directions_run),
      ('swimming', '游泳', Icons.pool),
      ('quick', '快速记录', Icons.flash_on),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        M3SectionHeader(
          title: '快速开始',
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        Row(
          children: types.map((item) {
            final typeMeta = WorkoutTypeCatalog.of(item.$1);
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  final route = item.$1 == 'quick'
                      ? TrainRoutes.quick
                      : '/train/${item.$1}/new';
                  context.push(route);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: typeMeta.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Icon(item.$3, color: typeMeta.color, size: 24),
                      const SizedBox(height: 4),
                      Text(
                        item.$2,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 最近记录
  Widget _buildRecentSessions(BuildContext context, List<RecentSession> recentSessions) {
    final colorScheme = Theme.of(context).colorScheme;

    if (recentSessions.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: colorScheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: colorScheme.outline,
              ),
              const SizedBox(height: 12),
              Text(
                '暂无训练记录',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        M3SectionHeader(
          title: '最近记录',
          padding: EdgeInsets.zero,
          action: TextButton(
            onPressed: () => context.push(NavRoutes.records),
            child: const Text('查看全部'),
          ),
        ),
        const SizedBox(height: 8),
        ...recentSessions.map((session) => _buildSessionItem(context, session)),
      ],
    );
  }

  Widget _buildSessionItem(BuildContext context, RecentSession session) {
    final dateFormat = DateFormat('MM-dd HH:mm');
    final typeMeta = WorkoutTypeCatalog.of(session.type);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: typeMeta.color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(typeMeta.icon, color: typeMeta.color, size: 20),
        ),
        title: Text(typeMeta.label),
        subtitle: Text(dateFormat.format(session.datetime)),
        trailing: Text(
          '${session.durationMinutes}分钟',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.outline,
          ),
        ),
        onTap: () {
          context.push(RecordsRoutes.session(session.id));
        },
      ),
    );
  }
}
