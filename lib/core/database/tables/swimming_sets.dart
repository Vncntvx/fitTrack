import 'package:drift/drift.dart';

import 'swimming_entries.dart';

/// 游泳分组训练表
/// 存储游泳训练的分组详情（热身/主训练/放松）
@TableIndex(name: 'idx_sets_entry', columns: {#swimmingEntryId})
class SwimmingSets extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 关联的游泳记录ID
  /// 游泳记录删除时级联删除
  IntColumn get swimmingEntryId => integer()
      .references(SwimmingEntries, #id, onDelete: KeyAction.cascade)();

  /// 分组类型：warmup(热身), main(主训练), cooldown(放松)
  TextColumn get setType => text()();

  /// 分组描述
  TextColumn get description => text().nullable()();

  /// 分组距离（米）
  RealColumn get distanceMeters => real()();

  /// 分组时长（秒）
  IntColumn get durationSeconds => integer()();

  /// 排序顺序
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
