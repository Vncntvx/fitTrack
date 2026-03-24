import 'dart:io';

import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/template_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test('deleteTemplate returns 0 when template does not exist', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-template-delete-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final repository = TemplateRepository(db);

      final deleted = await repository.deleteTemplate(999999);
      expect(deleted, 0);

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}
