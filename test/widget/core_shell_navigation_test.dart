import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:fittrack/core/router/main_shell.dart';

void main() {
  testWidgets('底部导航包含四个入口：今日/训练/记录/我的', (tester) async {
    final router = GoRouter(
      initialLocation: '/today',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/today',
              builder: (context, state) => const Scaffold(body: Text('今日页')),
            ),
            GoRoute(
              path: '/train',
              builder: (context, state) => const Scaffold(body: Text('训练页')),
            ),
            GoRoute(
              path: '/records',
              builder: (context, state) => const Scaffold(body: Text('记录页')),
            ),
            GoRoute(
              path: '/me',
              builder: (context, state) => const Scaffold(body: Text('我的页')),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    // 验证底部导航存在
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));

    // 验证导航项标签
    expect(find.widgetWithText(NavigationDestination, '今日'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, '训练'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, '记录'), findsOneWidget);
    expect(find.widgetWithText(NavigationDestination, '我的'), findsOneWidget);

    // 验证初始内容
    expect(find.text('今日页'), findsOneWidget);
  });

  testWidgets('点击导航项可切换页面', (tester) async {
    final router = GoRouter(
      initialLocation: '/today',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/today',
              builder: (context, state) => const Scaffold(body: Text('今日页')),
            ),
            GoRoute(
              path: '/train',
              builder: (context, state) => const Scaffold(body: Text('训练页')),
            ),
            GoRoute(
              path: '/records',
              builder: (context, state) => const Scaffold(body: Text('记录页')),
            ),
            GoRoute(
              path: '/me',
              builder: (context, state) => const Scaffold(body: Text('我的页')),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    // 点击训练
    await tester.tap(find.widgetWithText(NavigationDestination, '训练'));
    await tester.pumpAndSettle();
    expect(find.text('训练页'), findsOneWidget);

    // 点击记录
    await tester.tap(find.widgetWithText(NavigationDestination, '记录'));
    await tester.pumpAndSettle();
    expect(find.text('记录页'), findsOneWidget);

    // 点击我的
    await tester.tap(find.widgetWithText(NavigationDestination, '我的'));
    await tester.pumpAndSettle();
    expect(find.text('我的页'), findsOneWidget);

    // 点击今日
    await tester.tap(find.widgetWithText(NavigationDestination, '今日'));
    await tester.pumpAndSettle();
    expect(find.text('今日页'), findsOneWidget);
  });

  testWidgets('导航索引根据当前路径正确计算', (tester) async {
    final router = GoRouter(
      initialLocation: '/train',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/today',
              builder: (context, state) => const Scaffold(body: Text('今日页')),
            ),
            GoRoute(
              path: '/train',
              builder: (context, state) => const Scaffold(body: Text('训练页')),
            ),
            GoRoute(
              path: '/records',
              builder: (context, state) => const Scaffold(body: Text('记录页')),
            ),
            GoRoute(
              path: '/me',
              builder: (context, state) => const Scaffold(body: Text('我的页')),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    // 验证初始选中训练（索引 1）
    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, equals(1));
    expect(find.text('训练页'), findsOneWidget);
  });

  testWidgets('导航到 /me 子路径时高亮我的', (tester) async {
    final router = GoRouter(
      initialLocation: '/me/goals',
      routes: [
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(
              path: '/today',
              builder: (context, state) => const Scaffold(body: Text('今日页')),
            ),
            GoRoute(
              path: '/train',
              builder: (context, state) => const Scaffold(body: Text('训练页')),
            ),
            GoRoute(
              path: '/records',
              builder: (context, state) => const Scaffold(body: Text('记录页')),
            ),
            GoRoute(
              path: '/me',
              builder: (context, state) => const Scaffold(body: Text('我的页')),
              routes: [
                GoRoute(
                  path: 'goals',
                  builder: (context, state) => const Scaffold(body: Text('目标页')),
                ),
              ],
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pump();

    // 验证我的高亮（索引 3）
    final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navBar.selectedIndex, equals(3));
    expect(find.text('目标页'), findsOneWidget);
  });
}
