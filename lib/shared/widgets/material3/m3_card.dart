import 'package:flutter/material.dart';

/// Material 3 风格卡片
/// 统一应用 M3 设计规范
class M3Card extends StatelessWidget {
  const M3Card({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.elevation = 0,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final double elevation;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      elevation: elevation,
      color: color ?? colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}

/// Material 3 风格区块标题
class M3SectionHeader extends StatelessWidget {
  const M3SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.padding,
  });

  final String title;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Material 3 风格进度环
class M3ProgressRing extends StatelessWidget {
  const M3ProgressRing({
    super.key,
    required this.progress,
    required this.child,
    this.size = 80,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.valueColor,
  });

  final double progress;
  final Widget child;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor ?? colorScheme.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(
                valueColor ?? colorScheme.primary,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Material 3 风格统计卡片
class M3StatCard extends StatelessWidget {
  const M3StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.icon,
    this.onTap,
    this.color,
  });

  final String title;
  final String value;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = color ?? colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: cardColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                      color: cardColor,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
