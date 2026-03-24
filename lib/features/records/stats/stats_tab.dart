import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/usecase_providers.dart';
import '../../../core/usecases/stats/stats_models.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/material3/m3_card.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/workout/workout_type_catalog.dart';
import '../../../shared/widgets/charts/chart_colors.dart';

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
      padding: const EdgeInsets.all(16),
      children: [
        // 核心统计卡片
        _buildSummaryRow(context, stats),
        const SizedBox(height: 16),

        // 连续训练天数
        _buildStreakCard(context, stats.currentStreak),
        const SizedBox(height: 16),

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
        const SizedBox(width: 12),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.tertiaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.tertiary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_fire_department,
                size: 32,
                color: colorScheme.tertiary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '连续训练',
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onTertiaryContainer.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$streak 天',
                    style: TextStyle(
                      fontSize: 28,
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
              '训练类型分布',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...distribution.entries.map((entry) {
              final typeMeta = WorkoutTypeCatalog.of(entry.key);
              final color = ChartColors.getTrainingTypeColor(entry.key);
              final total = distribution.values.fold(0, (a, b) => a + b);
              final percentage = total > 0 ? (entry.value / total * 100).toStringAsFixed(0) : '0';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(typeMeta.icon, size: 20, color: color),
                    const SizedBox(width: 8),
                    Text(typeMeta.label),
                    const Spacer(),
                    Container(
                      width: 100,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: total > 0 ? entry.value / total : 0,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 48,
                      child: Text(
                        '$percentage%',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: 12,
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
