import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/routes/routes.dart';
import '../../core/providers/usecase_providers.dart';
import '../../core/database/database.dart';
import '../../core/usecases/training/get_training_entry_data_usecase.dart';
import '../../shared/layout/app_responsive.dart';
import '../../shared/workout/workout_type_catalog.dart';
import '../../shared/widgets/async_value_widget.dart';
import '../../shared/widgets/material3/m3_card.dart';

/// 训练入口页面
/// 一级入口，承担整个 app 的核心任务
class TrainPage extends ConsumerWidget {
  const TrainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entryDataAsync = ref.watch(trainingEntryDataProvider(templateLimit: 5));

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
          const SizedBox(height: 16),
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
    final crossAxisCount = layout.isDesktop ? 2 : layout.gridColumns;

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
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: item.color.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => context.push(item.route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                item.icon,
                size: 32,
                color: item.color,
              ),
              const SizedBox(height: 8),
              Text(
                item.label,
                style: TextStyle(
                  fontSize: 16,
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

  /// 快速记录区域
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
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickTypes.map((item) {
            return ActionChip(
              avatar: Icon(
                item.$3,
                size: 18,
                color: colorScheme.onSecondaryContainer,
              ),
              label: Text(item.$2),
              backgroundColor: colorScheme.secondaryContainer,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              onPressed: () {
                context.push('${TrainRoutes.quick}?type=${item.$1}');
              },
            );
          }).toList(),
        ),
      ],
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
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 0,
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
    final colorScheme = Theme.of(context).colorScheme;
    final daysAgo = DateTime.now().difference(lastSession.datetime).inDays;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          final route = _getRouteForType(lastSession.type);
          final templateParam = lastSession.templateId != null
              ? '?templateId=${lastSession.templateId}'
              : '';
          context.push('$route$templateParam');
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.replay,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '复制上次训练',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${typeMeta.label} · ${daysAgo}天前',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
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
