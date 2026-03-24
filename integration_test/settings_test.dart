import 'dart:io';
import 'dart:ui';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fittrack/app.dart';
import 'package:fittrack/core/backup/backup_crypto_service.dart';
import 'package:fittrack/core/backup/backup_provider.dart';
import 'package:fittrack/core/backup/backup_service.dart';
import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/network/network_info_service.dart';
import 'package:fittrack/core/repositories/settings_repository.dart';
import 'package:fittrack/main.dart' as app;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class _InMemoryBackupProvider implements BackupProvider {
  Uint8List? payload;
  String? uploadedPath;

  @override
  Future<void> delete(String path) async {}

  @override
  Future<Uint8List> download(String path) async {
    if (payload == null) {
      throw StateError('未找到备份数据');
    }
    return payload!;
  }

  @override
  Future<List<BackupFileInfo>> listFiles(String prefix) async => const [];

  @override
  Future<bool> testConnection() async => true;

  @override
  Future<void> upload(String path, Uint8List data) async {
    uploadedPath = path;
    payload = data;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const defaultTimeout = Duration(seconds: 20);
  const pumpStep = Duration(milliseconds: 100);

  late void Function(FlutterErrorDetails)? originalFlutterOnError;
  late bool Function(Object, StackTrace)? originalPlatformOnError;
  late ErrorWidgetBuilder originalErrorWidgetBuilder;

  setUp(() {
    originalFlutterOnError = FlutterError.onError;
    originalPlatformOnError = PlatformDispatcher.instance.onError;
    originalErrorWidgetBuilder = ErrorWidget.builder;
  });

  tearDown(() {
    FlutterError.onError = originalFlutterOnError;
    PlatformDispatcher.instance.onError = originalPlatformOnError;
    ErrorWidget.builder = originalErrorWidgetBuilder;
  });

  String collectVisibleTextSample(WidgetTester tester, {int maxItems = 20}) {
    final texts = find
        .byType(Text)
        .evaluate()
        .map((element) => element.widget as Text)
        .map((widget) => widget.data ?? widget.textSpan?.toPlainText())
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
    throw TestFailure('$message\n可见文本样本: ${collectVisibleTextSample(tester)}');
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
    final message =
        failureMessage ?? '在限定时间内未找到任一目标控件: ${finders.join(' OR ')}';
    throw TestFailure('$message\n可见文本样本: ${collectVisibleTextSample(tester)}');
  }

  Future<void> pumpUntilGone(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = defaultTimeout,
    Duration step = pumpStep,
    String? failureMessage,
  }) async {
    final maxPumps = (timeout.inMilliseconds / step.inMilliseconds).ceil();
    for (var i = 0; i < maxPumps; i++) {
      if (finder.evaluate().isEmpty) {
        return;
      }
      await tester.pump(step);
    }
    final message = failureMessage ?? '在限定时间内目标控件未消失: $finder';
    throw TestFailure('$message\n可见文本样本: ${collectVisibleTextSample(tester)}');
  }

  Future<void> tapWhenReady(
    WidgetTester tester,
    Finder finder, {
    String? failureMessage,
  }) async {
    await pumpUntilFound(tester, finder, failureMessage: failureMessage);
    await tester.ensureVisible(finder.first);
    await tester.pump(pumpStep);
    final hitTestable = finder.hitTestable();
    await pumpUntilFound(tester, hitTestable, failureMessage: failureMessage);
    await tester.tap(hitTestable.first);
    await tester.pump(pumpStep);
  }

  Finder navDestinationInShell(String label) {
    return find.descendant(
      of: find.byType(NavigationBar),
      matching: find.widgetWithText(NavigationDestination, label),
    );
  }

  Finder settingsTile(String title) {
    return find.ancestor(of: find.text(title), matching: find.byType(ListTile));
  }

  Future<void> launchApp(WidgetTester tester) async {
    await app.bootstrapApp();
    runApp(const ProviderScope(child: WorkoutTrackerApp()));
    await tester.pump(pumpStep);
    await pumpUntilFound(
      tester,
      find.byType(NavigationBar),
      failureMessage: '应用启动后未出现底部导航栏',
    );
    await pumpUntilAnyFound(tester, [
      find.text('今日'),
      find.text('历史记录'),
      find.text('统计数据'),
      find.text('设置'),
    ], failureMessage: '应用启动后未进入主导航页');
  }

  Future<void> relaunchApp(WidgetTester tester) async {
    runApp(const SizedBox.shrink());
    await tester.pump(pumpStep);
    runApp(const ProviderScope(child: WorkoutTrackerApp()));
    await tester.pump(pumpStep);
    await pumpUntilFound(
      tester,
      find.byType(NavigationBar),
      failureMessage: '重启后未出现底部导航栏',
    );
  }

  Future<void> shutdownApp(WidgetTester tester) async {
    runApp(const SizedBox.shrink());
    await tester.pump(pumpStep);
    await tester.pump(pumpStep);
  }

  Future<String> createIsolatedDatabasePath(String prefix) async {
    final supportDir = await getApplicationSupportDirectory();
    return path.join(
      supportDir.path,
      '${prefix}_${DateTime.now().microsecondsSinceEpoch}.db',
    );
  }

  Future<void> openSettingsPage(WidgetTester tester) async {
    await tapWhenReady(
      tester,
      navDestinationInShell('设置'),
      failureMessage: '未找到设置导航入口',
    );
    await pumpUntilAnyFound(tester, [
      find.text('目标设置'),
      find.text('单位设置'),
    ], failureMessage: '未进入设置页');
  }

  group('Settings integration', () {
    testWidgets('Distance unit persists after navigation and relaunch', (
      WidgetTester tester,
    ) async {
      try {
        await launchApp(tester);
        await openSettingsPage(tester);

        final distanceTile = settingsTile('距离单位');
        final targetLabel =
            find
                .descendant(of: distanceTile, matching: find.text('公里 (km)'))
                .evaluate()
                .isNotEmpty
            ? '英里 (mi)'
            : '公里 (km)';

        await tapWhenReady(tester, distanceTile, failureMessage: '未找到距离单位设置项');
        await pumpUntilFound(
          tester,
          find.byType(AlertDialog),
          failureMessage: '点击距离单位后未弹出选择框',
        );

        final kmOption = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('公里 (km)'),
        );
        final miOption = find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('英里 (mi)'),
        );
        await pumpUntilAnyFound(tester, [
          kmOption,
          miOption,
        ], failureMessage: '距离单位对话框未渲染可选项');

        await tapWhenReady(
          tester,
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text(targetLabel),
          ),
          failureMessage: '未找到目标距离单位选项',
        );
        await pumpUntilGone(
          tester,
          find.byType(AlertDialog),
          failureMessage: '选择距离单位后对话框未关闭',
        );

        await pumpUntilFound(
          tester,
          find.descendant(of: distanceTile, matching: find.text(targetLabel)),
          failureMessage: '设置页未显示新的距离单位',
        );

        await tapWhenReady(
          tester,
          navDestinationInShell('历史'),
          failureMessage: '未找到历史导航入口',
        );
        await pumpUntilFound(
          tester,
          find.text('历史记录'),
          failureMessage: '未进入历史页',
        );

        await openSettingsPage(tester);
        await pumpUntilFound(
          tester,
          find.descendant(of: distanceTile, matching: find.text(targetLabel)),
          failureMessage: '跨页面返回后距离单位未持久化',
        );

        await relaunchApp(tester);
        await openSettingsPage(tester);
        await pumpUntilFound(
          tester,
          find.descendant(of: distanceTile, matching: find.text(targetLabel)),
          failureMessage: '重启应用后距离单位未持久化',
        );
      } finally {
        await shutdownApp(tester);
      }
    });
  });

  group('Backup and restore integration', () {
    testWidgets('Backup restore reverts settings and post-backup writes', (
      WidgetTester tester,
    ) async {
      final dbPath = await createIsolatedDatabasePath('fittrack_it_backup');
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      final db = AppDatabase.native(path: dbPath);
      final backupService = BackupService(db);
      final settingsRepo = SettingsRepository(db);
      final provider = _InMemoryBackupProvider();
      int? createdConfigId;
      String? createdBackupPath;

      try {
        final existingConfig =
            await (db.select(db.backupConfigurations)
                  ..orderBy([(t) => OrderingTerm.asc(t.id)])
                  ..limit(1))
                .getSingleOrNull();

        final activeConfig =
            existingConfig ??
            await (() async {
              createdConfigId = await db
                  .into(db.backupConfigurations)
                  .insert(
                    const BackupConfigurationsCompanion(
                      providerType: Value('webdav'),
                      displayName: Value('integration-test'),
                      endpoint: Value('https://integration.local'),
                      bucketOrPath: Value('/fittrack'),
                      isDefault: Value(false),
                    ),
                  );
              return (db.select(db.backupConfigurations)
                    ..where((t) => t.id.equals(createdConfigId!))
                    ..limit(1))
                  .getSingle();
            })();

        await settingsRepo.getOrCreateSettings();
        final beforeSettings = await (db.select(
          db.userSettings,
        )..limit(1)).getSingle();

        final backupResult = await backupService.backup(
          provider,
          'integration_backups',
          configId: activeConfig.id,
        );
        expect(
          backupResult.success,
          isTrue,
          reason: '备份失败: ${backupResult.error}',
        );
        createdBackupPath = backupResult.path;
        expect(provider.uploadedPath, isNot(equals(null)));
        expect(provider.payload, isNot(equals(null)));

        final envelope = BackupCryptoService.tryParseEnvelope(
          provider.payload!,
        );
        expect(envelope, isA<BackupEncryptionEnvelope>());
        expect(envelope!.payloadVersion, isNotEmpty);

        final recordCandidates = await backupService.listBackups(
          activeConfig.id,
        );
        expect(recordCandidates, isNotEmpty);
        final backupRecord = recordCandidates.firstWhere(
          (record) => record.targetPath == backupResult.path,
          orElse: () => throw StateError('未找到本次备份记录'),
        );

        final changedDays = beforeSettings.weeklyWorkoutDaysGoal == 7 ? 6 : 7;
        final changedMinutes = beforeSettings.weeklyWorkoutMinutesGoal == 600
            ? 540
            : 600;
        final changedWeightUnit = beforeSettings.weightUnit == 'kg'
            ? 'lbs'
            : 'kg';
        final changedDistanceUnit = beforeSettings.distanceUnit == 'km'
            ? 'mi'
            : 'km';
        final marker =
            'integration-restore-${DateTime.now().microsecondsSinceEpoch}';

        await settingsRepo.updateWeeklyDaysGoal(changedDays);
        await settingsRepo.updateWeeklyMinutesGoal(changedMinutes);
        await settingsRepo.updateWeightUnit(changedWeightUnit);
        await settingsRepo.updateDistanceUnit(changedDistanceUnit);
        await db
            .into(db.trainingSessions)
            .insert(
              TrainingSessionsCompanion.insert(
                datetime: DateTime.now(),
                type: 'cycling',
                durationMinutes: 30,
                intensity: 'moderate',
                note: Value(marker),
              ),
            );

        final mutatedSettings = await (db.select(
          db.userSettings,
        )..limit(1)).getSingle();
        expect(
          mutatedSettings.weeklyWorkoutDaysGoal,
          isNot(beforeSettings.weeklyWorkoutDaysGoal),
        );
        expect(mutatedSettings.weightUnit, isNot(beforeSettings.weightUnit));
        expect(
          mutatedSettings.distanceUnit,
          isNot(beforeSettings.distanceUnit),
        );

        final restoreResult = await backupService.restore(
          provider,
          backupRecord,
        );
        expect(
          restoreResult.success,
          isTrue,
          reason: '恢复失败: ${restoreResult.error}',
        );

        final restoredSettings = await (db.select(
          db.userSettings,
        )..limit(1)).getSingle();
        expect(
          restoredSettings.weeklyWorkoutDaysGoal,
          beforeSettings.weeklyWorkoutDaysGoal,
        );
        expect(
          restoredSettings.weeklyWorkoutMinutesGoal,
          beforeSettings.weeklyWorkoutMinutesGoal,
        );
        expect(restoredSettings.weightUnit, beforeSettings.weightUnit);
        expect(restoredSettings.distanceUnit, beforeSettings.distanceUnit);

        final postBackupSessions = await (db.select(
          db.trainingSessions,
        )..where((t) => t.note.equals(marker))).get();
        expect(postBackupSessions, isEmpty);
      } finally {
        if (createdBackupPath != null) {
          await (db.delete(
            db.backupRecords,
          )..where((t) => t.targetPath.equals(createdBackupPath!))).go();
        }
        if (createdConfigId != null) {
          await (db.delete(
            db.backupRecords,
          )..where((t) => t.configId.equals(createdConfigId!))).go();
          await (db.delete(
            db.backupConfigurations,
          )..where((t) => t.id.equals(createdConfigId!))).go();
        }
        await db.close();
        if (await dbFile.exists()) {
          await dbFile.delete();
        }
      }
    });
  });

  group('Network Info Service', () {
    testWidgets('Should get IP address', (WidgetTester tester) async {
      try {
        await launchApp(tester);
        final ip = await NetworkInfoService.getLocalIpAddress();

        // 模拟器场景下可能为空，这里仅校验非空时格式基本有效
        if (ip != null) {
          expect(ip.isNotEmpty, true);
        }
      } finally {
        await shutdownApp(tester);
      }
    });
  });
}
