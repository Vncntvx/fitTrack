import 'package:fittrack/core/providers/app_database_provider.dart';
import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/exercise_repository.dart';
import 'package:fittrack/core/repositories/template_repository.dart';
import 'package:fittrack/shared/theme/app_theme.dart';
import 'package:fittrack/web/admin/backup_page.dart' as web_backup;
import 'package:fittrack/web/admin/dashboard_page.dart';
import 'package:fittrack/web/admin/web_exercises_page.dart';
import 'package:fittrack/web/admin/web_templates_page.dart';
import 'package:fittrack/shared/widgets/empty_state_widget.dart';
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

  Future<ProviderContainer> pumpAdminPage(
    WidgetTester tester,
    Widget page, {
    required AppDatabase database,
  }) async {
    tester.view
      ..physicalSize = const Size(1600, 1200)
      ..devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

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

  testWidgets('Dashboard 页面渲染关键模块', (tester) async {
    final handle = await createTestDatabase(
      prefix: 'fittrack-admin-dashboard-',
    );
    addTearDown(handle.dispose);

    final container = await pumpAdminPage(
      tester,
      const DashboardPage(),
      database: handle.database,
    );
    addTearDown(container.dispose);

    expect(find.text('仪表板'), findsOneWidget);
    expect(find.text('训练数据总览'), findsOneWidget);
    expect(find.text('本周训练'), findsOneWidget);
    expect(find.text('训练类型分布'), findsOneWidget);
    expect(find.text('Web 门户'), findsOneWidget);
    expect(find.text('高级管理'), findsOneWidget);
  });

  testWidgets('WebExercises 页面渲染列表并支持删除反馈', (tester) async {
    final handle = await createTestDatabase(prefix: 'fittrack-admin-exercise-');
    addTearDown(handle.dispose);

    final exerciseRepository = ExerciseRepository(handle.database);
    const targetExerciseName = 'widget_admin_exercise_target';
    const otherExerciseName = 'widget_admin_exercise_other';
    await exerciseRepository.createExercise(
      name: targetExerciseName,
      category: 'chest',
    );
    await exerciseRepository.createExercise(
      name: otherExerciseName,
      category: 'back',
    );

    final container = await pumpAdminPage(
      tester,
      const WebExercisesPage(),
      database: handle.database,
    );
    addTearDown(container.dispose);

    expect(find.text('动作管理'), findsOneWidget);
    final dataTable = find.byType(DataTable);
    await pumpUntilFound(
      tester,
      find.descendant(of: dataTable, matching: find.text(targetExerciseName)),
    );

    final searchField = find.byType(TextField).first;
    await tester.enterText(searchField, targetExerciseName);
    await pumpBounded(tester);

    expect(
      find.descendant(of: dataTable, matching: find.text(targetExerciseName)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dataTable, matching: find.text(otherExerciseName)),
      findsNothing,
    );

    final deleteButton = find.descendant(
      of: dataTable,
      matching: find.widgetWithIcon(IconButton, Icons.delete),
    );
    expect(deleteButton, findsOneWidget);
    await tester.ensureVisible(deleteButton);
    await tester.tap(deleteButton);
    await pumpUntilFound(tester, find.text('确认删除'));

    final confirmDialog = find.byType(AlertDialog);
    await tester.tap(
      find.descendant(
        of: confirmDialog,
        matching: find.widgetWithText(TextButton, '删除'),
      ),
    );
    await pumpBounded(tester);

    expect(find.text('动作已删除'), findsOneWidget);
    expect(
      find.descendant(of: dataTable, matching: find.text(targetExerciseName)),
      findsNothing,
    );
  });

  testWidgets('WebTemplates 页面渲染模板并支持操作反馈', (tester) async {
    final handle = await createTestDatabase(prefix: 'fittrack-admin-template-');
    addTearDown(handle.dispose);

    final templateRepository = TemplateRepository(handle.database);
    const templateName = 'widget_admin_template_target';
    final templateId = await templateRepository.createTemplate(
      name: templateName,
      type: 'strength',
    );
    await templateRepository.addTemplateExercise(
      templateId: templateId,
      exerciseName: '测试动作',
      sets: 3,
      reps: 10,
    );

    final container = await pumpAdminPage(
      tester,
      const WebTemplatesPage(),
      database: handle.database,
    );
    addTearDown(container.dispose);

    expect(find.text('模板管理'), findsOneWidget);
    await pumpUntilFound(tester, find.text(templateName));
    expect(find.text(templateName), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, '导出'));
    await pumpBounded(tester);
    expect(find.text('导出功能开发中'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, '创建模板'));
    await pumpUntilFound(tester, find.text('模板名称'));

    final dialog = find.byType(AlertDialog);
    expect(
      find.descendant(of: dialog, matching: find.text('训练类型')),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(
        of: dialog,
        matching: find.widgetWithText(TextButton, '取消'),
      ),
    );
    await pumpBounded(tester);
  });

  testWidgets('WebBackup 页面在无配置时显示引导和必填反馈', (tester) async {
    final handle = await createTestDatabase(prefix: 'fittrack-admin-backup-');
    addTearDown(handle.dispose);

    final container = await pumpAdminPage(
      tester,
      const web_backup.BackupPage(),
      database: handle.database,
    );
    addTearDown(container.dispose);

    expect(find.text('备份管理'), findsOneWidget);
    expect(find.text('备份目标'), findsOneWidget);
    expect(find.textContaining('尚未配置备份目标'), findsOneWidget);
    expect(find.text('备份数据'), findsOneWidget);
    expect(find.byType(EmptyStateWidget), findsOneWidget);

    final addWebDavButton = find.widgetWithText(OutlinedButton, '添加 WebDAV');
    expect(addWebDavButton, findsOneWidget);
    await tester.ensureVisible(addWebDavButton);
    await tester.tap(addWebDavButton);
    await pumpUntilFound(tester, find.text('添加 WEBDAV 配置'));

    final dialog = find.byType(AlertDialog);
    await tester.tap(
      find.descendant(
        of: dialog,
        matching: find.widgetWithText(ElevatedButton, '保存'),
      ),
    );
    await pumpBounded(tester);

    expect(find.text('请填写所有必填字段'), findsOneWidget);
    expect(find.text('添加 WEBDAV 配置'), findsOneWidget);
  });
}
