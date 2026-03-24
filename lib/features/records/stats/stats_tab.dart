import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/usecase_providers.dart';
import '../../../core/usecases/stats/stats_models.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/charts/chart_colors.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/material3/m3_card.dart';
import '../../../shared/workout/workout_type_catalog.dart';

/// 统计 Tab
class StatsTab extends ConsumerWidget {
  const StatsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(overviewStatsProvider);

    return AsyncValueWidget(
      asyncValue: statsAsync,
      dataBuilder: (stats) => _buildStatsContent(context, stats),
    );
  }

  Widget _buildStatsContent(BuildContext context, OverviewStats stats) {
    if (stats.recentSessions.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.insights,
        message: '暂无统计数据',
        subtitle: '开始训练后这里会显示统计信息',
      );
    }

    return ListView(
      padding: AppSpacing.allLg,
      children: [
        // 核心统计卡片
        _buildSummaryRow(context, stats),
        const SizedBox(height: AppSpacing.md),

        // 连续训练天数
        _buildStreakCard(context, stats.currentStreak),
        const SizedBox(height: AppSpacing.md),

        // 训练类型分布
        _buildTypeDistributionCard(context, stats.typeDistribution),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, OverviewStats stats) {
    return Row(
      children: [
        Expanded(
          child: M3StatCard(
            title: '本周训练',
            value: '${stats.weeklyCount}',
            subtitle: '次',
            icon: Icons.fitness_center,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: M3StatCard(
            title: '本周时长',
            value: '${stats.weeklyMinutes}',
            subtitle: '分钟',
            icon: Icons.timer,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(BuildContext context, int streak) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: AppElevation.card,
      color: colorScheme.tertiaryContainer,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: AppSpacing.card,
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withOpacity(AppOpacity.subtle),
                borderRadius: AppRadius.circularMd,
              ),
              child: Icon(
                Icons.local_fire_department,
                size: AppSize.iconXl,
                color: colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '连续训练',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onTertiaryContainer
                          .withOpacity(AppOpacity.secondary),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$streak 天',
                    style: textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onTertiaryContainer,
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

  Widget _buildTypeDistributionCard(
    BuildContext context,
    Map<String, int> distribution,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: AppElevation.card,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: AppSpacing.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '训练类型分布',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...distribution.entries.map((entry) {
              final typeMeta = WorkoutTypeCatalog.of(entry.key);
              final color = ChartColors.getTrainingTypeColor(entry.key);
              final total = distribution.values.fold(0, (a, b) => a + b);
              final percentage =
                  total > 0 ? (entry.value / total * 100).toStringAsFixed(0) : '0';

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Icon(typeMeta.icon, size: AppSize.iconMd, color: color),
                    const SizedBox(width: AppSpacing.sm),
                    Text(typeMeta.label, style: textTheme.bodyMedium),
                    const Spacer(),
                    Container(
                      width: 100,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: AppRadius.circularXs,
                      ),
                      child: FractionallySizedBox(
                        widthFactor: total > 0 ? entry.value / total : 0,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: AppRadius.circularXs,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '$percentage%',
                        textAlign: TextAlign.end,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
