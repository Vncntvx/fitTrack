import 'dart:io';

import 'package:fittrack/core/database/database.dart';
import 'package:path/path.dart' as path;

/// 测试数据库句柄
class TestDatabaseHandle {
  TestDatabaseHandle({
    required this.tempDir,
    required this.database,
  });

  final Directory tempDir;
  final AppDatabase database;
  bool _disposed = false;

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await database.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  }
}

/// 创建独立临时数据库
Future<TestDatabaseHandle> createTestDatabase({
  String prefix = 'fittrack-test-',
}) async {
  final tempDir = Directory.systemTemp.createTempSync(prefix);
  final dbPath = path.join(tempDir.path, 'fittrack.db');
  final database = AppDatabase.native(path: dbPath);
  return TestDatabaseHandle(tempDir: tempDir, database: database);
}

/// 在独立数据库上下文中执行测试逻辑
Future<T> withTestDatabase<T>({
  String prefix = 'fittrack-test-',
  required Future<T> Function(AppDatabase db) body,
}) async {
  final handle = await createTestDatabase(prefix: prefix);
  try {
    return await body(handle.database);
  } finally {
    await handle.dispose();
  }
}
