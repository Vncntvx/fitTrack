import 'package:riverpod/riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../logging/logger_service.dart';
import '../usecases/training/delete_training_usecase.dart';
import '../usecases/training/get_training_entry_data_usecase.dart';
import '../usecases/training/save_running_session_usecase.dart';
import '../usecases/training/save_strength_session_usecase.dart';
import '../usecases/training/save_swimming_session_usecase.dart';
import '../usecases/training/save_workout_usecase.dart';
import '../usecases/exercise/delete_exercise_usecase.dart';
import '../usecases/pr/check_and_record_pr_usecase.dart';
import '../usecases/pr/rebuild_personal_records_usecase.dart';
import '../usecases/template/duplicate_template_usecase.dart';
import '../usecases/template/save_template_usecase.dart';
import '../usecases/stats/get_overview_stats_usecase.dart';
import '../usecases/stats/get_running_stats_usecase.dart';
import '../usecases/stats/get_swimming_stats_usecase.dart';
import '../usecases/stats/stats_models.dart';
import '../usecases/today/get_today_dashboard_usecase.dart';
import '../repositories/stats_repository.dart';
import 'app_database_provider.dart';

part 'usecase_providers.g.dart';

Future<T> _runLoggedQuery<T>({
  required String tag,
  required String message,
  Map<String, dynamic>? data,
  required Future<T> Function() action,
}) async {
  final logger = LoggerService.instance;
  final stopwatch = Stopwatch()..start();

  await logger.debug(tag, '$message开始', data: data);

  try {
    final result = await action();
    stopwatch.stop();
    await logger.info(
      tag,
      '$message完成',
      data: {...?data, 'elapsedMs': stopwatch.elapsedMilliseconds},
    );
    return result;
  } catch (error, stackTrace) {
    stopwatch.stop();
    await logger.error(
      tag,
      '$message失败',
      error: error,
      stackTrace: stackTrace,
      data: {...?data, 'elapsedMs': stopwatch.elapsedMilliseconds},
    );
    rethrow;
  }
}

RebuildPersonalRecordsUseCase _buildPersonalRecordsRebuilder(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final trainingRepo = ref.watch(trainingRepositoryProvider);
  final strengthRepo = ref.watch(strengthEntryRepositoryProvider);
  final runningRepo = ref.watch(runningRepositoryProvider);
  final swimmingRepo = ref.watch(swimmingRepositoryProvider);
  return RebuildPersonalRecordsUseCase(
    db,
    trainingRepo,
    strengthRepo,
    runningRepo,
    swimmingRepo,
  );
}

// ==================== Training Use Cases ====================

@riverpod
DeleteTrainingUseCase deleteTrainingUseCase(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final repo = ref.watch(trainingRepositoryProvider);
  final prRebuilder = _buildPersonalRecordsRebuilder(ref);
  return DeleteTrainingUseCase(repo, db, prRebuilder);
}

@riverpod
SaveStrengthSessionUseCase saveStrengthSessionUseCase(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final trainingRepo = ref.watch(trainingRepositoryProvider);
  final strengthRepo = ref.watch(strengthEntryRepositoryProvider);
  final prRebuilder = _buildPersonalRecordsRebuilder(ref);
  return SaveStrengthSessionUseCase(
    db,
    trainingRepo,
    strengthRepo,
    prRebuilder,
  );
}

@riverpod
SaveRunningSessionUseCase saveRunningSessionUseCase(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final trainingRepo = ref.watch(trainingRepositoryProvider);
  final runningRepo = ref.watch(runningRepositoryProvider);
  final prRebuilder = _buildPersonalRecordsRebuilder(ref);
  return SaveRunningSessionUseCase(db, trainingRepo, runningRepo, prRebuilder);
}

@riverpod
SaveSwimmingSessionUseCase saveSwimmingSessionUseCase(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final trainingRepo = ref.watch(trainingRepositoryProvider);
  final swimmingRepo = ref.watch(swimmingRepositoryProvider);
  final prRebuilder = _buildPersonalRecordsRebuilder(ref);
  return SaveSwimmingSessionUseCase(
    db,
    trainingRepo,
    swimmingRepo,
    prRebuilder,
  );
}

@riverpod
GetTrainingEntryDataUseCase getTrainingEntryDataUseCase(Ref ref) {
  final templateRepo = ref.watch(templateRepositoryProvider);
  final trainingRepo = ref.watch(trainingRepositoryProvider);
  return GetTrainingEntryDataUseCase(templateRepo, trainingRepo);
}

final saveWorkoutUseCaseProvider = Provider.autoDispose<SaveWorkoutUseCase>((
  ref,
) {
  final repo = ref.watch(trainingRepositoryProvider);
  return SaveWorkoutUseCase(repo);
});

// ==================== Exercise Use Cases ====================

@riverpod
DeleteExerciseUseCase deleteExerciseUseCase(Ref ref) {
  final repo = ref.watch(exerciseRepositoryProvider);
  return DeleteExerciseUseCase(repo);
}

// ==================== Template Use Cases ====================

final saveTemplateUseCaseProvider = Provider.autoDispose<SaveTemplateUseCase>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  final repo = ref.watch(templateRepositoryProvider);
  return SaveTemplateUseCase(db, repo);
});

final duplicateTemplateUseCaseProvider =
    Provider.autoDispose<DuplicateTemplateUseCase>((ref) {
      final db = ref.watch(appDatabaseProvider);
      final repo = ref.watch(templateRepositoryProvider);
      return DuplicateTemplateUseCase(db, repo);
    });

// ==================== PR Use Cases ====================

@riverpod
CheckStrengthPrUseCase checkStrengthPrUseCase(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return CheckStrengthPrUseCase(db);
}

@riverpod
CheckRunningPrUseCase checkRunningPrUseCase(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return CheckRunningPrUseCase(db);
}

@riverpod
CheckSwimmingPrUseCase checkSwimmingPrUseCase(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return CheckSwimmingPrUseCase(db);
}

@riverpod
RebuildPersonalRecordsUseCase rebuildPersonalRecordsUseCase(Ref ref) {
  return _buildPersonalRecordsRebuilder(ref);
}

// ==================== Stats Repository ====================

@riverpod
StatsRepository statsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return StatsRepository(db);
}

// ==================== Stats Use Cases ====================

@riverpod
GetOverviewStatsUseCase getOverviewStatsUseCase(Ref ref) {
  final statsRepo = ref.watch(statsRepositoryProvider);
  return GetOverviewStatsUseCase(statsRepo);
}

@riverpod
GetRunningStatsUseCase getRunningStatsUseCase(Ref ref) {
  final statsRepo = ref.watch(statsRepositoryProvider);
  return GetRunningStatsUseCase(statsRepo);
}

@riverpod
GetSwimmingStatsUseCase getSwimmingStatsUseCase(Ref ref) {
  final statsRepo = ref.watch(statsRepositoryProvider);
  return GetSwimmingStatsUseCase(statsRepo);
}

@riverpod
GetTodayDashboardUseCase getTodayDashboardUseCase(Ref ref) {
  final trainingRepo = ref.watch(trainingRepositoryProvider);
  final statsRepo = ref.watch(statsRepositoryProvider);
  final settingsRepo = ref.watch(settingsRepositoryProvider);
  return GetTodayDashboardUseCase(trainingRepo, statsRepo, settingsRepo);
}

// ==================== Stats Data Providers ====================

/// 总览统计数据 Provider
/// 使用 FutureProvider 暴露统计数据，自动处理 loading/error 状态
@riverpod
Future<OverviewStats> overviewStats(Ref ref) async {
  return _runLoggedQuery(
    tag: 'OverviewStatsProvider',
    message: '加载统计总览',
    action: () async {
      final useCase = ref.watch(getOverviewStatsUseCaseProvider);
      return useCase();
    },
  );
}

/// 跑步统计数据 Provider
@riverpod
Future<RunningStats> runningStats(Ref ref) async {
  return _runLoggedQuery(
    tag: 'RunningStatsProvider',
    message: '加载跑步统计',
    action: () async {
      final useCase = ref.watch(getRunningStatsUseCaseProvider);
      return useCase();
    },
  );
}

/// 游泳统计数据 Provider
@riverpod
Future<SwimmingStats> swimmingStats(Ref ref) async {
  return _runLoggedQuery(
    tag: 'SwimmingStatsProvider',
    message: '加载游泳统计',
    action: () async {
      final useCase = ref.watch(getSwimmingStatsUseCaseProvider);
      return useCase();
    },
  );
}

/// 今日页聚合数据 Provider
/// 使用 family 传入日期与列表大小，避免在 build 中创建新 Future。
@riverpod
Future<TodayDashboardData> todayDashboard(
  Ref ref, {
  required DateTime referenceDate,
  int recentLimit = 3,
}) async {
  return _runLoggedQuery(
    tag: 'TodayDashboardProvider',
    message: '加载今日页数据',
    data: {
      'referenceDate': referenceDate.toIso8601String(),
      'recentLimit': recentLimit,
    },
    action: () async {
      final useCase = ref.watch(getTodayDashboardUseCaseProvider);
      return useCase(
        GetTodayDashboardParams(
          referenceDate: referenceDate,
          recentLimit: recentLimit,
        ),
      );
    },
  );
}

/// 训练入口页数据 Provider
@riverpod
Future<TrainingEntryData> trainingEntryData(
  Ref ref, {
  int templateLimit = 3,
}) async {
  return _runLoggedQuery(
    tag: 'TrainingEntryDataProvider',
    message: '加载训练入口数据',
    data: {'templateLimit': templateLimit},
    action: () async {
      final useCase = ref.watch(getTrainingEntryDataUseCaseProvider);
      return useCase(GetTrainingEntryDataParams(templateLimit: templateLimit));
    },
  );
}
