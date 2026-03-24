import 'package:drift/drift.dart';

import 'training_sessions.dart';
import 'exercises.dart';

/// 力量训练条目表
/// 存储力量训练的详细组数信息
@TableIndex(name: 'idx_strength_session', columns: {#sessionId})
@TableIndex(name: 'idx_strength_exercise', columns: {#exerciseId})
class StrengthExerciseEntries extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 关联的训练会话ID（原名 workoutRecordId）
  /// 会话删除时级联删除力量条目
  IntColumn get sessionId => integer().references(
    TrainingSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// 关联的动作库ID（可选）
  /// 动作删除受限，避免破坏历史训练数据
  IntColumn get exerciseId => integer().nullable().references(
    Exercises,
    #id,
    onDelete: KeyAction.restrict,
  )();

  /// 练习名称（保留以兼容手动输入）
  TextColumn get exerciseName => text()();

  /// 组数
  IntColumn get sets => integer()();

  /// 默认次数
  IntColumn get defaultReps => integer()();

  /// 默认重量（可选）
  RealColumn get defaultWeight => real().nullable()();

  /// 每组次数（JSON 数组，支持不同次数，如 "[10, 8, 6]"）
  TextColumn get repsPerSet => text().nullable()();

  /// 每组重量（JSON 数组，如 "[60.0, 65.0, 70.0]"）
  TextColumn get weightPerSet => text().nullable()();

  /// 每组完成状态（JSON 数组，如 "[true, true, false]"）
  TextColumn get setCompleted => text().nullable()();

  /// 是否为热身组
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();

  /// RPE（主观强度感受，1-10）
  IntColumn get rpe => integer().nullable()();

  /// 休息时间（秒）
  IntColumn get restSeconds => integer().nullable()();

  /// 排序顺序
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  /// 备注
  TextColumn get note => text().nullable()();
}
