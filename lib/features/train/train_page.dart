import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database.dart';
import '../../core/providers/usecase_providers.dart';
import '../../core/router/routes/routes.dart';
import '../../core/usecases/training/get_training_entry_data_usecase.dart';
import '../../shared/layout/app_responsive.dart';
import '../../shared/theme/design_tokens.dart';
import '../../shared/widgets/async_value_widget.dart';
import '../../shared/widgets/material3/m3_card.dart';
import '../../shared/workout/workout_type_catalog.dart';

/// 训练入口页面
/// 一级入口，承担整个 app 的核心任务
class TrainPage extends ConsumerWidget {
  const TrainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryDataAsync =
        ref.watch(trainingEntryDataProvider(templateLimit: 5));

    return Scaffold(
      appBar: AppBar(
        title: const Text('开始训练'),
        centerTitle: true,
      ),
      body: AsyncValueWidget<TrainingEntryData>(
        asyncValue: entryDataAsync,
        dataBuilder: (data) => ResponsivePage(
          child: _buildContent(context, ref, data),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    TrainingEntryData data,
  ) {
    final layout = AppResponsive.of(context);

    return ListView(
      children: [
        // 主要运动类型网格
        _buildWorkoutTypeGrid(context, layout),
        SizedBox(height: layout.sectionSpacing),

        // 快速记录
        _buildQuickLogSection(context),
        SizedBox(height: layout.sectionSpacing),

        // 最近模板
        if (data.recentTemplates.isNotEmpty) ...[
          M3SectionHeader(
            title: '最近模板',
            padding: EdgeInsets.zero,
            action: TextButton(
              onPressed: () => context.push(MeRoutes.templates),
              child: const Text('管理'),
            ),
          ),
          _buildRecentTemplates(context, data.recentTemplates),
          const SizedBox(height: AppSpacing.md),
        ],

        // 复制上次训练
        if (data.lastSession != null)
          _buildCopyLastSession(context, data.lastSession!),
      ],
    );
  }

  /// 主要运动类型网格
  Widget _buildWorkoutTypeGrid(BuildContext context, AppResponsiveData layout) {
    final types = [
      _WorkoutTypeItem(
        type: 'strength',
        label: '力量训练',
        icon: Icons.fitness_center,
        color: WorkoutTypeCatalog.of('strength').color,
        route: TrainRoutes.strengthNew,
      ),
      _WorkoutTypeItem(
        type: 'running',
        label: '跑步',
        icon: Icons.directions_run,
        color: WorkoutTypeCatalog.of('running').color,
        route: TrainRoutes.runningNew,
      ),
      _WorkoutTypeItem(
        type: 'swimming',
        label: '游泳',
        icon: Icons.pool,
        color: WorkoutTypeCatalog.of('swimming').color,
        route: TrainRoutes.swimmingNew,
      ),
      _WorkoutTypeItem(
        type: 'quick',
        label: '快速记录',
        icon: Icons.flash_on,
        color: WorkoutTypeCatalog.of('cycling').color,
        route: TrainRoutes.quick,
      ),
    ];

    // 计算列数：在大屏幕上使用 2 列以保持按钮大小合适
    final crossAxisCount = layout.isExpanded ? 2 : layout.gridColumns;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: layout.cardSpacing,
        crossAxisSpacing: layout.cardSpacing,
        childAspectRatio: 1.5,
      ),
      itemCount: types.length,
      itemBuilder: (context, index) => _buildTypeCard(context, types[index]),
    );
  }

  Widget _buildTypeCard(BuildContext context, _WorkoutTypeItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: AppElevation.card,
      color: item.color.withOpacity(AppOpacity.light),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: InkWell(
        onTap: () => context.push(item.route),
        borderRadius: AppRadius.card,
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: AppSize.iconXxl,
                color: item.color,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.label,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 快速记录区域 - 使用 2x2 网格布局避免不均匀换行
  Widget _buildQuickLogSection(BuildContext context) {
    final quickTypes = [
      ('cycling', '骑行', Icons.directions_bike),
      ('yoga', '瑜伽', Icons.self_improvement),
      ('walking', '步行', Icons.directions_walk),
      ('jump_rope', '跳绳', Icons.sports_gymnastics),
    ];

    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const M3SectionHeader(
          title: '其他运动',
          padding: EdgeInsets.zero,
        ),
        const SizedBox(height: AppSpacing.sm),
        // 使用 2x2 网格布局
        Row(
          children: [
            Expanded(
              child: _buildQuickTypeChip(context, quickTypes[0], colorScheme),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildQuickTypeChip(context, quickTypes[1], colorScheme),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _buildQuickTypeChip(context, quickTypes[2], colorScheme),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildQuickTypeChip(context, quickTypes[3], colorScheme),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickTypeChip(
    BuildContext context,
    (String, String, IconData) item,
    ColorScheme colorScheme,
  ) {
    return ActionChip(
      avatar: Icon(
        item.$3,
        size: AppSize.iconSm,
        color: colorScheme.onSecondaryContainer,
      ),
      label: Text(item.$2),
      backgroundColor: colorScheme.secondaryContainer,
      side: BorderSide.none,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.chip),
      onPressed: () {
        context.push('${TrainRoutes.quick}?type=${item.$1}');
      },
    );
  }

  /// 最近模板列表
  Widget _buildRecentTemplates(
    BuildContext context,
    List<WorkoutTemplate> templates,
  ) {
    return Column(
      children: templates.take(5).map((template) {
        final typeMeta = WorkoutTypeCatalog.of(template.type);
        return Card(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          elevation: AppElevation.card,
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeMeta.color.withOpacity(AppOpacity.light),
                borderRadius: AppRadius.circularSm,
              ),
              child: Icon(typeMeta.icon, color: typeMeta.color, size: AppSize.iconMd),
            ),
            title: Text(template.name),
            subtitle: Text(typeMeta.label),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              final route = _getRouteForType(template.type);
              context.push('$route?templateId=${template.id}');
            },
          ),
        );
      }).toList(),
    );
  }

  /// 复制上次训练卡片
  Widget _buildCopyLastSession(
    BuildContext context,
    TrainingSession lastSession,
  ) {
    final typeMeta = WorkoutTypeCatalog.of(lastSession.type);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final daysAgo = DateTime.now().difference(lastSession.datetime).inDays;

    return Card(
      margin: EdgeInsets.zero,
      elevation: AppElevation.card,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: InkWell(
        onTap: () {
          final route = _getRouteForType(lastSession.type);
          final templateParam = lastSession.templateId != null
              ? '?templateId=${lastSession.templateId}'
              : '';
          context.push('$route$templateParam');
        },
        borderRadius: AppRadius.card,
        child: Padding(
          padding: AppSpacing.card,
          child: Row(
            children: [
              Container(
                width: AppSize.touchTarget,
                height: AppSize.touchTarget,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(AppOpacity.subtle),
                  borderRadius: AppRadius.circularMd,
                ),
                child: Icon(
                  Icons.replay,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '复制上次训练',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${typeMeta.label} · $daysAgo天前',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer
                            .withOpacity(AppOpacity.secondary),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRouteForType(String type) {
    switch (type) {
      case 'strength':
        return TrainRoutes.strengthNew;
      case 'running':
        return TrainRoutes.runningNew;
      case 'swimming':
        return TrainRoutes.swimmingNew;
      default:
        return TrainRoutes.quick;
    }
  }
}

/// 运动类型数据类
class _WorkoutTypeItem {
  const _WorkoutTypeItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.route,
  });

  final String type;
  final String label;
  final IconData icon;
  final Color color;
  final String route;
}
