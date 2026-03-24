import 'package:flutter/widgets.dart';

import '../theme/design_tokens.dart';

/// 窗口尺寸类别
/// 基于 Material 3 断点规范
enum WindowSizeClass {
  /// 紧凑 - 手机竖屏 (< 600dp)
  compact,

  /// 中等 - 手机横屏、小平板 (600-840dp)
  medium,

  /// 扩展 - 平板、桌面 (> 840dp)
  expanded,
}

/// 页面响应式尺寸
class AppResponsiveData {
  const AppResponsiveData({
    required this.width,
    required this.height,
    required this.windowSizeClass,
    required this.pagePadding,
    required this.sectionSpacing,
    required this.cardSpacing,
    required this.gridColumns,
    required this.maxContentWidth,
    required this.useNavigationRail,
  });

  /// 屏幕宽度
  final double width;

  /// 屏幕高度
  final double height;

  /// 窗口尺寸类别
  final WindowSizeClass windowSizeClass;

  /// 页面边距
  final double pagePadding;

  /// 区块间距
  final double sectionSpacing;

  /// 卡片间距
  final double cardSpacing;

  /// 网格列数
  final int gridColumns;

  /// 内容最大宽度
  final double maxContentWidth;

  /// 是否使用侧边导航
  final bool useNavigationRail;

  /// 是否为紧凑布局
  bool get isCompact => windowSizeClass == WindowSizeClass.compact;

  /// 是否为中等布局
  bool get isMedium => windowSizeClass == WindowSizeClass.medium;

  /// 是否为扩展布局
  bool get isExpanded => windowSizeClass == WindowSizeClass.expanded;

  /// 是否为平板或更大屏幕
  bool get isTabletOrLarger =>
      windowSizeClass == WindowSizeClass.medium ||
      windowSizeClass == WindowSizeClass.expanded;
}

/// 响应式布局工具
class AppResponsive {
  AppResponsive._();

  /// 从 BuildContext 获取响应式数据
  static AppResponsiveData of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final height = mediaQuery.size.height;
    return forSize(width, height);
  }

  /// 根据尺寸计算响应式参数
  static AppResponsiveData forSize(double width, double height) {
    // 确定窗口尺寸类别
    final WindowSizeClass sizeClass;
    if (width < AppBreakpoints.compact) {
      sizeClass = WindowSizeClass.compact;
    } else if (width < AppBreakpoints.medium) {
      sizeClass = WindowSizeClass.medium;
    } else {
      sizeClass = WindowSizeClass.expanded;
    }

    // 根据尺寸类别设置布局参数
    switch (sizeClass) {
      case WindowSizeClass.compact:
        return AppResponsiveData(
          width: width,
          height: height,
          windowSizeClass: sizeClass,
          pagePadding: AppSpacing.lg,
          sectionSpacing: AppSpacing.xl,
          cardSpacing: AppSpacing.md,
          gridColumns: 2,
          maxContentWidth: double.infinity,
          useNavigationRail: false,
        );

      case WindowSizeClass.medium:
        return AppResponsiveData(
          width: width,
          height: height,
          windowSizeClass: sizeClass,
          pagePadding: AppSpacing.xxl,
          sectionSpacing: AppSpacing.xxl,
          cardSpacing: AppSpacing.lg,
          gridColumns: 2,
          maxContentWidth: AppBreakpoints.maxContentWidth,
          useNavigationRail: true,
        );

      case WindowSizeClass.expanded:
        return AppResponsiveData(
          width: width,
          height: height,
          windowSizeClass: sizeClass,
          pagePadding: AppSpacing.xxxl,
          sectionSpacing: AppSpacing.xxxl,
          cardSpacing: AppSpacing.xl,
          gridColumns: 3,
          maxContentWidth: AppBreakpoints.maxContentWidth,
          useNavigationRail: true,
        );
    }
  }

  /// 已废弃 - 使用 forSize 代替
  @Deprecated('Use forSize instead')
  static AppResponsiveData forWidth(double width, {bool isLandscape = false}) {
    return forSize(width, 800); // 默认高度
  }
}

/// 响应式页面容器
/// 在大屏幕上限制最大宽度并居中
class ResponsivePage extends StatelessWidget {
  const ResponsivePage({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
    this.centerContent = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final bool centerContent;

  @override
  Widget build(BuildContext context) {
    final layout = AppResponsive.of(context);
    final effectiveMaxWidth = maxWidth ?? layout.maxContentWidth;
    final effectivePadding = padding ?? EdgeInsets.all(layout.pagePadding);

    Widget content = Padding(
      padding: effectivePadding,
      child: child,
    );

    // 在大屏幕上限制宽度
    if (layout.isTabletOrLarger && effectiveMaxWidth != double.infinity) {
      content = Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// 响应式卡片网格
/// 根据屏幕宽度自动调整列数
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 1.5,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  });

  final List<Widget> children;
  final double childAspectRatio;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  @override
  Widget build(BuildContext context) {
    final layout = AppResponsive.of(context);
    final spacing = mainAxisSpacing ?? layout.cardSpacing;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layout.gridColumns,
        mainAxisSpacing: spacing,
        crossAxisSpacing: crossAxisSpacing ?? spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}

/// 自适应布局构建器
/// 根据屏幕尺寸返回不同的布局
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  /// 紧凑布局 (手机)
  final Widget compact;

  /// 中等布局 (小平板)
  final Widget? medium;

  /// 扩展布局 (大平板/桌面)
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    final layout = AppResponsive.of(context);

    switch (layout.windowSizeClass) {
      case WindowSizeClass.expanded:
        return expanded ?? medium ?? compact;
      case WindowSizeClass.medium:
        return medium ?? compact;
      case WindowSizeClass.compact:
        return compact;
    }
  }
}
