import '../../database/database.dart';
import '../../repositories/template_repository.dart';
import '../../repositories/training_repository.dart';
import '../base/usecase.dart';

/// 训练入口页参数
class GetTrainingEntryDataParams {
  const GetTrainingEntryDataParams({this.templateLimit = 3});

  final int templateLimit;
}

/// 训练入口页数据
class TrainingEntryData {
  const TrainingEntryData({
    required this.recentTemplates,
    required this.lastSession,
  });

  final List<WorkoutTemplate> recentTemplates;
  final TrainingSession? lastSession;
}

/// 训练入口页聚合查询 Use Case
/// 聚合最近模板和上次训练，避免 UI 直接依赖多个仓库。
class GetTrainingEntryDataUseCase
    extends UseCase<TrainingEntryData, GetTrainingEntryDataParams> {
  GetTrainingEntryDataUseCase(
    this._templateRepository,
    this._trainingRepository,
  );

  final TemplateRepository _templateRepository;
  final TrainingRepository _trainingRepository;

  @override
  Future<TrainingEntryData> call(GetTrainingEntryDataParams params) async {
    final recentTemplates = await _templateRepository.getRecent(
      limit: params.templateLimit,
    );
    final lastSessions = await _trainingRepository.getRecent(limit: 1);

    return TrainingEntryData(
      recentTemplates: recentTemplates,
      lastSession: lastSessions.isEmpty ? null : lastSessions.first,
    );
  }
}
