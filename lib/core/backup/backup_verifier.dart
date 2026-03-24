import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as path;

import 'backup_provider.dart';
import 'backup_crypto_service.dart';

/// 备份验证器
class BackupVerifier {
  static String calculateChecksum(Uint8List data) {
    final digest = sha256.convert(data);
    return digest.toString();
  }

  static Future<String> calculateChecksumFromFile(File file) async {
    final bytes = await file.readAsBytes();
    return calculateChecksum(bytes);
  }

  static bool verify(Uint8List data, String expectedChecksum) {
    final actualChecksum = calculateChecksum(data);
    return actualChecksum == expectedChecksum;
  }

  static bool verifyEncryptedPayload(Uint8List data, String expectedChecksum) {
    final envelope = BackupCryptoService.tryParseEnvelope(data);
    if (envelope == null) {
      return false;
    }
    return envelope.plaintextChecksum == expectedChecksum;
  }

  static Map<String, dynamic> generateMetadata(
    String filename,
    int size,
    String checksum, {
    String? note,
  }) {
    return {
      'filename': filename,
      'size': size,
      'checksum': checksum,
      'checksumAlgorithm': 'SHA-256',
      'createdAt': DateTime.now().toIso8601String(),
      'note': note,
    };
  }

  static Future<void> saveMetadata(
    String backupPath,
    Map<String, dynamic> metadata,
    BackupProvider provider,
  ) async {
    final metadataPath = '${path.withoutExtension(backupPath)}.meta.json';
    final jsonString = const JsonEncoder.withIndent('  ').convert(metadata);
    final data = Uint8List.fromList(utf8.encode(jsonString));
    await provider.upload(metadataPath, data);
  }

  static Future<Map<String, dynamic>?> readMetadata(
    String backupPath,
    BackupProvider provider,
  ) async {
    try {
      final metadataPath = '${path.withoutExtension(backupPath)}.meta.json';
      final data = await provider.download(metadataPath);
      final jsonString = utf8.decode(data);
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
