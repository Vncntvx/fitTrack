import 'package:flutter/widgets.dart';

/// 页面响应式尺寸
class AppResponsiveData {
  const AppResponsiveData({
    required this.width,
    required this.pagePadding,
    required this.sectionSpacing,
    required this.cardSpacing,
    required this.gridColumns,
    required this.isTablet,
    required this.isDesktop,
    required this.maxContentWidth,
  });

  final double width;
  final double pagePadding;
  final double sectionSpacing;
  final double cardSpacing;
  final int gridColumns;
  final bool isTablet;
  final bool isDesktop;
  final double maxContentWidth;
}

/// 响应式布局工具
class AppResponsive {
  AppResponsive._();

  static AppResponsiveData of(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;

    return forWidth(width, isLandscape: isLandscape);
  }

  /// 根据宽度计算响应式参数
  /// [isLandscape] 用于区分横屏手机和真正的平板/桌面设备
  static AppResponsiveData forWidth(double width, {bool isLandscape = false}) {
    // 超大屏幕 (>= 1400px) - 真正的桌面设备
    if (width >= 1400) {
      return AppResponsiveData(
        width: width,
        pagePadding: 48,
        sectionSpacing: 32,
        cardSpacing: 20,
        gridColumns: 4,
        isTablet: true,
        isDesktop: true,
        maxContentWidth: 800,
      );
    }

    // 大屏幕 (>= 1100px) - 桌面或平板
    if (width >= 1100) {
      return AppResponsiveData(
        width: width,
        pagePadding: 32,
        sectionSpacing: 28,
        cardSpacing: 16,
        // 横屏手机保持 2 列，平板/桌面用 3 列
        gridColumns: isLandscape ? 2 : 3,
        isTablet: true,
        isDesktop: !isLandscape,
        maxContentWidth: 720,
      );
    }

    // 中屏幕 (>= 720px) - 平板或横屏手机
    if (width >= 720) {
      return AppResponsiveData(
        width: width,
        pagePadding: 24,
        sectionSpacing: 24,
        cardSpacing: 12,
        // 横屏手机保持 2 列
        gridColumns: 2,
        isTablet: !isLandscape,
        isDesktop: false,
        maxContentWidth: 600,
      );
    }

    // 手机端 (< 720px)
    return AppResponsiveData(
      width: width,
      pagePadding: 16,
      sectionSpacing: 20,
      cardSpacing: 12,
      gridColumns: 2,
      isTablet: false,
      isDesktop: false,
      maxContentWidth: double.infinity,
    );
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
    this.useScrollView = true,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;
  final bool useScrollView;

  @override
  Widget build(BuildContext context) {
    final layout = AppResponsive.of(context);
    final effectiveMaxWidth = maxWidth ?? layout.maxContentWidth;
    final effectivePadding = padding ?? EdgeInsets.all(layout.pagePadding);

    // 只在真正的桌面设备上限制宽度
    if (layout.isDesktop && !layout.isTablet) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: Padding(
            padding: effectivePadding,
            child: child,
          ),
        ),
      );
    }

    // 平板和横屏手机：限制宽度但不要居中（太宽了）
    if (layout.isTablet && layout.width > 1100) {
      return Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: Padding(
            padding: effectivePadding,
            child: child,
          ),
        ),
      );
    }

    // 手机端：直接使用 padding
    return Padding(
      padding: effectivePadding,
      child: child,
    );
  }
}

/// 响应式卡片网格
/// 根据屏幕宽度自动调整列数
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.childAspectRatio = 1.5,
    this.mainAxisSpacing = 12,
    this.crossAxisSpacing = 12,
  });

  final List<Widget> children;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  Widget build(BuildContext context) {
    final layout = AppResponsive.of(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layout.gridColumns,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: children.length,
      itemBuilder: (context, index) => children[index],
    );
  }
}
