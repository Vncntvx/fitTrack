import 'package:drift/drift.dart';

import 'running_entries.dart';

/// 跑步分段记录表
/// 存储跑步的每公里/每圈详细数据
@TableIndex(name: 'idx_splits_entry', columns: {#runningEntryId})
class RunningSplits extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 关联的跑步记录ID
  /// 跑步记录删除时级联删除
  IntColumn get runningEntryId => integer()
      .references(RunningEntries, #id, onDelete: KeyAction.cascade)();

  /// 分段序号
  IntColumn get splitNumber => integer()();

  /// 分段距离（米）
  RealColumn get distanceMeters => real()();

  /// 分段时长（秒）
  IntColumn get durationSeconds => integer()();

  /// 分段配速（秒/公里）
  IntColumn get paceSeconds => integer()();

  /// 该段平均心率（可选）
  IntColumn get avgHeartRate => integer().nullable()();

  /// 该段步频（可选）
  IntColumn get cadence => integer().nullable()();

  /// 该段爬升（米，可选）
  RealColumn get elevationGain => real().nullable()();

  /// 是否为手动标记
  BoolColumn get isManual => boolean().withDefault(const Constant(false))();
}
