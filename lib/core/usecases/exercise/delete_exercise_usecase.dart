import '../../repositories/exercise_repository.dart';
import '../base/usecase.dart';

/// 删除动作结果
enum DeleteExerciseResult {
  success,
  hasStrengthReferences,
  hasTemplateReferences,
  hasPrReferences,
  notFound,
}

/// 删除动作 Use Case
/// 封装引用检查的业务规则
class DeleteExerciseUseCase extends UseCase<DeleteExerciseResult, int> {
  final ExerciseRepository _repository;

  DeleteExerciseUseCase(this._repository);

  @override
  Future<DeleteExerciseResult> call(int id) async {
    final exercise = await _repository.getById(id);
    if (exercise == null) {
      return DeleteExerciseResult.notFound;
    }

    // 检查引用
    final refs = await _repository.getReferences(id);

    if (refs.strengthEntryCount > 0) {
      return DeleteExerciseResult.hasStrengthReferences;
    }

    if (refs.templateCount > 0) {
      return DeleteExerciseResult.hasTemplateReferences;
    }

    if (refs.prCount > 0) {
      return DeleteExerciseResult.hasPrReferences;
    }

    // 安全删除
    await _repository.delete(id);
    return DeleteExerciseResult.success;
  }
}
