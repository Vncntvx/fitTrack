import 'package:drift/drift.dart';

import 'training_sessions.dart';

/// 跑步专项记录表
/// 存储跑步训练的详细数据
@TableIndex(name: 'idx_running_session', columns: {#sessionId})
class RunningEntries extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 关联的训练会话ID
  /// 会话删除时级联删除跑步明细
  IntColumn get sessionId => integer().references(
    TrainingSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// 跑步类型：easy(轻松跑), tempo(节奏跑), interval(间歇跑), lsd(长距离慢跑), recovery(恢复跑), race(比赛)
  TextColumn get runType => text()();

  /// 总距离（米）
  RealColumn get distanceMeters => real()();

  /// 总时长（秒）
  IntColumn get durationSeconds => integer()();

  /// 平均配速（秒/公里）
  IntColumn get avgPaceSeconds => integer()();

  /// 最快配速（秒/公里）
  IntColumn get bestPaceSeconds => integer().nullable()();

  /// 平均心率（可选）
  IntColumn get avgHeartRate => integer().nullable()();

  /// 最大心率（可选）
  IntColumn get maxHeartRate => integer().nullable()();

  /// 平均步频（可选）
  IntColumn get avgCadence => integer().nullable()();

  /// 最大步频（可选）
  IntColumn get maxCadence => integer().nullable()();

  /// 总爬升（米，可选）
  RealColumn get elevationGain => real().nullable()();

  /// 总下降（米，可选）
  RealColumn get elevationLoss => real().nullable()();

  /// 跑鞋/装备（可选）
  TextColumn get footwear => text().nullable()();

  /// 天气数据JSON（可选）
  TextColumn get weatherJson => text().nullable()();
}
