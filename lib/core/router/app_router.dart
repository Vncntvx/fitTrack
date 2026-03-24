import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/today/today_page.dart';
import '../../features/train/train_page.dart';
import '../../features/records/records_page.dart';
import '../../features/me/me_page.dart';
import '../../features/me/goals/goals_page.dart';
import '../../features/me/preferences/preferences_page.dart';
import '../../features/me/about/about_page.dart';
import '../../features/settings/lan_settings_page.dart';
import '../../features/exercises/exercises_page.dart';
import '../../features/templates/templates_page.dart';
import '../../features/pr/pr_page.dart';
import '../../features/backup/backup_page.dart' as features_backup;
import '../../features/training/quick_log_page.dart';
import '../../features/training/session_detail_page.dart';
import '../../features/training/strength/strength_session_page.dart';
import '../../features/training/running/running_session_page.dart';
import '../../features/training/swimming/swimming_session_page.dart';
import '../../web/admin/table_management_view.dart';
import '../../web/admin/export_import_console.dart';
import '../../web/admin/system_info_page.dart';
import '../../web/admin/backup_page.dart' as web_backup;
import '../../web/admin/dashboard_page.dart';
import '../../web/admin/web_exercises_page.dart';
import '../../web/admin/web_templates_page.dart';
import '../../web/admin/web_pr_page.dart';
import '../../features/settings/log_viewer_page.dart';
import 'main_shell.dart';
import 'routes/routes.dart';

class _RouterErrorPage extends StatelessWidget {
  const _RouterErrorPage({required this.error});

  final Exception? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面打开失败')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              const Text(
                '页面加载失败，请稍后重试',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? '未知路由错误',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 应用路由配置
final appRouter = GoRouter(
  initialLocation: NavRoutes.today,
  errorBuilder: (context, state) => _RouterErrorPage(error: state.error),
  // 重定向遗留路由
  redirect: (context, state) {
    final path = state.matchedLocation;
    // 处理根路径重定向
    if (path == '/') {
      return NavRoutes.today;
    }
    // 检查其他遗留路由
    if (LegacyRedirects.isLegacy(path)) {
      return LegacyRedirects.getRedirect(path);
    }
    return null;
  },
  routes: [
    // 带底部导航的主页面
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        // 今日页面
        GoRoute(
          path: NavRoutes.today,
          builder: (context, state) => const TodayPage(),
        ),
        // 训练入口页面
        GoRoute(
          path: NavRoutes.train,
          builder: (context, state) => const TrainPage(),
        ),
        // 记录页面（合并历史+统计）
        GoRoute(
          path: NavRoutes.records,
          builder: (context, state) => const RecordsPage(),
        ),
        // 我的页面
        GoRoute(
          path: NavRoutes.me,
          builder: (context, state) => const MePage(),
          routes: [
            GoRoute(
              path: 'goals',
              builder: (context, state) => const GoalsPage(),
            ),
            GoRoute(
              path: 'exercises',
              builder: (context, state) => const ExercisesPage(),
            ),
            GoRoute(
              path: 'templates',
              builder: (context, state) => const TemplatesPage(),
            ),
            GoRoute(
              path: 'pr',
              builder: (context, state) => const PrPage(),
            ),
            GoRoute(
              path: 'preferences',
              builder: (context, state) => const PreferencesPage(),
            ),
            GoRoute(
              path: 'backup',
              builder: (context, state) => const features_backup.BackupPage(),
            ),
            GoRoute(
              path: 'lan',
              builder: (context, state) => const LanSettingsPage(),
            ),
            GoRoute(
              path: 'about',
              builder: (context, state) => const AboutPage(),
            ),
          ],
        ),
      ],
    ),

    // 训练二级路由（不带底部导航）
    // 力量训练
    GoRoute(
      path: TrainRoutes.strengthNew,
      builder: (context, state) {
        final templateId = int.tryParse(
          state.uri.queryParameters['templateId'] ?? '',
        );
        return StrengthSessionPage(templateId: templateId);
      },
    ),
    GoRoute(
      path: '/train/strength/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return StrengthSessionPage(sessionId: id);
      },
    ),
    // 跑步训练
    GoRoute(
      path: TrainRoutes.runningNew,
      builder: (context, state) {
        final templateId = int.tryParse(
          state.uri.queryParameters['templateId'] ?? '',
        );
        return RunningSessionPage(templateId: templateId);
      },
    ),
    GoRoute(
      path: '/train/running/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return RunningSessionPage(sessionId: id);
      },
    ),
    // 游泳训练
    GoRoute(
      path: TrainRoutes.swimmingNew,
      builder: (context, state) {
        final templateId = int.tryParse(
          state.uri.queryParameters['templateId'] ?? '',
        );
        return SwimmingSessionPage(templateId: templateId);
      },
    ),
    GoRoute(
      path: '/train/swimming/:id/edit',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return SwimmingSessionPage(sessionId: id);
      },
    ),
    // 快速记录
    GoRoute(
      path: TrainRoutes.quick,
      builder: (context, state) {
        return const QuickLogPage();
      },
    ),

    // 训练详情（根据类型重定向到对应编辑页面）
    GoRoute(
      path: '/records/session/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '');
        return SessionDetailPage(sessionId: id ?? 0);
      },
    ),

    // Web 管理路由（不带底部导航）
    GoRoute(
      path: '/admin',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/admin/table',
      builder: (context, state) => const TableManagementView(),
    ),
    GoRoute(
      path: '/admin/export',
      builder: (context, state) => const ExportImportConsole(),
    ),
    GoRoute(
      path: '/admin/system',
      builder: (context, state) => const SystemInfoPage(),
    ),
    GoRoute(
      path: '/admin/backup',
      builder: (context, state) => const web_backup.BackupPage(),
    ),
    GoRoute(
      path: '/admin/exercises',
      builder: (context, state) => const WebExercisesPage(),
    ),
    GoRoute(
      path: '/admin/templates',
      builder: (context, state) => const WebTemplatesPage(),
    ),
    GoRoute(
      path: '/admin/pr',
      builder: (context, state) => const WebPrPage(),
    ),
    // 日志查看页面（独立页面）
    GoRoute(
      path: '/logs',
      builder: (context, state) => const LogViewerPage(),
    ),
  ],
);
