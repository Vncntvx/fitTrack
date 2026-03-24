import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/logging/logger_service.dart';
import 'core/logging/provider_log_observer.dart';

Future<void> bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_CN');

  // 初始化日志服务
  final logger = LoggerService.instance;
  await logger.initialize();

  // 捕获 Flutter 错误
  FlutterError.onError = (FlutterErrorDetails details) {
    unawaited(
      logger.fatal(
        'FlutterError',
        details.exception.toString(),
        error: details.exception,
        stackTrace: details.stack,
      ),
    );
    FlutterError.presentError(details);
  };

  // 捕获异步错误
  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(
      logger.fatal(
        'PlatformError',
        error.toString(),
        error: error,
        stackTrace: stack,
      ),
    );
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    unawaited(
      logger.error(
        'ErrorWidget',
        '构建错误组件',
        error: details.exception,
        stackTrace: details.stack,
      ),
    );
    return const Material(child: Center(child: Text('页面渲染失败，请重启应用后重试')));
  };
}

void main() {
  runZonedGuarded(
    () async {
      await bootstrapApp();
      runApp(
        const ProviderScope(
          observers: [ProviderLogObserver()],
          child: WorkoutTrackerApp(),
        ),
      );
    },
    (error, stackTrace) {
      unawaited(
        LoggerService.instance.fatal(
          'UncaughtZoneError',
          '应用发生未捕获异常',
          error: error,
          stackTrace: stackTrace,
        ),
      );
    },
  );
}
