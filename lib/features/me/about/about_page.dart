import 'package:flutter/material.dart';

/// 关于应用页面
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 应用图标和名称
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    size: 40,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'FitTrack',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '版本 1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 描述
          Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            color: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'FitTrack 是一款个人训练记录应用',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '支持力量训练、跑步、游泳等多种运动类型的记录和分析，帮助你追踪训练进度，达成健身目标。',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 功能特点
          _buildFeatureItem(
            context,
            icon: Icons.offline_bolt,
            title: '本地优先',
            description: '数据存储在本地，无需网络',
          ),
          _buildFeatureItem(
            context,
            icon: Icons.devices,
            title: 'Web 管理',
            description: '局域网访问 Web 界面',
          ),
          _buildFeatureItem(
            context,
            icon: Icons.backup,
            title: '数据备份',
            description: '支持 WebDAV 备份',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary),
        title: Text(title),
        subtitle: Text(description),
      ),
    );
  }
}
