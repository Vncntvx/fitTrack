import '../database/database.dart';
import '../secure_storage/secure_storage_service.dart';

/// 备份凭据服务
/// 管理备份配置对应的密钥读写与清理
class BackupCredentialService {
  BackupCredentialService(this._secureStorage);

  final SecureStorageService _secureStorage;

  Future<String?> readWebDavUsername(int configId) {
    return _secureStorage.read(_webDavUsernameKey(configId));
  }

  Future<String?> readWebDavPassword(int configId) {
    return _secureStorage.read(_webDavPasswordKey(configId));
  }

  Future<String?> readS3AccessKey(int configId) {
    return _secureStorage.read(_s3AccessKeyKey(configId));
  }

  Future<String?> readS3SecretKey(int configId) {
    return _secureStorage.read(_s3SecretKeyKey(configId));
  }

  Future<String?> readBackupEncryptionMasterKey() {
    return _secureStorage.read(SecureStorageService.backupEncryptionMasterKey);
  }

  Future<void> writeWebDavCredentials({
    required int configId,
    String? username,
    String? password,
  }) async {
    if (username != null && username.isNotEmpty) {
      await _secureStorage.write(_webDavUsernameKey(configId), username);
    }
    if (password != null && password.isNotEmpty) {
      await _secureStorage.write(_webDavPasswordKey(configId), password);
    }
  }

  Future<void> writeS3Credentials({
    required int configId,
    String? accessKey,
    String? secretKey,
  }) async {
    if (accessKey != null && accessKey.isNotEmpty) {
      await _secureStorage.write(_s3AccessKeyKey(configId), accessKey);
    }
    if (secretKey != null && secretKey.isNotEmpty) {
      await _secureStorage.write(_s3SecretKeyKey(configId), secretKey);
    }
  }

  Future<void> writeBackupEncryptionMasterKey(String value) {
    return _secureStorage.write(
      SecureStorageService.backupEncryptionMasterKey,
      value,
    );
  }

  Future<void> deleteCredentials(int configId) async {
    await _secureStorage.delete(_webDavUsernameKey(configId));
    await _secureStorage.delete(_webDavPasswordKey(configId));
    await _secureStorage.delete(_s3AccessKeyKey(configId));
    await _secureStorage.delete(_s3SecretKeyKey(configId));
  }

  String _webDavUsernameKey(int configId) =>
      '${SecureStorageService.webdavUsername}_$configId';

  String _webDavPasswordKey(int configId) =>
      '${SecureStorageService.webdavPassword}_$configId';

  String _s3AccessKeyKey(int configId) =>
      '${SecureStorageService.s3AccessKey}_$configId';

  String _s3SecretKeyKey(int configId) =>
      '${SecureStorageService.s3SecretKey}_$configId';
}

class ResolvedBackupCredentials {
  const ResolvedBackupCredentials.webdav({
    required this.username,
    required this.password,
  }) : accessKey = null,
       secretKey = null;

  const ResolvedBackupCredentials.s3({
    required this.accessKey,
    required this.secretKey,
  }) : username = null,
       password = null;

  final String? username;
  final String? password;
  final String? accessKey;
  final String? secretKey;
}

/// 按配置解析备份凭据
Future<ResolvedBackupCredentials> resolveBackupCredentials({
  required BackupCredentialService credentials,
  required BackupConfiguration config,
}) async {
  if (config.providerType == 'webdav') {
    final username = await credentials.readWebDavUsername(config.id);
    final password = await credentials.readWebDavPassword(config.id);
    if (username == null || password == null) {
      throw StateError('Missing WebDAV credentials for config ${config.id}');
    }
    return ResolvedBackupCredentials.webdav(
      username: username,
      password: password,
    );
  }

  if (config.providerType == 's3') {
    final accessKey = await credentials.readS3AccessKey(config.id);
    final secretKey = await credentials.readS3SecretKey(config.id);
    if (accessKey == null || secretKey == null) {
      throw StateError('Missing S3 credentials for config ${config.id}');
    }
    return ResolvedBackupCredentials.s3(
      accessKey: accessKey,
      secretKey: secretKey,
    );
  }

  throw UnsupportedError('Unsupported provider type: ${config.providerType}');
}
