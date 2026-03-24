import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:path_provider/path_provider.dart';

import '../database/database.dart';
import 'lan_server.dart';
import '../logging/logger_service.dart';

const String _serviceTag = 'ForegroundService';
const int _foregroundNotificationId = 888;

/// Android 后台隔离入口（必须保留 entry-point）
@pragma('vm:entry-point')
Future<void> lanServiceOnStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();

  LanServer? server;

  // 监听启动命令
  service.on('startService').listen((event) async {
    if (server?.isRunning ?? false) {
      service.invoke('lanStarted', {'displayHost': null});
      return;
    }

    final payload = event ?? const <String, dynamic>{};
    final port = (payload['port'] as num?)?.toInt() ?? 8080;
    final token = payload['token'] as String?;
    final dbPath = payload['dbPath'] as String? ?? _defaultAndroidDbPath;
    final displayHost = payload['displayHost'] as String?;

    try {
      final db = AppDatabase.native(path: dbPath);

      server = LanServer(db);
      await server!.start(port, token: token);

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'FitTrack',
          content: displayHost == null
              ? '服务运行中，请在应用内查看局域网地址'
              : '服务运行中: http://$displayHost:$port',
        );
      }

      service.invoke('lanStarted', {'port': port, 'displayHost': displayHost});
    } catch (e, stackTrace) {
      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'FitTrack',
          content: '服务启动失败，请查看日志',
        );
      }

      service.invoke('lanStartFailed', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });
    }
  });

  // 监听停止命令
  service.on('stopService').listen((_) async {
    await server?.stop();
    service.stopSelf();
  });

  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(title: 'FitTrack', content: '服务待命中');
  }
}

/// iOS 后台入口（必须保留 entry-point）
@pragma('vm:entry-point')
Future<bool> lanServiceOnIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

const String _defaultAndroidDbPath =
    '/data/user/0/com.vncntvx.fittrack/files/fittrack_db';

/// 前台服务管理器
/// 管理 Android 前台服务的生命周期
class ForegroundServiceManager {
  ForegroundServiceManager();

  final _service = FlutterBackgroundService();
  bool _isRunning = false;
  bool _initialized = false;
  final LoggerService _logger = LoggerService.instance;

  /// 兼容旧版本已持久化的 callback handle（原静态入口）
  @pragma('vm:entry-point')
  static Future<void> onStart(ServiceInstance service) async {
    await lanServiceOnStart(service);
  }

  /// 兼容更早版本可能持久化的私有入口名
  @pragma('vm:entry-point')
  static Future<void> _onStart(ServiceInstance service) async {
    await lanServiceOnStart(service);
  }

  /// 兼容旧版本 iOS 后台入口
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    return lanServiceOnIosBackground(service);
  }

  /// 兼容更早版本可能持久化的私有 iOS 入口名
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    return lanServiceOnIosBackground(service);
  }

  /// 是否正在运行
  bool get isRunning => _isRunning;

  /// 获取服务运行状态
  Future<bool> isServiceRunning() async {
    _isRunning = await _service.isRunning();
    return _isRunning;
  }

  /// 初始化服务
  Future<void> initialize() async {
    if (_initialized) {
      _isRunning = await _service.isRunning();
      return;
    }

    await _logger.info(_serviceTag, '初始化前台服务');
    try {
      await _service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: lanServiceOnStart,
          autoStart: false,
          autoStartOnBoot: false,
          isForegroundMode: true,
          initialNotificationTitle: 'FitTrack',
          initialNotificationContent: '服务待命中',
          foregroundServiceNotificationId: _foregroundNotificationId,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: false,
          onForeground: lanServiceOnStart,
          onBackground: lanServiceOnIosBackground,
        ),
      );
      _initialized = true;
    } catch (e, stackTrace) {
      await _logger.error(
        _serviceTag,
        '初始化前台服务失败',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }

    _isRunning = await _service.isRunning();
  }

  /// 启动服务
  Future<bool> startService({
    required int port,
    String? token,
    String? displayHost,
  }) async {
    await initialize();
    final dbPath = await _resolveDatabasePath();

    _isRunning = await _service.isRunning();
    if (!_isRunning) {
      final started = await _service.startService();
      if (!started) {
        await _logger.warning(_serviceTag, '前台服务进程启动失败');
        return false;
      }
      _isRunning = true;
    }

    StreamSubscription? startedSub;
    StreamSubscription? failedSub;
    final completer = Completer<bool>();

    startedSub = _service.on('lanStarted').listen((event) {
      if (!completer.isCompleted) {
        completer.complete(true);
      }
    });
    failedSub = _service.on('lanStartFailed').listen((event) async {
      await _logger.warning(
        _serviceTag,
        '前台服务报告 LAN 启动失败',
        data: {'event': event},
      );
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    _service.invoke('startService', {
      'port': port,
      'token': token,
      'dbPath': dbPath,
      'displayHost': displayHost,
    });
    await _logger.info(
      _serviceTag,
      '前台服务启动请求已发送',
      data: {'port': port, 'dbPath': dbPath, 'displayHost': displayHost},
    );

    try {
      final started = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () async {
          await _logger.warning(
            _serviceTag,
            '等待 LAN 启动事件超时',
            data: {'port': port, 'timeoutSeconds': 5},
          );
          return false;
        },
      );
      if (!started) {
        _isRunning = false;
      }
      return started;
    } finally {
      await startedSub.cancel();
      await failedSub.cancel();
    }
  }

  /// 停止服务
  Future<void> stopService() async {
    _isRunning = await _service.isRunning();
    if (!_isRunning) return;

    _service.invoke('stopService');
    _isRunning = false;
    await _logger.info(_serviceTag, '前台服务停止请求已发送');
  }

  Future<String> _resolveDatabasePath() async {
    final directory = await getApplicationSupportDirectory();
    return '${directory.path}/fittrack_db';
  }
}
