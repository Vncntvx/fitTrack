import '../../database/database.dart';
import '../../repositories/template_repository.dart';
import '../base/usecase.dart';

/// 复制模板参数
class DuplicateTemplateParams {
  const DuplicateTemplateParams({
    required this.templateId,
    this.nameOverride,
  });

  final int templateId;
  final String? nameOverride;
}

/// 复制模板结果
enum DuplicateTemplateResult {
  success,
  notFound,
}

/// 复制模板 Use Case
/// 负责完整复制模板及其动作列表，确保 Web 与 App 行为一致。
class DuplicateTemplateUseCase
    extends UseCase<(DuplicateTemplateResult, int?), DuplicateTemplateParams> {
  DuplicateTemplateUseCase(this._db, this._repository);

  final AppDatabase _db;
  final TemplateRepository _repository;

  @override
  Future<(DuplicateTemplateResult, int?)> call(
    DuplicateTemplateParams params,
  ) async {
    return await _db.transaction(() async {
      final detail = await _repository.getTemplateDetail(params.templateId);
      if (detail == null) {
        return (DuplicateTemplateResult.notFound, null);
      }

      final newTemplateId = await _repository.createTemplate(
        name: params.nameOverride ?? '${detail.template.name} (副本)',
        type: detail.template.type,
        description: detail.template.description,
      );

      if (detail.exercises.isNotEmpty) {
        await _repository.addTemplateExercises(
          newTemplateId,
          detail.exercises
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

      return (DuplicateTemplateResult.success, newTemplateId);
    });
  }
}
