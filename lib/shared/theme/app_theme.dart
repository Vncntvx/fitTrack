import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/providers/app_database_provider.dart';

part 'app_theme.g.dart';

/// 主题模式
enum ThemeModeOption { system, light, dark }

/// 主题 AsyncNotifier
/// 使用 Riverpod 2.x AsyncNotifier 模式处理异步初始化
@Riverpod(keepAlive: true)
class ThemeModeNotifier extends _$ThemeModeNotifier {
  @override
  Future<ThemeMode> build() async {
    // 从存储加载主题模式
    final settingsRepo = ref.watch(settingsRepositoryProvider);
    final mode = await settingsRepo.getThemeMode();
    return _themeModeFromStorage(mode);
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeModeOption mode) async {
    final nextMode = _themeModeFromOption(mode);
    final settingsRepo = ref.read(settingsRepositoryProvider);

    final saved = await settingsRepo.updateThemeMode(
      _themeModeToStorage(nextMode),
    );

    if (!saved) {
      throw StateError('保存主题模式失败');
    }

    // 更新状态
    state = AsyncData(nextMode);
  }

  ThemeMode _themeModeFromOption(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.system:
        return ThemeMode.system;
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
    }
  }

  ThemeMode _themeModeFromStorage(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToStorage(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

/// 当前主题模式 Provider
/// 返回 ThemeMode.system 作为加载中的默认值
@riverpod
ThemeMode currentThemeMode(Ref ref) {
  final asyncMode = ref.watch(themeModeProvider);
  return asyncMode.value ?? ThemeMode.system;
}

/// 应用主题配置
class AppTheme {
  // ========== 颜色常量 ==========
  static const Color _primaryColor = Color(0xFFBB86FC);
  static const Color _secondaryColor = Color(0xFF03DAC6);
  static const Color _tertiaryColor = Color(0xFF3700B3);
  static const Color _errorColor = Color(0xFFCF6679);
  static const Color _surfaceDark = Color(0xFF121212);
  static const Color _surfaceVariantDark = Color(0xFF1E1E1E);
  static const Color _outlineColor = Color(0xFF888888);
  static const Color _outlineVariantColor = Color(0xFF444444);
  static const Color _surfaceLight = Color(0xFFFCF8FF);
  static const Color _surfaceVariantLight = Color(0xFFF1EBF5);
  static const Color _outlineLight = Color(0xFF7A757F);
  static const Color _outlineVariantLight = Color(0xFFCAC4CF);

  /// 获取暗色主题
  /// 包含完整的 Material 3 组件主题定义
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryColor,
        onPrimary: Colors.black,
        secondary: _secondaryColor,
        onSecondary: Colors.black,
        tertiary: _tertiaryColor,
        surface: _surfaceDark,
        onSurface: Colors.white,
        surfaceContainerHighest: _surfaceVariantDark,
        onSurfaceVariant: Colors.white70,
        error: _errorColor,
        onError: Colors.black,
        outline: _outlineColor,
        outlineVariant: _outlineVariantColor,
      ),
      scaffoldBackgroundColor: const Color(0xFF000000),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _surfaceVariantDark,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
        ),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.15,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _primaryColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceVariantDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _outlineVariantColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceVariantDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        contentTextStyle: const TextStyle(fontSize: 14, color: Colors.white70),
      ),
      dividerTheme: const DividerThemeData(
        color: _outlineVariantColor,
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _surfaceDark,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.white60,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceDark,
        indicatorColor: _primaryColor.withAlpha(50),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceVariantDark,
        labelStyle: const TextStyle(color: Colors.white),
        side: const BorderSide(color: _outlineVariantColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _surfaceVariantDark,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.black,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryColor;
          return Colors.grey;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return _primaryColor.withAlpha(150);
          }
          return Colors.grey.withAlpha(100);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryColor;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.black),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return _primaryColor;
          return Colors.white70;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: _primaryColor,
        inactiveTrackColor: _primaryColor.withAlpha(100),
        thumbColor: _primaryColor,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryColor,
        linearTrackColor: _outlineVariantColor,
        circularTrackColor: _outlineVariantColor,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: _primaryColor,
        unselectedLabelColor: Colors.white60,
        indicatorColor: _primaryColor,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Colors.white,
        iconColor: Colors.white70,
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      popupMenuTheme: PopupMenuThemeData(
        color: _surfaceVariantDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: _surfaceVariantDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  /// 获取亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: _primaryColor,
        onPrimary: Colors.white,
        secondary: _secondaryColor,
        onSecondary: Colors.black,
        tertiary: _tertiaryColor,
        onTertiary: Colors.white,
        surface: _surfaceLight,
        onSurface: Color(0xFF1D1B20),
        surfaceContainerHighest: _surfaceVariantLight,
        onSurfaceVariant: Color(0xFF49454F),
        error: Color(0xFFB3261E),
        onError: Colors.white,
        outline: _outlineLight,
        outlineVariant: _outlineVariantLight,
      ),
      scaffoldBackgroundColor: const Color(0xFFF8F4FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: _surfaceLight,
        foregroundColor: Color(0xFF1D1B20),
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _outlineVariantLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB3261E)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFB3261E), width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF49454F)),
        hintStyle: const TextStyle(color: Color(0xFF7A757F)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      dividerTheme: const DividerThemeData(
        color: _outlineVariantLight,
        thickness: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceLight,
        indicatorColor: _primaryColor.withAlpha(32),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceVariantLight,
        labelStyle: const TextStyle(color: Color(0xFF1D1B20)),
        side: const BorderSide(color: _outlineVariantLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF2B2930),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryColor,
        linearTrackColor: _outlineVariantLight,
        circularTrackColor: _outlineVariantLight,
      ),
      listTileTheme: const ListTileThemeData(
        textColor: Color(0xFF1D1B20),
        iconColor: Color(0xFF49454F),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }
}
