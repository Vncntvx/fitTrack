import 'package:fittrack/app.dart';
import 'package:fittrack/core/providers/app_database_provider.dart';
import 'package:fittrack/core/router/app_router.dart';
import 'package:fittrack/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'test_db_helper.dart';

/// 通过有限帧推进来替代 pumpAndSettle，避免被持续动画卡住测试。
Future<void> pumpBounded(
  WidgetTester tester, {
  int maxPumps = 60,
  Duration step = const Duration(milliseconds: 16),
}) async {
  for (var i = 0; i < maxPumps; i++) {
    await tester.pump(step);
    if (!tester.binding.hasScheduledFrame) {
      return;
    }
  }
}

/// 在限定帧数内等待目标控件出现，超时直接失败。
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  int maxPumps = 300,
  Duration step = const Duration(milliseconds: 16),
}) async {
  for (var i = 0; i < maxPumps; i++) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await tester.pump(step);
  }
  throw TestFailure('在限定帧数内未找到目标控件: $finder');
}

/// 启动带独立数据库的应用测试壳
Future<TestDatabaseHandle> pumpWorkoutApp(
  WidgetTester tester, {
  List overrides = const [],
}) async {
  final handle = await createTestDatabase(prefix: 'fittrack-widget-');

  await initializeDateFormatting('zh_CN');
  appRouter.go('/');

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(handle.database),
        currentThemeModeProvider.overrideWithValue(ThemeMode.light),
        ...overrides,
      ],
      child: const WorkoutTrackerApp(),
    ),
  );
  await pumpBounded(tester);

  return handle;
}
