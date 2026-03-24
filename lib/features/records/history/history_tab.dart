import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/database.dart';
import '../../../core/providers/app_database_provider.dart';
import '../../../core/providers/usecase_providers.dart';
import '../../../core/router/routes/routes.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../../shared/widgets/empty_state_widget.dart';
import '../../../shared/widgets/filter_chip_group.dart';
import '../../../shared/widgets/session_card.dart';
import '../../../shared/workout/workout_type_catalog.dart';

/// 历史记录 Tab
class HistoryTab extends ConsumerStatefulWidget {
  const HistoryTab({super.key});

  @override
  ConsumerState<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends ConsumerState<HistoryTab> {
  String? _selectedType;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final sessionsAsync = ref.watch(trainingSessionsStreamProvider);

    return Column(
      children: [
        // 搜索栏
        Padding(
          padding: AppSpacing.allLg,
          child: TextField(
            decoration: InputDecoration(
              hintText: '搜索记录...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),
        ),

        // 类型筛选
        Padding(
          padding: AppSpacing.horizontalLg,
          child: SingleSelectChipGroup<String>(
            options: const [
              FilterOption(value: 'all', label: '全部'),
              FilterOption(
                value: 'strength',
                label: '力量',
                icon: Icons.fitness_center,
              ),
              FilterOption(
                value: 'running',
                label: '跑步',
                icon: Icons.directions_run,
              ),
              FilterOption(
                value: 'swimming',
                label: '游泳',
                icon: Icons.pool,
              ),
            ],
            selectedValue: _selectedType ?? 'all',
            onSelectionChanged: (value) {
              setState(() => _selectedType = value == 'all' ? null : value);
            },
            wrap: false,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // 列表
        Expanded(
          child: AsyncValueWidget(
            asyncValue: sessionsAsync,
            dataBuilder: (sessions) =>
                _buildSessionList(context, ref, sessions),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionList(
    BuildContext context,
    WidgetRef ref,
    List<TrainingSession> sessions,
  ) {
    // 应用筛选
    final filtered = sessions.where((session) {
      // 类型筛选
      if (_selectedType != null && session.type != _selectedType) {
        return false;
      }
      // 搜索筛选
      if (_searchQuery.isNotEmpty) {
        final typeLabel = WorkoutTypeCatalog.labelOf(session.type);
        if (!typeLabel.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !(session.note?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
                false)) {
          return false;
        }
      }
      return true;
    }).toList();

    // 按日期降序排序
    filtered.sort((a, b) => b.datetime.compareTo(a.datetime));

    if (filtered.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.history,
        message: _selectedType != null || _searchQuery.isNotEmpty
            ? '没有找到匹配的记录'
            : '暂无训练记录',
        subtitle: '开始记录你的训练吧',
        action: _selectedType != null || _searchQuery.isNotEmpty
            ? TextButton(
                onPressed: () {
                  setState(() {
                    _selectedType = null;
                    _searchQuery = '';
                  });
                },
                child: const Text('清除筛选'),
              )
            : null,
      );
    }

    // 转换为 SessionWithDetails 列表
    final sessionWithDetails =
        filtered.map((s) => SessionWithDetails(session: s)).toList();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(trainingSessionsStreamProvider);
      },
      child: ListView(
        padding: AppSpacing.horizontalLg,
        children: [
          DateGroupedSessions(
            sessions: sessionWithDetails,
            onSessionTap: (item) {
              context.push(RecordsRoutes.session(item.session.id));
            },
            onSessionDelete: (item) {
              _showDeleteConfirmation(context, ref, item.session);
            },
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    TrainingSession session,
  ) {
    final typeMeta = WorkoutTypeCatalog.of(session.type);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除记录'),
        content: Text('确定要删除这条${typeMeta.label}记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final useCase = ref.read(deleteTrainingUseCaseProvider);
              await useCase(session.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('记录已删除')),
                );
              }
            },
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}
