import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// 单选选项数据
class SelectOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SelectOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// 单选选项组件 - 使用 SegmentedButton
/// 适用于 2-5 个短选项的单选场景
/// 自动适应宽度，避免丑陋的 3+1 换行问题
class SingleSelectSegmented<T> extends StatelessWidget {
  const SingleSelectSegmented({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.showIcons = false,
    this.enabled = true,
  });

  final List<SelectOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final bool showIcons;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: options.map((opt) {
        return ButtonSegment<T>(
          value: opt.value,
          label: Text(opt.label),
          icon: showIcons && opt.icon != null ? Icon(opt.icon, size: 18) : null,
        );
      }).toList(),
      selected: {selected},
      onSelectionChanged: enabled
          ? (Set<T> selection) {
              if (selection.isNotEmpty) {
                onChanged(selection.first);
              }
            }
          : null,
      showSelectedIcon: false,
      style: const ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// 单选网格 - 使用统一宽度的 ChoiceChip 排列成 2 列
/// 适用于 4-8 个选项的场景，避免 Wrap 导致的不均匀换行
class SingleSelectGrid<T> extends StatelessWidget {
  const SingleSelectGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.columns = 2,
    this.showIcons = true,
    this.enabled = true,
  });

  final List<SelectOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;
  final int columns;
  final bool showIcons;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 按列数分组
    final rows = <List<SelectOption<T>>>[];
    for (var i = 0; i < options.length; i += columns) {
      rows.add(options.skip(i).take(columns).toList());
    }

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: row != rows.last ? AppSpacing.sm : 0,
          ),
          child: Row(
            children: row.asMap().entries.map((entry) {
              final index = entry.key;
              final opt = entry.value;
              final isSelected = opt.value == selected;

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: index > 0 ? AppSpacing.sm : 0,
                  ),
                  child: _buildOptionTile(
                    context,
                    opt,
                    isSelected,
                    colorScheme,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    SelectOption<T> opt,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    return Material(
      color: isSelected
          ? colorScheme.secondaryContainer
          : colorScheme.surfaceContainerHighest,
      borderRadius: AppRadius.button,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? () => onChanged(opt.value) : null,
        borderRadius: AppRadius.button,
        child: Container(
          height: AppSize.touchTarget,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showIcons && opt.icon != null) ...[
                Icon(
                  opt.icon,
                  size: 18,
                  color: isSelected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  opt.label,
                  style: TextStyle(
                    color: isSelected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 快捷选项行 - 用于距离/时长快捷选择
/// 使用等宽按钮，不会产生换行问题
class QuickSelectRow<T> extends StatelessWidget {
  const QuickSelectRow({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
  });

  final List<SelectOption<T>> options;
  final T? selected;
  final ValueChanged<T> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final opt = entry.value;
        final isSelected = opt.value == selected;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: index > 0 ? AppSpacing.sm : 0,
            ),
            child: ActionChip(
              label: Text(
                opt.label,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              backgroundColor: isSelected
                  ? colorScheme.secondaryContainer
                  : colorScheme.surfaceContainerHighest,
              side: BorderSide.none,
              onPressed: enabled ? () => onChanged(opt.value) : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}
