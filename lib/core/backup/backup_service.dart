import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as path;

import '../../core/database/database.dart';
import '../secure_storage/secure_storage_service.dart';
import 'backup_credential_service.dart';
import 'backup_crypto_service.dart';
import 'backup_provider.dart';

/// JSON 数据类型别名
typedef JsonMap = Map<String, Object?>;

/// JSON 列表类型别名
typedef JsonList = List<Object?>;

// ========== 类型安全的 JSON 解析辅助函数 ==========

/// 从 JSON Map 中获取 String 值
String _getString(JsonMap json, String key) => json[key] as String;

/// 从 JSON Map 中获取可空 String 值
String? _getNullableString(JsonMap json, String key) => json[key] as String?;

/// 从 JSON Map 中获取 int 值
int _getInt(JsonMap json, String key) => json[key] as int;

/// 从 JSON Map 中获取可空 int 值
int? _getNullableInt(JsonMap json, String key) => json[key] as int?;

/// 从 JSON Map 中获取 bool 值
bool _getBool(JsonMap json, String key) => json[key] as bool;

/// 从 JSON Map 中获取 double 值
double _getDouble(JsonMap json, String key) => (json[key] as num).toDouble();

/// 从 JSON Map 中获取可空 double 值
double? _getNullableDouble(JsonMap json, String key) =>
    (json[key] as num?)?.toDouble();

/// 从 JSON Map 中获取 DateTime 值
DateTime _getDateTime(JsonMap json, String key) =>
    DateTime.parse(json[key] as String);

/// 将 dynamic List 转换为类型化的 JsonMap 列表
List<JsonMap> _parseJsonList(List<dynamic> list) => list.cast<JsonMap>();

/// 备份服务
/// 管理数据库备份和恢复
class BackupService {
  final AppDatabase _db;
  final BackupCryptoService _cryptoService;

  BackupService(
    this._db, {
    BackupCryptoService? cryptoService,
    BackupCredentialService? credentials,
  }) : _cryptoService =
           cryptoService ??
           BackupCryptoService(
             credentials ?? BackupCredentialService(SecureStorageService()),
           );

  /// 导出完整数据
  Future<Map<String, dynamic>> exportData() async {
    return _exportDatabase();
  }

  /// 导入完整数据
  Future<void> importData(Map<String, dynamic> data) async {
    // 先做格式归一化再进入导入事务，确保恢复流程只处理一种结构，降低分支复杂度。
    final normalized = _normalizeImportData(data);
    _validateImportPayload(normalized);
    await _importDatabase(normalized);
  }

  /// 执行备份
  Future<BackupResult> backup(
    BackupProvider provider,
    String basePath, {
    int? configId,
  }) async {
    try {
      BackupConfiguration? targetConfig;
      if (configId != null) {
        targetConfig =
            await (_db.select(_db.backupConfigurations)
                  ..where((c) => c.id.equals(configId))
                  ..limit(1))
                .getSingleOrNull();
      }
      targetConfig ??=
          await (_db.select(_db.backupConfigurations)
                ..where((c) => c.isDefault.equals(true))
                ..limit(1))
              .getSingleOrNull();
      targetConfig ??= await (_db.select(
        _db.backupConfigurations,
      )..limit(1)).getSingleOrNull();

      // 生成备份文件名
      final timestamp = DateTime.now();
      final filename =
          'workout_backup_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_'
          '${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}.json';
      final remotePath = path.join(basePath, filename);

      // 导出数据
      final payload = await exportData();
      final payloadVersion = _extractPayloadVersion(payload);

      // 转换为 JSON 并进行加密封装
      final jsonString = const JsonEncoder.withIndent('  ').convert(payload);
      final plaintextData = Uint8List.fromList(utf8.encode(jsonString));
      final encrypted = await _cryptoService.encryptPayload(
        plaintextData,
        payloadVersion: payloadVersion,
      );
      final encryptedChecksum = BackupCryptoService.sha256Hex(encrypted.bytes);

      // 上传
      await provider.upload(remotePath, encrypted.bytes);

      // 记录备份历史
      await _recordBackup(
        providerType: targetConfig?.providerType ?? 'unknown',
        configId: targetConfig?.id,
        targetPath: remotePath,
        checksum: encrypted.plaintextChecksum,
        size: encrypted.bytes.length,
        metadata: {
          'payloadFormat': BackupCryptoService.encryptedPayloadFormat,
          'payloadVersion': encrypted.payloadVersion,
          'envelopeVersion': encrypted.envelopeVersion,
          'encryptionAlgorithm': encrypted.encryptionAlgorithm,
          'keyDerivation': encrypted.keyDerivation,
          'checksumAlgorithm': BackupCryptoService.checksumAlgorithm,
          'encryptedChecksum': encryptedChecksum,
          'checksumScope': 'plaintext',
        },
      );

      return BackupResult(
        success: true,
        path: remotePath,
        checksum: encrypted.plaintextChecksum,
      );
    } on BackupSecurityException catch (e) {
      return BackupResult(success: false, error: e.message);
    } catch (e) {
      return BackupResult(success: false, error: e.toString());
    }
  }

  /// 执行恢复
  Future<RestoreResult> restore(
    BackupProvider provider,
    BackupRecord record,
  ) async {
    try {
      // 下载备份文件
      final downloadedData = await provider.download(record.targetPath);
      final metadata = _parseRecordMetadata(record.metadataJson);
      final expectedChecksum = _requiredRecordChecksum(record);
      final expectedEncrypted = BackupCryptoService.metadataExpectsEncrypted(
        metadata,
      );
      final encryptedEnvelope = BackupCryptoService.tryParseEnvelope(
        downloadedData,
      );

      late final Uint8List importBytes;
      if (expectedEncrypted) {
        if (encryptedEnvelope == null) {
          return RestoreResult(
            success: false,
            error: '备份记录要求加密格式，但载荷不是受支持的加密备份',
          );
        }
        _validateEncryptedMetadata(
          metadata: metadata!,
          envelope: encryptedEnvelope,
          encryptedData: downloadedData,
        );
        importBytes = await _cryptoService.decryptEnvelope(encryptedEnvelope);
      } else if (encryptedEnvelope != null) {
        // 兼容已加密但缺失新元数据的历史记录。
        importBytes = await _cryptoService.decryptEnvelope(encryptedEnvelope);
      } else {
        final actualChecksum = BackupCryptoService.sha256Hex(downloadedData);
        if (actualChecksum != expectedChecksum) {
          return RestoreResult(success: false, error: '校验和不匹配，文件可能已损坏');
        }
        importBytes = downloadedData;
      }

      final actualPlaintextChecksum = BackupCryptoService.sha256Hex(
        importBytes,
      );
      if (actualPlaintextChecksum != expectedChecksum) {
        return RestoreResult(success: false, error: '恢复前完整性校验失败，备份内容可能被篡改');
      }

      // 解析数据并导入
      final exportData = _decodeBackupPayload(importBytes);

      // 恢复采用“校验通过后再覆盖导入”语义；一旦进入导入，成功/失败由内部事务整体决定。
      await importData(exportData);

      return RestoreResult(success: true);
    } on BackupSecurityException catch (e) {
      return RestoreResult(success: false, error: e.message);
    } on FormatException catch (e) {
      return RestoreResult(success: false, error: e.message);
    } catch (e) {
      return RestoreResult(success: false, error: e.toString());
    }
  }

  /// 列出备份
  Future<List<BackupRecord>> listBackups(int configId) async {
    return await (_db.select(_db.backupRecords)
          ..where((r) => r.configId.equals(configId))
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
        .get();
  }

  /// 导出数据库
  Future<Map<String, dynamic>> _exportDatabase() async {
    final workouts = await _db.select(_db.trainingSessions).get();
    final strengthExercises = await _db
        .select(_db.strengthExerciseEntries)
        .get();
    final runningEntries = await _db.select(_db.runningEntries).get();
    final runningSplits = await _db.select(_db.runningSplits).get();
    final swimmingEntries = await _db.select(_db.swimmingEntries).get();
    final swimmingSets = await _db.select(_db.swimmingSets).get();
    final templates = await _db.select(_db.workoutTemplates).get();
    final templateExercises = await _db.select(_db.templateExercises).get();
    final exercises = await _db.select(_db.exercises).get();
    final personalRecords = await _db.select(_db.personalRecords).get();
    final settings = await _db.select(_db.userSettings).get();
    final backupConfigs = await _db.select(_db.backupConfigurations).get();
    final backupRecords = await _db.select(_db.backupRecords).get();

    return {
      'version': '2.0.0',
      'exportDate': DateTime.now().toIso8601String(),
      'workouts': workouts
          .map(
            (w) => {
              'id': w.id,
              'datetime': w.datetime.toIso8601String(),
              'type': w.type,
              'durationMinutes': w.durationMinutes,
              'intensity': w.intensity,
              'note': w.note,
              'isGoalCompleted': w.isGoalCompleted,
              'templateId': w.templateId,
              'createdAt': w.createdAt.toIso8601String(),
              'updatedAt': w.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'strengthExercises': strengthExercises
          .map(
            (e) => {
              'id': e.id,
              'sessionId': e.sessionId,
              'exerciseId': e.exerciseId,
              'exerciseName': e.exerciseName,
              'sets': e.sets,
              'defaultReps': e.defaultReps,
              'defaultWeight': e.defaultWeight,
              'repsPerSet': e.repsPerSet,
              'weightPerSet': e.weightPerSet,
              'setCompleted': e.setCompleted,
              'isWarmup': e.isWarmup,
              'rpe': e.rpe,
              'restSeconds': e.restSeconds,
              'note': e.note,
              'sortOrder': e.sortOrder,
            },
          )
          .toList(),
      'runningEntries': runningEntries
          .map(
            (e) => {
              'id': e.id,
              'sessionId': e.sessionId,
              'runType': e.runType,
              'distanceMeters': e.distanceMeters,
              'durationSeconds': e.durationSeconds,
              'avgPaceSeconds': e.avgPaceSeconds,
              'bestPaceSeconds': e.bestPaceSeconds,
              'avgHeartRate': e.avgHeartRate,
              'maxHeartRate': e.maxHeartRate,
              'avgCadence': e.avgCadence,
              'maxCadence': e.maxCadence,
              'elevationGain': e.elevationGain,
              'elevationLoss': e.elevationLoss,
              'footwear': e.footwear,
              'weatherJson': e.weatherJson,
            },
          )
          .toList(),
      'runningSplits': runningSplits
          .map(
            (s) => {
              'id': s.id,
              'runningEntryId': s.runningEntryId,
              'splitNumber': s.splitNumber,
              'distanceMeters': s.distanceMeters,
              'durationSeconds': s.durationSeconds,
              'paceSeconds': s.paceSeconds,
              'avgHeartRate': s.avgHeartRate,
              'cadence': s.cadence,
              'elevationGain': s.elevationGain,
              'isManual': s.isManual,
            },
          )
          .toList(),
      'swimmingEntries': swimmingEntries
          .map(
            (e) => {
              'id': e.id,
              'sessionId': e.sessionId,
              'environment': e.environment,
              'poolLengthMeters': e.poolLengthMeters,
              'primaryStroke': e.primaryStroke,
              'distanceMeters': e.distanceMeters,
              'durationSeconds': e.durationSeconds,
              'pacePer100m': e.pacePer100m,
              'trainingType': e.trainingType,
              'equipment': e.equipment,
            },
          )
          .toList(),
      'swimmingSets': swimmingSets
          .map(
            (s) => {
              'id': s.id,
              'swimmingEntryId': s.swimmingEntryId,
              'setType': s.setType,
              'description': s.description,
              'distanceMeters': s.distanceMeters,
              'durationSeconds': s.durationSeconds,
              'sortOrder': s.sortOrder,
            },
          )
          .toList(),
      'templates': templates
          .map(
            (t) => {
              'id': t.id,
              'name': t.name,
              'type': t.type,
              'description': t.description,
              'isDefault': t.isDefault,
              'createdAt': t.createdAt.toIso8601String(),
              'updatedAt': t.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'templateExercises': templateExercises
          .map(
            (e) => {
              'id': e.id,
              'templateId': e.templateId,
              'exerciseId': e.exerciseId,
              'exerciseName': e.exerciseName,
              'sets': e.sets,
              'reps': e.reps,
              'weight': e.weight,
              'sortOrder': e.sortOrder,
            },
          )
          .toList(),
      'exercises': exercises
          .map(
            (e) => {
              'id': e.id,
              'name': e.name,
              'category': e.category,
              'movementType': e.movementType,
              'primaryMuscles': e.primaryMuscles,
              'secondaryMuscles': e.secondaryMuscles,
              'defaultSets': e.defaultSets,
              'defaultReps': e.defaultReps,
              'defaultWeight': e.defaultWeight,
              'isCustom': e.isCustom,
              'isEnabled': e.isEnabled,
              'description': e.description,
              'createdAt': e.createdAt.toIso8601String(),
              'updatedAt': e.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'personalRecords': personalRecords
          .map(
            (r) => {
              'id': r.id,
              'recordType': r.recordType,
              'exerciseId': r.exerciseId,
              'value': r.value,
              'unit': r.unit,
              'achievedAt': r.achievedAt.toIso8601String(),
              'sessionId': r.sessionId,
              'createdAt': r.createdAt.toIso8601String(),
            },
          )
          .toList(),
      'settings': settings
          .map(
            (s) => {
              'id': s.id,
              'weeklyWorkoutDaysGoal': s.weeklyWorkoutDaysGoal,
              'weeklyWorkoutMinutesGoal': s.weeklyWorkoutMinutesGoal,
              'themeMode': s.themeMode,
              'weightUnit': s.weightUnit,
              'distanceUnit': s.distanceUnit,
              'lanServiceEnabled': s.lanServiceEnabled,
              'lanServicePort': s.lanServicePort,
              'lanServiceTokenEnabled': s.lanServiceTokenEnabled,
              'defaultBackupConfigId': s.defaultBackupConfigId,
              'createdAt': s.createdAt.toIso8601String(),
              'updatedAt': s.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'backupConfigs': backupConfigs
          .map(
            (c) => {
              'id': c.id,
              'providerType': c.providerType,
              'displayName': c.displayName,
              'endpoint': c.endpoint,
              'bucketOrPath': c.bucketOrPath,
              'region': c.region,
              'isDefault': c.isDefault,
              'createdAt': c.createdAt.toIso8601String(),
              'updatedAt': c.updatedAt.toIso8601String(),
            },
          )
          .toList(),
      'backupRecords': backupRecords
          .map(
            (r) => {
              'id': r.id,
              'configId': r.configId,
              'providerType': r.providerType,
              'targetPath': r.targetPath,
              'createdAt': r.createdAt.toIso8601String(),
              'status': r.status,
              'checksum': r.checksum,
              'metadataJson': r.metadataJson,
            },
          )
          .toList(),
    };
  }

  /// 导入数据库
  Future<void> _importDatabase(Map<String, dynamic> data) async {
    // 先清空后重建必须在单事务内执行，避免中途失败导致数据库落在“半导入”状态。
    await _db.transaction(() async {
      // 删除顺序遵循外键依赖：先删子表，再删父表。
      await _db.delete(_db.userSettings).go();
      await _db.delete(_db.runningSplits).go();
      await _db.delete(_db.swimmingSets).go();
      await _db.delete(_db.runningEntries).go();
      await _db.delete(_db.swimmingEntries).go();
      await _db.delete(_db.strengthExerciseEntries).go();
      await _db.delete(_db.templateExercises).go();
      await _db.delete(_db.workoutTemplates).go();
      await _db.delete(_db.personalRecords).go();
      await _db.delete(_db.backupRecords).go();
      await _db.delete(_db.backupConfigurations).go();
      await _db.delete(_db.trainingSessions).go();
      await _db.delete(_db.exercises).go();

      // 重建顺序与依赖一致：先基础维表，再会话主表，最后明细/关联表。
      final exercises = _parseJsonList(
        data['exercises'] as List<dynamic>? ?? <dynamic>[],
      );
      for (final item in exercises) {
        await _db
            .into(_db.exercises)
            .insert(
              ExercisesCompanion(
                id: Value(_getInt(item, 'id')),
                name: Value(_getString(item, 'name')),
                category: Value(_getString(item, 'category')),
                movementType: Value(
                  item['movementType'] as String? ?? 'compound',
                ),
                primaryMuscles: Value(
                  _getNullableString(item, 'primaryMuscles'),
                ),
                secondaryMuscles: Value(
                  _getNullableString(item, 'secondaryMuscles'),
                ),
                defaultSets: Value(item['defaultSets'] as int? ?? 3),
                defaultReps: Value(item['defaultReps'] as int? ?? 10),
                defaultWeight: Value(_getNullableDouble(item, 'defaultWeight')),
                isCustom: Value(item['isCustom'] as bool? ?? false),
                isEnabled: Value(item['isEnabled'] as bool? ?? true),
                description: Value(_getNullableString(item, 'description')),
                createdAt: item['createdAt'] != null
                    ? Value(_getDateTime(item, 'createdAt'))
                    : Value(DateTime.now()),
                updatedAt: item['updatedAt'] != null
                    ? Value(_getDateTime(item, 'updatedAt'))
                    : Value(DateTime.now()),
              ),
            );
      }

      final templates = _parseJsonList(
        data['templates'] as List<dynamic>? ?? <dynamic>[],
      );
      for (final item in templates) {
        await _db
            .into(_db.workoutTemplates)
            .insert(
              WorkoutTemplatesCompanion(
                id: Value(_getInt(item, 'id')),
                name: Value(_getString(item, 'name')),
                type: Value(_getString(item, 'type')),
                description: Value(_getNullableString(item, 'description')),
                isDefault: Value(item['isDefault'] as bool? ?? false),
                createdAt: item['createdAt'] != null
                    ? Value(_getDateTime(item, 'createdAt'))
                    : Value(DateTime.now()),
                updatedAt: item['updatedAt'] != null
                    ? Value(_getDateTime(item, 'updatedAt'))
                    : Value(DateTime.now()),
              ),
            );
      }

      final backupConfigs = _parseJsonList(
        data['backupConfigs'] as List<dynamic>? ?? <dynamic>[],
      );
      for (final item in backupConfigs) {
        await _db
            .into(_db.backupConfigurations)
            .insert(
              BackupConfigurationsCompanion(
                id: Value(_getInt(item, 'id')),
                providerType: Value(_getString(item, 'providerType')),
                displayName: Value(_getString(item, 'displayName')),
                endpoint: Value(_getString(item, 'endpoint')),
                bucketOrPath: Value(_getString(item, 'bucketOrPath')),
                region: Value(_getNullableString(item, 'region')),
                isDefault: Value(item['isDefault'] as bool? ?? false),
                createdAt: item['createdAt'] != null
                    ? Value(_getDateTime(item, 'createdAt'))
                    : Value(DateTime.now()),
                updatedAt: item['updatedAt'] != null
                    ? Value(_getDateTime(item, 'updatedAt'))
                    : Value(DateTime.now()),
              ),
            );
      }

      // 会话主表先写入，后续 running/swimming/strength 明细通过 sessionId 关联。
      final workouts = _parseJsonList(
        data['workouts'] as List<dynamic>? ?? <dynamic>[],
      );
      for (final item in workouts) {
        await _db
            .into(_db.trainingSessions)
            .insert(
              TrainingSessionsCompanion(
                id: Value(_getInt(item, 'id')),
                datetime: Value(_getDateTime(item, 'datetime')),
                type: Value(_getString(item, 'type')),
                durationMinutes: Value(_getInt(item, 'durationMinutes')),
                intensity: Value(_getString(item, 'intensity')),
                note: Value(_getNullableString(item, 'note')),
                isGoalCompleted: Value(_getBool(item, 'isGoalCompleted')),
                templateId: Value(_getNullableInt(item, 'templateId')),
                createdAt: Value(_getDateTime(item, 'createdAt')),
                updatedAt: Value(_getDateTime(item, 'updatedAt')),
              ),
            );
      }

      // 明细表按依赖顺序导入，确保外键始终可解析。
      final strengthExercises = _parseJsonList(
        data['strengthExercises'] as List<dynamic>? ?? <dynamic>[],
      );
      for (final item in strengthExercises) {
        await _db
            .into(_db.strengthExerciseEntries)
            .insert(
              StrengthExerciseEntriesCompanion(
                id: Value(_getInt(item, 'id')),
                sessionId: Value(_getInt(item, 'sessionId')),
                exerciseId: Value(_getNullableInt(item, 'exerciseId')),
                exerciseName: Value(_getString(item, 'exerciseName')),
                sets: Value(_getInt(item, 'sets')),
                defaultReps: Value(_getInt(item, 'defaultReps')),
                defaultWeight: Value(_getNullableDouble(item, 'defaultWeight')),
                repsPerSet: Value(_getNullableString(item, 'repsPerSet')),
                weightPerSet: Value(_getNullableString(item, 'weightPerSet')),
                setCompleted: Value(_getNullableString(item, 'setCompleted')),
                isWarmup: Value(_getBool(item, 'isWarmup')),
                rpe: Value(_getNullableInt(item, 'rpe')),
                restSeconds: Value(_getNullableInt(item, 'restSeconds')),
                note: Value(_getNullableString(item, 'note')),
                sortOrder: Value(_getInt(item, 'sortOrder')),
              ),
            );
      }

      final runningEntries = _parseJsonList(
        data['runningEntries'] as List<dynamic>? ?? <dynamic>[],
      );
      for (final item in runningEntries) {
        await _db
            .into(_db.runningEntries)
            .insert(
              RunningEntriesCompanion(
                id: Value(_getInt(item, 'id')),
                sessionId: Value(_getInt(item, 'sessionId')),
                runType: Value(_getString(item, 'runType')),
                distanceMeters: Value(_getDouble(item, 'distanceMeters')),
                durationSeconds: Value(_getInt(item, 'durationSeconds')),
                avgPaceSeconds: Value(_getInt(item, 'avgPaceSeconds')),
                bestPaceSeconds: Value(
                  _getNullableInt(item, 'bestPaceSeconds'),
                ),
                avgHeartRate: Value(_getNullableInt(item, 'avgHeartRate')),
                maxHeartRate: Value(_getNullableInt(item, 'maxHeartRate')),
                avgCadence: Value(_getNullableInt(item, 'avgCadence')),
                maxCadence: Value(_getNullableInt(item, 'maxCadence')),
                elevationGain: Value(_getNullableDouble(item, 'elevationGain')),
                elevationLoss: Value(_getNullableDouble(item, 'elevationLoss')),
                footwear: Value(_getNullableString(item, 'footwear')),
                weatherJson: Value(_getNullableString(item, 'weatherJson')),
              ),
            );
      }

      final runningSplits = _parseJsonList(
        data['runningSplits'] as List<dynamic>? ?? <dynamic>[],
      );
      for (final item in runningSplits) {
        await _db
            .into(_db.runningSplits)
            .insert(
              RunningSplitsCompanion(
                id: Value(_getInt(item, 'id')),
                runningEntryId: Value(_getInt(item, 'runningEntryId')),
                splitNumber: Value(_getInt(item, 'splitNumber')),
                distanceMeters: Value(_getDouble(item, 'distanceMeters')),
                durationSeconds: Value(_getInt(item, 'durationSeconds')),
                paceSeconds: Value(_getInt(item, 'paceSeconds')),
                avgHeartRate: Value(_getNullableInt(item, 'avgHeartRate')),
                cadence: Value(_getNullableInt(item, 'cadence')),
                elevationGain: Value(_getNullableDouble(item, 'elevationGain')),
                isManual: Value(item['isManual'] as bool? ?? false),
              ),
            );
      }

      final swimmingEntries = _parseJsonList(
        data['swimmingEntries'] as List<dynamic>? ?? <dynamic>[],
      );
      for (final item in swimmingEntries) {
        await _db
            .into(_db.swimmingEntries)
            .insert(
              SwimmingEntriesCompanion(
                id: Value(_getInt(item, 'id')),
                sessionId: Value(_getInt(item, 'sessionId')),
                environment: Value(_getString(item, 'environment')),
                poolLengthMeters: Value(
                  _getNullableInt(item, 'poolLengthMeters'),
                ),
                primaryStroke: Value(_getString(item, 'primaryStroke')),
                distanceMeters: Value(_getDouble(item, 'distanceMeters')),
                durationSeconds: Value(_getInt(item, 'durationSeconds')),
                pacePer100m: Value(_getInt(item, 'pacePer100m')),
                trainingType: Value(_getNullableString(item, 'trainingType')),
                equipment: Value(_getNullableString(item, 'equipment')),
              ),
            );
      }

      final swimmingSets = _parseJsonList(
        data['swimmingSets'] as List<dynamic>? ?? <dynamic>[],
      );
      for (final item in swimmingSets) {
        await _db
            .into(_db.swimmingSets)
            .insert(
              SwimmingSetsCompanion(
                id: Value(_getInt(item, 'id')),
                swimmingEntryId: Value(_getInt(item, 'swimmingEntryId')),
                setType: Value(_getString(item, 'setType')),
                description: Value(_getNullableString(item, 'description')),
                distanceMeters: Value(_getDouble(item, 'distanceMeters')),
                durationSeconds: Value(_getInt(item, 'durationSeconds')),
                sortOrder: Value(item['sortOrder'] as int? ?? 0),
              ),
            );
      }

      final templateExercises = _parseJsonList(
        data['templateExercises'] as List<dynamic>? ?? <dynamic>[],
      );
      for (final item in templateExercises) {
        await _db
            .into(_db.templateExercises)
            .insert(
              TemplateExercisesCompanion(
                id: Value(_getInt(item, 'id')),
                templateId: Value(_getInt(item, 'templateId')),
                exerciseId: Value(_getNullableInt(item, 'exerciseId')),
                exerciseName: Value(_getString(item, 'exerciseName')),
                sets: Value(_getInt(item, 'sets')),
                reps: Value(_getInt(item, 'reps')),
                weight: Value(_getNullableDouble(item, 'weight')),
                sortOrder: Value(item['sortOrder'] as int? ?? 0),
              ),
            );
      }

      final personalRecords = _parseJsonList(
        data['personalRecords'] as List<dynamic>? ?? <dynamic>[],
      );
      for (final item in personalRecords) {
        await _db
            .into(_db.personalRecords)
            .insert(
              PersonalRecordsCompanion(
                id: Value(_getInt(item, 'id')),
                recordType: Value(_getString(item, 'recordType')),
                exerciseId: Value(_getNullableInt(item, 'exerciseId')),
                value: Value(_getDouble(item, 'value')),
                unit: Value(_getString(item, 'unit')),
                achievedAt: Value(_getDateTime(item, 'achievedAt')),
                sessionId: Value(_getNullableInt(item, 'sessionId')),
                createdAt: item['createdAt'] != null
                    ? Value(_getDateTime(item, 'createdAt'))
                    : Value(DateTime.now()),
              ),
            );
      }

      final backupRecords = _parseJsonList(
        data['backupRecords'] as List<dynamic>? ?? <dynamic>[],
      );
      for (final item in backupRecords) {
        await _db
            .into(_db.backupRecords)
            .insert(
              BackupRecordsCompanion(
                id: Value(_getInt(item, 'id')),
                configId: Value(_getInt(item, 'configId')),
                providerType: Value(_getString(item, 'providerType')),
                targetPath: Value(_getString(item, 'targetPath')),
                createdAt: item['createdAt'] != null
                    ? Value(_getDateTime(item, 'createdAt'))
                    : Value(DateTime.now()),
                status: Value(item['status'] as String? ?? 'completed'),
                checksum: Value(_getNullableString(item, 'checksum')),
                metadataJson: Value(_getNullableString(item, 'metadataJson')),
              ),
            );
      }

      final settings = _parseJsonList(
        data['settings'] as List<dynamic>? ?? <dynamic>[],
      );
      if (settings.isNotEmpty) {
        final item = settings.first;
        await _db
            .into(_db.userSettings)
            .insert(
              UserSettingsCompanion(
                id: Value(_getInt(item, 'id')),
                weeklyWorkoutDaysGoal: Value(
                  item['weeklyWorkoutDaysGoal'] as int? ?? 3,
                ),
                weeklyWorkoutMinutesGoal: Value(
                  item['weeklyWorkoutMinutesGoal'] as int? ?? 150,
                ),
                themeMode: Value(item['themeMode'] as String? ?? 'system'),
                weightUnit: Value(item['weightUnit'] as String? ?? 'kg'),
                distanceUnit: Value(item['distanceUnit'] as String? ?? 'km'),
                lanServiceEnabled: Value(
                  item['lanServiceEnabled'] as bool? ?? false,
                ),
                lanServicePort: Value(item['lanServicePort'] as int? ?? 8080),
                lanServiceTokenEnabled: Value(
                  item['lanServiceTokenEnabled'] as bool? ?? false,
                ),
                defaultBackupConfigId: Value(
                  _getNullableInt(item, 'defaultBackupConfigId'),
                ),
                createdAt: item['createdAt'] != null
                    ? Value(_getDateTime(item, 'createdAt'))
                    : Value(DateTime.now()),
                updatedAt: item['updatedAt'] != null
                    ? Value(_getDateTime(item, 'updatedAt'))
                    : Value(DateTime.now()),
              ),
            );
      }
    });
  }

  Map<String, dynamic> _normalizeImportData(Map<String, dynamic> data) {
    final rawSource = data['data'];
    final source = rawSource is Map<String, dynamic> ? rawSource : data;

    final isLegacyBulkFormat =
        source.containsKey('trainingSessions') ||
        source.containsKey('workoutTemplates') ||
        source.containsKey('userSettings') ||
        source.containsKey('backupConfigurations');

    // 新格式直接透传；旧格式仅做字段名映射，不修补业务语义（缺失值在入库阶段按默认值处理）。
    if (!isLegacyBulkFormat) {
      return data;
    }

    return {
      'version': data['exportVersion'] ?? data['version'],
      'exportDate':
          data['exportDate'] ??
          source['exportDate'] ??
          DateTime.now().toIso8601String(),
      'workouts': source['trainingSessions'] ?? source['workouts'] ?? const [],
      'strengthExercises':
          source['strengthExerciseEntries'] ??
          source['strengthExercises'] ??
          const [],
      'runningEntries': source['runningEntries'] ?? const [],
      'runningSplits': source['runningSplits'] ?? const [],
      'swimmingEntries': source['swimmingEntries'] ?? const [],
      'swimmingSets': source['swimmingSets'] ?? const [],
      'templates':
          source['workoutTemplates'] ?? source['templates'] ?? const [],
      'templateExercises': source['templateExercises'] ?? const [],
      'exercises': source['exercises'] ?? const [],
      'personalRecords': source['personalRecords'] ?? const [],
      'settings': source['userSettings'] ?? source['settings'] ?? const [],
      'backupConfigs':
          source['backupConfigurations'] ?? source['backupConfigs'] ?? const [],
      'backupRecords': source['backupRecords'] ?? const [],
    };
  }

  void _validateImportPayload(Map<String, dynamic> data) {
    final version = data['version'];
    if (version is! String || version.trim().isEmpty) {
      throw const FormatException('备份数据缺少版本信息，拒绝导入');
    }
    final major = int.tryParse(version.split('.').first);
    if (major == null || (major != 1 && major != 2)) {
      throw FormatException('不支持的备份版本: $version');
    }
  }

  String _extractPayloadVersion(Map<String, dynamic> payload) {
    final version = payload['version'];
    if (version is String && version.trim().isNotEmpty) {
      return version;
    }
    throw const BackupSecurityException('导出数据缺少版本信息，拒绝生成备份');
  }

  Map<String, dynamic> _decodeBackupPayload(Uint8List bytes) {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('备份数据格式错误：根节点必须是 JSON 对象');
    }
    return decoded;
  }

  Map<String, dynamic>? _parseRecordMetadata(String? metadataJson) {
    if (metadataJson == null || metadataJson.trim().isEmpty) {
      return null;
    }
    final decoded = jsonDecode(metadataJson);
    if (decoded is! Map<String, dynamic>) {
      throw const BackupSecurityException('备份元数据格式错误');
    }
    return decoded;
  }

  String _requiredRecordChecksum(BackupRecord record) {
    final checksum = record.checksum;
    if (checksum == null || checksum.trim().isEmpty) {
      throw const BackupSecurityException('备份记录缺少校验和，拒绝恢复');
    }
    return checksum;
  }

  void _validateEncryptedMetadata({
    required Map<String, dynamic> metadata,
    required BackupEncryptionEnvelope envelope,
    required Uint8List encryptedData,
  }) {
    final format = metadata['payloadFormat'];
    if (format != BackupCryptoService.encryptedPayloadFormat) {
      throw const BackupSecurityException('备份元数据声明的载荷格式无效');
    }
    final encryptedChecksum = metadata['encryptedChecksum'];
    if (encryptedChecksum is! String || encryptedChecksum.isEmpty) {
      throw const BackupSecurityException('加密备份缺少密文校验和');
    }
    final actualEncryptedChecksum = BackupCryptoService.sha256Hex(
      encryptedData,
    );
    if (actualEncryptedChecksum != encryptedChecksum) {
      throw const BackupSecurityException('加密备份密文校验失败');
    }

    final envelopeVersion = metadata['envelopeVersion'];
    if (envelopeVersion is! int ||
        envelopeVersion != envelope.envelopeVersion) {
      throw const BackupSecurityException('加密备份版本与元数据不一致');
    }

    final payloadVersion = metadata['payloadVersion'];
    if (payloadVersion is! String ||
        payloadVersion != envelope.payloadVersion) {
      throw const BackupSecurityException('备份载荷版本与元数据不一致');
    }

    final algorithm = metadata['encryptionAlgorithm'];
    if (algorithm is! String || algorithm != envelope.algorithm) {
      throw const BackupSecurityException('加密算法与元数据不一致');
    }

    final derivation = metadata['keyDerivation'];
    if (derivation is! String || derivation != envelope.keyDerivation) {
      throw const BackupSecurityException('密钥派生算法与元数据不一致');
    }

    final checksumAlgorithm = metadata['checksumAlgorithm'];
    if (checksumAlgorithm is! String ||
        checksumAlgorithm != BackupCryptoService.checksumAlgorithm) {
      throw const BackupSecurityException('备份元数据校验算法不受支持');
    }
  }

  /// 记录备份历史
  Future<void> _recordBackup({
    required String providerType,
    required int? configId,
    required String targetPath,
    required String checksum,
    required int size,
    Map<String, Object?>? metadata,
  }) async {
    if (configId == null) return;
    final mergedMetadata = <String, Object?>{
      'size': size,
      'algorithm': 'sha256',
      if (metadata != null) ...metadata,
    };
    await _db
        .into(_db.backupRecords)
        .insert(
          BackupRecordsCompanion(
            configId: Value(configId),
            providerType: Value(providerType),
            targetPath: Value(targetPath),
            status: const Value('completed'),
            checksum: Value(checksum),
            metadataJson: Value(jsonEncode(mergedMetadata)),
          ),
        );
  }
}
