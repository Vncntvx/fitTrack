import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' show sha256;
import 'package:cryptography/cryptography.dart';

import 'backup_credential_service.dart';

/// 备份安全异常
class BackupSecurityException implements Exception {
  const BackupSecurityException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 已加密备份载荷
class EncryptedBackupPayload {
  const EncryptedBackupPayload({
    required this.bytes,
    required this.payloadVersion,
    required this.plaintextChecksum,
    required this.envelopeVersion,
    required this.encryptionAlgorithm,
    required this.keyDerivation,
  });

  final Uint8List bytes;
  final String payloadVersion;
  final String plaintextChecksum;
  final int envelopeVersion;
  final String encryptionAlgorithm;
  final String keyDerivation;
}

/// 已解析的加密备份信封
class BackupEncryptionEnvelope {
  const BackupEncryptionEnvelope({
    required this.envelopeVersion,
    required this.payloadVersion,
    required this.algorithm,
    required this.keyDerivation,
    required this.salt,
    required this.nonce,
    required this.tag,
    required this.ciphertext,
    required this.plaintextChecksum,
    required this.checksumAlgorithm,
  });

  final int envelopeVersion;
  final String payloadVersion;
  final String algorithm;
  final String keyDerivation;
  final Uint8List salt;
  final Uint8List nonce;
  final Uint8List tag;
  final Uint8List ciphertext;
  final String plaintextChecksum;
  final String checksumAlgorithm;
}

/// 备份加解密服务
class BackupCryptoService {
  BackupCryptoService(this._credentials, {Random? random, AesGcm? cipher})
    : _random = random ?? Random.secure(),
      _cipher = cipher ?? AesGcm.with256bits();

  final BackupCredentialService _credentials;
  final Random _random;
  final AesGcm _cipher;

  static const String encryptedPayloadFormat = 'encrypted-v1';
  static const String envelopeMarker = 'fittrack.backup.encrypted';
  static const String encryptionAlgorithm = 'AES-256-GCM';
  static const String keyDerivation = 'HKDF-SHA256';
  static const String checksumAlgorithm = 'SHA-256';
  static const String _hkdfInfo = 'fittrack-backup-encryption-v1';
  static const int _envelopeVersion = 1;
  static const int _masterKeyLength = 32;
  static const int _nonceLength = 12;
  static const int _saltLength = 16;

  static String sha256Hex(Uint8List data) => sha256.convert(data).toString();

  static bool metadataExpectsEncrypted(Map<String, dynamic>? metadata) {
    if (metadata == null) return false;
    return metadata['payloadFormat'] == encryptedPayloadFormat;
  }

  static BackupEncryptionEnvelope? tryParseEnvelope(Uint8List bytes) {
    Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } catch (_) {
      return null;
    }
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    final marker = decoded['format'];
    if (marker == null) {
      return null;
    }
    if (marker != envelopeMarker) {
      return null;
    }
    return _parseEnvelope(decoded);
  }

  Future<EncryptedBackupPayload> encryptPayload(
    Uint8List plaintext, {
    required String payloadVersion,
  }) async {
    final plaintextChecksum = sha256Hex(plaintext);
    final salt = _randomBytes(_saltLength);
    final nonce = _randomBytes(_nonceLength);
    final aad = _buildAad(
      payloadVersion: payloadVersion,
      plaintextChecksum: plaintextChecksum,
    );
    final derivedKey = await _derivePerBackupKey(salt);
    final secretBox = await _cipher.encrypt(
      plaintext,
      secretKey: derivedKey,
      nonce: nonce,
      aad: aad,
    );

    final envelope = <String, dynamic>{
      'format': envelopeMarker,
      'envelopeVersion': _envelopeVersion,
      'payloadVersion': payloadVersion,
      'cipher': <String, dynamic>{
        'algorithm': encryptionAlgorithm,
        'keyDerivation': keyDerivation,
        'salt': base64Encode(salt),
        'nonce': base64Encode(secretBox.nonce),
        'tag': base64Encode(secretBox.mac.bytes),
      },
      'integrity': <String, dynamic>{
        'plaintextChecksum': plaintextChecksum,
        'checksumAlgorithm': checksumAlgorithm,
      },
      'ciphertext': base64Encode(secretBox.cipherText),
    };
    final encoded = Uint8List.fromList(utf8.encode(jsonEncode(envelope)));
    return EncryptedBackupPayload(
      bytes: encoded,
      payloadVersion: payloadVersion,
      plaintextChecksum: plaintextChecksum,
      envelopeVersion: _envelopeVersion,
      encryptionAlgorithm: encryptionAlgorithm,
      keyDerivation: keyDerivation,
    );
  }

  Future<Uint8List> decryptEnvelope(BackupEncryptionEnvelope envelope) async {
    if (envelope.envelopeVersion != _envelopeVersion) {
      throw BackupSecurityException('不支持的加密备份版本: ${envelope.envelopeVersion}');
    }
    if (envelope.algorithm != encryptionAlgorithm) {
      throw BackupSecurityException('不支持的加密算法: ${envelope.algorithm}');
    }
    if (envelope.keyDerivation != keyDerivation) {
      throw BackupSecurityException('不支持的密钥派生算法: ${envelope.keyDerivation}');
    }
    if (envelope.checksumAlgorithm != checksumAlgorithm) {
      throw BackupSecurityException('不支持的校验算法: ${envelope.checksumAlgorithm}');
    }

    final aad = _buildAad(
      payloadVersion: envelope.payloadVersion,
      plaintextChecksum: envelope.plaintextChecksum,
    );
    final secretBox = SecretBox(
      envelope.ciphertext,
      nonce: envelope.nonce,
      mac: Mac(envelope.tag),
    );

    try {
      final key = await _derivePerBackupKey(envelope.salt);
      final plaintext = await _cipher.decrypt(
        secretBox,
        secretKey: key,
        aad: aad,
      );
      final bytes = Uint8List.fromList(plaintext);
      final actualChecksum = sha256Hex(bytes);
      if (actualChecksum != envelope.plaintextChecksum) {
        throw const BackupSecurityException('解密成功但明文校验失败');
      }
      return bytes;
    } on SecretBoxAuthenticationError {
      throw const BackupSecurityException('备份解密失败：认证标签校验失败');
    } on BackupSecurityException {
      rethrow;
    } catch (e) {
      throw BackupSecurityException('备份解密失败: $e');
    }
  }

  Future<SecretKey> _derivePerBackupKey(Uint8List salt) async {
    final masterKeyBytes = await _loadOrCreateMasterKey();
    final hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: _masterKeyLength);
    return hkdf.deriveKey(
      secretKey: SecretKey(masterKeyBytes),
      nonce: salt,
      info: utf8.encode(_hkdfInfo),
    );
  }

  Future<Uint8List> _loadOrCreateMasterKey() async {
    final encoded = await _credentials.readBackupEncryptionMasterKey();
    if (encoded != null && encoded.isNotEmpty) {
      try {
        final bytes = base64Decode(encoded);
        if (bytes.length != _masterKeyLength) {
          throw const BackupSecurityException('备份主密钥长度无效');
        }
        return Uint8List.fromList(bytes);
      } on BackupSecurityException {
        rethrow;
      } catch (_) {
        throw const BackupSecurityException('备份主密钥格式损坏，无法解密备份');
      }
    }

    final generated = _randomBytes(_masterKeyLength);
    await _credentials.writeBackupEncryptionMasterKey(base64Encode(generated));
    return generated;
  }

  Uint8List _randomBytes(int length) {
    final values = List<int>.generate(
      length,
      (_) => _random.nextInt(256),
      growable: false,
    );
    return Uint8List.fromList(values);
  }

  Uint8List _buildAad({
    required String payloadVersion,
    required String plaintextChecksum,
  }) {
    return Uint8List.fromList(
      utf8.encode(
        '$envelopeMarker|v$_envelopeVersion|$payloadVersion|$plaintextChecksum',
      ),
    );
  }

  static BackupEncryptionEnvelope _parseEnvelope(Map<String, dynamic> json) {
    final envelopeVersion = json['envelopeVersion'];
    final payloadVersion = json['payloadVersion'];
    final cipher = json['cipher'];
    final integrity = json['integrity'];
    final ciphertext = json['ciphertext'];
    if (envelopeVersion is! int ||
        payloadVersion is! String ||
        payloadVersion.isEmpty ||
        cipher is! Map<String, dynamic> ||
        integrity is! Map<String, dynamic> ||
        ciphertext is! String ||
        ciphertext.isEmpty) {
      throw const BackupSecurityException('加密备份结构无效');
    }

    final algorithm = cipher['algorithm'];
    final derived = cipher['keyDerivation'];
    final salt = cipher['salt'];
    final nonce = cipher['nonce'];
    final tag = cipher['tag'];
    final plaintextChecksum = integrity['plaintextChecksum'];
    final checksumAlg = integrity['checksumAlgorithm'];
    if (algorithm is! String ||
        algorithm.isEmpty ||
        derived is! String ||
        derived.isEmpty ||
        salt is! String ||
        salt.isEmpty ||
        nonce is! String ||
        nonce.isEmpty ||
        tag is! String ||
        tag.isEmpty ||
        plaintextChecksum is! String ||
        plaintextChecksum.isEmpty ||
        checksumAlg is! String ||
        checksumAlg.isEmpty) {
      throw const BackupSecurityException('加密备份字段缺失或格式错误');
    }

    try {
      final saltBytes = Uint8List.fromList(base64Decode(salt));
      final nonceBytes = Uint8List.fromList(base64Decode(nonce));
      final tagBytes = Uint8List.fromList(base64Decode(tag));
      final cipherBytes = Uint8List.fromList(base64Decode(ciphertext));
      return BackupEncryptionEnvelope(
        envelopeVersion: envelopeVersion,
        payloadVersion: payloadVersion,
        algorithm: algorithm,
        keyDerivation: derived,
        salt: saltBytes,
        nonce: nonceBytes,
        tag: tagBytes,
        ciphertext: cipherBytes,
        plaintextChecksum: plaintextChecksum,
        checksumAlgorithm: checksumAlg,
      );
    } catch (_) {
      throw const BackupSecurityException('加密备份内容损坏，无法解析');
    }
  }
}
