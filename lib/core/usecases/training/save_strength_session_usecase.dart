import 'dart:convert';

import '../../database/database.dart';
import '../../repositories/strength_entry_repository.dart';
import '../../repositories/training_repository.dart';
import '../base/usecase.dart';
import '../pr/rebuild_personal_records_usecase.dart';

/// 力量训练动作输入
class StrengthExerciseInput {
  const StrengthExerciseInput({
    this.exerciseId,
    required this.exerciseName,
    required this.defaultReps,
    required this.defaultWeight,
    required this.repsPerSet,
    required this.weightPerSet,
    required this.completedSets,
    required this.rpeValues,
    required this.restSecondsValues,
  });

  final int? exerciseId;
  final String exerciseName;
  final int defaultReps;
  final double defaultWeight;
  final List<int> repsPerSet;
  final List<double> weightPerSet;
  final List<bool> completedSets;
  final List<int?> rpeValues;
  final List<int?> restSecondsValues;
}

/// 保存力量训练参数
class SaveStrengthSessionParams {
  const SaveStrengthSessionParams({
    this.sessionId,
    this.templateId,
    required this.startTime,
    required this.elapsedSeconds,
    required this.intensity,
    this.note,
    required this.exercises,
  });

  final int? sessionId;
  final int? templateId;
  final DateTime startTime;
  final int elapsedSeconds;
  final String intensity;
  final String? note;
  final List<StrengthExerciseInput> exercises;
}

/// 保存力量训练 Use Case
/// 负责以事务方式保存会话与子表，并在提交后重建 PR。
class SaveStrengthSessionUseCase
    extends UseCase<int, SaveStrengthSessionParams> {
  SaveStrengthSessionUseCase(
    this._db,
    this._trainingRepository,
    this._strengthEntryRepository,
    this._prRebuilder,
  );

  final AppDatabase _db;
  final TrainingRepository _trainingRepository;
  final StrengthEntryRepository _strengthEntryRepository;
  final RebuildPersonalRecordsUseCase _prRebuilder;

  @override
  Future<int> call(SaveStrengthSessionParams params) async {
    return await _db.transaction(() async {
      final durationMinutes = (params.elapsedSeconds / 60).round();

      final sessionId = await _upsertSession(params, durationMinutes);

      await (_db.delete(
        _db.strengthExerciseEntries,
      )..where((entry) => entry.sessionId.equals(sessionId))).go();

      for (var i = 0; i < params.exercises.length; i++) {
        final exercise = params.exercises[i];
        await _strengthEntryRepository.addStrengthExercise(
          sessionId: sessionId,
          exerciseId: exercise.exerciseId,
          exerciseName: exercise.exerciseName,
          sets: exercise.repsPerSet.length,
          defaultReps: exercise.defaultReps,
          defaultWeight: exercise.defaultWeight > 0
              ? exercise.defaultWeight
              : null,
          repsPerSet: jsonEncode(exercise.repsPerSet),
          weightPerSet: exercise.weightPerSet.any((weight) => weight > 0)
              ? jsonEncode(exercise.weightPerSet)
              : null,
          setCompleted: jsonEncode(exercise.completedSets),
          rpe: _maxNonNull(exercise.rpeValues),
          restSeconds: _firstNonNull(exercise.restSecondsValues),
          sortOrder: i,
        );
      }

      await _prRebuilder.rebuildForTrainingType('strength');
      return sessionId;
    });
  }

  Future<int> _upsertSession(
    SaveStrengthSessionParams params,
    int durationMinutes,
  ) async {
    if (params.sessionId != null) {
      await _trainingRepository.updateTraining(
        params.sessionId!,
        datetime: params.startTime,
        type: 'strength',
        durationMinutes: durationMinutes,
        intensity: params.intensity,
        note: params.note,
        templateId: params.templateId,
      );
      return params.sessionId!;
    }

    return _trainingRepository.createTraining(
      datetime: params.startTime,
      type: 'strength',
      durationMinutes: durationMinutes,
      intensity: params.intensity,
      note: params.note,
      templateId: params.templateId,
    );
  }

  int? _maxNonNull(List<int?> values) {
    final filtered = values.whereType<int>().toList();
    if (filtered.isEmpty) return null;
    return filtered.reduce((a, b) => a > b ? a : b);
  }

  int? _firstNonNull(List<int?> values) {
    for (final value in values) {
      if (value != null) return value;
    }
    return null;
  }
}
