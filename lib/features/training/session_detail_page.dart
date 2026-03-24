import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database.dart';
import '../../core/providers/app_database_provider.dart';
import '../../shared/widgets/loading_indicator.dart';

/// 训练详情重定向页面
/// 根据 session id 查询训练类型，跳转到对应的编辑页面
class SessionDetailPage extends ConsumerStatefulWidget {
  final int sessionId;

  const SessionDetailPage({super.key, required this.sessionId});

  @override
  ConsumerState<SessionDetailPage> createState() => _SessionDetailPageState();
}

class _SessionDetailPageState extends ConsumerState<SessionDetailPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    final repo = ref.read(trainingRepositoryProvider);
    final session = await repo.getById(widget.sessionId);

    if (!mounted) return;

    if (session == null) {
      // 训练记录不存在，返回上一页并提示
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/records');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('训练记录不存在')),
      );
      return;
    }

    // 根据训练类型跳转到对应的编辑页面
    final targetPath = _getTargetPath(session);
    context.replace(targetPath);
  }

  String _getTargetPath(TrainingSession session) {
    switch (session.type) {
      case 'strength':
        return '/train/strength/${session.id}/edit';
      case 'running':
        return '/train/running/${session.id}/edit';
      case 'swimming':
        return '/train/swimming/${session.id}/edit';
      default:
        // 其他类型暂不支持编辑，返回记录页
        return '/records';
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: LoadingIndicator(),
      ),
    );
  }
}
