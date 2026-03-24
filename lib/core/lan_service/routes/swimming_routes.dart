import 'package:shelf/shelf.dart';
import '../../database/database.dart';
import '../../repositories/swimming_repository.dart';
import '../response_helper.dart';

/// 游泳记录 API 处理器
class SwimmingApiHandler {
  final SwimmingRepository _repository;

  SwimmingApiHandler(AppDatabase db) : _repository = SwimmingRepository(db);

  /// 获取所有游泳记录
  Future<Response> getAll(Request request) async {
    try {
      final entries = await _repository.getAll();
      return LanApiResponse.ok(
        data: entries.map(_entryToJson).toList(),
        message: 'Fetched swimming entries successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取单个游泳记录
  Future<Response> getById(Request request, String id) async {
    try {
      final entryId = int.tryParse(id);
      if (entryId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final entry = await _repository.getById(entryId);
      if (entry == null) {
        return LanApiResponse.notFound('Swimming entry not found');
      }

      return LanApiResponse.ok(
        data: _entryToJson(entry),
        message: 'Fetched swimming entry successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取分组数据
  Future<Response> getSets(Request request, String id) async {
    try {
      final entryId = int.tryParse(id);
      if (entryId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final sets = await _repository.getSets(entryId);
      return LanApiResponse.ok(
        data: sets.map(_setToJson).toList(),
        message: 'Fetched swimming sets successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取游泳统计
  Future<Response> getStats(Request request) async {
    try {
      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));
      final weeklyDistance = await _repository.getWeeklyDistance(weekStart);
      final monthlyDistance = await _repository.getMonthlyDistance(
        now.year,
        now.month,
      );
      final allEntries = await _repository.getAll();

      final totalDistance = allEntries.fold<double>(
        0,
        (sum, e) => sum + e.distanceMeters,
      );
      final totalDuration = allEntries.fold<int>(
        0,
        (sum, e) => sum + e.durationSeconds,
      );

      return LanApiResponse.ok(
        data: {
          'totalSwims': allEntries.length,
          'totalDistanceMeters': totalDistance,
          'totalDurationSeconds': totalDuration,
          'weeklyDistanceMeters': weeklyDistance,
          'monthlyDistanceMeters': monthlyDistance,
        },
        message: 'Fetched swimming stats successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 转换游泳记录为 JSON
  Map<String, dynamic> _entryToJson(SwimmingEntry entry) {
    return {
      'id': entry.id,
      'sessionId': entry.sessionId,
      'environment': entry.environment,
      'poolLengthMeters': entry.poolLengthMeters,
      'primaryStroke': entry.primaryStroke,
      'distanceMeters': entry.distanceMeters,
      'durationSeconds': entry.durationSeconds,
      'pacePer100m': entry.pacePer100m,
      'trainingType': entry.trainingType,
      'equipment': entry.equipment,
    };
  }

  /// 转换分组为 JSON
  Map<String, dynamic> _setToJson(SwimmingSet set) {
    return {
      'id': set.id,
      'swimmingEntryId': set.swimmingEntryId,
      'setType': set.setType,
      'description': set.description,
      'distanceMeters': set.distanceMeters,
      'durationSeconds': set.durationSeconds,
      'sortOrder': set.sortOrder,
    };
  }
}
