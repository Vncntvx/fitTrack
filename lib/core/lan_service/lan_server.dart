import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import '../database/database.dart';
import 'routes/workout_routes.dart';
import 'routes/settings_routes.dart';
import 'routes/backup_routes.dart';
import 'routes/exercise_routes.dart';
import 'routes/template_routes.dart';
import 'routes/pr_routes.dart';
import 'routes/running_routes.dart';
import 'routes/swimming_routes.dart';
import 'routes/strength_routes.dart';
import 'routes/bulk_routes.dart';
import 'web_asset_service.dart';
import 'middleware/auth_middleware.dart';
import 'middleware/coop_coep_middleware.dart';
import '../logging/logger_service.dart';

/// 局域网服务器
/// 提供 HTTP API 和 Web UI
class LanServer {
  final AppDatabase _db;
  final LoggerService _logger = LoggerService.instance;
  HttpServer? _server;
  int? _port;
  String? _token;
  Handler? _webHandler;
  bool _dbClosed = false;

  /// 获取当前端口
  int? get port => _port;

  /// 获取访问令牌
  String? get token => _token;

  /// 是否正在运行
  bool get isRunning => _server != null;

  LanServer(this._db);

  /// 启动服务器
  Future<void> start(int port, {String? token}) async {
    if (_server != null) {
      throw StateError('服务器已在运行');
    }

    _port = port;
    _token = token;

    try {
      // 初始化 Web 资源处理器
      _webHandler = await WebAssetService.createHandler();
      await _logger.info('LanServer', 'Web 资源处理器初始化完成');
    } catch (e) {
      await _logger.error('LanServer', 'Web 资源处理器初始化失败', error: e);
      rethrow;
    }

    final router = _createRouter();

    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(coopCoepMiddleware())
        .addMiddleware(_corsMiddleware())
        .addMiddleware(authMiddleware(token))
        .addHandler(router.call);

    try {
      _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
      await _logger.info(
        'LanServer',
        '局域网服务器已启动',
        data: {'host': _server!.address.host, 'port': port},
      );
    } catch (e, stackTrace) {
      await _logger.error(
        'LanServer',
        '局域网服务器启动失败',
        error: e,
        stackTrace: stackTrace,
        data: {'port': port},
      );
      rethrow;
    }
  }

  /// 停止服务器
  Future<void> stop() async {
    await _server?.close();
    _server = null;
    _port = null;
    if (!_dbClosed) {
      await _db.close();
      _dbClosed = true;
    }
    await _logger.info('LanServer', '局域网服务器已停止');
  }

  /// 创建路由
  Router _createRouter() {
    final router = Router();
    final workoutHandler = WorkoutApiHandler(_db);
    final settingsHandler = SettingsApiHandler(_db);
    final backupHandler = BackupApiHandler(_db);
    final exerciseHandler = ExerciseApiHandler(_db);
    final templateHandler = TemplateApiHandler(_db);
    final prHandler = PrApiHandler(_db);
    final runningHandler = RunningApiHandler(_db);
    final swimmingHandler = SwimmingApiHandler(_db);
    final strengthHandler = StrengthApiHandler(_db);
    final bulkHandler = BulkApiHandler(_db);

    // 健康检查（无需认证）
    router.get('/health', _healthHandler);

    // ==================== 训练记录 API ====================
    router.get('/api/workouts', workoutHandler.getWorkouts);
    router.get('/api/workouts/<id>', workoutHandler.getWorkoutById);
    router.post('/api/workouts', workoutHandler.createWorkout);
    router.put('/api/workouts/<id>', workoutHandler.updateWorkout);
    router.delete('/api/workouts/<id>', workoutHandler.deleteWorkout);
    router.get('/api/stats', workoutHandler.getStats);

    // ==================== 动作库 API ====================
    router.get('/api/exercises', exerciseHandler.getAll);
    router.get('/api/exercises/<id>', exerciseHandler.getById);
    router.post('/api/exercises', exerciseHandler.create);
    router.put('/api/exercises/<id>', exerciseHandler.update);
    router.delete('/api/exercises/<id>', exerciseHandler.delete);
    router.post('/api/exercises/bulk-delete', exerciseHandler.bulkDelete);
    router.post('/api/exercises/import', exerciseHandler.import);
    router.get('/api/exercises/export', exerciseHandler.export);

    // ==================== 训练模板 API ====================
    router.get('/api/templates', templateHandler.getAll);
    router.get('/api/templates/<id>', templateHandler.getById);
    router.post('/api/templates', templateHandler.create);
    router.put('/api/templates/<id>', templateHandler.update);
    router.delete('/api/templates/<id>', templateHandler.delete);
    router.post('/api/templates/<id>/exercises', templateHandler.addExercise);
    router.delete(
      '/api/templates/exercises/<exerciseId>',
      templateHandler.deleteExercise,
    );

    // ==================== 个人记录 API ====================
    router.get('/api/pr', prHandler.getAll);
    router.get('/api/pr/<type>', prHandler.getByType);
    router.get('/api/pr/exercise/<exerciseId>', prHandler.getByExercise);
    router.delete('/api/pr/<id>', prHandler.delete);

    // ==================== 跑步记录 API ====================
    router.get('/api/running', runningHandler.getAll);
    router.get('/api/running/<id>', runningHandler.getById);
    router.get('/api/running/<id>/splits', runningHandler.getSplits);
    router.get('/api/running/stats', runningHandler.getStats);

    // ==================== 游泳记录 API ====================
    router.get('/api/swimming', swimmingHandler.getAll);
    router.get('/api/swimming/<id>', swimmingHandler.getById);
    router.get('/api/swimming/<id>/sets', swimmingHandler.getSets);
    router.get('/api/swimming/stats', swimmingHandler.getStats);

    // ==================== 力量训练 API ====================
    router.get('/api/strength/<sessionId>', strengthHandler.getBySession);
    router.post('/api/strength/<sessionId>', strengthHandler.addEntry);
    router.put('/api/strength/entry/<entryId>', strengthHandler.updateEntry);
    router.delete('/api/strength/entry/<entryId>', strengthHandler.deleteEntry);

    // ==================== 批量操作与导入导出 API ====================
    router.post('/api/bulk/workouts/delete', bulkHandler.bulkDeleteWorkouts);
    router.post('/api/bulk/workouts/update', bulkHandler.bulkUpdateWorkouts);
    router.get('/api/export/json', bulkHandler.exportJson);
    router.post('/api/import/json', bulkHandler.importJson);
    router.get('/api/export/csv', bulkHandler.exportCsv);

    // ==================== 设置 API ====================
    router.get('/api/settings', settingsHandler.getSettings);
    router.put('/api/settings', settingsHandler.updateSettings);

    // ==================== 备份 API ====================
    router.get('/api/backup-configs', backupHandler.getConfigs);
    router.get('/api/backup-configs/default', backupHandler.getDefaultConfig);
    router.post('/api/backup-configs', backupHandler.createConfig);
    router.delete('/api/backup-configs/<id>', backupHandler.deleteConfig);
    router.post('/api/backup', backupHandler.backup);
    router.post('/api/backup/<id>', backupHandler.backup);
    router.get('/api/backup-records', backupHandler.getBackupRecords);
    router.post('/api/restore', backupHandler.restore);

    // ==================== Web UI 资源 ====================
    router.get('/<path|.*>', _webHandler!);

    return router;
  }

  /// 健康检查处理器
  Response _healthHandler(Request request) {
    return Response.ok(
      jsonEncode({
        'status': 'ok',
        'timestamp': DateTime.now().toIso8601String(),
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// CORS 中间件
  Middleware _corsMiddleware() {
    return (Handler handler) {
      return (Request request) async {
        // 处理 OPTIONS 预检请求
        if (request.method == 'OPTIONS') {
          return Response.ok(
            '',
            headers: {
              'Access-Control-Allow-Origin': '*',
              'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
              'Access-Control-Allow-Headers': 'Content-Type, Authorization',
            },
          );
        }

        final response = await handler(request);
        return response.change(
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization',
          },
        );
      };
    };
  }
}
