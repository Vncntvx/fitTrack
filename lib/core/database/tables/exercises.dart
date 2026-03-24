import 'package:drift/drift.dart';

/// 动作库表
/// 存储所有可用的训练动作，包括系统预置和用户自定义
@TableIndex(name: 'idx_exercises_category', columns: {#category})
class Exercises extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 动作名称
  TextColumn get name => text()();

  /// 动作分类：chest(胸), back(背), shoulders(肩), arms(臂), legs(腿), core(核心), full_body(全身), cardio(有氧)
  TextColumn get category => text()();

  /// 动作类型：compound(复合动作), isolation(孤立动作)
  TextColumn get movementType =>
      text().withDefault(const Constant('compound'))();

  /// 主要肌群（逗号分隔）
  TextColumn get primaryMuscles => text().nullable()();

  /// 次要肌群（逗号分隔）
  TextColumn get secondaryMuscles => text().nullable()();

  /// 默认组数
  IntColumn get defaultSets => integer().withDefault(const Constant(3))();

  /// 默认次数
  IntColumn get defaultReps => integer().withDefault(const Constant(10))();

  /// 默认重量（可选）
  RealColumn get defaultWeight => real().nullable()();

  /// 是否为用户自定义动作
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();

  /// 是否启用
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  /// 动作描述/说明
  TextColumn get description => text().nullable()();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<String> get customConstraints => ['UNIQUE (name)'];
}
