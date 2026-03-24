import 'dart:io';

import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/providers/app_database_provider.dart';
import 'package:fittrack/core/repositories/settings_repository.dart';
import 'package:fittrack/shared/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

class _FailingSettingsRepository extends SettingsRepository {
  _FailingSettingsRepository(super.db);

  @override
  Future<String> getThemeMode() async => 'system';

  @override
  Future<bool> updateThemeMode(String themeMode) async => false;
}

void main() {
  group('ThemeModeNotifier', () {
    test('loads persisted mode and persists updates', () async {
      final tempDir = await Directory.systemTemp.createTemp('fittrack-theme-');
      final dbPath = path.join(tempDir.path, 'fittrack.db');
      final db = AppDatabase.native(path: dbPath);

      try {
        final settings = SettingsRepository(db);
        await settings.updateThemeMode('dark');

        // 创建 ProviderContainer 测试
        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
          ],
        );

        // 等待初始化完成
        final notifier = container.read(themeModeProvider.notifier);
        await notifier.future;

        // 验证加载的主题
        expect(
          container.read(themeModeProvider).value,
          ThemeMode.dark,
        );

        // 更新主题
        await notifier.setThemeMode(ThemeModeOption.light);

        expect(
          container.read(themeModeProvider).value,
          ThemeMode.light,
        );
        expect(await settings.getThemeMode(), 'light');

        container.dispose();
      } finally {
        await db.close();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });

    test('throws and keeps state when persistence fails', () async {
      final tempDir = await Directory.systemTemp.createTemp('fittrack-theme-');
      final dbPath = path.join(tempDir.path, 'fittrack.db');
      final db = AppDatabase.native(path: dbPath);

      try {
        final container = ProviderContainer(
          overrides: [
            settingsRepositoryProvider.overrideWithValue(
              _FailingSettingsRepository(db),
            ),
          ],
        );

        final notifier = container.read(themeModeProvider.notifier);
        await notifier.future;

        await expectLater(
          notifier.setThemeMode(ThemeModeOption.dark),
          throwsA(isA<StateError>()),
        );

        // 验证状态保持不变
        expect(
          container.read(themeModeProvider).value,
          ThemeMode.system,
        );

        container.dispose();
      } finally {
        await db.close();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });
  });
}
