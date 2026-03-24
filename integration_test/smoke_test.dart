import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fittrack/app.dart';
import 'package:fittrack/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Smoke Test', () {
    testWidgets('App launch and shell navigation smoke', (
      WidgetTester tester,
    ) async {
      final originalFlutterOnError = FlutterError.onError;
      final originalPlatformOnError = PlatformDispatcher.instance.onError;
      addTearDown(() {
        FlutterError.onError = originalFlutterOnError;
        PlatformDispatcher.instance.onError = originalPlatformOnError;
      });

      await app.bootstrapApp();
      runApp(const ProviderScope(child: WorkoutTrackerApp()));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('今日'), findsWidgets);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('开始训练'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(find.widgetWithText(NavigationDestination, '历史'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('历史记录'), findsOneWidget);

      await tester.tap(find.widgetWithText(NavigationDestination, '统计'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('统计数据'), findsOneWidget);

      await tester.tap(find.widgetWithText(NavigationDestination, '设置'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('设置'), findsWidgets);

      await tester.tap(find.widgetWithText(NavigationDestination, '今日'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('开始训练'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('开始训练'), findsWidgets);
    });
  });
}
