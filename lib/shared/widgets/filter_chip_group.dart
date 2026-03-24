import 'package:flutter/material.dart';

/// 筛选选项
class FilterOption<T> {
  const FilterOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

/// 筛选 Chip 组
/// Material 3 风格的多选筛选组件
class FilterChipGroup<T> extends StatelessWidget {
  const FilterChipGroup({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onSelectionChanged,
    this.label,
    this.wrap = true,
  });

  /// 所有可选选项
  final List<FilterOption<T>> options;

  /// 当前选中的值
  final Set<T> selectedValues;

  /// 选择变化回调
  final ValueChanged<Set<T>> onSelectionChanged;

  /// 分组标签
  final String? label;

  /// 是否换行显示
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chips = options.map((option) {
      final isSelected = selectedValues.contains(option.value);
      return FilterChip(
        label: Text(option.label),
        avatar: option.icon != null
            ? Icon(
                option.icon,
                size: 18,
                color: isSelected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              )
            : null,
        selected: isSelected,
        onSelected: (selected) {
          final newValues = Set<T>.from(selectedValues);
          if (selected) {
            newValues.add(option.value);
          } else {
            newValues.remove(option.value);
          }
          onSelectionChanged(newValues);
        },
        selectedColor: colorScheme.secondaryContainer,
        checkmarkColor: colorScheme.onSecondaryContainer,
        backgroundColor: colorScheme.surfaceContainerHighest,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
        ],
        wrap
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips,
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: chips
                      .map((chip) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: chip,
                          ))
                      .toList(),
                ),
              ),
      ],
    );
  }
}

/// 单选筛选 Chip 组
/// 使用 FilterChip 实现单选行为
class SingleSelectChipGroup<T> extends StatelessWidget {
  const SingleSelectChipGroup({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelectionChanged,
    this.label,
    this.wrap = true,
  });

  /// 所有可选选项
  final List<FilterOption<T>> options;

  /// 当前选中的值
  final T? selectedValue;

  /// 选择变化回调
  final ValueChanged<T?> onSelectionChanged;

  /// 分组标签
  final String? label;

  /// 是否换行显示
  final bool wrap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final chips = options.map((option) {
      final isSelected = option.value == selectedValue;
      return FilterChip(
        label: Text(option.label),
        avatar: option.icon != null
            ? Icon(
                option.icon,
                size: 18,
                color: isSelected
                    ? colorScheme.onSecondaryContainer
                    : colorScheme.onSurfaceVariant,
              )
            : null,
        selected: isSelected,
        onSelected: (selected) {
          onSelectionChanged(selected ? option.value : null);
        },
        selectedColor: colorScheme.secondaryContainer,
        checkmarkColor: colorScheme.onSecondaryContainer,
        backgroundColor: colorScheme.surfaceContainerHighest,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      );
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.outline,
            ),
          ),
          const SizedBox(height: 8),
        ],
        wrap
            ? Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chips,
              )
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: chips
                      .map((chip) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: chip,
                          ))
                      .toList(),
                ),
              ),
      ],
    );
  }
}
