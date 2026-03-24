import 'package:riverpod/riverpod.dart';

import '../backup/backup_credential_service.dart';
import '../backup/backup_provider_factory.dart';
import '../backup/backup_service.dart';
import '../database/database.dart';
import '../lan_service/foreground_service.dart';
import '../repositories/backup_config_repository.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/running_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/strength_entry_repository.dart';
import '../repositories/swimming_repository.dart';
import '../repositories/template_repository.dart';
import '../repositories/training_repository.dart';
import '../secure_storage/secure_storage_service.dart';

/// 数据库 Provider
/// 提供应用数据库的单例实例
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// 训练记录 Repository Provider
final trainingRepositoryProvider = Provider.autoDispose<TrainingRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  final strengthEntries = ref.watch(strengthEntryRepositoryProvider);
  return TrainingRepository(db, strengthEntries: strengthEntries);
});

/// 动作 Repository Provider
final exerciseRepositoryProvider = Provider.autoDispose<ExerciseRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return ExerciseRepository(db);
});

/// 模板 Repository Provider
final templateRepositoryProvider = Provider.autoDispose<TemplateRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return TemplateRepository(db);
});

/// 设置 Repository Provider
final settingsRepositoryProvider = Provider.autoDispose<SettingsRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return SettingsRepository(db);
});

/// 跑步记录 Repository Provider
final runningRepositoryProvider = Provider.autoDispose<RunningRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RunningRepository(db);
});

/// 游泳记录 Repository Provider
final swimmingRepositoryProvider = Provider.autoDispose<SwimmingRepository>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return SwimmingRepository(db);
});

/// 备份配置 Repository Provider
final backupConfigRepositoryProvider =
    Provider.autoDispose<BackupConfigRepository>((ref) {
      final db = ref.watch(appDatabaseProvider);
      return BackupConfigRepository(db);
    });

/// 备份服务 Provider
final backupServiceProvider = Provider.autoDispose<BackupService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  final credentials = ref.watch(backupCredentialServiceProvider);
  return BackupService(db, credentials: credentials);
});

/// 力量条目仓库 Provider
final strengthEntryRepositoryProvider =
    Provider.autoDispose<StrengthEntryRepository>((ref) {
      final db = ref.watch(appDatabaseProvider);
      return StrengthEntryRepository(db);
    });

/// 安全存储服务 Provider
final secureStorageServiceProvider = Provider.autoDispose<SecureStorageService>((
  ref,
) {
  return SecureStorageService();
});

/// 备份凭据服务 Provider
final backupCredentialServiceProvider =
    Provider.autoDispose<BackupCredentialService>((ref) {
      final secureStorage = ref.watch(secureStorageServiceProvider);
      return BackupCredentialService(secureStorage);
    });

/// 备份 Provider 工厂
final backupProviderFactoryProvider =
    Provider.autoDispose<BackupProviderFactory>((ref) {
      final credentials = ref.watch(backupCredentialServiceProvider);
      return BackupProviderFactory(credentials);
    });

/// 前台服务管理器 Provider
final foregroundServiceManagerProvider =
    Provider.autoDispose<ForegroundServiceManager>((ref) {
      return ForegroundServiceManager();
    });

// ==================== Stream Providers ====================

/// 所有训练记录 Stream Provider
final trainingSessionsStreamProvider =
    StreamProvider.autoDispose<List<TrainingSession>>((ref) {
      final repo = ref.watch(trainingRepositoryProvider);
      return repo.watchAll();
    });

/// 所有动作 Stream Provider
final exercisesStreamProvider =
    StreamProvider.autoDispose<List<Exercise>>((ref) {
      final repo = ref.watch(exerciseRepositoryProvider);
      return repo.watchAll();
    });

/// 所有模板 Stream Provider
final templatesStreamProvider =
    StreamProvider.autoDispose<List<WorkoutTemplate>>((ref) {
      final repo = ref.watch(templateRepositoryProvider);
      return repo.watchAll();
    });

/// 用户设置 Stream Provider
final settingsStreamProvider = StreamProvider.autoDispose<UserSetting?>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return repo.watchSettings();
});
