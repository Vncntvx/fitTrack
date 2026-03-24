import '../../database/database.dart';
import '../../repositories/running_repository.dart';
import '../../repositories/training_repository.dart';
import '../base/usecase.dart';
import '../pr/rebuild_personal_records_usecase.dart';

/// 跑步分段输入
class RunningSplitInput {
  const RunningSplitInput({
    required this.splitNumber,
    required this.distanceKm,
    required this.durationSeconds,
    this.heartRate,
    this.cadence,
  });

  final int splitNumber;
  final double distanceKm;
  final int durationSeconds;
  final int? heartRate;
  final int? cadence;
}

/// 保存跑步训练参数
class SaveRunningSessionParams {
  const SaveRunningSessionParams({
    this.sessionId,
    this.templateId,
    required this.startTime,
    required this.runType,
    required this.distanceKm,
    required this.durationMinutes,
    required this.durationSeconds,
    this.avgHeartRate,
    this.maxHeartRate,
    this.avgCadence,
    this.elevationGain,
    this.note,
    required this.splits,
  });

  final int? sessionId;
  final int? templateId;
  final DateTime startTime;
  final String runType;
  final double distanceKm;
  final int durationMinutes;
  final int durationSeconds;
  final int? avgHeartRate;
  final int? maxHeartRate;
  final int? avgCadence;
  final double? elevationGain;
  final String? note;
  final List<RunningSplitInput> splits;
}

/// 保存跑步训练 Use Case
class SaveRunningSessionUseCase extends UseCase<int, SaveRunningSessionParams> {
  SaveRunningSessionUseCase(
    this._db,
    this._trainingRepository,
    this._runningRepository,
    this._prRebuilder,
  );

  final AppDatabase _db;
  final TrainingRepository _trainingRepository;
  final RunningRepository _runningRepository;
  final RebuildPersonalRecordsUseCase _prRebuilder;

  @override
  Future<int> call(SaveRunningSessionParams params) async {
    return await _db.transaction(() async {
      // 会话、跑步明细、分段与 PR 刷新属于同一业务单元，任一步失败都应整体回滚。
      // 训练主表仅存分钟粒度；派生值在事务内一次计算，确保主从记录口径一致。
      final totalDurationSeconds =
          params.durationMinutes * 60 + params.durationSeconds;
      final totalMinutes =
          params.durationMinutes + (params.durationSeconds / 60).round();
      final avgPaceSeconds =
          RunningRepository.calculatePace(totalDurationSeconds, params.distanceKm * 1000);

      final sessionId = await _upsertSession(
        params,
        durationMinutes: totalMinutes,
      );

      // 编辑采用“更新主记录→清空旧分段→重放新分段”，必须原子完成以避免主从不一致。
      final existingEntry = await _runningRepository.getBySessionId(sessionId);
      late final int runningEntryId;
      if (existingEntry == null) {
        runningEntryId = await _runningRepository.createRunningEntry(
          sessionId: sessionId,
          runType: params.runType,
          distanceMeters: params.distanceKm * 1000,
          durationSeconds: totalDurationSeconds,
          avgPaceSeconds: avgPaceSeconds,
          avgHeartRate: params.avgHeartRate,
          maxHeartRate: params.maxHeartRate,
          avgCadence: params.avgCadence,
          elevationGain: params.elevationGain,
        );
      } else {
        runningEntryId = existingEntry.id;
        await _runningRepository.updateRunningEntry(
          existingEntry.id,
          runType: params.runType,
          distanceMeters: params.distanceKm * 1000,
          durationSeconds: totalDurationSeconds,
          avgPaceSeconds: avgPaceSeconds,
          avgHeartRate: params.avgHeartRate,
          maxHeartRate: params.maxHeartRate,
          avgCadence: params.avgCadence,
          elevationGain: params.elevationGain,
        );
        await _runningRepository.deleteSplitsByEntryId(existingEntry.id);
      }

      // 删除旧分段后按当前输入重放，确保编辑后分段序列与页面状态一致。
      for (final split in params.splits) {
        await _runningRepository.addRunningSplit(
          runningEntryId: runningEntryId,
          splitNumber: split.splitNumber,
          distanceMeters: split.distanceKm * 1000,
          durationSeconds: split.durationSeconds,
          paceSeconds: RunningRepository.calculatePace(
            split.durationSeconds,
            split.distanceKm * 1000,
          ),
          avgHeartRate: split.heartRate,
          cadence: split.cadence,
        );
      }

      // PR 重建放在事务尾部并纳入同事务，确保 PR 与本次训练数据要么同时成功，要么同时回滚。
      await _prRebuilder.rebuildForTrainingType('running');
      return sessionId;
    });
  }

  Future<int> _upsertSession(
    SaveRunningSessionParams params, {
    required int durationMinutes,
  }) async {
    if (params.sessionId != null) {
      await _trainingRepository.updateTraining(
        params.sessionId!,
        datetime: params.startTime,
        type: 'running',
        durationMinutes: durationMinutes,
        intensity: _getIntensityFromRunType(params.runType),
        note: params.note,
        templateId: params.templateId,
      );
      return params.sessionId!;
    }

    return _trainingRepository.createTraining(
      datetime: params.startTime,
      type: 'running',
      durationMinutes: durationMinutes,
      intensity: _getIntensityFromRunType(params.runType),
      note: params.note,
      templateId: params.templateId,
    );
  }

  String _getIntensityFromRunType(String runType) {
    switch (runType) {
      case 'easy':
      case 'recovery':
        return 'light';
      case 'tempo':
      case 'lsd':
        return 'moderate';
      case 'interval':
      case 'race':
        return 'high';
      default:
        return 'moderate';
    }
  }
}
