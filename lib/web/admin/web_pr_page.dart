import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../core/providers/app_database_provider.dart';
import '../../shared/widgets/charts/chart_colors.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/loading_indicator.dart';

/// 个人记录页面
class WebPrPage extends ConsumerWidget {
  const WebPrPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('个人记录')),
      body: FutureBuilder<List<PersonalRecord>>(
        future: db.select(db.personalRecords).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.error_outline,
              message: '加载失败',
              subtitle: snapshot.error.toString(),
            );
          }
          if (!snapshot.hasData) {
            return const LoadingIndicator();
          }

          final records = snapshot.data!;
          if (records.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.emoji_events_outlined,
              message: '暂无个人记录',
            );
          }

          final grouped = <String, List<PersonalRecord>>{};
          for (final record in records) {
            final type = record.recordType;
            grouped.putIfAbsent(type, () => []).add(record);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return _buildTypeSection(context, entry.key, entry.value);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildTypeSection(
    BuildContext context,
    String type,
    List<PersonalRecord> records,
  ) {
    // 按数值排序（对于配速，越小越好）
    final isPace = type.contains('pace');
    records.sort(
      (a, b) =>
          isPace ? a.value.compareTo(b.value) : b.value.compareTo(a.value),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getTypeIcon(type), color: _getTypeColor(type)),
                const SizedBox(width: 8),
                Text(
                  _getTypeLabel(type),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(type).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${records.length} 条记录',
                    style: TextStyle(color: _getTypeColor(type), fontSize: 12),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...records
                .take(5)
                .map((record) => _buildRecordTile(context, record)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTile(BuildContext context, PersonalRecord record) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getTypeColor(
          record.recordType,
        ).withValues(alpha: 0.2),
        child: Text(
          '#${record.id}',
          style: TextStyle(color: _getTypeColor(record.recordType)),
        ),
      ),
      title: Text(_formatValue(record)),
      subtitle: Text(
        '${record.unit} · ${_formatDate(record.achievedAt)}',
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
    );
  }

  String _formatValue(PersonalRecord record) {
    final type = record.recordType;
    if (type.contains('distance')) {
      if (record.unit == 'meters') {
        return '${(record.value / 1000).toStringAsFixed(2)} km';
      }
    }
    if (type.contains('pace')) {
      final minutes = record.value.toInt() ~/ 60;
      final seconds = record.value.toInt() % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')} /km';
    }
    if (type.contains('1rm')) {
      return '${record.value.toStringAsFixed(1)} kg';
    }
    return '${record.value.toStringAsFixed(1)} ${record.unit}';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _getTypeLabel(String type) {
    const labels = {
      'strength_1rm': '力量最大重量 (1RM)',
      'strength_volume': '力量训练容量',
      'running_distance': '跑步最长距离',
      'running_pace': '跑步最快配速',
      'swimming_distance': '游泳最长距离',
      'swimming_pace': '游泳最快配速',
    };
    return labels[type] ?? type;
  }

  Color _getTypeColor(String type) {
    const colors = {
      'strength_1rm': ChartColors.strength,
      'strength_volume': ChartColors.primary,
      'running_distance': ChartColors.running,
      'running_pace': ChartColors.runTempo,
      'swimming_distance': ChartColors.swimming,
      'swimming_pace': ChartColors.strokeFreestyle,
    };
    return colors[type] ?? ChartColors.primary;
  }

  IconData _getTypeIcon(String type) {
    const icons = {
      'strength_1rm': Icons.fitness_center,
      'strength_volume': Icons.fitness_center,
      'running_distance': Icons.directions_run,
      'running_pace': Icons.speed,
      'swimming_distance': Icons.pool,
      'swimming_pace': Icons.timer,
    };
    return icons[type] ?? Icons.emoji_events;
  }
}
