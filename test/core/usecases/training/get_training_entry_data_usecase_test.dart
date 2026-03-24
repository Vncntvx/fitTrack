import 'package:fittrack/core/usecases/training/get_training_entry_data_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' show Value;
import 'package:fittrack/core/database/database.dart';

import '../../../helpers/test_data_builder.dart';
import '../../../helpers/test_db_helper.dart';

void main() {
  test(
    'get training entry data returns recent templates and last session',
    () async {
      await withTestDatabase(
        body: (db) async {
          final builder = TestDataBuilder(db);

          final templateAId = await builder.addTemplate(
            name: '力量模板A',
            type: 'strength',
          );
          final templateBId = await builder.addTemplate(
            name: '跑步模板B',
            type: 'running',
          );
          final templateCId = await builder.addTemplate(
            name: '游泳模板C',
            type: 'swimming',
          );
          final templateDId = await builder.addTemplate(
            name: '力量模板D',
            type: 'strength',
          );

          await (db.update(
            db.workoutTemplates,
          )..where((t) => t.id.equals(templateAId))).write(
            WorkoutTemplatesCompanion(
              updatedAt: Value(DateTime(2026, 3, 1, 10)),
            ),
          );
          await (db.update(
            db.workoutTemplates,
          )..where((t) => t.id.equals(templateBId))).write(
            WorkoutTemplatesCompanion(
              updatedAt: Value(DateTime(2026, 3, 2, 10)),
            ),
          );
          await (db.update(
            db.workoutTemplates,
          )..where((t) => t.id.equals(templateCId))).write(
            WorkoutTemplatesCompanion(
              updatedAt: Value(DateTime(2026, 3, 3, 10)),
            ),
          );
          await (db.update(
            db.workoutTemplates,
          )..where((t) => t.id.equals(templateDId))).write(
            WorkoutTemplatesCompanion(
              updatedAt: Value(DateTime(2026, 3, 4, 10)),
            ),
          );

          await builder.addTrainingSession(
            datetime: DateTime(2026, 3, 1, 8),
            type: 'cycling',
          );
          await builder.addTrainingSession(
            datetime: DateTime(2026, 3, 2, 9),
            type: 'walking',
          );

          final useCase = GetTrainingEntryDataUseCase(
            builder.templateRepo,
            builder.trainingRepo,
          );
          final result = await useCase(
            const GetTrainingEntryDataParams(templateLimit: 3),
          );

          expect(result.recentTemplates, hasLength(3));
          expect(
            result.recentTemplates.map((template) => template.name).toList(),
            ['力量模板D', '游泳模板C', '跑步模板B'],
          );
          expect(result.lastSession, isNotNull);
          expect(result.lastSession!.datetime, DateTime(2026, 3, 2, 9));
          expect(result.lastSession!.type, 'walking');
        },
      );
    },
  );

  test('get training entry data respects template limit boundary', () async {
    await withTestDatabase(
      body: (db) async {
        final builder = TestDataBuilder(db);
        await builder.addTemplate(name: '力量模板A', type: 'strength');
        await builder.addTemplate(name: '跑步模板B', type: 'running');
        await builder.addTrainingSession(
          datetime: DateTime(2026, 3, 8, 6),
          type: 'cycling',
        );

        final useCase = GetTrainingEntryDataUseCase(
          builder.templateRepo,
          builder.trainingRepo,
        );
        final result = await useCase(
          const GetTrainingEntryDataParams(templateLimit: 0),
        );

        expect(result.recentTemplates, isEmpty);
        expect(result.lastSession, isNotNull);
        expect(result.lastSession!.type, 'cycling');
      },
    );
  });

  test(
    'get training entry data returns empty list and null when no data',
    () async {
      await withTestDatabase(
        body: (db) async {
          final builder = TestDataBuilder(db);
          final useCase = GetTrainingEntryDataUseCase(
            builder.templateRepo,
            builder.trainingRepo,
          );

          final result = await useCase(const GetTrainingEntryDataParams());

          expect(result.recentTemplates, isEmpty);
          expect(result.lastSession, isNull);
        },
      );
    },
  );
}
