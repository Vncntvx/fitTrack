import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../database/database.dart';
import '../../repositories/running_repository.dart';
import '../../repositories/strength_entry_repository.dart';
import '../../repositories/swimming_repository.dart';
import '../../repositories/training_repository.dart';
import '../../repositories/stats_repository.dart';
import '../../usecases/pr/rebuild_personal_records_usecase.dart';
import '../../usecases/training/delete_training_usecase.dart';
import '../../usecases/training/save_workout_usecase.dart';
import '../response_helper.dart';

/// 训练记录 API 处理器
class WorkoutApiHandler {
  static const Set<String> _specializedTypes = {
    'strength',
    'running',
    'swimming',
  };
  final TrainingRepository _repository;
  final StatsRepository _statsRepo;
  final AppDatabase _db;

  WorkoutApiHandler(AppDatabase db)
    : _repository = TrainingRepository(db),
      _statsRepo = StatsRepository(db),
      _db = db;

  /// 获取所有训练记录
  Future<Response> getWorkouts(Request request) async {
    try {
      final sessions = await _repository.getAll();
      return LanApiResponse.ok(
        data: sessions.map((s) => _sessionToJson(s)).toList(),
        message: 'Fetched workouts successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取单个训练记录
  Future<Response> getWorkoutById(Request request, String id) async {
    try {
      final sessionId = int.tryParse(id);
      if (sessionId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final session = await _repository.getById(sessionId);
      if (session == null) {
        return LanApiResponse.notFound('Session not found');
      }

      return LanApiResponse.ok(
        data: _sessionToJson(session),
        message: 'Fetched workout successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 创建训练记录
  Future<Response> createWorkout(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      // 验证必填字段
      if (data['datetime'] == null || (data['datetime'] as String).isEmpty) {
        return LanApiResponse.badRequest('datetime is required');
      }
      if (data['type'] == null || (data['type'] as String).isEmpty) {
        return LanApiResponse.badRequest('type is required');
      }
      if (data['durationMinutes'] == null ||
          (data['durationMinutes'] as int) <= 0) {
        return LanApiResponse.badRequest(
          'durationMinutes must be greater than 0',
        );
      }
      if (data['intensity'] == null || (data['intensity'] as String).isEmpty) {
        return LanApiResponse.badRequest('intensity is required');
      }

      final type = data['type'] as String;
      if (_specializedTypes.contains(type)) {
        return LanApiResponse.badRequest(
          'Unsupported type for this endpoint. Use specialized endpoints for strength/running/swimming.',
        );
      }

      final result = await SaveWorkoutUseCase(_repository)(
        SaveWorkoutParams(
          datetime: DateTime.parse(data['datetime'] as String),
          type: type,
          durationMinutes: data['durationMinutes'] as int,
          intensity: data['intensity'] as String,
          note: data['note'] as String?,
          isGoalCompleted: data['isGoalCompleted'] as bool? ?? false,
        ),
      );
      if (result.$1 == SaveWorkoutResult.unsupportedType) {
        return LanApiResponse.badRequest(
          'Unsupported type for this endpoint. Use specialized endpoints for strength/running/swimming.',
        );
      }
      final id = result.$2;

      return LanApiResponse.created(
        data: {'id': id},
        message: 'Created successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 更新训练记录
  Future<Response> updateWorkout(Request request, String id) async {
    try {
      final sessionId = int.tryParse(id);
      if (sessionId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final existing = await _repository.getById(sessionId);
      if (existing == null) {
        return LanApiResponse.notFound('Session not found');
      }

      final targetType = data['type'] as String? ?? existing.type;
      if (_specializedTypes.contains(targetType)) {
        return LanApiResponse.badRequest(
          'Unsupported type for this endpoint. Use specialized endpoints for strength/running/swimming.',
        );
      }

      final result = await SaveWorkoutUseCase(_repository)(
        SaveWorkoutParams(
          sessionId: sessionId,
          datetime: data['datetime'] != null
              ? DateTime.parse(data['datetime'] as String)
              : existing.datetime,
          type: targetType,
          durationMinutes:
              data['durationMinutes'] as int? ?? existing.durationMinutes,
          intensity: data['intensity'] as String? ?? existing.intensity,
          note: data['note'] as String? ?? existing.note,
          isGoalCompleted:
              data['isGoalCompleted'] as bool? ?? existing.isGoalCompleted,
          templateId: existing.templateId,
        ),
      );

      if (result.$1 == SaveWorkoutResult.notFound) {
        return LanApiResponse.notFound('Session not found');
      }
      if (result.$1 == SaveWorkoutResult.unsupportedType) {
        return LanApiResponse.badRequest(
          'Unsupported type for this endpoint. Use specialized endpoints for strength/running/swimming.',
        );
      }

      return LanApiResponse.ok(
        data: {'id': sessionId},
        message: 'Updated successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 删除训练记录
  Future<Response> deleteWorkout(Request request, String id) async {
    try {
      final sessionId = int.tryParse(id);
      if (sessionId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      // 使用 Use Case 执行删除
      final useCase = DeleteTrainingUseCase(
        _repository,
        _db,
        RebuildPersonalRecordsUseCase(
          _db,
          _repository,
          StrengthEntryRepository(_db),
          RunningRepository(_db),
          SwimmingRepository(_db),
        ),
      );
      final result = await useCase(sessionId);

      if (result == DeleteTrainingResult.notFound) {
        return LanApiResponse.notFound('Session not found');
      }

      return LanApiResponse.ok(
        data: {'id': sessionId},
        message: 'Deleted successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取统计数据
  Future<Response> getStats(Request request) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weekStartDate = DateTime(
        weekStart.year,
        weekStart.month,
        weekStart.day,
      );

      final days = await _statsRepo.countUniqueDaysThisWeek(weekStartDate);
      final minutes = await _statsRepo.getWeeklyTotalMinutes(weekStartDate);
      final streak = await _statsRepo.getCurrentStreak();
      final typeDist = await _statsRepo.getTypeDistribution();
      final mostFrequent = typeDist.entries.isNotEmpty
          ? typeDist.entries.reduce((a, b) => a.value >= b.value ? a : b).key
          : null;
      final allSessions = await _repository.getAll();
      final intensitySummary = <String, int>{
        'light': 0,
        'moderate': 0,
        'high': 0,
      };
      for (final session in allSessions) {
        if (intensitySummary.containsKey(session.intensity)) {
          intensitySummary[session.intensity] =
              (intensitySummary[session.intensity] ?? 0) + 1;
        }
      }
      String avgIntensity = '-';
      if (intensitySummary.values.any((count) => count > 0)) {
        avgIntensity = intensitySummary.entries
            .reduce((a, b) => a.value >= b.value ? a : b)
            .key;
      }

      return LanApiResponse.ok(
        data: {
          'workoutDaysThisWeek': days,
          'totalMinutesThisWeek': minutes,
          'currentStreak': streak,
          'mostFrequentType': mostFrequent,
          // 兼容 web 管理页字段
          'weeklyCount': days,
          'totalMinutes': allSessions.fold<int>(
            0,
            (sum, session) => sum + session.durationMinutes,
          ),
          'weeklyMinutes': minutes,
          'totalWorkouts': allSessions.length,
          'avgIntensity': avgIntensity,
        },
        message: 'Fetched workout stats successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 转换训练记录为 JSON
  Map<String, dynamic> _sessionToJson(TrainingSession session) {
    return {
      'id': session.id,
      'datetime': session.datetime.toIso8601String(),
      'type': session.type,
      'durationMinutes': session.durationMinutes,
      'intensity': session.intensity,
      'note': session.note,
      'isGoalCompleted': session.isGoalCompleted,
      'createdAt': session.createdAt.toIso8601String(),
      'updatedAt': session.updatedAt.toIso8601String(),
    };
  }
}
