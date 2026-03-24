import 'package:drift/drift.dart';

import 'backup_configurations.dart';

/// 用户设置表
/// 存储应用的全局设置，如目标、主题、局域网配置等
class UserSettings extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 每周运动天数目标（默认3天）
  IntColumn get weeklyWorkoutDaysGoal =>
      integer().withDefault(const Constant(3))();

  /// 每周运动分钟数目标（默认150分钟）
  IntColumn get weeklyWorkoutMinutesGoal =>
      integer().withDefault(const Constant(150))();

  /// 主题模式：system, dark, light
  TextColumn get themeMode => text().withDefault(const Constant('system'))();

  /// 重量单位：kg, lbs
  TextColumn get weightUnit => text().withDefault(const Constant('kg'))();

  /// 距离单位：km, mi
  TextColumn get distanceUnit => text().withDefault(const Constant('km'))();

  /// 局域网服务是否启用
  BoolColumn get lanServiceEnabled =>
      boolean().withDefault(const Constant(false))();

  /// 局域网服务端口号（默认8080）
  IntColumn get lanServicePort => integer().withDefault(const Constant(8080))();

  /// 局域网服务访问令牌是否启用（默认关闭）
  BoolColumn get lanServiceTokenEnabled =>
      boolean().withDefault(const Constant(false))();

  /// 默认备份配置ID
  /// 配置删除时自动清空默认配置引用
  IntColumn get defaultBackupConfigId => integer().nullable().references(
    BackupConfigurations,
    #id,
    onDelete: KeyAction.setNull,
  )();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
