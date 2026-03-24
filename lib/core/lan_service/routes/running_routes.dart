import 'package:shelf/shelf.dart';
import '../../database/database.dart';
import '../../repositories/running_repository.dart';
import '../response_helper.dart';

/// 跑步记录 API 处理器
class RunningApiHandler {
  final RunningRepository _repository;

  RunningApiHandler(AppDatabase db) : _repository = RunningRepository(db);

  /// 获取所有跑步记录
  Future<Response> getAll(Request request) async {
    try {
      final entries = await _repository.getAll();
      return LanApiResponse.ok(
        data: entries.map(_entryToJson).toList(),
        message: 'Fetched running entries successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取单个跑步记录
  Future<Response> getById(Request request, String id) async {
    try {
      final entryId = int.tryParse(id);
      if (entryId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final entry = await _repository.getById(entryId);
      if (entry == null) {
        return LanApiResponse.notFound('Running entry not found');
      }

      return LanApiResponse.ok(
        data: _entryToJson(entry),
        message: 'Fetched running entry successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取分段数据
  Future<Response> getSplits(Request request, String id) async {
    try {
      final entryId = int.tryParse(id);
      if (entryId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final splits = await _repository.getSplits(entryId);
      return LanApiResponse.ok(
        data: splits.map(_splitToJson).toList(),
        message: 'Fetched running splits successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取跑步统计
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
          'totalRuns': allEntries.length,
          'totalDistanceMeters': totalDistance,
          'totalDurationSeconds': totalDuration,
          'weeklyDistanceMeters': weeklyDistance,
          'monthlyDistanceMeters': monthlyDistance,
        },
        message: 'Fetched running stats successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 转换跑步记录为 JSON
  Map<String, dynamic> _entryToJson(RunningEntry entry) {
    return {
      'id': entry.id,
      'sessionId': entry.sessionId,
      'runType': entry.runType,
      'distanceMeters': entry.distanceMeters,
      'durationSeconds': entry.durationSeconds,
      'avgPaceSeconds': entry.avgPaceSeconds,
      'bestPaceSeconds': entry.bestPaceSeconds,
      'avgHeartRate': entry.avgHeartRate,
      'maxHeartRate': entry.maxHeartRate,
      'avgCadence': entry.avgCadence,
      'maxCadence': entry.maxCadence,
      'elevationGain': entry.elevationGain,
      'elevationLoss': entry.elevationLoss,
      'footwear': entry.footwear,
      'weatherJson': entry.weatherJson,
    };
  }

  /// 转换分段为 JSON
  Map<String, dynamic> _splitToJson(RunningSplit split) {
    return {
      'id': split.id,
      'runningEntryId': split.runningEntryId,
      'splitNumber': split.splitNumber,
      'distanceMeters': split.distanceMeters,
      'durationSeconds': split.durationSeconds,
      'paceSeconds': split.paceSeconds,
      'avgHeartRate': split.avgHeartRate,
      'cadence': split.cadence,
      'elevationGain': split.elevationGain,
      'isManual': split.isManual,
    };
  }
}
