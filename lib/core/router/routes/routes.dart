// 路由常量定义
// 集中管理所有路由路径，便于维护和重构

/// 底部导航一级路由
abstract class NavRoutes {
  /// 今日页面
  static const today = '/today';

  /// 训练入口页面
  static const train = '/train';

  /// 记录页面（合并历史+统计）
  static const records = '/records';

  /// 我的页面（个人中心）
  static const me = '/me';

  /// 所有底部导航路由
  static const all = [today, train, records, me];
}

/// 训练二级路由
abstract class TrainRoutes {
  /// 力量训练新建
  static const strengthNew = '/train/strength/new';

  /// 力量训练编辑
  static String strengthEdit(int id) => '/train/strength/$id/edit';

  /// 跑步训练新建
  static const runningNew = '/train/running/new';

  /// 跑步训练编辑
  static String runningEdit(int id) => '/train/running/$id/edit';

  /// 游泳训练新建
  static const swimmingNew = '/train/swimming/new';

  /// 游泳训练编辑
  static String swimmingEdit(int id) => '/train/swimming/$id/edit';

  /// 快速记录
  static const quick = '/train/quick';

  /// 所有训练路由
  static const all = [strengthNew, runningNew, swimmingNew, quick];
}

/// 记录二级路由
abstract class RecordsRoutes {
  /// 训练详情
  static String session(int id) => '/records/session/$id';
}

/// 我的二级路由
abstract class MeRoutes {
  /// 目标设置
  static const goals = '/me/goals';

  /// 动作库
  static const exercises = '/me/exercises';

  /// 训练模板
  static const templates = '/me/templates';

  /// 个人记录
  static const pr = '/me/pr';

  /// 偏好设置
  static const preferences = '/me/preferences';

  /// 备份与恢复
  static const backup = '/me/backup';

  /// Web 管理界面
  static const lan = '/me/lan';

  /// 关于应用
  static const about = '/me/about';

  /// 所有我的路由
  static const all = [goals, exercises, templates, pr, preferences, backup, lan, about];
}

/// 遗留路由重定向映射
abstract class LegacyRedirects {
  /// 遗留路由到新路由的映射
  static const Map<String, String> mappings = {
    '/': NavRoutes.today,
    '/history': NavRoutes.records,
    '/stats': NavRoutes.records,
    '/settings': NavRoutes.me,
    '/settings/lan': MeRoutes.lan,
    '/settings/exercises': MeRoutes.exercises,
    '/settings/templates': MeRoutes.templates,
    '/settings/pr': MeRoutes.pr,
    '/settings/backup': MeRoutes.backup,
    '/training': NavRoutes.train,
  };

  /// 检查是否为遗留路由
  static bool isLegacy(String path) {
    return mappings.containsKey(path) || path.startsWith('/settings/');
  }

  /// 获取重定向目标
  static String? getRedirect(String path) {
    if (mappings.containsKey(path)) {
      return mappings[path];
    }
    // 处理动态路由 /settings/* -> /me/*
    if (path.startsWith('/settings/')) {
      return path.replaceFirst('/settings/', '/me/');
    }
    return null;
  }
}
