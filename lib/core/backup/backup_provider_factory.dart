import '../database/database.dart';
import 'backup_credential_service.dart';
import 'backup_provider.dart';
import 'providers/s3_provider.dart';
import 'providers/webdav_provider.dart';

/// 备份提供者工厂
/// 根据配置与凭据构建具体的备份 Provider
class BackupProviderFactory {
  BackupProviderFactory(this._credentials);

  final BackupCredentialService _credentials;

  Future<BackupProvider> create(BackupConfiguration config) async {
    final resolved = await resolveBackupCredentials(
      credentials: _credentials,
      config: config,
    );

    if (config.providerType == 'webdav') {
      return WebDavBackupProvider(
        endpoint: config.endpoint,
        username: resolved.username!,
        password: resolved.password!,
        basePath: config.bucketOrPath,
      );
    }

    if (config.providerType == 's3') {
      return S3BackupProvider(
        endpoint: config.endpoint,
        accessKey: resolved.accessKey!,
        secretKey: resolved.secretKey!,
        bucket: config.bucketOrPath,
        region: config.region ?? 'us-east-1',
      );
    }

    throw UnsupportedError('不支持的 providerType: ${config.providerType}');
  }
}
