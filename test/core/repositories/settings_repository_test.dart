import 'dart:io';

import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test('theme and unit settings persist after reopening database', () async {
    final tempDir = await Directory.systemTemp.createTemp('fittrack-settings-');
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db1 = AppDatabase.native(path: dbPath);
      final repo1 = SettingsRepository(db1);

      expect(await repo1.updateThemeMode('dark'), isTrue);
      expect(await repo1.updateWeightUnit('lbs'), isTrue);
      expect(await repo1.updateDistanceUnit('mi'), isTrue);
      expect(await repo1.getThemeMode(), 'dark');
      expect(await repo1.getWeightUnit(), 'lbs');
      expect(await repo1.getDistanceUnit(), 'mi');
      await db1.close();

      final db2 = AppDatabase.native(path: dbPath);
      final repo2 = SettingsRepository(db2);
      expect(await repo2.getThemeMode(), 'dark');
      expect(await repo2.getWeightUnit(), 'lbs');
      expect(await repo2.getDistanceUnit(), 'mi');
      await db2.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });

  test('rejects invalid unit values', () async {
    final tempDir = await Directory.systemTemp.createTemp('fittrack-settings-');
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final repo = SettingsRepository(db);

      await expectLater(
        repo.updateWeightUnit('stone'),
        throwsA(isA<ArgumentError>()),
      );
      await expectLater(
        repo.updateDistanceUnit('meter'),
        throwsA(isA<ArgumentError>()),
      );
      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}
