import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/package_info_provider.dart';

/// 系统信息页面
/// 显示应用和系统信息
class SystemInfoPage extends ConsumerWidget {
  const SystemInfoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = ref.watch(appVersionProvider);
    final fullVersion = ref.watch(fullVersionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('系统信息')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('应用信息'),
          _buildAppInfoCard(appVersion, fullVersion),
          const SizedBox(height: 24),
          _buildSectionTitle('数据库信息'),
          _buildDatabaseInfoCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('服务信息'),
          _buildServiceInfoCard(),
        ],
      ),
    );
  }

  /// 分区标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// 应用信息卡片
  Widget _buildAppInfoCard(
    AsyncValue<String> appVersion,
    AsyncValue<String> fullVersion,
  ) {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.app_shortcut),
            title: Text('应用名称'),
            subtitle: Text('FitTrack'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('版本'),
            subtitle: Text(appVersion.value ?? '加载中...'),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.build),
            title: const Text('构建版本'),
            subtitle: Text(fullVersion.value ?? '加载中...'),
          ),
          const Divider(height: 1),
          const ListTile(
            leading: Icon(Icons.code),
            title: Text('技术栈'),
            subtitle: Text('Flutter 3.41 + Dart 3.11 + Riverpod'),
          ),
        ],
      ),
    );
  }

  /// 数据库信息卡片
  Widget _buildDatabaseInfoCard() {
    return const Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.storage),
            title: Text('数据库'),
            subtitle: Text('Drift (SQLite)'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.table_chart),
            title: Text('表数量'),
            subtitle: Text(
              '5 (UserSettings, WorkoutRecords, StrengthExerciseEntries, BackupConfigurations, BackupRecords)',
            ),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.schema),
            title: Text('版本'),
            subtitle: Text('1'),
          ),
        ],
      ),
    );
  }

  /// 服务信息卡片
  Widget _buildServiceInfoCard() {
    return const Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(Icons.wifi_tethering),
            title: Text('LAN 服务'),
            subtitle: Text('Shelf HTTP Server'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.web),
            title: Text('Web UI'),
            subtitle: Text('Flutter Web (WASM)'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.api),
            title: Text('API'),
            subtitle: Text('RESTful (13 个端点)'),
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.security),
            title: Text('认证'),
            subtitle: Text('Bearer Token'),
          ),
        ],
      ),
    );
  }
}
