// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_info_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 应用包信息 Provider
/// 提供应用的版本、构建号等信息

@ProviderFor(packageInfo)
final packageInfoProvider = PackageInfoProvider._();

/// 应用包信息 Provider
/// 提供应用的版本、构建号等信息

final class PackageInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<PackageInfo>,
          PackageInfo,
          FutureOr<PackageInfo>
        >
    with $FutureModifier<PackageInfo>, $FutureProvider<PackageInfo> {
  /// 应用包信息 Provider
  /// 提供应用的版本、构建号等信息
  PackageInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'packageInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$packageInfoHash();

  @$internal
  @override
  $FutureProviderElement<PackageInfo> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PackageInfo> create(Ref ref) {
    return packageInfo(ref);
  }
}

String _$packageInfoHash() => r'41f10b7668cfc9d09df704d18b851ed9440397d6';

/// 应用名称 Provider

@ProviderFor(appName)
final appNameProvider = AppNameProvider._();

/// 应用名称 Provider

final class AppNameProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// 应用名称 Provider
  AppNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appNameHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appName(ref);
  }
}

String _$appNameHash() => r'6cfb8400bfbe1076cbdd0da9d68cd24aa854b0ed';

/// 应用版本 Provider (如 0.1.0)

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// 应用版本 Provider (如 0.1.0)

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// 应用版本 Provider (如 0.1.0)
  AppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'b4f7f940dc09c859660ad01e056295d0e2d031ae';

/// 构建号 Provider (如 1)

@ProviderFor(buildNumber)
final buildNumberProvider = BuildNumberProvider._();

/// 构建号 Provider (如 1)

final class BuildNumberProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// 构建号 Provider (如 1)
  BuildNumberProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'buildNumberProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$buildNumberHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return buildNumber(ref);
  }
}

String _$buildNumberHash() => r'dfae108a25d2f0416bd090ad8fff50fbaa8123f6';

/// 完整版本字符串 Provider (如 0.1.0+1)

@ProviderFor(fullVersion)
final fullVersionProvider = FullVersionProvider._();

/// 完整版本字符串 Provider (如 0.1.0+1)

final class FullVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// 完整版本字符串 Provider (如 0.1.0+1)
  FullVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fullVersionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fullVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return fullVersion(ref);
  }
}

String _$fullVersionHash() => r'ac7496e153f84c12625d9827e9aa3302a58a6ecd';
