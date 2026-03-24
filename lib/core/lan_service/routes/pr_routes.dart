import 'package:drift/drift.dart';
import 'package:shelf/shelf.dart';
import '../../database/database.dart';
import '../response_helper.dart';

/// 个人记录 API 处理器
class PrApiHandler {
  final AppDatabase _db;

  PrApiHandler(this._db);

  /// 获取所有 PR
  Future<Response> getAll(Request request) async {
    try {
      final records = await _db.select(_db.personalRecords).get();
      return LanApiResponse.ok(
        data: records.map(_prToJson).toList(),
        message: 'Fetched personal records successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 按类型获取 PR
  Future<Response> getByType(Request request, String type) async {
    try {
      final records =
          await (_db.select(_db.personalRecords)
                ..where((p) => p.recordType.equals(type))
                ..orderBy([(p) => OrderingTerm.desc(p.value)]))
              .get();
      return LanApiResponse.ok(
        data: records.map(_prToJson).toList(),
        message: 'Fetched personal records successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取某动作的 PR 历史
  Future<Response> getByExercise(Request request, String exerciseId) async {
    try {
      final id = int.tryParse(exerciseId);
      if (id == null) {
        return LanApiResponse.badRequest('Invalid exercise ID');
      }

      final records =
          await (_db.select(_db.personalRecords)
                ..where((p) => p.exerciseId.equals(id))
                ..orderBy([(p) => OrderingTerm.desc(p.achievedAt)]))
              .get();
      return LanApiResponse.ok(
        data: records.map(_prToJson).toList(),
        message: 'Fetched personal records successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 删除 PR
  Future<Response> delete(Request request, String id) async {
    return LanApiResponse.conflict(
      'PR is derived data and cannot be deleted directly',
      code: 'pr_delete_not_allowed',
    );
  }

  Map<String, dynamic> _prToJson(PersonalRecord record) {
    return {
      'id': record.id,
      'recordType': record.recordType,
      'exerciseId': record.exerciseId,
      'value': record.value,
      'unit': record.unit,
      'achievedAt': record.achievedAt.toIso8601String(),
      'sessionId': record.sessionId,
    };
  }
}
