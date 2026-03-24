import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_database_provider.dart';
import '../../core/providers/usecase_providers.dart';
import '../../core/database/database.dart';
import '../../shared/workout/workout_type_catalog.dart';

/// 表格管理视图
/// Web 端高级数据管理界面
class TableManagementView extends ConsumerStatefulWidget {
  const TableManagementView({super.key});

  @override
  ConsumerState<TableManagementView> createState() =>
      _TableManagementViewState();
}

class _TableManagementViewState extends ConsumerState<TableManagementView> {
  final Set<int> _selectedIds = {};
  bool _selectAll = false;

  final List<String> _columns = ['ID', '日期时间', '类型', '时长', '强度', '备注', '操作'];

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(trainingRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('数据管理'),
        actions: [
          if (_selectedIds.isNotEmpty)
            TextButton.icon(
              onPressed: _deleteSelected,
              icon: const Icon(Icons.delete, color: Colors.red),
              label: Text(
                '删除选中 (${_selectedIds.length})',
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
      body: FutureBuilder<List<TrainingSession>>(
        future: repo.getAll(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final sessions = snapshot.data!;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(
                    label: Checkbox(
                      value: _selectAll,
                      onChanged: (value) {
                        setState(() {
                          _selectAll = value ?? false;
                          if (_selectAll) {
                            _selectedIds.addAll(sessions.map((s) => s.id));
                          } else {
                            _selectedIds.clear();
                          }
                        });
                      },
                    ),
                  ),
                  ..._columns.map((col) => DataColumn(label: Text(col))),
                ],
                rows: sessions.map((session) {
                  final isSelected = _selectedIds.contains(session.id);

                  return DataRow(
                    selected: isSelected,
                    onSelectChanged: (selected) {
                      setState(() {
                        if (selected ?? false) {
                          _selectedIds.add(session.id);
                        } else {
                          _selectedIds.remove(session.id);
                        }
                        _selectAll = _selectedIds.length == sessions.length;
                      });
                    },
                    cells: [
                      DataCell(
                        Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value ?? false) {
                                _selectedIds.add(session.id);
                              } else {
                                _selectedIds.remove(session.id);
                              }
                            });
                          },
                        ),
                      ),
                      DataCell(Text('${session.id}')),
                      DataCell(
                        Text(
                          DateFormat(
                            'yyyy-MM-dd HH:mm',
                          ).format(session.datetime),
                        ),
                      ),
                      DataCell(_buildTypeChip(session.type)),
                      DataCell(Text('${session.durationMinutes} 分钟')),
                      DataCell(_buildIntensityChip(session.intensity)),
                      DataCell(
                        Text(session.note ?? '-'),
                        placeholder: session.note == null,
                      ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: () => _editSession(session),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 20,
                                color: Colors.red,
                              ),
                              onPressed: () => _deleteSession(session),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建类型标签
  Widget _buildTypeChip(String type) {
    final typeMeta = WorkoutTypeCatalog.of(type);

    return Chip(
      label: Text(typeMeta.label, style: const TextStyle(fontSize: 12)),
      backgroundColor: typeMeta.color.withAlpha(30),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// 构建强度标签
  Widget _buildIntensityChip(String intensity) {
    final intensityLabels = {'light': '轻度', 'moderate': '中度', 'high': '高强度'};

    final intensityColors = {
      'light': Colors.green,
      'moderate': Colors.orange,
      'high': Colors.red,
    };

    return Chip(
      label: Text(
        intensityLabels[intensity] ?? intensity,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: (intensityColors[intensity] ?? Colors.grey).withAlpha(
        30,
      ),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  /// 编辑记录
  void _editSession(TrainingSession session) {
    // TODO: 导航到编辑页面
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('编辑记录 ID: ${session.id}')));
  }

  /// 删除单个记录
  Future<void> _deleteSession(TrainingSession session) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除记录 ID: ${session.id} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(deleteTrainingUseCaseProvider)(session.id);
      if (!mounted) return;
      setState(() {
        _selectedIds.remove(session.id);
        _selectAll = false;
      });
    }
  }

  /// 删除选中的记录
  Future<void> _deleteSelected() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('批量删除'),
        content: Text('确定要删除选中的 ${_selectedIds.length} 条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final deleteTraining = ref.read(deleteTrainingUseCaseProvider);
      for (final id in _selectedIds.toList()) {
        await deleteTraining(id);
      }
      if (!mounted) return;
      setState(() {
        _selectedIds.clear();
        _selectAll = false;
      });
    }
  }
}
