import 'package:drift/drift.dart';

import 'training_sessions.dart';

/// 游泳专项记录表
/// 存储游泳训练的详细数据
@TableIndex(name: 'idx_swimming_session', columns: {#sessionId})
@TableIndex(name: 'idx_swimming_stroke', columns: {#primaryStroke})
class SwimmingEntries extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 关联的训练会话ID
  /// 会话删除时级联删除游泳明细
  IntColumn get sessionId => integer().references(
    TrainingSessions,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// 训练环境：pool(泳池), open_water(开放水域)
  TextColumn get environment => text()();

  /// 泳池长度（米），开放水域可为空
  IntColumn get poolLengthMeters => integer().nullable()();

  /// 主要泳姿：freestyle(自由泳), breaststroke(蛙泳), backstroke(仰泳), butterfly(蝶泳), mixed(混合)
  TextColumn get primaryStroke => text()();

  /// 总距离（米）
  RealColumn get distanceMeters => real()();

  /// 总时长（秒）
  IntColumn get durationSeconds => integer()();

  /// 每100米配速（秒）
  IntColumn get pacePer100m => integer()();

  /// 训练类型：technique(技术), endurance(耐力), speed(速度), recovery(恢复)
  TextColumn get trainingType => text().nullable()();

  /// 使用的装备（JSON数组）：fins(脚蹼), pull_buoy(浮板), paddles(划水掌), kickboard(打水板), snorkel(呼吸管)
  TextColumn get equipment => text().nullable()();
}
