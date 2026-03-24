import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_database_provider.dart';
import '../../../core/database/database.dart';
import '../../../shared/widgets/async_value_widget.dart';

/// 偏好设置页面
class PreferencesPage extends ConsumerWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('单位设置'),
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
      children: [
        // 重量单位
        _buildUnitSection(
          context,
          ref,
          title: '重量单位',
          currentValue: settings.weightUnit,
          options: const [
            ('kg', '千克'),
            ('lbs', '磅'),
          ],
          onChanged: (value) async {
            final repo = ref.read(settingsRepositoryProvider);
            await repo.updateWeightUnit(value);
          },
        ),

        // 距离单位
        _buildUnitSection(
          context,
          ref,
          title: '距离单位',
          currentValue: settings.distanceUnit,
          options: const [
            ('km', '公里'),
            ('mi', '英里'),
          ],
          onChanged: (value) async {
            final repo = ref.read(settingsRepositoryProvider);
            await repo.updateDistanceUnit(value);
          },
        ),
      ],
    );
  }

  Widget _buildUnitSection(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String currentValue,
    required List<(String, String)> options,
    required ValueChanged<String> onChanged,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.outline,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          elevation: 0,
          color: colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: options.map((option) {
              final isSelected = option.$1 == currentValue;
              return RadioListTile<String>(
                title: Text(option.$2),
                value: option.$1,
                groupValue: currentValue,
                onChanged: (value) {
                  if (value != null) onChanged(value);
                },
                secondary: isSelected
                    ? Icon(Icons.check, color: colorScheme.primary)
                    : null,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
