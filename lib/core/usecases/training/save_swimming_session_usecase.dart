import 'dart:convert';

import '../../database/database.dart';
import '../../repositories/swimming_repository.dart';
import '../../repositories/training_repository.dart';
import '../base/usecase.dart';
import '../pr/rebuild_personal_records_usecase.dart';

/// 游泳分组输入
class SwimmingSetInput {
  const SwimmingSetInput({
    required this.setType,
    required this.distanceMeters,
    required this.durationSeconds,
    this.description,
  });

  final String setType;
  final double distanceMeters;
  final int durationSeconds;
  final String? description;
}

/// 保存游泳训练参数
class SaveSwimmingSessionParams {
  const SaveSwimmingSessionParams({
    this.sessionId,
    this.templateId,
    required this.startTime,
    required this.environment,
    required this.primaryStroke,
    required this.distanceMeters,
    required this.durationMinutes,
    required this.durationSeconds,
    this.poolLengthMeters,
    this.trainingType,
    required this.equipment,
    this.note,
    required this.sets,
  });

  final int? sessionId;
  final int? templateId;
  final DateTime startTime;
  final String environment;
  final int? poolLengthMeters;
  final String primaryStroke;
  final double distanceMeters;
  final int durationMinutes;
  final int durationSeconds;
  final String? trainingType;
  final Set<String> equipment;
  final String? note;
  final List<SwimmingSetInput> sets;
}

/// 保存游泳训练 Use Case
class SaveSwimmingSessionUseCase
    extends UseCase<int, SaveSwimmingSessionParams> {
  SaveSwimmingSessionUseCase(
    this._db,
    this._trainingRepository,
    this._swimmingRepository,
    this._prRebuilder,
  );

  final AppDatabase _db;
  final TrainingRepository _trainingRepository;
  final SwimmingRepository _swimmingRepository;
  final RebuildPersonalRecordsUseCase _prRebuilder;

  @override
  Future<int> call(SaveSwimmingSessionParams params) async {
    return await _db.transaction(() async {
      // 会话、游泳明细、分组与 PR 刷新是一组原子写入，失败时应统一回滚。
      // 训练主表仅存分钟粒度；派生值在事务内统一计算，避免主从口径漂移。
      final totalDurationSeconds =
          params.durationMinutes * 60 + params.durationSeconds;
      final totalMinutes =
          params.durationMinutes + (params.durationSeconds / 60).ceil();
      final pacePer100m = SwimmingRepository.calculatePacePer100m(
        totalDurationSeconds,
        params.distanceMeters,
      );

      final sessionId = await _upsertSession(
        params,
        durationMinutes: totalMinutes,
      );

      // 编辑采用“更新主记录→清空旧分组→按当前输入重建”，必须在同事务内完成。
      final existingEntry = await _swimmingRepository.getBySessionId(sessionId);
      late final int swimmingEntryId;
      if (existingEntry == null) {
        swimmingEntryId = await _swimmingRepository.createSwimmingEntry(
          sessionId: sessionId,
          environment: params.environment,
          poolLengthMeters: params.poolLengthMeters,
          primaryStroke: params.primaryStroke,
          distanceMeters: params.distanceMeters,
          durationSeconds: totalDurationSeconds,
          pacePer100m: pacePer100m,
          trainingType: params.trainingType,
          equipment: params.equipment.isNotEmpty
              ? jsonEncode(params.equipment.toList())
              : null,
        );
      } else {
        swimmingEntryId = existingEntry.id;
        await _swimmingRepository.updateSwimmingEntry(
          existingEntry.id,
          environment: params.environment,
          poolLengthMeters: params.poolLengthMeters,
          primaryStroke: params.primaryStroke,
          distanceMeters: params.distanceMeters,
          durationSeconds: totalDurationSeconds,
          pacePer100m: pacePer100m,
          trainingType: params.trainingType,
          equipment: params.equipment.isNotEmpty
              ? jsonEncode(params.equipment.toList())
              : null,
        );
        await _swimmingRepository.deleteSetsByEntryId(existingEntry.id);
      }

      // sortOrder 由当前输入顺序决定，保证展示顺序与用户编辑顺序一致。
      for (var i = 0; i < params.sets.length; i++) {
        final setData = params.sets[i];
        await _swimmingRepository.addSwimmingSet(
          swimmingEntryId: swimmingEntryId,
          setType: setData.setType,
          description: setData.description,
          distanceMeters: setData.distanceMeters,
          durationSeconds: setData.durationSeconds,
          sortOrder: i,
        );
      }

      // PR 重建纳入事务尾部，保证 PR 与本次训练明细一致，不产生“数据已写入但 PR 未刷新”。
      await _prRebuilder.rebuildForTrainingType('swimming');
      return sessionId;
    });
  }

  Future<int> _upsertSession(
    SaveSwimmingSessionParams params, {
    required int durationMinutes,
  }) async {
    if (params.sessionId != null) {
      await _trainingRepository.updateTraining(
        params.sessionId!,
        datetime: params.startTime,
        type: 'swimming',
        durationMinutes: durationMinutes,
        intensity: _getIntensityFromTrainingType(params.trainingType),
        note: params.note,
        templateId: params.templateId,
      );
      return params.sessionId!;
    }

    return _trainingRepository.createTraining(
      datetime: params.startTime,
      type: 'swimming',
      durationMinutes: durationMinutes,
      intensity: _getIntensityFromTrainingType(params.trainingType),
      note: params.note,
      templateId: params.templateId,
    );
  }

  String _getIntensityFromTrainingType(String? trainingType) {
    switch (trainingType) {
      case 'recovery':
        return 'light';
      case 'endurance':
      case 'technique':
        return 'moderate';
      case 'interval':
      case 'race_pace':
        return 'high';
      default:
        return 'moderate';
    }
  }
}
