import 'dart:io';

import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/template_repository.dart';
import 'package:fittrack/core/usecases/template/duplicate_template_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test('duplicate template copies all exercises in one flow', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-duplicate-template-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);
      final repo = TemplateRepository(db);

      final templateId = await repo.createTemplate(
        name: '全身训练',
        type: 'strength',
        description: '原始模板',
      );
      await repo.addTemplateExercises(templateId, [
        TemplateExerciseData(exerciseName: '深蹲', sets: 5, reps: 5, weight: 100),
        TemplateExerciseData(exerciseName: '卧推', sets: 5, reps: 5, weight: 80),
      ]);

      final useCase = DuplicateTemplateUseCase(db, repo);
      final result = await useCase(
        DuplicateTemplateParams(templateId: templateId),
      );

      expect(result.$1, DuplicateTemplateResult.success);
      expect(result.$2, isNotNull);

      final duplicated = await repo.getTemplateDetail(result.$2!);
      expect(duplicated, isNotNull);
      expect(duplicated!.template.id, isNot(templateId));
      expect(duplicated.template.name, '全身训练 (副本)');
      expect(duplicated.exercises, hasLength(2));
      expect(duplicated.exercises[0].exerciseName, '深蹲');
      expect(duplicated.exercises[0].sets, 5);
      expect(duplicated.exercises[1].exerciseName, '卧推');
      expect(duplicated.exercises[1].weight, 80);

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });

  test(
    'duplicate template returns notFound when template does not exist',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'fittrack-duplicate-template-not-found-',
      );
      final dbPath = path.join(tempDir.path, 'fittrack.db');

      try {
        final db = AppDatabase.native(path: dbPath);
        final repo = TemplateRepository(db);
        final useCase = DuplicateTemplateUseCase(db, repo);

        final result = await useCase(
          const DuplicateTemplateParams(templateId: 999999),
        );

        expect(result.$1, DuplicateTemplateResult.notFound);
        expect(result.$2, isNull);
        expect(await repo.getAll(), isEmpty);

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );
}
