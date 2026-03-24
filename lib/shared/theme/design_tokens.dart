import 'package:flutter/material.dart';

// ============================================================================
// FitTrack Design Tokens
// ============================================================================
// 中心化设计令牌系统，确保整个应用的视觉一致性
// 所有间距、圆角、阴影、透明度值都应从这里引用
// ============================================================================

/// 间距系统
/// 基于 4px 网格的间距值，用于 padding、margin、gap
class AppSpacing {
  AppSpacing._();

  /// 最小间距 - 4px
  static const double xs = 4;

  /// 小间距 - 8px
  static const double sm = 8;

  /// 中间距 - 12px
  static const double md = 12;

  /// 标准间距 - 16px
  static const double lg = 16;

  /// 大间距 - 20px
  static const double xl = 20;

  /// 超大间距 - 24px
  static const double xxl = 24;

  /// 巨大间距 - 32px
  static const double xxxl = 32;

  /// 页面边距 - 48px
  static const double page = 48;

  // ==================== 常用 EdgeInsets ====================

  /// 无边距
  static const EdgeInsets zero = EdgeInsets.zero;

  /// 所有方向 xs 边距
  static const EdgeInsets allXs = EdgeInsets.all(xs);

  /// 所有方向 sm 边距
  static const EdgeInsets allSm = EdgeInsets.all(sm);

  /// 所有方向 md 边距
  static const EdgeInsets allMd = EdgeInsets.all(md);

  /// 所有方向 lg 边距
  static const EdgeInsets allLg = EdgeInsets.all(lg);

  /// 所有方向 xl 边距
  static const EdgeInsets allXl = EdgeInsets.all(xl);

  /// 所有方向 xxl 边距
  static const EdgeInsets allXxl = EdgeInsets.all(xxl);

  /// 水平 lg 边距
  static const EdgeInsets horizontalLg = EdgeInsets.symmetric(horizontal: lg);

  /// 水平 xxl 边距
  static const EdgeInsets horizontalXxl = EdgeInsets.symmetric(horizontal: xxl);

  /// 垂直 sm 边距
  static const EdgeInsets verticalSm = EdgeInsets.symmetric(vertical: sm);

  /// 垂直 md 边距
  static const EdgeInsets verticalMd = EdgeInsets.symmetric(vertical: md);

  /// 垂直 lg 边距
  static const EdgeInsets verticalLg = EdgeInsets.symmetric(vertical: lg);

  /// 卡片内边距
  static const EdgeInsets card = EdgeInsets.all(lg);

  /// 列表项内边距
  static const EdgeInsets listItem = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// 对话框内边距
  static const EdgeInsets dialog = EdgeInsets.all(xxl);

  /// 底部表单内边距
  static const EdgeInsets bottomSheet = EdgeInsets.fromLTRB(lg, lg, lg, xxxl);

  /// 区块标题内边距
  static const EdgeInsets sectionHeader = EdgeInsets.fromLTRB(0, lg, 0, sm);

  /// 页面标准内边距
  static const EdgeInsets pagePadding = EdgeInsets.all(lg);

  /// 大卡片内边距
  static const EdgeInsets cardLarge = EdgeInsets.all(xxl);
}

/// 圆角系统
/// 基于 Material 3 的圆角值
class AppRadius {
  AppRadius._();

  /// 无圆角
  static const double none = 0;

  /// 超小圆角 - 4px (chips, small elements)
  static const double xs = 4;

  /// 小圆角 - 8px (buttons, small cards)
  static const double sm = 8;

  /// 中圆角 - 12px (cards, inputs)
  static const double md = 12;

  /// 大圆角 - 16px (large cards, containers)
  static const double lg = 16;

  /// 超大圆角 - 20px (featured cards)
  static const double xl = 20;

  /// 巨大圆角 - 28px (dialogs, bottom sheets)
  static const double xxl = 28;

  /// 完全圆形
  static const double full = 999;

  // ==================== 常用 BorderRadius ====================

  /// 无圆角
  static BorderRadius get zero => BorderRadius.zero;

  /// 超小圆角
  static BorderRadius get circularXs => BorderRadius.circular(xs);

  /// 小圆角
  static BorderRadius get circularSm => BorderRadius.circular(sm);

  /// 中圆角
  static BorderRadius get circularMd => BorderRadius.circular(md);

  /// 大圆角
  static BorderRadius get circularLg => BorderRadius.circular(lg);

  /// 超大圆角
  static BorderRadius get circularXl => BorderRadius.circular(xl);

  /// 巨大圆角 (对话框)
  static BorderRadius get circularXxl => BorderRadius.circular(xxl);

  /// 顶部圆角 (底部表单)
  static BorderRadius get topXxl => const BorderRadius.vertical(
    top: Radius.circular(xxl),
  );

  /// 卡片圆角
  static BorderRadius get card => circularLg;

  /// 输入框圆角
  static BorderRadius get input => circularMd;

  /// 按钮圆角
  static BorderRadius get button => circularMd;

  /// 芯片圆角
  static BorderRadius get chip => circularSm;
}

/// 阴影/高度系统
/// Material 3 高度语义
class AppElevation {
  AppElevation._();

  /// 无阴影 - 平面
  static const double level0 = 0;

  /// 轻微浮起 - 卡片默认
  static const double level1 = 1;

  /// 中等浮起 - 悬停状态
  static const double level2 = 2;

  /// 高浮起 - FAB、导航栏
  static const double level3 = 3;

  /// 最高浮起 - 对话框
  static const double level4 = 4;

  /// 卡片默认阴影
  static const double card = level0;

  /// 浮动按钮阴影
  static const double fab = level3;

  /// 对话框阴影
  static const double dialog = level4;

  /// AppBar 阴影
  static const double appBar = level0;

  /// 底部导航阴影
  static const double bottomNav = level2;
}

/// 透明度系统
/// 用于一致的透明度效果
class AppOpacity {
  AppOpacity._();

  /// 禁用状态
  static const double disabled = 0.38;

  /// 轻微强调 (背景色、overlay)
  static const double subtle = 0.08;

  /// 浅色背景 (快速按钮等)
  static const double light = 0.15;

  /// 中等强调 (hover 状态)
  static const double moderate = 0.12;

  /// 明显强调 (active 状态)
  static const double emphasized = 0.16;

  /// 次要文本透明度
  static const double secondary = 0.7;

  /// 较强强调 (选中项背景)
  static const double strong = 0.24;

  /// 半透明
  static const double semiTransparent = 0.5;

  /// 大部分不透明
  static const double mostlyOpaque = 0.7;

  /// 几乎不透明
  static const double almostOpaque = 0.87;
}

/// 尺寸系统
/// 常用组件尺寸
class AppSize {
  AppSize._();

  /// 图标尺寸 - 小
  static const double iconSm = 16;

  /// 图标尺寸 - 中
  static const double iconMd = 20;

  /// 图标尺寸 - 标准
  static const double iconLg = 24;

  /// 图标尺寸 - 大
  static const double iconXl = 28;

  /// 图标尺寸 - 超大
  static const double iconXxl = 32;

  /// 图标尺寸 - 巨大
  static const double iconXxxl = 48;

  /// 头像尺寸 - 小
  static const double avatarSm = 32;

  /// 头像尺寸 - 中
  static const double avatarMd = 40;

  /// 头像尺寸 - 大
  static const double avatarLg = 48;

  /// 头像尺寸 - 超大
  static const double avatarXl = 56;

  /// 触摸目标最小尺寸 (Material 规范)
  static const double touchTarget = 48;

  /// 按钮最小高度
  static const double buttonHeight = 40;

  /// 输入框最小高度
  static const double inputHeight = 56;

  /// 列表项最小高度
  static const double listItemHeight = 56;

  /// AppBar 高度
  static const double appBarHeight = 56;

  /// NavigationBar 高度
  static const double navBarHeight = 80;

  /// NavigationRail 宽度
  static const double navRailWidth = 80;

  /// NavigationRail 展开宽度
  static const double navRailWidthExtended = 256;
}

/// 断点系统
/// 响应式布局断点
class AppBreakpoints {
  AppBreakpoints._();

  /// 紧凑宽度上限 (手机竖屏)
  static const double compact = 600;

  /// 中等宽度上限 (手机横屏、小平板)
  static const double medium = 840;

  /// 扩展宽度开始 (平板、桌面)
  static const double expanded = 840;

  /// 大屏幕 (大平板、桌面)
  static const double large = 1200;

  /// 超大屏幕 (宽屏桌面)
  static const double extraLarge = 1600;

  /// 内容最大宽度 (文本为主的页面)
  static const double maxContentWidth = 720;

  /// 仪表盘最大宽度
  static const double maxDashboardWidth = 1200;

  /// 表单最大宽度
  static const double maxFormWidth = 600;
}

/// 动画时长系统
class AppDuration {
  AppDuration._();

  /// 快速动画 - 100ms
  static const Duration fast = Duration(milliseconds: 100);

  /// 标准动画 - 200ms
  static const Duration standard = Duration(milliseconds: 200);

  /// 中等动画 - 300ms
  static const Duration medium = Duration(milliseconds: 300);

  /// 慢速动画 - 400ms
  static const Duration slow = Duration(milliseconds: 400);

  /// 页面切换 - 300ms
  static const Duration pageTransition = Duration(milliseconds: 300);
}

/// 动画曲线系统
class AppCurves {
  AppCurves._();

  /// 标准缓动
  static const Curve standard = Curves.easeInOut;

  /// 减速缓动 (进入)
  static const Curve decelerate = Curves.easeOut;

  /// 加速缓动 (离开)
  static const Curve accelerate = Curves.easeIn;

  /// 强调缓动
  static const Curve emphasized = Curves.easeInOutCubic;
}
