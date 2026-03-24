import 'package:drift/drift.dart';

import 'workout_templates.dart';

/// 训练会话表
/// 存储每次训练会话的基本信息（原 WorkoutRecords）
@TableIndex(name: 'idx_sessions_datetime', columns: {#datetime})
@TableIndex(name: 'idx_sessions_type', columns: {#type})
@TableIndex(name: 'idx_sessions_type_datetime', columns: {#type, #datetime})
class TrainingSessions extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 会话日期时间
  DateTimeColumn get datetime => dateTime()();

  /// 运动类型：strength, running, swimming, cycling, jump_rope, walking, yoga, stretching, custom
  TextColumn get type => text()();

  /// 运动时长（分钟）
  IntColumn get durationMinutes => integer()();

  /// 运动强度：light, moderate, high
  TextColumn get intensity => text()();

  /// 备注
  TextColumn get note => text().nullable()();

  /// 是否完成目标
  BoolColumn get isGoalCompleted =>
      boolean().withDefault(const Constant(false))();

  /// 使用的模板ID（可选）
  /// 模板删除时自动设为 NULL
  IntColumn get templateId => integer()
      .nullable()
      .references(WorkoutTemplates, #id, onDelete: KeyAction.setNull)();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
