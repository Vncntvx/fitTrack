import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// 图表颜色定义
/// 统一管理图表使用的颜色
/// 
/// 优先使用 [WorkoutColors] 主题扩展获取上下文感知的颜色
/// 此类提供静态默认值用于无 BuildContext 的场景
class ChartColors {
  ChartColors._();

  // ==================== 训练类型颜色 (亮色模式默认值) ====================

  /// 主色 - 用于默认/未知类型
  static const Color primary = Color(0xFFFF6B35);

  /// 力量训练 - 蓝色
  static const Color strength = Color(0xFF1976D2);

  /// 跑步 - 橙色
  static const Color running = Color(0xFFE65100);

  /// 游泳 - 青色
  static const Color swimming = Color(0xFF00838F);

  /// 骑行 - 绿色
  static const Color cycling = Color(0xFF2E7D32);

  /// 瑜伽 - 紫色
  static const Color yoga = Color(0xFF7B1FA2);

  /// 步行 - 青绿色
  static const Color walking = Color(0xFF00695C);

  // ==================== 跑步类型颜色 ====================

  /// 轻松跑
  static const Color runEasy = Color(0xFF4CAF50);

  /// 节奏跑
  static const Color runTempo = Color(0xFFFF9800);

  /// 间歇跑
  static const Color runInterval = Color(0xFFF44336);

  /// 长距离慢跑
  static const Color runLsd = Color(0xFF2196F3);

  /// 恢复跑
  static const Color runRecovery = Color(0xFF009688);

  /// 比赛
  static const Color runRace = Color(0xFFFFC107);

  // ==================== 游泳泳姿颜色 ====================

  /// 自由泳
  static const Color strokeFreestyle = Color(0xFF2196F3);

  /// 蛙泳
  static const Color strokeBreaststroke = Color(0xFF4CAF50);

  /// 仰泳
  static const Color strokeBackstroke = Color(0xFFFF9800);

  /// 蝶泳
  static const Color strokeButterfly = Color(0xFF9C27B0);

  // ==================== 辅助方法 ====================

  /// 获取训练类型颜色 (上下文感知版本)
  /// 
  /// 推荐使用此方法，会根据当前主题返回正确的颜色
  static Color getTrainingTypeColorFrom(BuildContext context, String type) {
    return context.workoutColors.forType(type);
  }

  /// 获取训练类型颜色 (静态默认值)
  /// 
  /// 无 BuildContext 时使用
  static Color getTrainingTypeColor(String type) {
    switch (type) {
      case 'strength':
        return strength;
      case 'running':
        return running;
      case 'swimming':
        return swimming;
      case 'cycling':
        return cycling;
      case 'yoga':
        return yoga;
      case 'walking':
        return walking;
      default:
        return Colors.grey;
    }
  }

  /// 获取跑步类型颜色
  static Color getRunTypeColor(String type) {
    switch (type) {
      case 'easy':
        return runEasy;
      case 'tempo':
        return runTempo;
      case 'interval':
        return runInterval;
      case 'lsd':
        return runLsd;
      case 'recovery':
        return runRecovery;
      case 'race':
        return runRace;
      default:
        return Colors.grey;
    }
  }

  /// 获取泳姿颜色
  static Color getStrokeColor(String stroke) {
    switch (stroke) {
      case 'freestyle':
        return strokeFreestyle;
      case 'breaststroke':
        return strokeBreaststroke;
      case 'backstroke':
        return strokeBackstroke;
      case 'butterfly':
        return strokeButterfly;
      default:
        return Colors.grey;
    }
  }
}