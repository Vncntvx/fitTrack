import 'package:flutter/material.dart';

import '../widgets/charts/chart_colors.dart';

/// 训练类型展示元数据
class WorkoutTypeMeta {
  const WorkoutTypeMeta({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String type;
  final String label;
  final IconData icon;
  final Color color;
}

/// 训练类型目录
/// 统一维护各模块公用的图标、文案与颜色，避免重复定义。
class WorkoutTypeCatalog {
  WorkoutTypeCatalog._();

  static const WorkoutTypeMeta _fallback = WorkoutTypeMeta(
    type: 'unknown',
    label: '其他',
    icon: Icons.sports,
    color: Colors.grey,
  );

  static const List<WorkoutTypeMeta> primaryEntryTypes = [
    WorkoutTypeMeta(
      type: 'strength',
      label: '健身',
      icon: Icons.fitness_center,
      color: ChartColors.strength,
    ),
    WorkoutTypeMeta(
      type: 'running',
      label: '跑步',
      icon: Icons.directions_run,
      color: ChartColors.running,
    ),
    WorkoutTypeMeta(
      type: 'swimming',
      label: '游泳',
      icon: Icons.pool,
      color: ChartColors.swimming,
    ),
    WorkoutTypeMeta(
      type: 'cycling',
      label: '骑行',
      icon: Icons.directions_bike,
      color: ChartColors.cycling,
    ),
    WorkoutTypeMeta(
      type: 'yoga',
      label: '瑜伽',
      icon: Icons.self_improvement,
      color: ChartColors.yoga,
    ),
  ];

  static const List<WorkoutTypeMeta> quickLogTypes = [
    WorkoutTypeMeta(
      type: 'cycling',
      label: '骑行',
      icon: Icons.directions_bike,
      color: ChartColors.cycling,
    ),
    WorkoutTypeMeta(
      type: 'jump_rope',
      label: '跳绳',
      icon: Icons.sports,
      color: Color(0xFF7E57C2),
    ),
    WorkoutTypeMeta(
      type: 'walking',
      label: '步行',
      icon: Icons.directions_walk,
      color: ChartColors.walking,
    ),
    WorkoutTypeMeta(
      type: 'yoga',
      label: '瑜伽',
      icon: Icons.self_improvement,
      color: ChartColors.yoga,
    ),
    WorkoutTypeMeta(
      type: 'stretching',
      label: '拉伸',
      icon: Icons.accessibility,
      color: Color(0xFF26A69A),
    ),
    WorkoutTypeMeta(
      type: 'custom',
      label: '自定义',
      icon: Icons.sports_handball,
      color: Colors.grey,
    ),
  ];

  static WorkoutTypeMeta of(String type) {
    for (final meta in [...primaryEntryTypes, ...quickLogTypes]) {
      if (meta.type == type) {
        return meta;
      }
    }
    return _fallback;
  }

  static String labelOf(String type) => of(type).label;

  static IconData iconOf(String type) => of(type).icon;

  static Color colorOf(String type) => of(type).color;
}
