import 'dart:io';

import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/backup_config_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test('setDefault throws for missing config id and keeps previous default', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-backup-config-default-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final repository = BackupConfigRepository(db);

      final configId = await repository.createWebDavConfig(
        displayName: 'default',
        endpoint: 'https://example.com',
        path: '/backups',
        isDefault: true,
      );

      await expectLater(
        repository.setDefault(configId + 1000),
        throwsA(isA<ArgumentError>()),
      );

      final defaultConfig = await repository.getDefault();
      expect(defaultConfig, isNotNull);
      expect(defaultConfig!.id, configId);

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}
