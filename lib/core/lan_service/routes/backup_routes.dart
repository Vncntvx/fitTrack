import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import '../../database/database.dart';
import '../../repositories/backup_config_repository.dart';
import '../../backup/backup_service.dart';
import '../../backup/backup_credential_service.dart';
import '../../backup/backup_provider_factory.dart';
import '../../secure_storage/secure_storage_service.dart';
import '../../logging/logger_service.dart';
import '../response_helper.dart';

/// 备份配置 API 处理器
class BackupApiHandler {
  final BackupConfigRepository _repository;
  final AppDatabase _db;
  final BackupCredentialService _credentials;
  final BackupProviderFactory _providerFactory;
  final BackupService _backupService;
  final LoggerService _logger = LoggerService.instance;

  BackupApiHandler._(
    this._db,
    this._repository,
    this._credentials,
    this._providerFactory,
    this._backupService,
  );

  factory BackupApiHandler(
    AppDatabase db, {
    BackupConfigRepository? repository,
    BackupCredentialService? credentials,
    BackupProviderFactory? providerFactory,
    BackupService? backupService,
  }) {
    final resolvedCredentials =
        credentials ?? BackupCredentialService(SecureStorageService());
    return BackupApiHandler._(
      db,
      repository ?? BackupConfigRepository(db),
      resolvedCredentials,
      providerFactory ?? BackupProviderFactory(resolvedCredentials),
      backupService ?? BackupService(db, credentials: resolvedCredentials),
    );
  }

  /// 获取所有备份配置
  Future<Response> getConfigs(Request request) async {
    try {
      final configs = await _repository.getAll();
      return LanApiResponse.ok(
        data: configs.map((c) => _configToJson(c)).toList(),
        message: 'Fetched backup configs successfully',
      );
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupApiHandler',
        '获取备份配置列表失败',
        error: e,
        stackTrace: stackTrace,
      );
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取默认配置
  Future<Response> getDefaultConfig(Request request) async {
    try {
      final config = await _repository.getDefault();
      if (config == null) {
        return LanApiResponse.notFound('No default config found');
      }
      return LanApiResponse.ok(
        data: _configToJson(config),
        message: 'Fetched default backup config successfully',
      );
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupApiHandler',
        '获取默认备份配置失败',
        error: e,
        stackTrace: stackTrace,
      );
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 创建备份配置
  Future<Response> createConfig(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final providerType = data['providerType'] as String;
      final int id;

      if (providerType == 'webdav') {
        if ((data['path'] as String?) == null ||
            (data['path'] as String).isEmpty) {
          return LanApiResponse.badRequest('path is required for webdav');
        }
        id = await _repository.createWebDavConfig(
          displayName: data['displayName'] as String,
          endpoint: data['endpoint'] as String,
          path: data['path'] as String,
          isDefault: data['isDefault'] as bool? ?? false,
        );
        final username = data['username'] as String?;
        final password = data['password'] as String?;
        await _credentials.writeWebDavCredentials(
          configId: id,
          username: username,
          password: password,
        );
      } else if (providerType == 's3') {
        if ((data['bucket'] as String?) == null ||
            (data['bucket'] as String).isEmpty) {
          return LanApiResponse.badRequest('bucket is required for s3');
        }
        id = await _repository.createS3Config(
          displayName: data['displayName'] as String,
          endpoint: data['endpoint'] as String,
          bucket: data['bucket'] as String,
          region: data['region'] as String?,
          isDefault: data['isDefault'] as bool? ?? false,
        );
        final accessKey = data['accessKey'] as String?;
        final secretKey = data['secretKey'] as String?;
        await _credentials.writeS3Credentials(
          configId: id,
          accessKey: accessKey,
          secretKey: secretKey,
        );
      } else {
        return LanApiResponse.badRequest('Invalid provider type');
      }

      return LanApiResponse.created(
        data: {'id': id},
        message: 'Config created successfully',
      );
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupApiHandler',
        '创建备份配置失败',
        error: e,
        stackTrace: stackTrace,
      );
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 删除备份配置
  Future<Response> deleteConfig(Request request, String id) async {
    try {
      final configId = int.tryParse(id);
      if (configId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final count = await _repository.deleteConfig(configId);
      if (count == 0) {
        return LanApiResponse.notFound('Config not found');
      }
      await _credentials.deleteCredentials(configId);

      return LanApiResponse.ok(
        data: {'id': configId},
        message: 'Config deleted successfully',
      );
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupApiHandler',
        '删除备份配置失败',
        error: e,
        stackTrace: stackTrace,
      );
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 触发备份
  Future<Response> backup(Request request, [String? id]) async {
    try {
      int? configId;
      if (id != null && id.isNotEmpty) {
        configId = int.tryParse(id);
      } else {
        final body = await request.readAsString();
        if (body.trim().isNotEmpty) {
          final data = jsonDecode(body) as Map<String, dynamic>;
          configId = data['configId'] as int?;
        }
      }

      BackupConfiguration? config;
      if (configId != null) {
        config = await _repository.getById(configId);
      } else {
        config = await _repository.getDefault();
      }
      config ??= await (_db.select(
        _db.backupConfigurations,
      )..limit(1)).getSingleOrNull();

      if (config == null) {
        return LanApiResponse.notFound('No backup configuration found');
      }

      final provider = await _providerFactory.create(config);
      final result = await _backupService.backup(
        provider,
        'backups',
        configId: config.id,
      );

      if (!result.success) {
        return LanApiResponse.internalServerError(
          result.error ?? 'Backup failed',
        );
      }

      return LanApiResponse.ok(
        data: {'path': result.path, 'checksum': result.checksum},
        message: 'Backup completed',
      );
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupApiHandler',
        '执行备份失败',
        error: e,
        stackTrace: stackTrace,
        data: {'pathId': id},
      );
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取备份记录
  Future<Response> getBackupRecords(Request request) async {
    try {
      final configIdParam = request.url.queryParameters['configId'];
      List<BackupRecord> records;
      if (configIdParam != null) {
        final configId = int.tryParse(configIdParam);
        if (configId == null) {
          return LanApiResponse.badRequest('Invalid configId');
        }
        records =
            await (_db.select(_db.backupRecords)
                  ..where((r) => r.configId.equals(configId))
                  ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
                .get();
      } else {
        records = await (_db.select(
          _db.backupRecords,
        )..orderBy([(r) => OrderingTerm.desc(r.createdAt)])).get();
      }

      return LanApiResponse.ok(
        data: records.map((r) => _recordToJson(r)).toList(),
        message: 'Fetched backup records successfully',
      );
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupApiHandler',
        '获取备份记录失败',
        error: e,
        stackTrace: stackTrace,
      );
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 从备份记录恢复
  Future<Response> restore(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final recordId = data['recordId'] as int?;
      if (recordId == null) {
        return LanApiResponse.badRequest('recordId is required');
      }

      final record = await (_db.select(
        _db.backupRecords,
      )..where((r) => r.id.equals(recordId))).getSingleOrNull();
      if (record == null) {
        return LanApiResponse.notFound('Backup record not found');
      }

      final config = await _repository.getById(record.configId);
      if (config == null) {
        return LanApiResponse.notFound('Backup configuration not found');
      }

      final provider = await _providerFactory.create(config);
      final result = await _backupService.restore(provider, record);
      if (!result.success) {
        return LanApiResponse.internalServerError(
          result.error ?? 'Restore failed',
        );
      }

      return LanApiResponse.ok(data: const {}, message: 'Restore completed');
    } catch (e, stackTrace) {
      await _logger.error(
        'BackupApiHandler',
        '执行恢复失败',
        error: e,
        stackTrace: stackTrace,
      );
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 转换配置为 JSON
  Map<String, dynamic> _configToJson(BackupConfiguration config) {
    return {
      'id': config.id,
      'providerType': config.providerType,
      'displayName': config.displayName,
      'endpoint': config.endpoint,
      'bucketOrPath': config.bucketOrPath,
      'region': config.region,
      'isDefault': config.isDefault,
      'createdAt': config.createdAt.toIso8601String(),
      'updatedAt': config.updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> _recordToJson(BackupRecord record) {
    return {
      'id': record.id,
      'configId': record.configId,
      'providerType': record.providerType,
      'targetPath': record.targetPath,
      'createdAt': record.createdAt.toIso8601String(),
      'status': record.status,
      'checksum': record.checksum,
      'metadataJson': record.metadataJson,
    };
  }
}
