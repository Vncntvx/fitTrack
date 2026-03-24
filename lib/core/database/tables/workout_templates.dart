import 'package:drift/drift.dart';

/// 训练模板表
/// 存储用户可复用的训练模板
@TableIndex(name: 'idx_templates_type', columns: {#type})
class WorkoutTemplates extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 模板名称
  TextColumn get name => text()();

  /// 模板类型：strength(健身), running(跑步), swimming(游泳)
  TextColumn get type => text()();

  /// 模板描述
  TextColumn get description => text().nullable()();

  /// 是否为默认模板
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
