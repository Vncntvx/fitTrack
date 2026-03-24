// ignore_for_file: experimental_member_use

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'database_native_executor_stub.dart'
    if (dart.library.ffi) 'database_native_executor_native.dart'
    as native_executor;
import 'tables/user_settings.dart';
import 'tables/training_sessions.dart';
import 'tables/strength_exercise_entries.dart';
import 'tables/backup_configurations.dart';
import 'tables/backup_records.dart';
import 'tables/exercises.dart';
import 'tables/running_entries.dart';
import 'tables/running_splits.dart';
import 'tables/swimming_entries.dart';
import 'tables/swimming_sets.dart';
import 'tables/workout_templates.dart';
import 'tables/template_exercises.dart';
import 'tables/personal_records.dart';
import 'seed/exercises_seed.dart';

part 'database.g.dart';

/// 应用数据库
/// 管理所有数据表的访问和操作
@DriftDatabase(
  tables: [
    UserSettings,
    TrainingSessions,
    StrengthExerciseEntries,
    BackupConfigurations,
    BackupRecords,
    Exercises,
    RunningEntries,
    RunningSplits,
    SwimmingEntries,
    SwimmingSets,
    WorkoutTemplates,
    TemplateExercises,
    PersonalRecords,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._internal(super.executor);

  /// 默认构造函数 - 使用标准路径
  factory AppDatabase() {
    return AppDatabase._internal(_openConnection());
  }

  /// 从指定路径创建数据库 - 用于前台服务
  factory AppDatabase.native({required String path}) {
    return AppDatabase._internal(native_executor.openNativeDatabase(path));
  }

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();

        // 导入动作库种子数据
        final seeder = ExerciseSeeder(this);
        await seeder.seedAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await _createBackupConfigurationIndexes();
        }
        if (from < 3) {
          await _migrateToV3(m);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');

        // 索引创建使用 IF NOT EXISTS，确保旧库和新库都能达到一致结构。
        await _createBackupConfigurationIndexes();
      },
    );
  }

  Future<void> _createBackupConfigurationIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_backup_configs_default '
      'ON backup_configurations (is_default);',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_backup_configs_provider '
      'ON backup_configurations (provider_type);',
    );
  }

  Future<void> _migrateToV3(Migrator m) async {
    // 通过重建受影响的表，显式刷新所有外键 onDelete 策略
    await m.alterTable(TableMigration(strengthExerciseEntries));
    await m.alterTable(TableMigration(runningEntries));
    await m.alterTable(TableMigration(swimmingEntries));
    await m.alterTable(TableMigration(templateExercises));
    await m.alterTable(TableMigration(personalRecords));
    await m.alterTable(TableMigration(backupRecords));
    await m.alterTable(TableMigration(userSettings));
  }

  /// 打开数据库连接
  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'fittrack_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
      native: const DriftNativeOptions(shareAcrossIsolates: true),
    );
  }
}
