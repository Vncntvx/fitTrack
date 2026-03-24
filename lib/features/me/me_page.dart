import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database.dart';
import '../../core/providers/app_database_provider.dart';
import '../../core/router/routes/routes.dart';
import '../../shared/layout/app_responsive.dart';
import '../../shared/theme/app_theme.dart';
import '../../shared/theme/design_tokens.dart';
import '../../shared/widgets/async_value_widget.dart';

/// 我的页面
/// 替代原设置页，定位为个人中心 + 训练资产入口 + 偏好设置
class MePage extends ConsumerStatefulWidget {
  const MePage({super.key});

  @override
  ConsumerState<MePage> createState() => _MePageState();
}

class _MePageState extends ConsumerState<MePage> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _ensureSettingsExist();
  }

  Future<void> _ensureSettingsExist() async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.getOrCreateSettings();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        appBar: AppBar(title: const Text('我的')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final settingsAsync = ref.watch(settingsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
      ),
      body: AsyncValueWidget(
        asyncValue: settingsAsync,
        dataBuilder: (settings) {
          if (settings == null) {
            // 设置正在加载中，显示加载状态
            return const Center(child: CircularProgressIndicator());
          }
          return _buildContent(context, ref, settings);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, UserSetting settings) {
    final layout = AppResponsive.of(context);

    return ResponsivePage(
      child: ListView(
        shrinkWrap: true,
        children: [
          // 目标卡片
          _buildGoalsCard(context, settings),
          SizedBox(height: layout.cardSpacing),

        // 训练管理
        _buildSection(
          context,
          title: '训练管理',
          items: [
            _MenuItem(
              icon: Icons.fitness_center,
              title: '动作库',
              subtitle: '管理训练动作',
              onTap: () => context.push(MeRoutes.exercises),
            ),
            _MenuItem(
              icon: Icons.description,
              title: '训练模板',
              subtitle: '快速开始训练',
              onTap: () => context.push(MeRoutes.templates),
            ),
            _MenuItem(
              icon: Icons.emoji_events,
              title: '个人记录',
              subtitle: '查看最佳成绩',
              onTap: () => context.push(MeRoutes.pr),
            ),
          ],
        ),

        // 偏好设置
        _buildSection(
          context,
          title: '偏好设置',
          items: [
            _MenuItem(
              icon: Icons.palette,
              title: '主题',
              subtitle: _getThemeLabel(settings.themeMode),
              onTap: () => _showThemeDialog(context, ref, settings),
            ),
            _MenuItem(
              icon: Icons.straighten,
              title: '单位设置',
              subtitle: '${settings.weightUnit}/${settings.distanceUnit}',
              onTap: () => context.push(MeRoutes.preferences),
            ),
          ],
        ),

        // 数据管理
        _buildSection(
          context,
          title: '数据',
          items: [
            _MenuItem(
              icon: Icons.backup,
              title: '备份与恢复',
              onTap: () => context.push(MeRoutes.backup),
            ),
            _MenuItem(
              icon: Icons.wifi_tethering,
              title: 'Web 管理界面',
              subtitle: '局域网访问',
              onTap: () => context.push(MeRoutes.lan),
            ),
          ],
        ),

        // 关于
        _buildSection(
          context,
          title: '关于',
          items: [
            _MenuItem(
              icon: Icons.info_outline,
              title: '关于应用',
              onTap: () => context.push(MeRoutes.about),
            ),
            _MenuItem(
              icon: Icons.bug_report,
              title: '查看日志',
              onTap: () => context.push('/logs'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
      ),
    );
  }

  Widget _buildGoalsCard(BuildContext context, UserSetting settings) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Card(
      margin: AppSpacing.allLg,
      elevation: AppElevation.card,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: InkWell(
        onTap: () => context.push(MeRoutes.goals),
        borderRadius: AppRadius.card,
        child: Padding(
          padding: AppSpacing.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '训练目标',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildGoalItem(
                      context,
                      icon: Icons.calendar_today,
                      label: '每周运动',
                      value: '${settings.weeklyWorkoutDaysGoal}天',
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xl),
                  Expanded(
                    child: _buildGoalItem(
                      context,
                      icon: Icons.timer,
                      label: '每周时长',
                      value: '${settings.weeklyWorkoutMinutesGoal}分钟',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: AppSize.iconSm,
              color:
                  colorScheme.onPrimaryContainer.withOpacity(AppOpacity.secondary),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer
                    .withOpacity(AppOpacity.secondary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
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
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  _MenuItemTile(item: entry.value),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: colorScheme.outlineVariant,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref, UserSetting settings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('主题'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('跟随系统'),
              value: 'system',
              groupValue: settings.themeMode,
              onChanged: (value) => _updateTheme(context, ref, value!),
            ),
            RadioListTile<String>(
              title: const Text('浅色'),
              value: 'light',
              groupValue: settings.themeMode,
              onChanged: (value) => _updateTheme(context, ref, value!),
            ),
            RadioListTile<String>(
              title: const Text('深色'),
              value: 'dark',
              groupValue: settings.themeMode,
              onChanged: (value) => _updateTheme(context, ref, value!),
            ),
          ],
        ),
      ),
    );
  }

  void _updateTheme(BuildContext context, WidgetRef ref, String themeMode) {
    Navigator.pop(context);

    // 转换字符串到 ThemeModeOption
    final option = switch (themeMode) {
      'light' => ThemeModeOption.light,
      'dark' => ThemeModeOption.dark,
      _ => ThemeModeOption.system,
    };

    // 调用 ThemeModeNotifier 更新主题
    ref.read(themeModeProvider.notifier).setThemeMode(option);
  }

  String _getThemeLabel(String themeMode) {
    switch (themeMode) {
      case 'light':
        return '浅色';
      case 'dark':
        return '深色';
      default:
        return '跟随系统';
    }
  }
}

/// 菜单项
class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
}

/// 菜单项 Widget
class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(item.icon, color: colorScheme.primary),
      title: Text(item.title),
      subtitle: item.subtitle != null ? Text(item.subtitle!) : null,
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.outline,
      ),
      onTap: item.onTap,
    );
  }
}
