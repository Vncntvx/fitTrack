import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_database_provider.dart';
import '../../core/providers/usecase_providers.dart';
import '../../core/repositories/template_repository.dart';
import '../../core/database/database.dart';
import '../../core/usecases/template/duplicate_template_usecase.dart';
import '../../shared/widgets/charts/chart_colors.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/loading_indicator.dart';

/// Web 模板管理页面
class WebTemplatesPage extends ConsumerStatefulWidget {
  const WebTemplatesPage({super.key});

  @override
  ConsumerState<WebTemplatesPage> createState() => _WebTemplatesPageState();
}

class _WebTemplatesPageState extends ConsumerState<WebTemplatesPage> {
  String? _selectedType;
  bool _isGridView = true;

  final List<Map<String, dynamic>> _templateTypes = [
    {'value': 'strength', 'label': '健身'},
    {'value': 'running', 'label': '跑步'},
    {'value': 'swimming', 'label': '游泳'},
  ];

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(templateRepositoryProvider);

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildToolbar(),
          Expanded(
            child: _isGridView ? _buildGridView(repo) : _buildListView(repo),
          ),
        ],
      ),
    );
  }

  /// 页面头部
  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      child: Row(
        children: [
          const Text(
            '模板管理',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          // 视图切换
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, icon: Icon(Icons.grid_view)),
              ButtonSegment(value: false, icon: Icon(Icons.view_list)),
            ],
            selected: {_isGridView},
            onSelectionChanged: (Set<bool> selection) {
              setState(() => _isGridView = selection.first);
            },
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
          // 类型筛选
          DropdownButton<String>(
            value: _selectedType,
            hint: const Text('全部类型'),
            items: [
              const DropdownMenuItem(value: null, child: Text('全部类型')),
              ..._templateTypes.map((type) {
                return DropdownMenuItem(
                  value: type['value'] as String,
                  child: Text(type['label'] as String),
                );
              }),
            ],
            onChanged: (value) {
              setState(() => _selectedType = value);
            },
          ),
          const Spacer(),
          // 导入导出
          OutlinedButton.icon(
            onPressed: _showImportDialog,
            icon: const Icon(Icons.upload),
            label: const Text('导入'),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: _exportTemplates,
            icon: const Icon(Icons.download),
            label: const Text('导出'),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _showCreateDialog,
            icon: const Icon(Icons.add),
            label: const Text('创建模板'),
          ),
        ],
      ),
    );
  }

  /// 网格视图
  Widget _buildGridView(TemplateRepository repo) {
    return FutureBuilder<List<WorkoutTemplate>>(
      future: _getFilteredTemplates(repo),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }

        final templates = snapshot.data!;

        if (templates.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.description_outlined,
            message: '暂无模板',
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 300,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            return _buildTemplateCard(templates[index], repo);
          },
        );
      },
    );
  }

  /// 列表视图
  Widget _buildListView(TemplateRepository repo) {
    return FutureBuilder<List<WorkoutTemplate>>(
      future: _getFilteredTemplates(repo),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }

        final templates = snapshot.data!;
        if (templates.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.description_outlined,
            message: '暂无模板',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            return _buildTemplateListTile(templates[index], repo);
          },
        );
      },
    );
  }

  /// 模板卡片
  Widget _buildTemplateCard(WorkoutTemplate template, TemplateRepository repo) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = _getTypeColor(template.type);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showTemplateDetail(template, repo),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              color: typeColor.withValues(alpha: 0.2),
              child: Center(
                child: Icon(
                  _getTypeIcon(template.type),
                  size: 40,
                  color: typeColor,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          template.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (template.isDefault)
                        Icon(Icons.star, size: 16, color: colorScheme.tertiary),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getTypeLabel(template.type),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '创建于 ${DateFormat('yyyy-MM-dd').format(template.createdAt)}',
                    style: TextStyle(fontSize: 11, color: colorScheme.outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 模板列表项
  Widget _buildTemplateListTile(
    WorkoutTemplate template,
    TemplateRepository repo,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = _getTypeColor(template.type);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getTypeIcon(template.type), color: typeColor),
        ),
        title: Row(
          children: [
            Text(template.name),
            if (template.isDefault) ...[
              const SizedBox(width: 8),
              Icon(Icons.star, size: 16, color: colorScheme.tertiary),
            ],
          ],
        ),
        subtitle: Text(
          '${_getTypeLabel(template.type)} · ${DateFormat('yyyy-MM-dd').format(template.createdAt)}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditDialog(template);
                break;
              case 'duplicate':
                _duplicateTemplate(template);
                break;
              case 'delete':
                _deleteTemplate(template, repo);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('编辑')],
              ),
            ),
            const PopupMenuItem(
              value: 'duplicate',
              child: Row(
                children: [Icon(Icons.copy), SizedBox(width: 8), Text('复制')],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '删除',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showTemplateDetail(template, repo),
      ),
    );
  }

  /// 获取筛选后的模板
  Future<List<WorkoutTemplate>> _getFilteredTemplates(
    TemplateRepository repo,
  ) async {
    if (_selectedType != null) {
      return await repo.getByType(_selectedType!);
    }
    return await repo.getAll();
  }

  /// 显示创建对话框
  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => _TemplateFormDialog(
        onSave: (data) async {
          final repo = ref.read(templateRepositoryProvider);
          await repo.createTemplate(
            name: data['name'] as String,
            type: data['type'] as String,
            description: data['description'] as String?,
            isDefault: data['isDefault'] as bool? ?? false,
          );
          if (!mounted) return;
          setState(() {});
        },
      ),
    );
  }

  /// 显示编辑对话框
  void _showEditDialog(WorkoutTemplate template) {
    showDialog(
      context: context,
      builder: (context) => _TemplateFormDialog(
        template: template,
        onSave: (data) async {
          final repo = ref.read(templateRepositoryProvider);
          await repo.updateTemplate(
            template.id,
            name: data['name'] as String?,
            type: data['type'] as String?,
            description: data['description'] as String?,
            isDefault: data['isDefault'] as bool?,
          );
          if (!mounted) return;
          setState(() {});
        },
      ),
    );
  }

  /// 显示模板详情
  void _showTemplateDetail(WorkoutTemplate template, TemplateRepository repo) {
    showDialog(
      context: context,
      builder: (context) =>
          _TemplateDetailDialog(template: template, repo: repo),
    );
  }

  /// 复制模板
  Future<void> _duplicateTemplate(WorkoutTemplate template) async {
    try {
      final result = await ref.read(duplicateTemplateUseCaseProvider)(
        DuplicateTemplateParams(templateId: template.id),
      );
      if (result.$1 != DuplicateTemplateResult.success) {
        throw StateError('模板不存在');
      }
      if (!mounted) return;
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('模板已复制，ID: ${result.$2}')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('复制失败: $e')));
      }
    }
  }

  /// 删除模板
  Future<void> _deleteTemplate(
    WorkoutTemplate template,
    TemplateRepository repo,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除模板「${template.name}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final deleted = await repo.deleteTemplate(template.id);
      if (!mounted) return;
      setState(() {});
      final message = deleted > 0 ? '模板已删除' : '模板不存在或已删除';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  /// 显示导入对话框
  void _showImportDialog() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('导入功能开发中')));
  }

  /// 导出模板
  void _exportTemplates() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('导出功能开发中')));
  }

  /// 获取类型标签
  String _getTypeLabel(String type) {
    const labels = {'strength': '健身', 'running': '跑步', 'swimming': '游泳'};
    return labels[type] ?? type;
  }

  /// 获取类型颜色
  Color _getTypeColor(String type) {
    const colors = {
      'strength': ChartColors.strength,
      'running': ChartColors.running,
      'swimming': ChartColors.swimming,
    };
    return colors[type] ?? ChartColors.primary;
  }

  /// 获取类型图标
  IconData _getTypeIcon(String type) {
    const icons = {
      'strength': Icons.fitness_center,
      'running': Icons.directions_run,
      'swimming': Icons.pool,
    };
    return icons[type] ?? Icons.sports;
  }
}

/// 模板表单对话框
class _TemplateFormDialog extends StatefulWidget {
  final WorkoutTemplate? template;
  final Function(Map<String, dynamic>) onSave;

  const _TemplateFormDialog({this.template, required this.onSave});

  @override
  State<_TemplateFormDialog> createState() => _TemplateFormDialogState();
}

class _TemplateFormDialogState extends State<_TemplateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _type = 'strength';
  bool _isDefault = false;

  @override
  void initState() {
    super.initState();
    if (widget.template != null) {
      _nameController.text = widget.template!.name;
      _descriptionController.text = widget.template!.description ?? '';
      _type = widget.template!.type;
      _isDefault = widget.template!.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.template != null ? '编辑模板' : '创建模板'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '模板名称',
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
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: '训练类型',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'strength', child: Text('健身')),
                DropdownMenuItem(value: 'running', child: Text('跑步')),
                DropdownMenuItem(value: 'swimming', child: Text('游泳')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() => _type = value);
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '描述（可选）',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('设为默认'),
              value: _isDefault,
              onChanged: (value) {
                setState(() => _isDefault = value);
              },
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
                'type': _type,
                'description': _descriptionController.text.isNotEmpty
                    ? _descriptionController.text
                    : null,
                'isDefault': _isDefault,
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

/// 模板详情对话框
class _TemplateDetailDialog extends StatelessWidget {
  final WorkoutTemplate template;
  final TemplateRepository repo;

  const _TemplateDetailDialog({required this.template, required this.repo});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(template.name),
      content: FutureBuilder<TemplateDetail?>(
        future: repo.getTemplateDetail(template.id),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const LoadingIndicator(size: 24);
          }

          final detail = snapshot.data!;

          return SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('类型: ${_getTypeLabel(template.type)}'),
                const SizedBox(height: 8),
                if (template.description != null &&
                    template.description!.isNotEmpty)
                  Text('描述: ${template.description}'),
                const SizedBox(height: 16),
                const Text(
                  '动作列表:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...detail.exercises.map((exercise) {
                  return ListTile(
                    dense: true,
                    title: Text(exercise.exerciseName),
                    subtitle: Text(
                      '${exercise.sets}组 × ${exercise.reps}次'
                      '${exercise.weight != null ? ' · ${exercise.weight}kg' : ''}',
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('关闭'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            context.go(
              '/train/${template.type}/new?templateId=${template.id}',
            );
          },
          child: const Text('开始训练'),
        ),
      ],
    );
  }

  String _getTypeLabel(String type) {
    const labels = {'strength': '健身', 'running': '跑步', 'swimming': '游泳'};
    return labels[type] ?? type;
  }
}
