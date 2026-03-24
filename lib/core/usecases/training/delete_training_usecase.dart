import '../../database/database.dart';
import '../../repositories/training_repository.dart';
import '../base/usecase.dart';
import '../pr/rebuild_personal_records_usecase.dart';

/// 删除训练记录结果
enum DeleteTrainingResult {
  success,
  notFound,
}

/// 删除训练记录 Use Case
/// 封装级联删除的业务决策逻辑
class DeleteTrainingUseCase extends UseCase<DeleteTrainingResult, int> {
  final TrainingRepository _repository;
  final AppDatabase _db;
  final RebuildPersonalRecordsUseCase _prRebuilder;

  DeleteTrainingUseCase(this._repository, this._db, this._prRebuilder);

  @override
  Future<DeleteTrainingResult> call(int id) async {
    return await _db.transaction(() async {
      final session = await _repository.getById(id);
      if (session == null) {
        return DeleteTrainingResult.notFound;
      }

      // 根据训练类型删除关联数据
      await _deleteRelatedData(id, session.type);

      // 删除关联 PR，避免 personal_records.sessionId 外键阻塞主记录删除
      await (_db.delete(
        _db.personalRecords,
      )..where((record) => record.sessionId.equals(id))).go();

      // 删除主记录
      await (_db.delete(_db.trainingSessions)
            ..where((w) => w.id.equals(id))).go();

      await _prRebuilder.rebuildForTrainingType(session.type);

      return DeleteTrainingResult.success;
    });
  }

  Future<void> _deleteRelatedData(int sessionId, String type) async {
    switch (type) {
      case 'strength':
        await (_db.delete(_db.strengthExerciseEntries)
              ..where((e) => e.sessionId.equals(sessionId))).go();
        break;
      case 'running':
        final runningEntry = await (_db.select(_db.runningEntries)
              ..where((r) => r.sessionId.equals(sessionId))).getSingleOrNull();
        if (runningEntry != null) {
          await (_db.delete(_db.runningSplits)
                ..where((s) => s.runningEntryId.equals(runningEntry.id))).go();
          await (_db.delete(_db.runningEntries)
                ..where((r) => r.sessionId.equals(sessionId))).go();
        }
        break;
      case 'swimming':
        final swimmingEntry = await (_db.select(_db.swimmingEntries)
              ..where((s) => s.sessionId.equals(sessionId))).getSingleOrNull();
        if (swimmingEntry != null) {
          await (_db.delete(_db.swimmingSets)
                ..where((s) => s.swimmingEntryId.equals(swimmingEntry.id))).go();
          await (_db.delete(_db.swimmingEntries)
                ..where((s) => s.sessionId.equals(sessionId))).go();
        }
        break;
    }
  }
}
