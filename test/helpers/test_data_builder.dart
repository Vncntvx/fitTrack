import 'package:fittrack/core/database/database.dart';
import 'package:fittrack/core/repositories/running_repository.dart';
import 'package:fittrack/core/repositories/swimming_repository.dart';
import 'package:fittrack/core/repositories/template_repository.dart';
import 'package:fittrack/core/repositories/training_repository.dart';

/// 测试数据构造器：统一构造会话与模板，避免各测试重复样板代码
class TestDataBuilder {
  TestDataBuilder(this.db)
    : trainingRepo = TrainingRepository(db),
      runningRepo = RunningRepository(db),
      swimmingRepo = SwimmingRepository(db),
      templateRepo = TemplateRepository(db);

  final AppDatabase db;
  final TrainingRepository trainingRepo;
  final RunningRepository runningRepo;
  final SwimmingRepository swimmingRepo;
  final TemplateRepository templateRepo;

  /// 插入一条基础训练会话
  Future<int> addTrainingSession({
    DateTime? datetime,
    String type = 'cycling',
    int durationMinutes = 30,
    String intensity = 'moderate',
    String? note,
    bool isGoalCompleted = false,
    int? templateId,
  }) {
    return trainingRepo.createTraining(
      datetime: datetime ?? DateTime.now(),
      type: type,
      durationMinutes: durationMinutes,
      intensity: intensity,
      note: note,
      isGoalCompleted: isGoalCompleted,
      templateId: templateId,
    );
  }

  /// 插入跑步会话及其明细
  Future<int> addRunningSession({
    DateTime? datetime,
    int durationMinutes = 30,
    String intensity = 'moderate',
    String runType = 'easy',
    double distanceMeters = 5000,
    int durationSeconds = 1800,
    int avgPaceSeconds = 360,
  }) async {
    final sessionId = await addTrainingSession(
      datetime: datetime,
      type: 'running',
      durationMinutes: durationMinutes,
      intensity: intensity,
    );
    await runningRepo.createRunningEntry(
      sessionId: sessionId,
      runType: runType,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      avgPaceSeconds: avgPaceSeconds,
    );
    return sessionId;
  }

  /// 插入游泳会话及其明细
  Future<int> addSwimmingSession({
    DateTime? datetime,
    int durationMinutes = 30,
    String intensity = 'moderate',
    String environment = 'pool',
    int? poolLengthMeters = 25,
    String primaryStroke = 'freestyle',
    double distanceMeters = 1500,
    int durationSeconds = 1500,
    int pacePer100m = 100,
  }) async {
    final sessionId = await addTrainingSession(
      datetime: datetime,
      type: 'swimming',
      durationMinutes: durationMinutes,
      intensity: intensity,
    );
    await swimmingRepo.createSwimmingEntry(
      sessionId: sessionId,
      environment: environment,
      poolLengthMeters: poolLengthMeters,
      primaryStroke: primaryStroke,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      pacePer100m: pacePer100m,
    );
    return sessionId;
  }

  /// 插入模板及其单条动作
  Future<int> addTemplate({
    required String name,
    String type = 'strength',
    bool isDefault = false,
    String? exerciseName,
  }) async {
    final templateId = await templateRepo.createTemplate(
      name: name,
      type: type,
      isDefault: isDefault,
    );
      await templateRepo.addTemplateExercise(
        templateId: templateId,
        exerciseName: exerciseName ?? '$name动作',
        sets: 3,
        reps: 10,
        sortOrder: 0,
      );
    return templateId;
  }

  /// 批量插入通用会话（用于性能基准）
  Future<void> addBulkTrainingSessions({
    required int count,
    required DateTime start,
    String type = 'cycling',
    int durationMinutes = 30,
    String intensity = 'moderate',
  }) async {
    final sessions = List.generate(count, (index) {
      return TrainingSessionsCompanion.insert(
        datetime: start.add(Duration(minutes: index)),
        type: type,
        durationMinutes: durationMinutes,
        intensity: intensity,
      );
    });
    await db.batch((batch) {
      batch.insertAll(db.trainingSessions, sessions);
    });
  }
}
