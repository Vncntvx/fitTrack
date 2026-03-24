import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' hide isNotNull;
import 'package:fittrack/core/backup/backup_crypto_service.dart';
import 'package:fittrack/core/backup/backup_credential_service.dart';
import 'package:fittrack/core/backup/backup_provider.dart';
import 'package:fittrack/core/backup/backup_service.dart';
import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/secure_storage/secure_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

class _InMemoryBackupProvider implements BackupProvider {
  Uint8List? payload;

  @override
  Future<void> delete(String path) async {}

  @override
  Future<Uint8List> download(String path) async {
    if (payload == null) {
      throw StateError('missing payload');
    }
    return payload!;
  }

  @override
  Future<List<BackupFileInfo>> listFiles(String prefix) async => const [];

  @override
  Future<bool> testConnection() async => true;

  @override
  Future<void> upload(String path, Uint8List data) async {
    payload = data;
  }
}

class _MemorySecureStorageService extends SecureStorageService {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _values[key];
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }
}

BackupService _buildService(
  AppDatabase db,
  _MemorySecureStorageService secureStorage,
) {
  final credentials = BackupCredentialService(secureStorage);
  final crypto = BackupCryptoService(credentials);
  return BackupService(db, cryptoService: crypto);
}

Future<Directory> _createTestDir(String name) {
  return Directory.current.createTemp(name);
}

Future<BackupRecord> _insertRecord(
  AppDatabase db, {
  required String targetPath,
  required String checksum,
  String? metadataJson,
}) async {
  await db
      .into(db.backupConfigurations)
      .insert(
        const BackupConfigurationsCompanion(
          providerType: Value('webdav'),
          displayName: Value('default'),
          endpoint: Value('https://webdav.local'),
          bucketOrPath: Value('/backups'),
          isDefault: Value(true),
        ),
      );
  final recordId = await db
      .into(db.backupRecords)
      .insert(
        BackupRecordsCompanion.insert(
          configId: 1,
          providerType: 'webdav',
          targetPath: targetPath,
          status: 'completed',
          checksum: Value(checksum),
          metadataJson: Value(metadataJson),
        ),
      );
  return (db.select(
    db.backupRecords,
  )..where((t) => t.id.equals(recordId))).getSingle();
}

void main() {
  test(
    'backup export encrypts payload and preserves plaintext checksum verification',
    () async {
      final tempDir = await _createTestDir('fittrack-backup-export-');
      final dbPath = path.join(tempDir.path, 'fittrack.db');
      final provider = _InMemoryBackupProvider();
      final secureStorage = _MemorySecureStorageService();

      try {
        final db = AppDatabase.native(path: dbPath);
        await db
            .into(db.backupConfigurations)
            .insert(
              const BackupConfigurationsCompanion(
                providerType: Value('s3'),
                displayName: Value('default'),
                endpoint: Value('https://s3.local'),
                bucketOrPath: Value('bucket'),
                isDefault: Value(true),
              ),
            );
        final settingsId = await db
            .into(db.userSettings)
            .insert(
              const UserSettingsCompanion(
                lanServiceTokenEnabled: Value(true),
                themeMode: Value('dark'),
                weightUnit: Value('lbs'),
                distanceUnit: Value('mi'),
              ),
            );
        final service = _buildService(db, secureStorage);

        final result = await service.backup(provider, 'backups');
        expect(result.success, isTrue);
        expect(provider.payload, isA<Uint8List>());

        final envelope = BackupCryptoService.tryParseEnvelope(
          provider.payload!,
        );
        expect(envelope, isA<BackupEncryptionEnvelope>());
        expect(envelope!.algorithm, BackupCryptoService.encryptionAlgorithm);
        expect(envelope.keyDerivation, BackupCryptoService.keyDerivation);
        expect(result.checksum, envelope.plaintextChecksum);

        final records = await service.listBackups(1);
        expect(records, hasLength(1));
        final metadata =
            jsonDecode(records.first.metadataJson!) as Map<String, dynamic>;
        expect(
          metadata['payloadFormat'],
          BackupCryptoService.encryptedPayloadFormat,
        );
        expect(metadata['encryptedChecksum'], isA<String>());

        final restoreResult = await service.restore(provider, records.first);
        expect(restoreResult.success, isTrue);
        final settings = await (db.select(
          db.userSettings,
        )..limit(1)).getSingle();
        expect(settings.id, settingsId);
        expect(settings.lanServiceTokenEnabled, isTrue);
        expect(settings.weightUnit, 'lbs');
        expect(settings.distanceUnit, 'mi');

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );

  test(
    'restore rejects encrypted metadata when payload is plaintext',
    () async {
      final tempDir = await _createTestDir('fittrack-backup-plaintext-reject-');
      final dbPath = path.join(tempDir.path, 'fittrack.db');
      final provider = _InMemoryBackupProvider();
      final secureStorage = _MemorySecureStorageService();

      try {
        final db = AppDatabase.native(path: dbPath);
        final service = _buildService(db, secureStorage);
        final payload = <String, dynamic>{
          'version': '2.0.0',
          'exportDate': DateTime.now().toIso8601String(),
          'workouts': const <dynamic>[],
          'strengthExercises': const <dynamic>[],
          'runningEntries': const <dynamic>[],
          'runningSplits': const <dynamic>[],
          'swimmingEntries': const <dynamic>[],
          'swimmingSets': const <dynamic>[],
          'templates': const <dynamic>[],
          'templateExercises': const <dynamic>[],
          'exercises': const <dynamic>[],
          'personalRecords': const <dynamic>[],
          'backupConfigs': const <dynamic>[],
          'backupRecords': const <dynamic>[],
          'settings': const <dynamic>[],
        };
        final bytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
        provider.payload = bytes;
        final checksum = BackupCryptoService.sha256Hex(bytes);
        final metadata = jsonEncode({
          'payloadFormat': BackupCryptoService.encryptedPayloadFormat,
          'payloadVersion': '2.0.0',
          'envelopeVersion': 1,
          'encryptionAlgorithm': BackupCryptoService.encryptionAlgorithm,
          'keyDerivation': BackupCryptoService.keyDerivation,
          'checksumAlgorithm': BackupCryptoService.checksumAlgorithm,
          'encryptedChecksum': BackupCryptoService.sha256Hex(bytes),
        });
        final record = await _insertRecord(
          db,
          targetPath: 'backups/file.json',
          checksum: checksum,
          metadataJson: metadata,
        );

        final restoreResult = await service.restore(provider, record);
        expect(restoreResult.success, isFalse);
        expect(restoreResult.error, contains('备份记录要求加密格式'));

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );

  test('restore detects tampered encrypted payload before decrypt', () async {
    final tempDir = await _createTestDir('fittrack-backup-tampered-encrypted-');
    final dbPath = path.join(tempDir.path, 'fittrack.db');
    final provider = _InMemoryBackupProvider();
    final secureStorage = _MemorySecureStorageService();

    try {
      final db = AppDatabase.native(path: dbPath);
      final service = _buildService(db, secureStorage);

      await db
          .into(db.userSettings)
          .insert(
            const UserSettingsCompanion(
              lanServiceTokenEnabled: Value(true),
              themeMode: Value('light'),
            ),
          );

      await db
          .into(db.backupConfigurations)
          .insert(
            const BackupConfigurationsCompanion(
              providerType: Value('webdav'),
              displayName: Value('default'),
              endpoint: Value('https://webdav.local'),
              bucketOrPath: Value('/backups'),
              isDefault: Value(true),
            ),
          );
      final backupResult = await service.backup(provider, 'backups');
      expect(backupResult.success, isTrue);

      final records = await service.listBackups(1);
      expect(records, hasLength(1));
      final record = records.first;

      final envelopeJson =
          jsonDecode(utf8.decode(provider.payload!)) as Map<String, dynamic>;
      final ciphertextBase64 = envelopeJson['ciphertext'] as String;
      final ciphertextBytes = base64Decode(ciphertextBase64);
      ciphertextBytes[0] = ciphertextBytes[0] ^ 0x01;
      envelopeJson['ciphertext'] = base64Encode(ciphertextBytes);
      provider.payload = Uint8List.fromList(
        utf8.encode(jsonEncode(envelopeJson)),
      );

      final restoreResult = await service.restore(provider, record);
      expect(restoreResult.success, isFalse);
      expect(restoreResult.error, contains('加密备份密文校验失败'));

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });

  test('restore fails when decryption authentication tag is invalid', () async {
    final tempDir = await _createTestDir('fittrack-backup-decrypt-failure-');
    final dbPath = path.join(tempDir.path, 'fittrack.db');
    final provider = _InMemoryBackupProvider();
    final secureStorage = _MemorySecureStorageService();

    try {
      final db = AppDatabase.native(path: dbPath);
      final service = _buildService(db, secureStorage);
      await db
          .into(db.userSettings)
          .insert(const UserSettingsCompanion(themeMode: Value('dark')));

      await db
          .into(db.backupConfigurations)
          .insert(
            const BackupConfigurationsCompanion(
              providerType: Value('webdav'),
              displayName: Value('default'),
              endpoint: Value('https://webdav.local'),
              bucketOrPath: Value('/backups'),
              isDefault: Value(true),
            ),
          );
      final backupResult = await service.backup(provider, 'backups');
      expect(backupResult.success, isTrue);

      final records = await service.listBackups(1);
      final originalRecord = records.first;

      final envelopeJson =
          jsonDecode(utf8.decode(provider.payload!)) as Map<String, dynamic>;
      final cipher = envelopeJson['cipher'] as Map<String, dynamic>;
      final originalTag = cipher['tag'] as String;
      final tagBytes = base64Decode(originalTag);
      tagBytes[0] = tagBytes[0] ^ 0x01;
      cipher['tag'] = base64Encode(tagBytes);
      provider.payload = Uint8List.fromList(
        utf8.encode(jsonEncode(envelopeJson)),
      );

      final metadata =
          jsonDecode(originalRecord.metadataJson!) as Map<String, dynamic>;
      metadata['encryptedChecksum'] = BackupCryptoService.sha256Hex(
        provider.payload!,
      );
      final mutatedRecord = originalRecord.copyWith(
        metadataJson: Value(jsonEncode(metadata)),
      );

      final restoreResult = await service.restore(provider, mutatedRecord);
      expect(restoreResult.success, isFalse);
      expect(restoreResult.error, contains('认证标签校验失败'));

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });

  test(
    'importData accepts explicitly versioned legacy bulk export payload',
    () async {
      final tempDir = await _createTestDir('fittrack-backup-legacy-import-');
      final dbPath = path.join(tempDir.path, 'fittrack.db');
      final secureStorage = _MemorySecureStorageService();

      try {
        final db = AppDatabase.native(path: dbPath);
        final service = _buildService(db, secureStorage);
        final now = DateTime.now();

        await service.importData({
          'exportVersion': '1.0',
          'exportDate': now.toIso8601String(),
          'data': {
            'trainingSessions': [
              {
                'id': 1,
                'datetime': now.toIso8601String(),
                'type': 'running',
                'durationMinutes': 42,
                'intensity': 'moderate',
                'note': 'legacy payload',
                'isGoalCompleted': true,
                'templateId': null,
                'createdAt': now.toIso8601String(),
                'updatedAt': now.toIso8601String(),
              },
            ],
            'strengthExerciseEntries': const <dynamic>[],
            'runningEntries': const <dynamic>[],
            'runningSplits': const <dynamic>[],
            'swimmingEntries': const <dynamic>[],
            'swimmingSets': const <dynamic>[],
            'workoutTemplates': const <dynamic>[],
            'templateExercises': const <dynamic>[],
            'exercises': const <dynamic>[],
            'personalRecords': const <dynamic>[],
            'userSettings': [
              {
                'id': 1,
                'weeklyWorkoutDaysGoal': 5,
                'weeklyWorkoutMinutesGoal': 240,
                'themeMode': 'dark',
                'weightUnit': 'kg',
                'distanceUnit': 'km',
                'lanServiceEnabled': true,
                'lanServicePort': 8080,
                'lanServiceTokenEnabled': true,
                'defaultBackupConfigId': null,
                'createdAt': now.toIso8601String(),
                'updatedAt': now.toIso8601String(),
              },
            ],
            'backupConfigurations': const <dynamic>[],
            'backupRecords': const <dynamic>[],
          },
        });

        final sessions = await db.select(db.trainingSessions).get();
        final settings = await (db.select(
          db.userSettings,
        )..limit(1)).getSingle();

        expect(sessions, hasLength(1));
        expect(sessions.first.note, 'legacy payload');
        expect(settings.weeklyWorkoutDaysGoal, 5);
        expect(settings.lanServiceTokenEnabled, isTrue);

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );

  test('importData rejects payload without explicit version', () async {
    final tempDir = await _createTestDir('fittrack-backup-missing-version-');
    final dbPath = path.join(tempDir.path, 'fittrack.db');
    final secureStorage = _MemorySecureStorageService();

    try {
      final db = AppDatabase.native(path: dbPath);
      final service = _buildService(db, secureStorage);

      expect(
        () => service.importData({
          'exportDate': DateTime.now().toIso8601String(),
          'workouts': const <dynamic>[],
        }),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'message',
            contains('缺少版本信息'),
          ),
        ),
      );

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });

  test(
    'importData restores data with template and exercise foreign keys',
    () async {
      final tempDir = await _createTestDir('fittrack-backup-fk-import-');
      final dbPath = path.join(tempDir.path, 'fittrack.db');
      final secureStorage = _MemorySecureStorageService();

      try {
        final db = AppDatabase.native(path: dbPath);
        final service = _buildService(db, secureStorage);
        final now = DateTime(2026, 3, 15, 8, 0);

        await service.importData({
          'version': '2.0.0',
          'exportDate': now.toIso8601String(),
          'workouts': [
            {
              'id': 101,
              'datetime': now.toIso8601String(),
              'type': 'strength',
              'durationMinutes': 40,
              'intensity': 'high',
              'note': 'with fk',
              'isGoalCompleted': false,
              'templateId': 201,
              'createdAt': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
            },
          ],
          'strengthExercises': [
            {
              'id': 301,
              'sessionId': 101,
              'exerciseId': 401,
              'exerciseName': '测试深蹲',
              'sets': 3,
              'defaultReps': 5,
              'defaultWeight': 100.0,
              'repsPerSet': '[5,5,5]',
              'weightPerSet': '[100,100,100]',
              'setCompleted': '[true,true,true]',
              'isWarmup': false,
              'rpe': 8,
              'restSeconds': 120,
              'note': null,
              'sortOrder': 0,
            },
          ],
          'runningEntries': const <dynamic>[],
          'runningSplits': const <dynamic>[],
          'swimmingEntries': const <dynamic>[],
          'swimmingSets': const <dynamic>[],
          'templates': [
            {
              'id': 201,
              'name': '测试模板',
              'type': 'strength',
              'description': null,
              'isDefault': false,
              'createdAt': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
            },
          ],
          'templateExercises': const <dynamic>[],
          'exercises': [
            {
              'id': 401,
              'name': '测试深蹲',
              'category': 'legs',
              'movementType': 'compound',
              'primaryMuscles': null,
              'secondaryMuscles': null,
              'defaultSets': 3,
              'defaultReps': 5,
              'defaultWeight': 100.0,
              'isCustom': true,
              'isEnabled': true,
              'description': null,
              'createdAt': now.toIso8601String(),
              'updatedAt': now.toIso8601String(),
            },
          ],
          'personalRecords': const <dynamic>[],
          'backupConfigs': const <dynamic>[],
          'backupRecords': const <dynamic>[],
          'settings': const <dynamic>[],
        });

        final sessions = await db.select(db.trainingSessions).get();
        final strengthEntries = await db
            .select(db.strengthExerciseEntries)
            .get();
        expect(sessions, hasLength(1));
        expect(sessions.first.templateId, 201);
        expect(strengthEntries, hasLength(1));
        expect(strengthEntries.first.exerciseId, 401);

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );
}
