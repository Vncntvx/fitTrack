import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/database/database.dart';
import '../theme/design_tokens.dart';
import '../workout/workout_type_catalog.dart';

/// 训练会话数据容器
/// 用于在列表中显示会话及其详细信息
class SessionWithDetails {
  const SessionWithDetails({
    required this.session,
    this.details,
  });

  final TrainingSession session;
  final dynamic details; // RunningEntry, SwimmingEntry, StrengthExerciseEntry, or null
}

/// 统一的训练记录卡片
/// 用于历史列表、今日页最近记录等多处
///
/// Material 3 风格，支持紧凑模式和完整模式
class SessionCard extends StatelessWidget {
  const SessionCard({
    super.key,
    required this.session,
    this.details,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.showDate = true,
    this.compact = false,
  });

  /// 训练会话数据
  final TrainingSession session;

  /// 详细数据（跑步、游泳、力量条目）
  final dynamic details;

  /// 点击回调
  final VoidCallback? onTap;

  /// 删除回调
  final VoidCallback? onDelete;

  /// 编辑回调
  final VoidCallback? onEdit;

  /// 是否显示日期
  final bool showDate;

  /// 是否使用紧凑模式
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final typeMeta = WorkoutTypeCatalog.of(session.type);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin:
          EdgeInsets.only(bottom: compact ? AppSpacing.sm : AppSpacing.md),
      elevation: AppElevation.card,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
          child: Row(
            children: [
              _buildLeading(typeMeta, colorScheme),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: _buildContent(context, typeMeta)),
              _buildTrailing(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(WorkoutTypeMeta typeMeta, ColorScheme colorScheme) {
    return Container(
      width: AppSize.touchTarget,
      height: AppSize.touchTarget,
      decoration: BoxDecoration(
        color: typeMeta.color.withOpacity(AppOpacity.light),
        borderRadius: AppRadius.circularMd,
      ),
      child: Icon(typeMeta.icon, color: typeMeta.color),
    );
  }

  Widget _buildContent(BuildContext context, WorkoutTypeMeta typeMeta) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          typeMeta.label,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        if (showDate) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            DateFormat('MM-dd HH:mm').format(session.datetime),
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
        if (session.note?.isNotEmpty == true && !compact) ...[
          const SizedBox(height: 2),
          Text(
            session.note!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTrailing(BuildContext context, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: AppRadius.circularSm,
          ),
          child: Text(
            '${session.durationMinutes}分钟',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        if (onDelete != null || onEdit != null) ...[
          const SizedBox(width: AppSpacing.xs),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: colorScheme.onSurfaceVariant,
            ),
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  onEdit?.call();
                  break;
                case 'delete':
                  onDelete?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              if (onEdit != null)
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('编辑'),
                  ),
                ),
              if (onDelete != null)
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('删除'),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

/// 按日期分组的会话列表
class DateGroupedSessions extends StatelessWidget {
  const DateGroupedSessions({
    super.key,
    required this.sessions,
    required this.onSessionTap,
    this.onSessionDelete,
    this.onSessionEdit,
  });

  final List<SessionWithDetails> sessions;
  final void Function(SessionWithDetails) onSessionTap;
  final void Function(SessionWithDetails)? onSessionDelete;
  final void Function(SessionWithDetails)? onSessionEdit;

  @override
  Widget build(BuildContext context) {
    final grouped = _groupByDate(sessions);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final group = grouped[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 日期标题
            Padding(
              padding: AppSpacing.sectionHeader,
              child: Text(
                group.dateLabel,
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.outline,
                ),
              ),
            ),
            // 该日期的会话列表
            ...group.sessions.map(
              (item) => SessionCard(
                session: item.session,
                details: item.details,
                onTap: () => onSessionTap(item),
                onDelete: onSessionDelete != null
                    ? () => onSessionDelete!(item)
                    : null,
                onEdit: onSessionEdit != null
                    ? () => onSessionEdit!(item)
                    : null,
              ),
            ),
          ],
        );
      },
    );
  }

  List<_DateGroup> _groupByDate(List<SessionWithDetails> sessions) {
    final Map<String, List<SessionWithDetails>> map = {};

    for (final item in sessions) {
      final dateKey = _formatDateKey(item.session.datetime);
      map.putIfAbsent(dateKey, () => []).add(item);
    }

    return map.entries
        .map((e) => _DateGroup(dateLabel: e.key, sessions: e.value))
        .toList();
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return '今天';
    } else if (dateOnly == yesterday) {
      return '昨天';
    } else {
      return DateFormat('MM月dd日 EEEE', 'zh_CN').format(date);
    }
  }
}

class _DateGroup {
  const _DateGroup({
    required this.dateLabel,
    required this.sessions,
  });

  final String dateLabel;
  final List<SessionWithDetails> sessions;
}
