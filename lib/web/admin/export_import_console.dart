import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/backup/backup_service.dart';
import '../../core/providers/app_database_provider.dart';

/// 导出/导入控制台
/// Web 端数据导入导出管理
class ExportImportConsole extends ConsumerStatefulWidget {
  const ExportImportConsole({super.key});

  @override
  ConsumerState<ExportImportConsole> createState() =>
      _ExportImportConsoleState();
}

class _ExportImportConsoleState extends ConsumerState<ExportImportConsole> {
  bool _isExporting = false;
  String? _lastOperation;
  String? _exportData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('导入/导出')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('导出数据'),
          _buildExportCard(),
          const SizedBox(height: 24),
          if (_exportData != null) _buildExportPreviewCard(),
          const SizedBox(height: 24),
          if (_lastOperation != null) _buildStatusCard(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildExportCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('导出格式', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildExportButton(
                    'JSON',
                    Icons.code,
                    Colors.blue,
                    () => _exportJson(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildExportButton(
                    'CSV',
                    Icons.table_chart,
                    Colors.green,
                    () => _exportCsv(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildExportButton(
              '完整数据库',
              Icons.storage,
              Colors.orange,
              () => _exportDatabase(),
              fullWidth: true,
            ),
            if (_isExporting) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExportPreviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '导出预览',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _exportData!));
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('复制'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 300),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  _exportData!,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: Colors.grey.shade900,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('上次操作', style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(_lastOperation!),
          ],
        ),
      ),
    );
  }

  Widget _buildExportButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed, {
    bool fullWidth = false,
  }) {
    return ElevatedButton.icon(
      onPressed: _isExporting ? null : onPressed,
      icon: Icon(icon, color: color),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  Future<void> _exportJson() async {
    setState(() => _isExporting = true);

    try {
      final repo = ref.read(trainingRepositoryProvider);
      final workouts = await repo.getAll();

      final data = workouts
          .map(
            (w) => {
              'id': w.id,
              'datetime': w.datetime.toIso8601String(),
              'type': w.type,
              'durationMinutes': w.durationMinutes,
              'intensity': w.intensity,
              'note': w.note,
              'isGoalCompleted': w.isGoalCompleted,
              'createdAt': w.createdAt.toIso8601String(),
            },
          )
          .toList();

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);

      setState(() {
        _exportData = jsonString;
        _lastOperation = '导出 JSON 成功：${workouts.length} 条记录';
      });
    } catch (e) {
      setState(() => _lastOperation = '导出失败: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportCsv() async {
    setState(() => _isExporting = true);

    try {
      final repo = ref.read(trainingRepositoryProvider);
      final workouts = await repo.getAll();

      final csv = StringBuffer();
      csv.writeln('ID,DateTime,Type,Duration,Intensity,Note,GoalCompleted');

      for (final w in workouts) {
        csv.writeln(
          '${w.id},${w.datetime},${w.type},${w.durationMinutes},${w.intensity},"${w.note ?? ''}",${w.isGoalCompleted}',
        );
      }

      setState(() {
        _exportData = csv.toString();
        _lastOperation = '导出 CSV 成功：${workouts.length} 条记录';
      });
    } catch (e) {
      setState(() => _lastOperation = '导出失败: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _exportDatabase() async {
    setState(() => _isExporting = true);

    try {
      final data = await BackupService(ref.read(appDatabaseProvider)).exportData();

      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final workoutCount = (data['workouts'] as List<dynamic>? ?? const []).length;

      setState(() {
        _exportData = jsonString;
        _lastOperation = '导出完整备份成功：$workoutCount 条运动记录';
      });
    } catch (e) {
      setState(() => _lastOperation = '导出失败: $e');
    } finally {
      setState(() => _isExporting = false);
    }
  }
}
