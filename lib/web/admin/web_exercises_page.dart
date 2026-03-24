import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_database_provider.dart';
import '../../core/providers/usecase_providers.dart';
import '../../core/repositories/exercise_repository.dart';
import '../../core/database/database.dart';
import '../../core/usecases/exercise/delete_exercise_usecase.dart';

/// Web 动作管理页面
class WebExercisesPage extends ConsumerStatefulWidget {
  const WebExercisesPage({super.key});

  @override
  ConsumerState<WebExercisesPage> createState() => _WebExercisesPageState();
}

class _WebExercisesPageState extends ConsumerState<WebExercisesPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;
  final Set<int> _selectedIds = {};

  final List<Map<String, dynamic>> _categories = [
    {'value': 'chest', 'label': '胸'},
    {'value': 'back', 'label': '背'},
    {'value': 'shoulders', 'label': '肩'},
    {'value': 'arms', 'label': '臂'},
    {'value': 'legs', 'label': '腿'},
    {'value': 'core', 'label': '核心'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(exerciseRepositoryProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildToolbar(),
          Expanded(child: _buildDataTable(repo)),
        ],
      ),
    );
  }

  /// 页面头部
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          const Text(
            '动作管理',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索动作...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 工具栏
  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 分类筛选
          DropdownButton<String>(
            value: _selectedCategory,
            hint: const Text('全部分类'),
            items: [
              const DropdownMenuItem(value: null, child: Text('全部分类')),
              ..._categories.map((cat) {
                return DropdownMenuItem(
                  value: cat['value'] as String,
                  child: Text(cat['label'] as String),
                );
              }),
            ],
            onChanged: (value) {
              setState(() => _selectedCategory = value);
            },
          ),
          const SizedBox(width: 16),
          // 批量操作
          if (_selectedIds.isNotEmpty) ...[
            Text('已选择 ${_selectedIds.length} 项'),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _bulkDelete,
              icon: const Icon(Icons.delete),
              label: const Text('批量删除'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => setState(() => _selectedIds.clear()),
              child: const Text('取消选择'),
            ),
          ],
          const Spacer(),
          // 导入导出
          OutlinedButton.icon(
            onPressed: _showImportDialog,
            icon: const Icon(Icons.upload),
            label: const Text('导入'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _exportExercises,
            icon: const Icon(Icons.download),
            label: const Text('导出'),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _showAddDialog,
            icon: const Icon(Icons.add),
            label: const Text('添加动作'),
          ),
        ],
      ),
    );
  }

  /// 数据表格
  Widget _buildDataTable(ExerciseRepository repo) {
    return FutureBuilder<List<Exercise>>(
      future: _getFilteredExercises(repo),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final exercises = snapshot.data!;

        if (exercises.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  '暂无动作数据',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
            columns: const [
              DataColumn(label: Text('名称')),
              DataColumn(label: Text('分类')),
              DataColumn(label: Text('组数')),
              DataColumn(label: Text('次数')),
              DataColumn(label: Text('重量')),
              DataColumn(label: Text('类型')),
              DataColumn(label: Text('操作')),
            ],
            rows: exercises.map((exercise) {
              final isSelected = _selectedIds.contains(exercise.id);
              return DataRow(
                selected: isSelected,
                onSelectChanged: (selected) {
                  setState(() {
                    if (selected == true) {
                      _selectedIds.add(exercise.id);
                    } else {
                      _selectedIds.remove(exercise.id);
                    }
                  });
                },
                cells: [
                  DataCell(Text(exercise.name)),
                  DataCell(Text(_getCategoryLabel(exercise.category))),
                  DataCell(Text('${exercise.defaultSets}')),
                  DataCell(Text('${exercise.defaultReps}')),
                  DataCell(
                    Text(
                      exercise.defaultWeight != null
                          ? '${exercise.defaultWeight} kg'
                          : '-',
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: exercise.isCustom
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        exercise.isCustom ? '自定义' : '系统',
                        style: TextStyle(
                          color: exercise.isCustom ? Colors.blue : Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => _showEditDialog(exercise),
                          tooltip: '编辑',
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            size: 18,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteExercise(exercise),
                          tooltip: '删除',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// 获取筛选后的动作
  Future<List<Exercise>> _getFilteredExercises(ExerciseRepository repo) async {
    List<Exercise> exercises;

    if (_selectedCategory != null) {
      exercises = await repo.getByCategory(_selectedCategory!);
    } else {
      exercises = await repo.getEnabled();
    }

    if (_searchQuery.isNotEmpty) {
      exercises = exercises
          .where((e) => e.name.toLowerCase().contains(_searchQuery))
          .toList();
    }

    return exercises;
  }

  /// 获取分类标签
  String _getCategoryLabel(String category) {
    final cat = _categories.firstWhere(
      (c) => c['value'] == category,
      orElse: () => {'label': category},
    );
    return cat['label'] as String;
  }

  /// 显示添加对话框
  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => _ExerciseFormDialog(
        onSave: (data) async {
          final repo = ref.read(exerciseRepositoryProvider);
          await repo.createExercise(
            name: data['name'] as String,
            category: data['category'] as String,
            defaultSets: data['defaultSets'] as int? ?? 3,
            defaultReps: data['defaultReps'] as int? ?? 10,
            defaultWeight: data['defaultWeight'] as double?,
          );
          ref.invalidate(appDatabaseProvider);
        },
      ),
    );
  }

  /// 显示编辑对话框
  void _showEditDialog(Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => _ExerciseFormDialog(
        exercise: exercise,
        onSave: (data) async {
          final repo = ref.read(exerciseRepositoryProvider);
          await repo.updateExercise(
            exercise.id,
            name: data['name'] as String?,
            category: data['category'] as String?,
            defaultSets: data['defaultSets'] as int?,
            defaultReps: data['defaultReps'] as int?,
            defaultWeight: data['defaultWeight'] as double?,
          );
          ref.invalidate(appDatabaseProvider);
        },
      ),
    );
  }

  /// 删除动作
  Future<void> _deleteExercise(Exercise exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除动作「${exercise.name}」吗？'),
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
      final result = await ref.read(deleteExerciseUseCaseProvider)(exercise.id);
      if (!mounted) return;
      setState(() => _selectedIds.remove(exercise.id));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_deleteResultMessage(result))),
      );
    }
  }

  /// 批量删除
  Future<void> _bulkDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认批量删除'),
        content: Text('确定要删除选中的 ${_selectedIds.length} 个动作吗？'),
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
      final deleteExercise = ref.read(deleteExerciseUseCaseProvider);
      int successCount = 0;
      int strengthRefCount = 0;
      int templateRefCount = 0;
      int prRefCount = 0;
      int notFoundCount = 0;
      for (final id in _selectedIds.toList()) {
        final result = await deleteExercise(id);
        switch (result) {
          case DeleteExerciseResult.success:
            successCount++;
          case DeleteExerciseResult.hasStrengthReferences:
            strengthRefCount++;
          case DeleteExerciseResult.hasTemplateReferences:
            templateRefCount++;
          case DeleteExerciseResult.hasPrReferences:
            prRefCount++;
          case DeleteExerciseResult.notFound:
            notFoundCount++;
        }
      }
      if (!mounted) return;
      setState(() => _selectedIds.clear());

      final failCount =
          strengthRefCount + templateRefCount + prRefCount + notFoundCount;
      final summary = failCount > 0
          ? '已删除 $successCount 个，失败 $failCount 个'
          : '已删除 $successCount 个动作';
      final details = <String>[
        if (strengthRefCount > 0) '$strengthRefCount 个存在训练引用',
        if (templateRefCount > 0) '$templateRefCount 个存在模板引用',
        if (prRefCount > 0) '$prRefCount 个存在个人记录引用',
        if (notFoundCount > 0) '$notFoundCount 个不存在',
      ].join('，');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(details.isEmpty ? summary : '$summary；$details'),
        ),
      );
    }
  }

  String _deleteResultMessage(DeleteExerciseResult result) {
    switch (result) {
      case DeleteExerciseResult.success:
        return '动作已删除';
      case DeleteExerciseResult.hasStrengthReferences:
        return '无法删除：动作已被训练记录引用';
      case DeleteExerciseResult.hasTemplateReferences:
        return '无法删除：动作已被模板引用';
      case DeleteExerciseResult.hasPrReferences:
        return '无法删除：动作已被个人记录引用';
      case DeleteExerciseResult.notFound:
        return '动作不存在';
    }
  }

  /// 显示导入对话框
  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入动作'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('支持 CSV 和 JSON 格式'),
            SizedBox(height: 16),
            Text('CSV 格式：名称,分类,组数,次数,重量'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现文件导入
            },
            child: const Text('选择文件'),
          ),
        ],
      ),
    );
  }

  /// 导出动作
  void _exportExercises() {
    // TODO: 实现导出功能
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('导出功能开发中')));
  }
}

/// 动作表单对话框
class _ExerciseFormDialog extends StatefulWidget {
  final Exercise? exercise;
  final Function(Map<String, dynamic>) onSave;

  const _ExerciseFormDialog({this.exercise, required this.onSave});

  @override
  State<_ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends State<_ExerciseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');
  final _weightController = TextEditingController();
  String _category = 'chest';

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _nameController.text = widget.exercise!.name;
      _setsController.text = widget.exercise!.defaultSets.toString();
      _repsController.text = widget.exercise!.defaultReps.toString();
      _weightController.text = widget.exercise!.defaultWeight?.toString() ?? '';
      _category = widget.exercise!.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise != null ? '编辑动作' : '添加动作'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '动作名称',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请输入名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: '分类',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'chest', child: Text('胸')),
                DropdownMenuItem(value: 'back', child: Text('背')),
                DropdownMenuItem(value: 'shoulders', child: Text('肩')),
                DropdownMenuItem(value: 'arms', child: Text('臂')),
                DropdownMenuItem(value: 'legs', child: Text('腿')),
                DropdownMenuItem(value: 'core', child: Text('核心')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _setsController,
                    decoration: const InputDecoration(
                      labelText: '组数',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _repsController,
                    decoration: const InputDecoration(
                      labelText: '次数',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: '重量(kg)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSave({
                'name': _nameController.text,
                'category': _category,
                'defaultSets': int.tryParse(_setsController.text),
                'defaultReps': int.tryParse(_repsController.text),
                'defaultWeight': double.tryParse(_weightController.text),
              });
              Navigator.pop(context);
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
