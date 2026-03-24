import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_database_provider.dart';
import '../../../core/database/database.dart';
import '../../../shared/widgets/async_value_widget.dart';

/// 目标设置页面
class GoalsPage extends ConsumerWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('训练目标'),
      ),
      body: AsyncValueWidget(
        asyncValue: settingsAsync,
        dataBuilder: (settings) => settings != null
            ? _buildContent(context, ref, settings)
            : const Center(child: Text('无法加载设置')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, UserSetting settings) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 每周运动天数
        _buildGoalCard(
          context,
          ref,
          title: '每周运动天数',
          currentValue: settings.weeklyWorkoutDaysGoal,
          minValue: 1,
          maxValue: 7,
          unit: '天',
          icon: Icons.calendar_today,
          onChanged: (value) async {
            final repo = ref.read(settingsRepositoryProvider);
            await repo.updateWeeklyDaysGoal(value);
          },
        ),
        const SizedBox(height: 16),

        // 每周运动时长
        _buildGoalCard(
          context,
          ref,
          title: '每周运动时长',
          currentValue: settings.weeklyWorkoutMinutesGoal,
          minValue: 30,
          maxValue: 600,
          unit: '分钟',
          icon: Icons.timer,
          divisions: 19,
          onChanged: (value) async {
            final repo = ref.read(settingsRepositoryProvider);
            await repo.updateWeeklyMinutesGoal(value);
          },
        ),
      ],
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required int currentValue,
    required int minValue,
    required int maxValue,
    required String unit,
    required IconData icon,
    int? divisions,
    required ValueChanged<int> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Center(
              child: Text(
                '$currentValue $unit',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Slider(
              value: currentValue.toDouble(),
              min: minValue.toDouble(),
              max: maxValue.toDouble(),
              divisions: divisions ?? (maxValue - minValue),
              onChanged: (value) => onChanged(value.round()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$minValue $unit',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.outline,
                    ),
                  ),
                  Text(
                    '$maxValue $unit',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.outline,
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
}
