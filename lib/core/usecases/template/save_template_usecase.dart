import '../../database/database.dart';
import '../../repositories/template_repository.dart';
import '../base/usecase.dart';

/// 模板动作输入
class TemplateExerciseInput {
  const TemplateExerciseInput({
    this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.reps,
    this.weight,
  });

  final int? exerciseId;
  final String exerciseName;
  final int sets;
  final int reps;
  final double? weight;
}

/// 创建模板参数
class SaveTemplateParams {
  const SaveTemplateParams({
    required this.name,
    required this.type,
    this.description,
    this.isDefault = false,
    this.exercises = const [],
  });

  final String name;
  final String type;
  final String? description;
  final bool isDefault;
  final List<TemplateExerciseInput> exercises;
}

/// 创建模板 Use Case
/// 负责在同一事务中创建模板及其动作，避免半成功状态。
class SaveTemplateUseCase extends UseCase<int, SaveTemplateParams> {
  SaveTemplateUseCase(this._db, this._repository);

  final AppDatabase _db;
  final TemplateRepository _repository;

  @override
  Future<int> call(SaveTemplateParams params) async {
    return await _db.transaction(() async {
      final templateId = await _repository.createTemplate(
        name: params.name,
        type: params.type,
        description: params.description,
        isDefault: params.isDefault,
      );

      if (params.exercises.isNotEmpty) {
        await _repository.addTemplateExercises(
          templateId,
          params.exercises
              .map(
                (exercise) => TemplateExerciseData(
                  exerciseId: exercise.exerciseId,
                  exerciseName: exercise.exerciseName,
                  sets: exercise.sets,
                  reps: exercise.reps,
                  weight: exercise.weight,
                ),
              )
              .toList(),
        );
      }

      return templateId;
    });
  }
}
