import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// 图表主题配置
/// 统一管理图表的样式配置
class ChartTheme {
  ChartTheme._();

  // ==================== 网格线样式 ====================

  /// 默认网格线配置
  static FlGridData get gridData => FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: Colors.grey.shade200,
          strokeWidth: 1,
        ),
      );

  /// 无网格线配置
  static FlGridData get noGridData => const FlGridData(show: false);

  // ==================== 边框样式 ====================

  /// 默认边框配置（无边框）
  static FlBorderData get borderData => FlBorderData(show: false);

  // ==================== 标题样式 ====================

  /// 创建标题配置
  ///
  /// [bottomTitles] 底部标题生成函数
  /// [leftTitles] 左侧标题生成函数（可选）
  /// [reservedSizeLeft] 左侧保留空间
  /// [reservedSizeBottom] 底部保留空间
  static FlTitlesData titlesData({
    required String Function(double) bottomTitles,
    String Function(double)? leftTitles,
    double reservedSizeLeft = 40,
    double reservedSizeBottom = 30,
  }) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: leftTitles != null,
          getTitlesWidget: (value, meta) => Text(
            leftTitles?.call(value) ?? '',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
          reservedSize: reservedSizeLeft,
        ),
      ),
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) => Text(
            bottomTitles(value),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
          reservedSize: reservedSizeBottom,
        ),
      ),
    );
  }

  // ==================== 折线图样式 ====================

  /// 创建折线图数据
  ///
  /// [color] 线条颜色
  /// [spots] 数据点
  /// [isCurved] 是否曲线
  /// [showDots] 是否显示数据点
  /// [showBelowArea] 是否显示下方区域
  static LineChartBarData lineBarData({
    required Color color,
    required List<FlSpot> spots,
    bool isCurved = true,
    bool showDots = false,
    bool showBelowArea = true,
  }) {
    return LineChartBarData(
      isCurved: isCurved,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: FlDotData(show: showDots),
      belowBarData: BarAreaData(
        show: showBelowArea,
        color: color.withValues(alpha: 0.15),
      ),
      spots: spots,
    );
  }

  // ==================== 柱状图样式 ====================

  /// 创建柱状图条形数据
  ///
  /// [color] 颜色
  /// [width] 宽度
  /// [borderRadius] 圆角半径
  static BarChartRodData barRodData({
    required Color color,
    required double toY,
    double width = 16,
    double borderRadius = 4,
  }) {
    return BarChartRodData(
      toY: toY,
      color: color,
      width: width,
      borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
    );
  }

  // ==================== 饼图样式 ====================

  /// 创建饼图部分数据
  ///
  /// [value] 数值
  /// [color] 颜色
  /// [title] 标题
  /// [radius] 半径
  static PieChartSectionData pieSectionData({
    required double value,
    required Color color,
    String? title,
    double radius = 60,
  }) {
    return PieChartSectionData(
      color: color,
      value: value,
      title: title,
      radius: radius,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}