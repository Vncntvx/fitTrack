import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'routes/routes.dart';

/// 主页面壳组件
/// 包含底部导航栏
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _getCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(NavRoutes.train)) return 1;
    if (location.startsWith(NavRoutes.records)) return 2;
    if (location.startsWith(NavRoutes.me)) return 3;
    return 0; // default to /today
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        context.go(NavRoutes.today);
        break;
      case 1:
        context.go(NavRoutes.train);
        break;
      case 2:
        context.go(NavRoutes.records);
        break;
      case 3:
        context.go(NavRoutes.me);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _getCurrentIndex(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _onItemTapped,
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: '今日',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: '训练',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: '记录',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
