import 'dart:typed_data';

/// 备份提供者接口
/// 定义备份存储的基本操作
abstract class BackupProvider {
  /// 测试连接
  Future<bool> testConnection();

  /// 上传文件
  /// [path] 远程路径
  /// [data] 文件数据
  Future<void> upload(String path, Uint8List data);

  /// 下载文件
  /// [path] 远程路径
  Future<Uint8List> download(String path);

  /// 列出文件
  /// [prefix] 路径前缀
  Future<List<BackupFileInfo>> listFiles(String prefix);

  /// 删除文件
  /// [path] 远程路径
  Future<void> delete(String path);
}

/// 备份文件信息
class BackupFileInfo {
  final String path;
  final int size;
  final DateTime modifiedAt;

  BackupFileInfo({
    required this.path,
    required this.size,
    required this.modifiedAt,
  });
}

/// 备份结果
class BackupResult {
  final bool success;
  final String? path;
  final String? error;
  final String? checksum;

  BackupResult({required this.success, this.path, this.error, this.checksum});
}

/// 恢复结果
class RestoreResult {
  final bool success;
  final String? error;

  RestoreResult({required this.success, this.error});
}
