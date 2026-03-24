import 'dart:typed_data';
import 'package:minio/minio.dart';
import 'package:path/path.dart' as p;

import '../backup_provider.dart';

/// S3 备份提供者
class S3BackupProvider implements BackupProvider {
  final Minio _client;
  final String _bucket;
  final String _basePath;

  S3BackupProvider({
    required String endpoint,
    required String accessKey,
    required String secretKey,
    required String bucket,
    String region = 'us-east-1',
    String basePath = '',
  }) : _bucket = bucket,
       _basePath = basePath,
       _client = _buildClient(
         endpoint: endpoint,
         accessKey: accessKey,
         secretKey: secretKey,
         region: region,
       );

  @override
  Future<bool> testConnection() async {
    return _client.bucketExists(_bucket);
  }

  @override
  Future<void> upload(String path, Uint8List data) async {
    await _ensureBucket();
    final objectPath = _resolveObjectPath(path);
    await _client.putObject(
      _bucket,
      objectPath,
      Stream.value(data),
      size: data.length,
    );
  }

  @override
  Future<Uint8List> download(String path) async {
    final objectPath = _resolveObjectPath(path);
    final stream = await _client.getObject(_bucket, objectPath);
    final bytes = BytesBuilder();
    await for (final chunk in stream) {
      bytes.add(chunk);
    }
    return bytes.takeBytes();
  }

  @override
  Future<List<BackupFileInfo>> listFiles(String prefix) async {
    final objectPrefix = _resolveObjectPath(prefix);
    final result = await _client.listAllObjects(
      _bucket,
      prefix: objectPrefix,
      recursive: true,
    );

    return result.objects
        .where((item) => item.key != null)
        .map((item) {
          final key = item.key!;
          return BackupFileInfo(
            path: _stripBasePath(key),
            size: item.size ?? 0,
            modifiedAt:
                item.lastModified ?? DateTime.fromMillisecondsSinceEpoch(0),
          );
        })
        .where((item) => item.path.isNotEmpty)
        .toList();
  }

  @override
  Future<void> delete(String path) async {
    final objectPath = _resolveObjectPath(path);
    await _client.removeObject(_bucket, objectPath);
  }

  static Minio _buildClient({
    required String endpoint,
    required String accessKey,
    required String secretKey,
    required String region,
  }) {
    final uri = _toUri(endpoint);
    if (uri.path.isNotEmpty && uri.path != '/') {
      throw ArgumentError('S3 endpoint path is not supported: ${uri.path}');
    }
    return Minio(
      endPoint: uri.host,
      port: uri.hasPort ? uri.port : null,
      useSSL: uri.scheme == 'https',
      accessKey: accessKey,
      secretKey: secretKey,
      region: region,
    );
  }

  static Uri _toUri(String endpoint) {
    final trimmed = endpoint.trim();
    final value =
        trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed';
    final uri = Uri.parse(value);
    if (uri.host.isEmpty) {
      throw ArgumentError('Invalid S3 endpoint: $endpoint');
    }
    return uri;
  }

  String _normalizePath(String value) {
    return value.trim().replaceAll(RegExp(r'^/+|/+$'), '');
  }

  String _resolveObjectPath(String path) {
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

  String _stripBasePath(String objectPath) {
    final normalizedObject = _normalizePath(objectPath);
    final normalizedBase = _normalizePath(_basePath);
    if (normalizedBase.isEmpty) {
      return normalizedObject;
    }
    if (normalizedObject.startsWith('$normalizedBase/')) {
      return normalizedObject.substring(normalizedBase.length + 1);
    }
    if (normalizedObject == normalizedBase) {
      return '';
    }
    return normalizedObject;
  }

  Future<void> _ensureBucket() async {
    final exists = await _client.bucketExists(_bucket);
    if (!exists) {
      await _client.makeBucket(_bucket);
    }
  }
}
