import 'package:fittrack/core/repositories/template_repository.dart';
import 'package:fittrack/core/usecases/template/save_template_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_db_helper.dart';

void main() {
  test('creates template and exercises in a single flow', () async {
    await withTestDatabase(
      body: (db) async {
        final repository = TemplateRepository(db);
        final useCase = SaveTemplateUseCase(db, repository);

        final templateId = await useCase(
          const SaveTemplateParams(
            name: '半马训练模板',
            type: 'running',
            description: '跑步专项',
            isDefault: true,
            exercises: [
              TemplateExerciseInput(exerciseName: '热身跑', sets: 1, reps: 1),
              TemplateExerciseInput(exerciseName: '间歇跑', sets: 6, reps: 400),
            ],
          ),
        );

        final detail = await repository.getTemplateDetail(templateId);
        expect(detail, isNotNull);
        expect(detail!.template.name, '半马训练模板');
        expect(detail.template.type, 'running');
        expect(detail.template.description, '跑步专项');
        expect(detail.template.isDefault, isTrue);
        expect(detail.exercises, hasLength(2));
        expect(detail.exercises[0].exerciseName, '热身跑');
        expect(detail.exercises[1].exerciseName, '间歇跑');
        expect(detail.exercises[1].sortOrder, 1);
      },
    );
  });

  test('creates template without exercises on boundary input', () async {
    await withTestDatabase(
      body: (db) async {
        final repository = TemplateRepository(db);
        final useCase = SaveTemplateUseCase(db, repository);

        final templateId = await useCase(
          const SaveTemplateParams(
            name: '空模板',
            type: 'strength',
            exercises: [],
          ),
        );

        final detail = await repository.getTemplateDetail(templateId);
        expect(detail, isNotNull);
        expect(detail!.template.name, '空模板');
        expect(detail.exercises, isEmpty);
      },
    );
  });

  test('rolls back template creation when exercise insert fails', () async {
    await withTestDatabase(
      body: (db) async {
        final repository = TemplateRepository(db);
        final useCase = SaveTemplateUseCase(db, repository);

        await db.customStatement('''
CREATE TRIGGER fail_template_exercise_insert
BEFORE INSERT ON template_exercises
BEGIN
  SELECT RAISE(ABORT, 'forced template exercise failure');
END;
''');

        await expectLater(
          useCase(
            const SaveTemplateParams(
              name: '失败模板',
              type: 'strength',
              exercises: [
                TemplateExerciseInput(exerciseName: '深蹲', sets: 3, reps: 5),
              ],
            ),
          ),
          throwsA(anything),
        );

        final templates = await repository.getAll();
        final exerciseRows = await db.select(db.templateExercises).get();
        expect(templates.where((template) => template.name == '失败模板'), isEmpty);
        expect(exerciseRows, isEmpty);
      },
    );
  });
}
