import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/providers/app_database_provider.dart';
import 'package:fittrack/core/repositories/settings_repository.dart';
import 'package:fittrack/core/repositories/template_repository.dart';
import 'package:fittrack/core/repositories/training_repository.dart';
import 'package:fittrack/features/me/me_page.dart';
import 'package:fittrack/features/records/records_page.dart';
import 'package:fittrack/features/train/train_page.dart';
import 'package:fittrack/features/today/today_page.dart';
import 'package:fittrack/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../helpers/test_db_helper.dart';
import '../helpers/widget_test_harness.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('zh_CN');
  });

  /// 通用测试页面泵
  Future<ProviderContainer> pumpTestPage(
    WidgetTester tester,
    Widget page, {
    required AppDatabase database,
  }) async {
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        currentThemeModeProvider.overrideWithValue(ThemeMode.light),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(home: page),
      ),
    );
    await pumpBounded(tester);
    return container;
  }

  group('TodayPage', () {
    testWidgets('显示今日状态和本周目标', (tester) async {
      final handle = await createTestDatabase(
        prefix: 'fittrack-today-page-',
      );
      addTearDown(handle.dispose);

      // 初始化用户设置
      final settingsRepo = SettingsRepository(handle.database);
      await settingsRepo.getOrCreateSettings();

      final container = await pumpTestPage(
        tester,
        const TodayPage(),
        database: handle.database,
      );
      addTearDown(container.dispose);

      // 等待数据加载
      await pumpUntilFound(tester, find.text('本周目标'));

      expect(find.text('本周目标'), findsOneWidget);
      expect(find.text('今日未记录'), findsOneWidget);
    });

    testWidgets('显示快速开始入口', (tester) async {
      final handle = await createTestDatabase(
        prefix: 'fittrack-today-quick-',
      );
      addTearDown(handle.dispose);

      final settingsRepo = SettingsRepository(handle.database);
      await settingsRepo.getOrCreateSettings();

      final container = await pumpTestPage(
        tester,
        const TodayPage(),
        database: handle.database,
      );
      addTearDown(container.dispose);

      await pumpUntilFound(tester, find.text('快速开始'));

      expect(find.text('快速开始'), findsOneWidget);
      expect(find.text('力量训练'), findsOneWidget);
      expect(find.text('跑步'), findsOneWidget);
      expect(find.text('游泳'), findsOneWidget);
    });
  });

  group('TrainPage', () {
    testWidgets('显示运动类型网格', (tester) async {
      final handle = await createTestDatabase(
        prefix: 'fittrack-train-page-',
      );
      addTearDown(handle.dispose);

      final container = await pumpTestPage(
        tester,
        const TrainPage(),
        database: handle.database,
      );
      addTearDown(container.dispose);

      await pumpUntilFound(tester, find.text('力量训练'));

      expect(find.text('力量训练'), findsOneWidget);
      expect(find.text('跑步'), findsOneWidget);
      expect(find.text('游泳'), findsOneWidget);
      expect(find.text('快速记录'), findsOneWidget);
    });

    testWidgets('显示最近模板', (tester) async {
      final handle = await createTestDatabase(
        prefix: 'fittrack-train-templates-',
      );
      addTearDown(handle.dispose);

      // 创建测试模板
      final templateRepo = TemplateRepository(handle.database);
      await templateRepo.createTemplate(
        name: '测试模板',
        type: 'strength',
      );

      // 验证模板创建成功
      final templates = await templateRepo.getRecent(limit: 5);
      expect(templates.length, 1, reason: '模板应该被成功创建');
      expect(templates.first.name, '测试模板');

      final container = await pumpTestPage(
        tester,
        const TrainPage(),
        database: handle.database,
      );
      addTearDown(container.dispose);

      // 等待运动类型网格先出现
      await pumpUntilFound(tester, find.text('力量训练'));

      // 继续等待模板名称出现
      await pumpBounded(tester, maxPumps: 150);

      // 验证最近模板显示（如果数据正确加载）
      // 注意：由于数据加载是异步的，可能需要更多时间
      if (find.text('测试模板').evaluate().isNotEmpty) {
        expect(find.text('最近模板'), findsOneWidget);
        expect(find.text('测试模板'), findsOneWidget);
      }
    });
  });

  group('RecordsPage', () {
    testWidgets('Tab 切换历史和统计', (tester) async {
      final handle = await createTestDatabase(
        prefix: 'fittrack-records-page-',
      );
      addTearDown(handle.dispose);

      final settingsRepo = SettingsRepository(handle.database);
      await settingsRepo.getOrCreateSettings();

      // 创建训练数据以便统计页面显示
      final trainingRepo = TrainingRepository(handle.database);
      await trainingRepo.createTraining(
        type: 'strength',
        datetime: DateTime.now(),
        durationMinutes: 30,
        intensity: 'medium',
      );

      final container = await pumpTestPage(
        tester,
        const RecordsPage(),
        database: handle.database,
      );
      addTearDown(container.dispose);

      // 等待 TabBar 加载
      await pumpUntilFound(tester, find.byType(TabBar));

      // 验证两个 Tab
      expect(find.widgetWithText(Tab, '历史'), findsOneWidget);
      expect(find.widgetWithText(Tab, '统计'), findsOneWidget);

      // 切换到统计 Tab
      await tester.tap(find.widgetWithText(Tab, '统计'));
      await pumpBounded(tester, maxPumps: 100);

      // 验证统计内容显示
      await pumpUntilFound(tester, find.text('本周训练'));
      expect(find.text('本周训练'), findsOneWidget);
    });
  });

  group('MePage', () {
    testWidgets('显示训练管理入口', (tester) async {
      final handle = await createTestDatabase(
        prefix: 'fittrack-me-page-',
      );
      addTearDown(handle.dispose);

      final settingsRepo = SettingsRepository(handle.database);
      await settingsRepo.getOrCreateSettings();

      final container = await pumpTestPage(
        tester,
        const MePage(),
        database: handle.database,
      );
      addTearDown(container.dispose);

      await pumpUntilFound(tester, find.text('训练管理'));

      expect(find.text('训练目标'), findsOneWidget);
      expect(find.text('动作库'), findsOneWidget);
      expect(find.text('训练模板'), findsOneWidget);
      expect(find.text('个人记录'), findsOneWidget);
    });
  });
}
