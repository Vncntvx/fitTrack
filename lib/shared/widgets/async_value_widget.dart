import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_state_widget.dart';
import 'loading_indicator.dart';

/// AsyncValue 统一处理组件
/// 整合 loading/error/data 状态
class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({
    super.key,
    required this.asyncValue,
    required this.dataBuilder,
    this.loadingWidget,
    this.emptyIcon,
    this.emptyMessage = '暂无数据',
    this.emptySubtitle,
    this.emptyAction,
    this.errorMessage = '加载失败',
    this.retryAction,
  });

  /// 异步值
  final AsyncValue<T> asyncValue;

  /// 数据构建器
  final Widget Function(T data) dataBuilder;

  /// 自定义加载组件
  final Widget? loadingWidget;

  /// 空状态图标
  final IconData? emptyIcon;

  /// 空状态消息
  final String emptyMessage;

  /// 空状态副标题
  final String? emptySubtitle;

  /// 空状态操作按钮
  final Widget? emptyAction;

  /// 错误消息
  final String errorMessage;

  /// 重试操作
  final VoidCallback? retryAction;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      data: (data) {
        // 检查是否为空列表
        if (data is List && data.isEmpty) {
          return EmptyStateWidget(
            icon: emptyIcon ?? Icons.inbox_outlined,
            message: emptyMessage,
            subtitle: emptySubtitle,
            action: emptyAction,
          );
        }
        return dataBuilder(data);
      },
      loading: () => loadingWidget ?? const LoadingIndicator(),
      error: (error, stack) => _AsyncErrorWidget(
        message: errorMessage,
        error: error.toString(),
        retryAction: retryAction,
      ),
    );
  }
}

/// 异步错误组件
class _AsyncErrorWidget extends StatelessWidget {
  const _AsyncErrorWidget({
    required this.message,
    required this.error,
    this.retryAction,
  });

  final String message;
  final String error;
  final VoidCallback? retryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (retryAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: retryAction,
                icon: const Icon(Icons.refresh),
                label: const Text('重试'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}