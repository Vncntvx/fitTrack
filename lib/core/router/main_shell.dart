import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/layout/app_responsive.dart';
import '../../shared/theme/design_tokens.dart';
import 'routes/routes.dart';

/// 导航目的地配置
class _NavDestination {
  const _NavDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// 导航目的地列表
const _destinations = [
  _NavDestination(
    route: NavRoutes.today,
    icon: Icons.today_outlined,
    selectedIcon: Icons.today,
    label: '今日',
  ),
  _NavDestination(
    route: NavRoutes.train,
    icon: Icons.play_circle_outline,
    selectedIcon: Icons.play_circle,
    label: '训练',
  ),
  _NavDestination(
    route: NavRoutes.records,
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights,
    label: '记录',
  ),
  _NavDestination(
    route: NavRoutes.me,
    icon: Icons.person_outline,
    selectedIcon: Icons.person,
    label: '我的',
  ),
];

/// 主页面壳组件
/// 包含自适应导航：手机用底部导航栏，平板/桌面用侧边导航
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(NavRoutes.train)) return 1;
    if (location.startsWith(NavRoutes.records)) return 2;
    if (location.startsWith(NavRoutes.me)) return 3;
    return 0; // default to /today
  }

  void _onDestinationSelected(BuildContext context, int index) {
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final layout = AppResponsive.of(context);
    final currentIndex = _getCurrentIndex(context);

    // 平板/桌面使用 NavigationRail
    if (layout.useNavigationRail) {
      return _buildWithNavigationRail(context, currentIndex);
    }

    // 手机使用底部导航栏
    return _buildWithBottomNav(context, currentIndex);
  }

  /// 构建带 NavigationRail 的布局 (平板/桌面)
  Widget _buildWithNavigationRail(BuildContext context, int currentIndex) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // 侧边导航栏
            NavigationRail(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) =>
                  _onDestinationSelected(context, index),
              labelType: NavigationRailLabelType.all,
              backgroundColor: colorScheme.surface,
              indicatorColor: colorScheme.primaryContainer,
              leading: Padding(
                padding: const EdgeInsets.only(
                  top: AppSpacing.lg,
                  bottom: AppSpacing.xxl,
                ),
                child: Icon(
                  Icons.fitness_center,
                  size: AppSize.iconXxl,
                  color: colorScheme.primary,
                ),
              ),
              destinations: _destinations.map((dest) {
                return NavigationRailDestination(
                  icon: Icon(dest.icon),
                  selectedIcon: Icon(dest.selectedIcon),
                  label: Text(dest.label),
                );
              }).toList(),
            ),
            // 分隔线
            VerticalDivider(
              thickness: 1,
              width: 1,
              color: colorScheme.outlineVariant,
            ),
            // 主内容区域
            Expanded(child: child),
          ],
        ),
      ),
    );
  }

  /// 构建带底部导航栏的布局 (手机)
  Widget _buildWithBottomNav(BuildContext context, int currentIndex) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, index),
        destinations: _destinations.map((dest) {
          return NavigationDestination(
            icon: Icon(dest.icon),
            selectedIcon: Icon(dest.selectedIcon),
            label: dest.label,
          );
        }).toList(),
      ),
    );
  }
}
