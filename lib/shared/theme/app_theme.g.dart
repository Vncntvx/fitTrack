// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_theme.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 主题 AsyncNotifier
/// 使用 Riverpod 2.x AsyncNotifier 模式处理异步初始化

@ProviderFor(ThemeModeNotifier)
final themeModeProvider = ThemeModeNotifierProvider._();

/// 主题 AsyncNotifier
/// 使用 Riverpod 2.x AsyncNotifier 模式处理异步初始化
final class ThemeModeNotifierProvider
    extends $AsyncNotifierProvider<ThemeModeNotifier, ThemeMode> {
  /// 主题 AsyncNotifier
  /// 使用 Riverpod 2.x AsyncNotifier 模式处理异步初始化
  ThemeModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themeModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themeModeNotifierHash();

  @$internal
  @override
  ThemeModeNotifier create() => ThemeModeNotifier();
}

String _$themeModeNotifierHash() => r'b76a606200502b62c29d25540421f113f73f1c97';

/// 主题 AsyncNotifier
/// 使用 Riverpod 2.x AsyncNotifier 模式处理异步初始化

abstract class _$ThemeModeNotifier extends $AsyncNotifier<ThemeMode> {
  FutureOr<ThemeMode> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemeMode>, ThemeMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemeMode>, ThemeMode>,
              AsyncValue<ThemeMode>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 当前主题模式 Provider
/// 返回 ThemeMode.system 作为加载中的默认值

@ProviderFor(currentThemeMode)
final currentThemeModeProvider = CurrentThemeModeProvider._();

/// 当前主题模式 Provider
/// 返回 ThemeMode.system 作为加载中的默认值

final class CurrentThemeModeProvider
    extends $FunctionalProvider<ThemeMode, ThemeMode, ThemeMode>
    with $Provider<ThemeMode> {
  /// 当前主题模式 Provider
  /// 返回 ThemeMode.system 作为加载中的默认值
  CurrentThemeModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentThemeModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentThemeModeHash();

  @$internal
  @override
  $ProviderElement<ThemeMode> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ThemeMode create(Ref ref) {
    return currentThemeMode(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ThemeMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ThemeMode>(value),
    );
  }
}

String _$currentThemeModeHash() => r'c9e82d164a8a092d2d5e9e01dc14a4c24e9dd68c';
