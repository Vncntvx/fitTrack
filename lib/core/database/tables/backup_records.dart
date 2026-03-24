import 'package:drift/drift.dart';

import 'backup_configurations.dart';

/// 备份记录表
/// 存储每次备份的执行记录
@TableIndex(name: 'idx_backup_records_config', columns: {#configId})
class BackupRecords extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 关联的备份配置ID
  /// 配置删除时级联删除历史记录
  IntColumn get configId => integer().references(
    BackupConfigurations,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// 提供者类型：webdav, s3
  TextColumn get providerType => text()();

  /// 目标路径
  TextColumn get targetPath => text()();

  /// 创建时间
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  /// 状态：pending, completed, failed
  TextColumn get status => text()();

  /// SHA256 校验和
  TextColumn get checksum => text().nullable()();

  /// 元数据 JSON
  TextColumn get metadataJson => text().nullable()();
}
