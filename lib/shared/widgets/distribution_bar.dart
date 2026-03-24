import 'package:flutter/material.dart';

/// 分布条组件
/// 用于显示数据分布的横向条形图
class DistributionBar extends StatelessWidget {
  const DistributionBar({
    super.key,
    required this.segments,
    this.height = 24,
    this.borderRadius = 8,
  });

  /// 分段数据
  final List<DistributionSegment> segments;

  /// 高度
  final double height;

  /// 圆角半径
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (segments.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        child: Row(
          children: segments.map((segment) {
            return Expanded(
              flex: segment.flex,
              child: Container(
                color: segment.color,
                child: segment.label != null
                    ? Center(
                        child: Text(
                          segment.label!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// 分布分段数据
class DistributionSegment {
  const DistributionSegment({
    required this.flex,
    required this.color,
    this.label,
  });

  /// 弹性比例
  final int flex;

  /// 颜色
  final Color color;

  /// 标签
  final String? label;
}