import 'dart:typed_data';
import 'package:path/path.dart' as p;
import 'package:webdav_plus/webdav_plus.dart';

import '../backup_provider.dart';

/// WebDAV 备份提供者
class WebDavBackupProvider implements BackupProvider {
  final String _endpoint;
  final WebdavClient _client;
  final String _basePath;

  WebDavBackupProvider({
    required String endpoint,
    required String username,
    required String password,
    String basePath = '/',
  }) : _endpoint = endpoint,
       _basePath = basePath,
       _client = WebdavClient.withCredentials(
         username,
         password,
         baseUrl: endpoint,
         isPreemptive: true,
       );

  @override
  Future<bool> testConnection() async {
    try {
      final rootPath = _resolvePath('');
      final url = _buildUrl(rootPath);
      await _client.listWithDepth(url, 0);
      return true;
    } catch (e) {
      // WebDAV 连接测试失败
      return false;
    }
  }

  @override
  Future<void> upload(String path, Uint8List data) async {
    final remotePath = _resolvePath(path);
    final parent = p.posix.dirname(remotePath);
    await _ensureDirectory(parent);
    await _client.put(_buildUrl(remotePath), data);
  }

  @override
  Future<Uint8List> download(String path) async {
    final remotePath = _resolvePath(path);
    return _client.get(_buildUrl(remotePath));
  }

  @override
  Future<List<BackupFileInfo>> listFiles(String prefix) async {
    final remotePrefix = _resolvePath(prefix);
    final normalizedPrefix = _normalizePath(remotePrefix);
    final prefixUrl = _buildUrl(
      remotePrefix.isEmpty ? '' : '$normalizedPrefix/',
    );
    final resources = await _client.listWithDepth(prefixUrl, 1);
    final files = <BackupFileInfo>[];

    for (final resource in resources) {
      if (resource.isDirectory) continue;
      final relativePath = _toRelativePath(resource.href.path);
      if (relativePath.isEmpty) continue;
      files.add(
        BackupFileInfo(
          path: relativePath,
          size: resource.contentLength < 0 ? 0 : resource.contentLength,
          modifiedAt:
              resource.modified ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
      );
    }

    return files;
  }

  @override
  Future<void> delete(String path) async {
    final remotePath = _resolvePath(path);
    await _client.delete(_buildUrl(remotePath));
  }

  String _normalizePath(String value) {
    return value.trim().replaceAll(RegExp(r'^/+|/+$'), '');
  }

  String _resolvePath(String path) {
    final normalizedPath = _normalizePath(path);
    final normalizedBase = _normalizePath(_basePath);
    if (normalizedBase.isEmpty) {
      return normalizedPath;
    }
    if (normalizedPath.isEmpty ||
        normalizedPath == normalizedBase ||
        normalizedPath.startsWith('$normalizedBase/')) {
      return normalizedPath;
    }
    return p.posix.join(normalizedBase, normalizedPath);
  }

  String _buildUrl(String relativePath) {
    final base = _endpoint.endsWith('/')
        ? _endpoint.substring(0, _endpoint.length - 1)
        : _endpoint;
    final normalized = _normalizePath(relativePath);
    if (normalized.isEmpty) {
      return '$base/';
    }
    return '$base/$normalized';
  }

  String _toRelativePath(String hrefPath) {
    final endpointPath = _normalizePath(Uri.parse(_endpoint).path);
    var path = _normalizePath(hrefPath);
    if (endpointPath.isNotEmpty && path.startsWith('$endpointPath/')) {
      path = path.substring(endpointPath.length + 1);
    } else if (path == endpointPath) {
      path = '';
    }
    final base = _normalizePath(_basePath);
    if (base.isNotEmpty && path.startsWith('$base/')) {
      path = path.substring(base.length + 1);
    } else if (path == base) {
      path = '';
    }
    return path;
  }

  Future<void> _ensureDirectory(String dirPath) async {
    final normalized = _normalizePath(dirPath);
    if (normalized.isEmpty || normalized == '.') return;

    var current = '';
    for (final segment in normalized.split('/')) {
      if (segment.isEmpty) continue;
      current = current.isEmpty ? segment : '$current/$segment';
      final currentUrl = _buildUrl('$current/');
      try {
        await _client.createDirectory(currentUrl);
      } catch (e) {
        // 目录可能已存在，检查是否存在
        final exists = await _client.exists(currentUrl);
        if (!exists) rethrow;
      }
    }
  }
}
