import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 安全存储服务
/// 用于存储敏感信息如密码、密钥等
class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  /// 存储键名常量
  static const String lanServiceToken = 'lan_service_token';
  static const String webdavPassword = 'webdav_password';
  static const String webdavUsername = 'webdav_username';
  static const String s3AccessKey = 's3_access_key';
  static const String s3SecretKey = 's3_secret_key';
  static const String backupEncryptionMasterKey =
      'backup_encryption_master_key';

  /// 写入字符串值
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// 读取字符串值
  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  /// 删除指定键
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  /// 删除所有数据
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
