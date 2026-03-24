import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'package_info_provider.g.dart';

/// 应用包信息 Provider
/// 提供应用的版本、构建号等信息
@Riverpod(keepAlive: true)
Future<PackageInfo> packageInfo(Ref ref) async {
  return PackageInfo.fromPlatform();
}

/// 应用名称 Provider
@riverpod
Future<String> appName(Ref ref) async {
  final info = await ref.watch(packageInfoProvider.future);
  return info.appName;
}

/// 应用版本 Provider (如 0.1.0)
@riverpod
Future<String> appVersion(Ref ref) async {
  final info = await ref.watch(packageInfoProvider.future);
  return info.version;
}

/// 构建号 Provider (如 1)
@riverpod
Future<String> buildNumber(Ref ref) async {
  final info = await ref.watch(packageInfoProvider.future);
  return info.buildNumber;
}

/// 完整版本字符串 Provider (如 0.1.0+1)
@riverpod
Future<String> fullVersion(Ref ref) async {
  final info = await ref.watch(packageInfoProvider.future);
  return '${info.version}+${info.buildNumber}';
}
