import 'dart:convert';

import 'package:shelf/shelf.dart';

import '../../backup/backup_service.dart';
import '../../database/database.dart';
import '../../repositories/running_repository.dart';
import '../../repositories/strength_entry_repository.dart';
import '../../repositories/swimming_repository.dart';
import '../../repositories/training_repository.dart';
import '../../usecases/pr/rebuild_personal_records_usecase.dart';
import '../../usecases/training/delete_training_usecase.dart';
import '../../usecases/training/save_workout_usecase.dart';
import '../response_helper.dart';

/// 批量操作与数据导入导出 API 处理器
class BulkApiHandler {
  static const Set<String> _specializedTypes = {
    'strength',
    'running',
    'swimming',
  };
  BulkApiHandler(this._db);

  final AppDatabase _db;

  /// 批量删除训练记录
  Future<Response> bulkDeleteWorkouts(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final ids = (data['ids'] as List?)?.cast<int>() ?? [];

      if (ids.isEmpty) {
        return LanApiResponse.badRequest('ids array is required');
      }

      var deleted = 0;
      final repo = TrainingRepository(_db);
      final deleteTrainingUseCase = DeleteTrainingUseCase(
        repo,
        _db,
        RebuildPersonalRecordsUseCase(
          _db,
          repo,
          StrengthEntryRepository(_db),
          RunningRepository(_db),
          SwimmingRepository(_db),
        ),
      );

      for (final id in ids) {
        final result = await deleteTrainingUseCase(id);
        if (result == DeleteTrainingResult.success) {
          deleted++;
        }
      }

      return LanApiResponse.ok(
        data: {'deleted': deleted, 'requested': ids.length},
        message: 'Bulk delete completed',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 批量更新训练记录
  Future<Response> bulkUpdateWorkouts(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final updates = data['updates'] as List?;

      if (updates == null || updates.isEmpty) {
        return LanApiResponse.badRequest('updates array is required');
      }

      var updated = 0;
      var unsupported = 0;
      var notFound = 0;
      var invalid = 0;
      final repo = TrainingRepository(_db);
      final saveWorkoutUseCase = SaveWorkoutUseCase(repo);

      for (final item in updates) {
        final update = item as Map<String, dynamic>;
        final id = update['id'] as int?;
        if (id == null) {
          invalid++;
          continue;
        }

        final existing = await repo.getById(id);
        if (existing == null) {
          notFound++;
          continue;
        }

        final targetType = update['type'] as String? ?? existing.type;
        if (_specializedTypes.contains(targetType) ||
            _specializedTypes.contains(existing.type)) {
          unsupported++;
          continue;
        }

        final result = await saveWorkoutUseCase(
          SaveWorkoutParams(
            sessionId: id,
            datetime: update['datetime'] != null
                ? DateTime.parse(update['datetime'] as String)
                : existing.datetime,
            type: targetType,
            durationMinutes:
                update['durationMinutes'] as int? ?? existing.durationMinutes,
            intensity: update['intensity'] as String? ?? existing.intensity,
            note: update['note'] as String? ?? existing.note,
            isGoalCompleted:
                update['isGoalCompleted'] as bool? ?? existing.isGoalCompleted,
            templateId: existing.templateId,
          ),
        );
        if (result.$1 == SaveWorkoutResult.success) {
          updated++;
        } else if (result.$1 == SaveWorkoutResult.notFound) {
          notFound++;
        } else {
          unsupported++;
        }
      }

      return LanApiResponse.ok(
        data: {
          'updated': updated,
          'unsupported': unsupported,
          'notFound': notFound,
          'invalid': invalid,
          'requested': updates.length,
        },
        message: 'Bulk update completed',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 导出完整 JSON 数据
  Future<Response> exportJson(Request request) async {
    try {
      final data = await BackupService(_db).exportData();
      return LanApiResponse.ok(data: data, message: 'Export completed');
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 导出 CSV 数据
  Future<Response> exportCsv(Request request) async {
    try {
      final workouts = await TrainingRepository(_db).getAll();
      final csv = StringBuffer();
      csv.writeln('ID,DateTime,Type,Duration,Intensity,Note,GoalCompleted');

      for (final workout in workouts) {
        csv.writeln(
          '${workout.id},${workout.datetime.toIso8601String()},${workout.type},${workout.durationMinutes},${workout.intensity},"${workout.note ?? ''}",${workout.isGoalCompleted}',
        );
      }

      return Response.ok(
        csv.toString(),
        headers: {'Content-Type': 'text/csv; charset=utf-8'},
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 导入 JSON 数据
  Future<Response> importJson(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      await BackupService(_db).importData(data);

      return LanApiResponse.ok(data: const {}, message: 'Import completed');
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }
}
