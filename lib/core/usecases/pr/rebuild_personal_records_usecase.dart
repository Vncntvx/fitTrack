import 'dart:convert';

import '../../database/database.dart';
import '../../repositories/running_repository.dart';
import '../../repositories/strength_entry_repository.dart';
import '../../repositories/swimming_repository.dart';
import '../../repositories/training_repository.dart';
import '../base/usecase.dart';
import 'check_and_record_pr_usecase.dart';

/// 重建个人记录 Use Case
/// 在训练编辑、删除、导入恢复后重建派生 PR 数据，避免遗留脏数据。
class RebuildPersonalRecordsUseCase extends NoParamUseCase<void> {
  RebuildPersonalRecordsUseCase(
    this._db,
    this._trainingRepository,
    this._strengthEntryRepository,
    this._runningRepository,
    this._swimmingRepository,
  ) : _strengthPrUseCase = CheckStrengthPrUseCase(_db),
      _runningPrUseCase = CheckRunningPrUseCase(_db),
      _swimmingPrUseCase = CheckSwimmingPrUseCase(_db);

  final AppDatabase _db;
  final TrainingRepository _trainingRepository;
  final StrengthEntryRepository _strengthEntryRepository;
  final RunningRepository _runningRepository;
  final SwimmingRepository _swimmingRepository;
  final CheckStrengthPrUseCase _strengthPrUseCase;
  final CheckRunningPrUseCase _runningPrUseCase;
  final CheckSwimmingPrUseCase _swimmingPrUseCase;

  @override
  Future<void> call() async {
    await _db.transaction(() async {
      await _rebuildForTypesInCurrentTransaction(const {
        'strength',
        'running',
        'swimming',
      });
    });
  }

  /// 在当前事务中重建指定训练类型对应的 PR 数据。
  Future<void> rebuildForTrainingType(String trainingType) async {
    await _rebuildForTypesInCurrentTransaction({trainingType});
  }

  Future<void> rebuildForTrainingTypes(Set<String> trainingTypes) async {
    await _rebuildForTypesInCurrentTransaction(trainingTypes);
  }

  Future<void> _rebuildForTypesInCurrentTransaction(
    Set<String> trainingTypes,
  ) async {
    if (trainingTypes.isEmpty) return;

    await _clearPersonalRecords(trainingTypes);

    if (trainingTypes.contains('strength')) {
      await _rebuildStrengthPrs();
    }
    if (trainingTypes.contains('running')) {
      await _rebuildRunningPrs();
    }
    if (trainingTypes.contains('swimming')) {
      await _rebuildSwimmingPrs();
    }
  }

  Future<void> _clearPersonalRecords(Set<String> trainingTypes) async {
    final recordTypes = <String>{
      if (trainingTypes.contains('strength')) ...{
        PRType.strength1RM.value,
        PRType.strengthVolume.value,
      },
      if (trainingTypes.contains('running')) ...{
        PRType.runningDistance.value,
        PRType.runningPace.value,
      },
      if (trainingTypes.contains('swimming')) ...{
        PRType.swimmingDistance.value,
        PRType.swimmingPace.value,
      },
    };

    if (recordTypes.isEmpty) return;

    await (_db.delete(
      _db.personalRecords,
    )..where((p) => p.recordType.isIn(recordTypes))).go();
  }

  Future<void> _rebuildStrengthPrs() async {
    final sessions = await _trainingRepository.getByType('strength');
    final orderedSessions = [...sessions]
      ..sort((a, b) => a.datetime.compareTo(b.datetime));

    for (final session in orderedSessions) {
      final entries = await _strengthEntryRepository.getStrengthExercises(
        session.id,
      );

      double sessionVolume = 0;

      for (final entry in entries) {
        final repsPerSet = _decodeIntList(
          entry.repsPerSet,
          fallbackLength: entry.sets,
          fallbackValue: entry.defaultReps,
        );
        final weightPerSet = _decodeDoubleList(
          entry.weightPerSet,
          fallbackLength: entry.sets,
          fallbackValue: entry.defaultWeight ?? 0,
        );
        final completedFlags = _decodeBoolList(
          entry.setCompleted,
          fallbackLength: entry.sets,
          fallbackValue: false,
        );

        for (var i = 0; i < entry.sets; i++) {
          final isCompleted = i < completedFlags.length && completedFlags[i];
          if (!isCompleted) continue;

          final reps = i < repsPerSet.length
              ? repsPerSet[i]
              : entry.defaultReps;
          final weight = i < weightPerSet.length
              ? weightPerSet[i]
              : (entry.defaultWeight ?? 0);
          if (reps <= 0 || weight <= 0) continue;

          sessionVolume += reps * weight;

          await _strengthPrUseCase(
            CheckStrengthPrParams(
              exerciseId: entry.exerciseId,
              exerciseName: entry.exerciseName,
              weight: weight,
              reps: reps,
              sessionId: session.id,
              prType: PRType.strength1RM,
              achievedAt: session.datetime,
            ),
          );
        }
      }

      if (sessionVolume > 0) {
        await _strengthPrUseCase(
          CheckStrengthPrParams(
            exerciseName: '训练容量',
            weight: sessionVolume,
            reps: 1,
            sessionId: session.id,
            prType: PRType.strengthVolume,
            achievedAt: session.datetime,
          ),
        );
      }
    }
  }

  Future<void> _rebuildRunningPrs() async {
    final sessions = await _trainingRepository.getByType('running');
    final orderedSessions = [...sessions]
      ..sort((a, b) => a.datetime.compareTo(b.datetime));

    for (final session in orderedSessions) {
      final entry = await _runningRepository.getBySessionId(session.id);
      if (entry == null) continue;

      await _runningPrUseCase(
        CheckRunningPrParams(
          distanceMeters: entry.distanceMeters,
          durationSeconds: entry.durationSeconds,
          sessionId: session.id,
          runType: entry.runType,
          achievedAt: session.datetime,
        ),
      );
    }
  }

  Future<void> _rebuildSwimmingPrs() async {
    final sessions = await _trainingRepository.getByType('swimming');
    final orderedSessions = [...sessions]
      ..sort((a, b) => a.datetime.compareTo(b.datetime));

    for (final session in orderedSessions) {
      final entry = await _swimmingRepository.getBySessionId(session.id);
      if (entry == null) continue;

      await _swimmingPrUseCase(
        CheckSwimmingPrParams(
          distanceMeters: entry.distanceMeters,
          pacePer100m: entry.pacePer100m,
          sessionId: session.id,
          stroke: entry.primaryStroke,
          achievedAt: session.datetime,
        ),
      );
    }
  }

  List<int> _decodeIntList(
    String? value, {
    required int fallbackLength,
    required int fallbackValue,
  }) {
    if (value == null || value.isEmpty) {
      return List<int>.filled(fallbackLength, fallbackValue);
    }

    try {
      final list = (jsonDecode(value) as List<dynamic>)
          .map((item) => (item as num).toInt())
          .toList();
      return list;
    } catch (_) {
      return List<int>.filled(fallbackLength, fallbackValue);
    }
  }

  List<double> _decodeDoubleList(
    String? value, {
    required int fallbackLength,
    required double fallbackValue,
  }) {
    if (value == null || value.isEmpty) {
      return List<double>.filled(fallbackLength, fallbackValue);
    }

    try {
      return (jsonDecode(value) as List<dynamic>)
          .map((item) => (item as num).toDouble())
          .toList();
    } catch (e) {
      // JSON 解析失败，使用默认值
      return List<double>.filled(fallbackLength, fallbackValue);
    }
  }

  List<bool> _decodeBoolList(
    String? value, {
    required int fallbackLength,
    required bool fallbackValue,
  }) {
    if (value == null || value.isEmpty) {
      return List<bool>.filled(fallbackLength, fallbackValue);
    }

    try {
      return (jsonDecode(value) as List<dynamic>)
          .map((item) => item as bool)
          .toList();
    } catch (e) {
      // JSON 解析失败，使用默认值
      return List<bool>.filled(fallbackLength, fallbackValue);
    }
  }
}
