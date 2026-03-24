import 'package:drift/drift.dart';
import '../database/database.dart';

/// 备份配置 Repository
/// 提供备份配置的 CRUD 操作
class BackupConfigRepository {
  final AppDatabase _db;

  BackupConfigRepository(this._db);

  /// 创建 WebDAV 配置
  Future<int> createWebDavConfig({
    required String displayName,
    required String endpoint,
    required String path,
    bool isDefault = false,
  }) async {
    return await _db.transaction(() async {
      if (isDefault) {
        await _clearDefaultConfig();
      }

      return await _db.into(_db.backupConfigurations).insert(
            BackupConfigurationsCompanion(
              providerType: const Value('webdav'),
              displayName: Value(displayName),
              endpoint: Value(endpoint),
              bucketOrPath: Value(path),
              region: const Value.absent(),
              isDefault: Value(isDefault),
            ),
          );
    });
  }

  /// 创建 S3 配置
  Future<int> createS3Config({
    required String displayName,
    required String endpoint,
    required String bucket,
    String? region,
    bool isDefault = false,
  }) async {
    return await _db.transaction(() async {
      if (isDefault) {
        await _clearDefaultConfig();
      }

      return await _db.into(_db.backupConfigurations).insert(
            BackupConfigurationsCompanion(
              providerType: const Value('s3'),
              displayName: Value(displayName),
              endpoint: Value(endpoint),
              bucketOrPath: Value(bucket),
              region: Value(region),
              isDefault: Value(isDefault),
            ),
          );
    });
  }

  /// 根据ID获取配置
  Future<BackupConfiguration?> getById(int id) async {
    return await (_db.select(
      _db.backupConfigurations,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
  }

  /// 获取所有配置
  Future<List<BackupConfiguration>> getAll() async {
    return await _db.select(_db.backupConfigurations).get();
  }

  /// 获取默认配置
  Future<BackupConfiguration?> getDefault() async {
    return await (_db.select(_db.backupConfigurations)
          ..where((c) => c.isDefault.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  /// 设置为默认配置
  Future<void> setDefault(int id) async {
    await _db.transaction(() async {
      final target = await getById(id);
      if (target == null) {
        throw ArgumentError.value(id, 'id', '备份配置不存在');
      }

      // 清除所有默认标记
      await (_db.update(_db.backupConfigurations)).write(
        const BackupConfigurationsCompanion(
          isDefault: Value(false),
        ),
      );

      // 设置新的默认
      await (_db.update(_db.backupConfigurations)
            ..where((c) => c.id.equals(id))).write(
        BackupConfigurationsCompanion(
          isDefault: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  /// 更新配置
  Future<bool> updateConfig(
    int id, {
    String? displayName,
    String? endpoint,
    String? bucketOrPath,
    String? region,
  }) async {
    final existing = await getById(id);
    if (existing == null) return false;

    return await _db
        .update(_db.backupConfigurations)
        .replace(
          BackupConfigurationsCompanion(
            id: Value(id),
            providerType: Value(existing.providerType),
            displayName: displayName != null
                ? Value(displayName)
                : const Value.absent(),
            endpoint: endpoint != null ? Value(endpoint) : const Value.absent(),
            bucketOrPath: bucketOrPath != null
                ? Value(bucketOrPath)
                : const Value.absent(),
            region: region != null ? Value(region) : const Value.absent(),
            isDefault: Value(existing.isDefault),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  /// 删除配置
  /// 会级联删除关联的 BackupRecords
  Future<int> deleteConfig(int id) async {
    return await _db.transaction<int>(() async {
      // 先删除关联的 BackupRecords
      await (_db.delete(_db.backupRecords)
            ..where((r) => r.configId.equals(id)))
          .go();
      // 再删除配置
      return await (_db.delete(
        _db.backupConfigurations,
      )..where((c) => c.id.equals(id))).go();
    });
  }

  /// 清除默认配置标记（内部方法，在事务内调用）
  Future<void> _clearDefaultConfig() async {
    await (_db.update(_db.backupConfigurations)).write(
      const BackupConfigurationsCompanion(
        isDefault: Value(false),
      ),
    );
  }

  /// 监听所有配置（响应式）
  Stream<List<BackupConfiguration>> watchAll() {
    return _db.select(_db.backupConfigurations).watch();
  }
}
