import '../../repositories/training_repository.dart';
import '../base/usecase.dart';

/// 通用训练保存参数
class SaveWorkoutParams {
  const SaveWorkoutParams({
    this.sessionId,
    required this.datetime,
    required this.type,
    required this.durationMinutes,
    required this.intensity,
    this.note,
    this.isGoalCompleted = false,
    this.templateId,
  });

  final int? sessionId;
  final DateTime datetime;
  final String type;
  final int durationMinutes;
  final String intensity;
  final String? note;
  final bool isGoalCompleted;
  final int? templateId;
}

/// 通用训练保存结果
enum SaveWorkoutResult {
  success,
  notFound,
  unsupportedType,
}

/// 通用训练保存 Use Case
/// 用于快速记录和 LAN 基础训练 CRUD，保持 UI/HTTP 不直接操作 Repository。
class SaveWorkoutUseCase
    extends UseCase<(SaveWorkoutResult, int?), SaveWorkoutParams> {
  SaveWorkoutUseCase(this._repository);

  final TrainingRepository _repository;
  static const Set<String> _unsupportedTypes = {
    'strength',
    'running',
    'swimming',
  };

  @override
  Future<(SaveWorkoutResult, int?)> call(SaveWorkoutParams params) async {
    if (_unsupportedTypes.contains(params.type)) {
      return (SaveWorkoutResult.unsupportedType, null);
    }

    if (params.sessionId != null) {
      final existing = await _repository.getById(params.sessionId!);
      if (existing == null) {
        return (SaveWorkoutResult.notFound, null);
      }
      if (_unsupportedTypes.contains(existing.type)) {
        return (SaveWorkoutResult.unsupportedType, null);
      }

      final success = await _repository.updateTraining(
        params.sessionId!,
        datetime: params.datetime,
        type: params.type,
        durationMinutes: params.durationMinutes,
        intensity: params.intensity,
        note: params.note,
        isGoalCompleted: params.isGoalCompleted,
        templateId: params.templateId,
      );
      if (!success) {
        return (SaveWorkoutResult.notFound, null);
      }
      return (SaveWorkoutResult.success, params.sessionId);
    }

    final sessionId = await _repository.createTraining(
      datetime: params.datetime,
      type: params.type,
      durationMinutes: params.durationMinutes,
      intensity: params.intensity,
      note: params.note,
      isGoalCompleted: params.isGoalCompleted,
      templateId: params.templateId,
    );
    return (SaveWorkoutResult.success, sessionId);
  }
}
