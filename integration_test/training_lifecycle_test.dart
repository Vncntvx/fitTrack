import 'dart:ui';

import 'package:fittrack/app.dart';
import 'package:fittrack/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const defaultTimeout = Duration(seconds: 20);
  const pumpStep = Duration(milliseconds: 100);

  String collectVisibleTextSample(WidgetTester tester, {int maxItems = 20}) {
    final texts = find
        .byType(Text)
        .evaluate()
        .map((element) => element.widget as Text)
        .map(
          (textWidget) => textWidget.data ?? textWidget.textSpan?.toPlainText(),
        )
        .whereType<String>()
        .map((text) => text.trim())
        .where((text) => text.isNotEmpty)
        .toSet()
        .take(maxItems)
        .toList();
    return texts.isEmpty ? '无可见 Text' : texts.join(' | ');
  }

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = defaultTimeout,
    Duration step = pumpStep,
    String? failureMessage,
  }) async {
    final maxPumps = (timeout.inMilliseconds / step.inMilliseconds).ceil();
    for (var i = 0; i < maxPumps; i++) {
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      await tester.pump(step);
    }
    final message = failureMessage ?? '在限定时间内未找到目标控件: $finder';
    final textSample = collectVisibleTextSample(tester);
    throw TestFailure('$message\n可见文本样本: $textSample');
  }

  Future<void> pumpUntilAnyFound(
    WidgetTester tester,
    List<Finder> finders, {
    Duration timeout = defaultTimeout,
    Duration step = pumpStep,
    String? failureMessage,
  }) async {
    final maxPumps = (timeout.inMilliseconds / step.inMilliseconds).ceil();
    for (var i = 0; i < maxPumps; i++) {
      if (finders.any((finder) => finder.evaluate().isNotEmpty)) {
        return;
      }
      await tester.pump(step);
    }

    final markerDescriptions = finders.join(' OR ');
    final message = failureMessage ?? '在限定时间内未找到任一目标控件: $markerDescriptions';
    final textSample = collectVisibleTextSample(tester);
    throw TestFailure('$message\n可见文本样本: $textSample');
  }

  Future<void> tapWhenReady(
    WidgetTester tester,
    Finder finder, {
    String? failureMessage,
  }) async {
    await pumpUntilFound(tester, finder, failureMessage: failureMessage);

    await tester.ensureVisible(finder.first);
    await tester.pump(pumpStep);

    final hitTestableFinder = finder.hitTestable();
    await pumpUntilFound(
      tester,
      hitTestableFinder,
      failureMessage: failureMessage,
    );
    await tester.tap(hitTestableFinder.first);
    await tester.pump(pumpStep);
  }

  Future<void> enterTextWhenReady(
    WidgetTester tester,
    Finder finder,
    String text, {
    String? failureMessage,
  }) async {
    await tapWhenReady(tester, finder, failureMessage: failureMessage);
    await tester.enterText(finder.first, text);
    await tester.pump(pumpStep);
  }

  Future<void> launchApp(WidgetTester tester) async {
    final originalFlutterOnError = FlutterError.onError;
    final originalPlatformOnError = PlatformDispatcher.instance.onError;
    addTearDown(() {
      FlutterError.onError = originalFlutterOnError;
      PlatformDispatcher.instance.onError = originalPlatformOnError;
    });

    await app.bootstrapApp();
    runApp(const ProviderScope(child: WorkoutTrackerApp()));
    await tester.pump(pumpStep);
    await pumpUntilFound(
      tester,
      find.byType(NavigationBar),
      failureMessage: '应用启动后未出现底部导航栏',
    );
    await pumpUntilFound(
      tester,
      find.widgetWithText(FloatingActionButton, '开始训练'),
      failureMessage: '应用启动后未出现开始训练按钮',
    );
  }

  testWidgets('E2E: quick log create -> history visible -> stats visible', (
    WidgetTester tester,
  ) async {
    final uniqueNote = 'e2e-${DateTime.now().millisecondsSinceEpoch}';
    final trainingEntryMarkers = [
      find.text('最近模板'),
      find.text('复制上次训练'),
      find.text('其他'),
    ];
    Finder navDestinationInShell(String label) {
      return find.descendant(
        of: find.byType(NavigationBar),
        matching: find.widgetWithText(NavigationDestination, label),
      );
    }

    await launchApp(tester);

    await tapWhenReady(
      tester,
      find.byType(FloatingActionButton),
      failureMessage: '未找到开始训练浮动按钮',
    );
    await pumpUntilAnyFound(
      tester,
      trainingEntryMarkers,
      failureMessage: '点击开始训练后未进入训练入口页',
    );

    // 训练入口已改为“先选运动类型”，选择“其他”进入快速记录页。
    await tapWhenReady(tester, find.text('其他'), failureMessage: '未找到其他运动类型入口');
    await pumpUntilFound(
      tester,
      find.text('快速记录'),
      failureMessage: '未进入快速记录页面',
    );
    await pumpUntilFound(
      tester,
      find.text('运动类型'),
      failureMessage: '快速记录页面未渲染运动类型模块',
    );

    await tapWhenReady(
      tester,
      find.widgetWithText(ChoiceChip, '骑行'),
      failureMessage: '未找到骑行选项',
    );
    await tapWhenReady(
      tester,
      find.widgetWithText(ChoiceChip, '中度'),
      failureMessage: '未找到中度强度选项',
    );
    await enterTextWhenReady(
      tester,
      find.byType(TextFormField),
      uniqueNote,
      failureMessage: '未找到备注输入框',
    );
    await tester.scrollUntilVisible(
      find.widgetWithText(ElevatedButton, '保存记录'),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump(pumpStep);
    await tapWhenReady(
      tester,
      find.widgetWithText(ElevatedButton, '保存记录'),
      failureMessage: '未找到保存记录按钮',
    );
    await pumpUntilFound(
      tester,
      find.text('记录已保存'),
      failureMessage: '保存后未出现成功提示',
    );

    // 保存后会返回训练入口页，回退一次返回主导航壳。
    await pumpUntilAnyFound(
      tester,
      trainingEntryMarkers,
      failureMessage: '保存后未返回训练入口页',
    );
    final didPop = await tester.binding.handlePopRoute();
    expect(didPop, isTrue);
    await pumpUntilFound(tester, find.byType(NavigationBar));

    await tapWhenReady(
      tester,
      navDestinationInShell('历史'),
      failureMessage: '未找到历史导航入口',
    );
    await pumpUntilFound(tester, find.text('历史记录'));
    await enterTextWhenReady(
      tester,
      find.byType(TextField),
      uniqueNote,
      failureMessage: '未找到历史搜索框',
    );
    await tester.pump(pumpStep);
    expect(find.widgetWithText(ListTile, '骑行'), findsWidgets);
    expect(find.widgetWithText(ListTile, uniqueNote), findsOneWidget);

    await tapWhenReady(
      tester,
      navDestinationInShell('统计'),
      failureMessage: '未找到统计导航入口',
    );
    await pumpUntilFound(tester, find.text('统计数据'));
    expect(find.text('总览'), findsOneWidget);
    expect(find.text('本周训练'), findsOneWidget);
    expect(find.text('训练类型分布'), findsOneWidget);
  });
}
