import 'dart:async';

import 'package:riverpod/riverpod.dart';

import 'logger_service.dart';

/// Riverpod Provider 日志观察器
/// 统一记录 Provider 执行失败，便于在应用内日志页排查问题。
final class ProviderLogObserver extends ProviderObserver {
  const ProviderLogObserver();

  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    unawaited(
      LoggerService.instance.error(
        'Riverpod',
        'Provider 执行失败',
        error: error,
        stackTrace: stackTrace,
        data: {
          'provider':
              context.provider.name ?? context.provider.runtimeType.toString(),
        },
      ),
    );
  }
}
