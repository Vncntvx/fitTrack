import 'package:drift/drift.dart';

import 'exercises.dart';
import 'training_sessions.dart';

/// 个人最好成绩表
/// 存储用户的PR记录
@TableIndex(name: 'idx_pr_exercise', columns: {#exerciseId})
@TableIndex(name: 'idx_pr_type_exercise', columns: {#recordType, #exerciseId})
class PersonalRecords extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 记录类型：strength_1rm, strength_volume, running_distance, running_pace, swimming_distance
  TextColumn get recordType => text()();

  /// 关联的动作ID（力量训练）
  /// 动作删除受限，避免破坏 PR 归属
  IntColumn get exerciseId => integer().nullable().references(
    Exercises,
    #id,
    onDelete: KeyAction.restrict,
  )();

  /// 记录值
  RealColumn get value => real()();

  /// 单位：kg, meters, seconds
  TextColumn get unit => text()();

  /// 达成日期
  DateTimeColumn get achievedAt => dateTime()();

  /// 关联的训练会话ID
  /// 会话删除时保留 PR，清空来源会话引用
  IntColumn get sessionId => integer().nullable().references(
    TrainingSessions,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
