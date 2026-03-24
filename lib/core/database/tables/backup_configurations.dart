import 'package:drift/drift.dart';

/// 备份配置表
/// 存储 WebDAV 和 S3 的备份目标配置
@TableIndex(name: 'idx_backup_configs_default', columns: {#isDefault})
@TableIndex(name: 'idx_backup_configs_provider', columns: {#providerType})
class BackupConfigurations extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 提供者类型：webdav, s3
  TextColumn get providerType => text()();

  /// 显示名称
  TextColumn get displayName => text()();

  /// 服务端点 URL
  TextColumn get endpoint => text()();

  /// 存储桶或路径
  TextColumn get bucketOrPath => text()();

  /// 区域（S3 适用）
  TextColumn get region => text().nullable()();

  /// 是否为默认配置
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 更新时间
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
