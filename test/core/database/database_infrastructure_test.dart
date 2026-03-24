import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/training_stats_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;

void main() {
  test(
    'database enables foreign keys and creates backup configuration indexes',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'fittrack-db-infra-',
      );
      final dbPath = path.join(tempDir.path, 'fittrack.db');

      try {
        final db = AppDatabase.native(path: dbPath);

        final foreignKeysRow = await db
            .customSelect('PRAGMA foreign_keys;')
            .getSingle();
        final indexRows = await db
            .customSelect("PRAGMA index_list('backup_configurations');")
            .get();

        expect(foreignKeysRow.data.values.first, 1);
        expect(
          indexRows
              .map((row) => row.data['name'])
              .contains('idx_backup_configs_default'),
          isTrue,
        );
        expect(
          indexRows
              .map((row) => row.data['name'])
              .contains('idx_backup_configs_provider'),
          isTrue,
        );

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );

  test(
    'training stats repository aggregates weekly stats in SQL window',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'fittrack-training-stats-',
      );
      final dbPath = path.join(tempDir.path, 'fittrack.db');

      try {
        final db = AppDatabase.native(path: dbPath);
        final repo = TrainingStatsRepository(db);
        final now = DateTime.now();
        final weekStart = DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(Duration(days: now.weekday - 1));

        await db
            .into(db.trainingSessions)
            .insert(
              TrainingSessionsCompanion.insert(
                datetime: weekStart,
                type: 'running',
                durationMinutes: 30,
                intensity: 'moderate',
              ),
            );
        await db
            .into(db.trainingSessions)
            .insert(
              TrainingSessionsCompanion.insert(
                datetime: weekStart.add(const Duration(hours: 6)),
                type: 'strength',
                durationMinutes: 45,
                intensity: 'high',
              ),
            );
        await db
            .into(db.trainingSessions)
            .insert(
              TrainingSessionsCompanion.insert(
                datetime: weekStart.add(const Duration(days: 2)),
                type: 'swimming',
                durationMinutes: 60,
                intensity: 'moderate',
              ),
            );
        await db
            .into(db.trainingSessions)
            .insert(
              TrainingSessionsCompanion.insert(
                datetime: weekStart.subtract(const Duration(days: 1)),
                type: 'cycling',
                durationMinutes: 120,
                intensity: 'light',
              ),
            );

        expect(await repo.countThisWeek(), 2);
        expect(await repo.totalMinutesThisWeek(), 135);

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );

  test(
    'deleting training session cascades to running entries and splits',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'fittrack-db-fk-cascade-',
      );
      final dbPath = path.join(tempDir.path, 'fittrack.db');

      try {
        final db = AppDatabase.native(path: dbPath);

        final sessionId = await db
            .into(db.trainingSessions)
            .insert(
              TrainingSessionsCompanion.insert(
                datetime: DateTime(2026, 4, 1, 6, 0),
                type: 'running',
                durationMinutes: 30,
                intensity: 'moderate',
              ),
            );
        final entryId = await db
            .into(db.runningEntries)
            .insert(
              RunningEntriesCompanion.insert(
                sessionId: sessionId,
                runType: 'easy',
                distanceMeters: 5000,
                durationSeconds: 1800,
                avgPaceSeconds: 360,
              ),
            );
        await db
            .into(db.runningSplits)
            .insert(
              RunningSplitsCompanion.insert(
                runningEntryId: entryId,
                splitNumber: 1,
                distanceMeters: 1000,
                durationSeconds: 360,
                paceSeconds: 360,
              ),
            );

        await (db.delete(
          db.trainingSessions,
        )..where((s) => s.id.equals(sessionId))).go();

        final runningRows = await (db.select(
          db.runningEntries,
        )..where((r) => r.sessionId.equals(sessionId))).get();
        final splitRows = await (db.select(
          db.runningSplits,
        )..where((s) => s.runningEntryId.equals(entryId))).get();

        expect(runningRows, isEmpty);
        expect(splitRows, isEmpty);

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );

  test(
    'deleting backup config sets user settings defaultBackupConfigId to null',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'fittrack-db-fk-setnull-',
      );
      final dbPath = path.join(tempDir.path, 'fittrack.db');

      try {
        final db = AppDatabase.native(path: dbPath);

        final configId = await db
            .into(db.backupConfigurations)
            .insert(
              BackupConfigurationsCompanion.insert(
                providerType: 'webdav',
                displayName: '默认配置',
                endpoint: 'https://example.com',
                bucketOrPath: '/backup',
              ),
            );
        await db
            .into(db.userSettings)
            .insert(
              UserSettingsCompanion.insert(
                defaultBackupConfigId: Value(configId),
              ),
            );

        await (db.delete(
          db.backupConfigurations,
        )..where((c) => c.id.equals(configId))).go();

        final settings = await (db.select(
          db.userSettings,
        )..limit(1)).getSingle();
        expect(settings.defaultBackupConfigId, isNull);

        await db.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    },
  );

  test('deleting referenced exercise is restricted by foreign key', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-db-fk-restrict-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final db = AppDatabase.native(path: dbPath);

      final exerciseId = await db
          .into(db.exercises)
          .insert(
            ExercisesCompanion.insert(
              name: 'fk-restrict-exercise-001',
              category: 'legs',
            ),
          );
      final templateId = await db
          .into(db.workoutTemplates)
          .insert(
            WorkoutTemplatesCompanion.insert(name: '腿部训练', type: 'strength'),
          );
      await db
          .into(db.templateExercises)
          .insert(
            TemplateExercisesCompanion.insert(
              templateId: templateId,
              exerciseId: Value(exerciseId),
              exerciseName: 'fk-restrict-exercise-001',
              sets: 5,
              reps: 5,
            ),
          );

      await expectLater(
        (db.delete(db.exercises)..where((e) => e.id.equals(exerciseId))).go(),
        throwsA(
          predicate(
            (error) =>
                error.toString().contains('FOREIGN KEY constraint failed'),
          ),
        ),
      );

      final remained = await (db.select(
        db.exercises,
      )..where((e) => e.id.equals(exerciseId))).getSingleOrNull();
      expect(remained, isNotNull);

      await db.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });

  test('migration v2->v3 keeps data and applies fk delete actions', () async {
    final tempDir = await Directory.systemTemp.createTemp(
      'fittrack-db-fk-migration-v3-',
    );
    final dbPath = path.join(tempDir.path, 'fittrack.db');

    try {
      final initialDb = AppDatabase.native(path: dbPath);

      final configId = await initialDb
          .into(initialDb.backupConfigurations)
          .insert(
            BackupConfigurationsCompanion.insert(
              providerType: 'webdav',
              displayName: '迁移默认配置',
              endpoint: 'https://example.com',
              bucketOrPath: '/migrate',
            ),
          );
      await initialDb
          .into(initialDb.userSettings)
          .insert(
            UserSettingsCompanion.insert(
              defaultBackupConfigId: Value(configId),
            ),
          );

      final sessionId = await initialDb
          .into(initialDb.trainingSessions)
          .insert(
            TrainingSessionsCompanion.insert(
              datetime: DateTime(2026, 4, 2, 7, 0),
              type: 'running',
              durationMinutes: 40,
              intensity: 'moderate',
            ),
          );
      final runningEntryId = await initialDb
          .into(initialDb.runningEntries)
          .insert(
            RunningEntriesCompanion.insert(
              sessionId: sessionId,
              runType: 'tempo',
              distanceMeters: 8000,
              durationSeconds: 2400,
              avgPaceSeconds: 300,
            ),
          );
      await initialDb
          .into(initialDb.runningSplits)
          .insert(
            RunningSplitsCompanion.insert(
              runningEntryId: runningEntryId,
              splitNumber: 1,
              distanceMeters: 1000,
              durationSeconds: 300,
              paceSeconds: 300,
            ),
          );

      // 模拟历史 v2 库，触发升级到 v3。
      await initialDb.customStatement('PRAGMA user_version = 2;');
      await initialDb.close();

      final upgradedDb = AppDatabase.native(path: dbPath);

      final existingEntry = await (upgradedDb.select(
        upgradedDb.runningEntries,
      )..where((r) => r.id.equals(runningEntryId))).getSingleOrNull();
      expect(existingEntry, isNotNull);

      await (upgradedDb.delete(
        upgradedDb.backupConfigurations,
      )..where((c) => c.id.equals(configId))).go();
      final settingsAfterConfigDelete = await (upgradedDb.select(
        upgradedDb.userSettings,
      )..limit(1)).getSingle();
      expect(settingsAfterConfigDelete.defaultBackupConfigId, isNull);

      await (upgradedDb.delete(
        upgradedDb.trainingSessions,
      )..where((s) => s.id.equals(sessionId))).go();
      final entriesAfterDelete = await (upgradedDb.select(
        upgradedDb.runningEntries,
      )..where((r) => r.sessionId.equals(sessionId))).get();
      final splitsAfterDelete = await (upgradedDb.select(
        upgradedDb.runningSplits,
      )..where((s) => s.runningEntryId.equals(runningEntryId))).get();
      expect(entriesAfterDelete, isEmpty);
      expect(splitsAfterDelete, isEmpty);

      await upgradedDb.close();
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  });
}
