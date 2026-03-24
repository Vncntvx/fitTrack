import 'package:drift/drift.dart';
import '../../database/database.dart';
import '../../services/one_rm_calculator.dart';
import '../base/usecase.dart';

/// PR 检查结果
class PrResult {
  final bool isNewPR;
  final double? previousValue;
  final double? newValue;

  const PrResult({
    required this.isNewPR,
    this.previousValue,
    this.newValue,
  });
}

/// 力量训练 PR 参数
class CheckStrengthPrParams {
  final int? exerciseId;
  final String exerciseName;
  final double weight;
  final int reps;
  final int sessionId;
  final PRType prType;
  final DateTime? achievedAt;

  const CheckStrengthPrParams({
    this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.sessionId,
    this.prType = PRType.strength1RM,
    this.achievedAt,
  });
}

/// 跑步 PR 参数
class CheckRunningPrParams {
  final double distanceMeters;
  final int durationSeconds;
  final int sessionId;
  final String runType;
  final DateTime? achievedAt;

  const CheckRunningPrParams({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.sessionId,
    required this.runType,
    this.achievedAt,
  });
}

/// 游泳 PR 参数
class CheckSwimmingPrParams {
  final double distanceMeters;
  final int pacePer100m;
  final int sessionId;
  final String stroke;
  final DateTime? achievedAt;

  const CheckSwimmingPrParams({
    required this.distanceMeters,
    required this.pacePer100m,
    required this.sessionId,
    required this.stroke,
    this.achievedAt,
  });
}

/// 检查并记录力量训练 PR Use Case
/// 使用事务解决 Read-Compare-Write 竞态条件
class CheckStrengthPrUseCase extends UseCase<PrResult, CheckStrengthPrParams> {
  final AppDatabase _db;

  CheckStrengthPrUseCase(this._db);

  @override
  Future<PrResult> call(CheckStrengthPrParams params) async {
    final prValue = switch (params.prType) {
      PRType.strength1RM => OneRmCalculator.calculateAverage(
        params.weight,
        params.reps,
      ),
      PRType.strengthVolume => params.weight,
      _ => 0.0,
    };
    final unit = switch (params.prType) {
      PRType.strength1RM => 'kg',
      PRType.strengthVolume => 'kg·reps',
      _ => 'kg',
    };

    return await _db.transaction(() async {
      final currentPR = await _getCurrentPR(
        params.prType.value,
        exerciseId: params.exerciseId,
      );

      final isNewPR =
          prValue > 0 && (currentPR == null || prValue > currentPR.value);

      if (isNewPR) {
        await _createPR(
          recordType: params.prType.value,
          exerciseId: params.exerciseId,
          value: prValue,
          unit: unit,
          sessionId: params.sessionId,
          achievedAt: params.achievedAt,
        );
      }

      return PrResult(
        isNewPR: isNewPR,
        previousValue: currentPR?.value,
        newValue: isNewPR ? prValue : currentPR?.value,
      );
    });
  }

  Future<PersonalRecord?> _getCurrentPR(
    String recordType, {
    int? exerciseId,
  }) async {
    final query = _db.select(_db.personalRecords)
      ..where((p) => p.recordType.equals(recordType));

    if (exerciseId != null) {
      query.where((p) => p.exerciseId.equals(exerciseId));
    }

    query.orderBy([(p) => OrderingTerm.desc(p.value)]);
    query.limit(1);
    return query.getSingleOrNull();
  }

  Future<int> _createPR({
    required String recordType,
    int? exerciseId,
    required double value,
    required String unit,
    required int sessionId,
    DateTime? achievedAt,
  }) async {
    return await _db.into(_db.personalRecords).insert(
          PersonalRecordsCompanion(
            recordType: Value(recordType),
            exerciseId: Value(exerciseId),
            value: Value(value),
            unit: Value(unit),
            achievedAt: Value(achievedAt ?? DateTime.now()),
            sessionId: Value(sessionId),
          ),
        );
  }
}

/// 检查并记录跑步 PR Use Case
class CheckRunningPrUseCase extends UseCase<bool, CheckRunningPrParams> {
  final AppDatabase _db;

  CheckRunningPrUseCase(this._db);

  @override
  Future<bool> call(CheckRunningPrParams params) async {
    return await _db.transaction(() async {
      bool hasNewPR = false;

      // 检查距离 PR
      if (params.distanceMeters > 0) {
        final distancePR = await _getCurrentPR(PRType.runningDistance.value);
        if (distancePR == null || params.distanceMeters > distancePR.value) {
          await _createPR(
            recordType: PRType.runningDistance.value,
            value: params.distanceMeters,
            unit: 'meters',
            sessionId: params.sessionId,
            achievedAt: params.achievedAt,
          );
          hasNewPR = true;
        }
      }

      // 检查配速 PR（配速越小越快）
      if (params.durationSeconds > 0 && params.distanceMeters >= 1000) {
        final paceSeconds =
            (params.durationSeconds / params.distanceMeters * 1000).round();
        if (paceSeconds > 0) {
          final pacePR = await _getCurrentPR(PRType.runningPace.value);
          if (pacePR == null || paceSeconds < pacePR.value) {
            await _createPR(
              recordType: PRType.runningPace.value,
              value: paceSeconds.toDouble(),
              unit: 'seconds',
              sessionId: params.sessionId,
              achievedAt: params.achievedAt,
            );
            hasNewPR = true;
          }
        }
      }

      return hasNewPR;
    });
  }

  Future<PersonalRecord?> _getCurrentPR(String recordType) async {
    final isLowerBetter = recordType == PRType.runningPace.value;
    return await (_db.select(_db.personalRecords)
          ..where((p) => p.recordType.equals(recordType))
          ..orderBy([
            (p) => isLowerBetter
                ? OrderingTerm.asc(p.value)
                : OrderingTerm.desc(p.value),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> _createPR({
    required String recordType,
    required double value,
    required String unit,
    required int sessionId,
    DateTime? achievedAt,
  }) async {
    return await _db.into(_db.personalRecords).insert(
          PersonalRecordsCompanion(
            recordType: Value(recordType),
            value: Value(value),
            unit: Value(unit),
            achievedAt: Value(achievedAt ?? DateTime.now()),
            sessionId: Value(sessionId),
          ),
        );
  }
}

/// 检查并记录游泳 PR Use Case
class CheckSwimmingPrUseCase extends UseCase<bool, CheckSwimmingPrParams> {
  final AppDatabase _db;

  CheckSwimmingPrUseCase(this._db);

  @override
  Future<bool> call(CheckSwimmingPrParams params) async {
    return await _db.transaction(() async {
      bool hasNewPR = false;

      // 检查距离 PR
      if (params.distanceMeters > 0) {
        final distancePR = await _getCurrentPR(PRType.swimmingDistance.value);
        if (distancePR == null || params.distanceMeters > distancePR.value) {
          await _createPR(
            recordType: PRType.swimmingDistance.value,
            value: params.distanceMeters,
            unit: 'meters',
            sessionId: params.sessionId,
            achievedAt: params.achievedAt,
          );
          hasNewPR = true;
        }
      }

      // 检查配速 PR（每100米时间，越小越快）
      if (params.pacePer100m > 0 && params.distanceMeters >= 100) {
        final pacePR = await _getCurrentPR(PRType.swimmingPace.value);
        if (pacePR == null || params.pacePer100m < pacePR.value) {
          await _createPR(
            recordType: PRType.swimmingPace.value,
            value: params.pacePer100m.toDouble(),
            unit: 'seconds',
            sessionId: params.sessionId,
            achievedAt: params.achievedAt,
          );
          hasNewPR = true;
        }
      }

      return hasNewPR;
    });
  }

  Future<PersonalRecord?> _getCurrentPR(String recordType) async {
    final isLowerBetter = recordType == PRType.swimmingPace.value;
    return await (_db.select(_db.personalRecords)
          ..where((p) => p.recordType.equals(recordType))
          ..orderBy([
            (p) => isLowerBetter
                ? OrderingTerm.asc(p.value)
                : OrderingTerm.desc(p.value),
          ])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> _createPR({
    required String recordType,
    required double value,
    required String unit,
    required int sessionId,
    DateTime? achievedAt,
  }) async {
    return await _db.into(_db.personalRecords).insert(
          PersonalRecordsCompanion(
            recordType: Value(recordType),
            value: Value(value),
            unit: Value(unit),
            achievedAt: Value(achievedAt ?? DateTime.now()),
            sessionId: Value(sessionId),
          ),
        );
  }
}

/// PR 类型枚举
enum PRType {
  strength1RM('strength_1rm'),
  strengthVolume('strength_volume'),
  runningDistance('running_distance'),
  runningPace('running_pace'),
  swimmingDistance('swimming_distance'),
  swimmingPace('swimming_pace');

  final String value;
  const PRType(this.value);

  String get label {
    switch (this) {
      case PRType.strength1RM:
        return '力量最大重量';
      case PRType.strengthVolume:
        return '力量训练容量';
      case PRType.runningDistance:
        return '跑步最长距离';
      case PRType.runningPace:
        return '跑步最快配速';
      case PRType.swimmingDistance:
        return '游泳最长距离';
      case PRType.swimmingPace:
        return '游泳最快配速';
    }
  }
}
