import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_database_provider.dart';
import '../../core/providers/usecase_providers.dart';
import '../../core/repositories/template_repository.dart';
import '../../core/database/database.dart';
import '../../core/usecases/template/duplicate_template_usecase.dart';
import '../../shared/workout/workout_type_catalog.dart';
import '../../shared/widgets/charts/chart_colors.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/loading_indicator.dart';

/// 训练模板管理页面
/// 显示所有可用模板，支持按类型筛选和管理
class TemplatesPage extends ConsumerStatefulWidget {
  const TemplatesPage({super.key});

  @override
  ConsumerState<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends ConsumerState<TemplatesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _templateTypes = [
    {'value': 'strength', 'label': '健身', 'icon': Icons.fitness_center},
    {'value': 'running', 'label': '跑步', 'icon': Icons.directions_run},
    {'value': 'swimming', 'label': '游泳', 'icon': Icons.pool},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _templateTypes.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(templateRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('训练模板'),
        bottom: TabBar(
          controller: _tabController,
          tabs: _templateTypes
              .map(
                (type) => Tab(
                  icon: Icon(type['icon'] as IconData),
                  text: type['label'] as String,
                ),
              )
              .toList(),
          onTap: (_) => setState(() {}),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: _templateTypes
            .map((type) => _buildTemplateList(repo, type['value'] as String))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTemplateDialog(),
        icon: const Icon(Icons.add),
        label: const Text('创建模板'),
      ),
    );
  }

  /// 构建模板列表
  Widget _buildTemplateList(TemplateRepository repo, String type) {
    return FutureBuilder<List<WorkoutTemplate>>(
      future: repo.getByType(type),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }

        final templates = snapshot.data!;

        if (templates.isEmpty) {
          return _buildEmptyState(type);
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (!mounted) return;
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              return _buildTemplateCard(templates[index], repo);
            },
          ),
        );
      },
    );
  }

  /// 构建空状态
  Widget _buildEmptyState(String type) {
    final typeLabels = {'strength': '健身', 'running': '跑步', 'swimming': '游泳'};

    return EmptyStateWidget(
      icon: Icons.description_outlined,
      message: '暂无${typeLabels[type] ?? type}模板',
      subtitle: '点击下方按钮创建新模板',
    );
  }

  /// 构建模板卡片
  Widget _buildTemplateCard(WorkoutTemplate template, TemplateRepository repo) {
    final templateColor = _getTypeColor(template.type);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: templateColor.withValues(alpha: 0.2),
              child: Icon(_getTypeIcon(template.type), color: templateColor),
            ),
            title: Row(
              children: [
                Text(template.name),
                if (template.isDefault) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '默认',
                      style: TextStyle(
                        fontSize: 10,
                        color: colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (template.description != null &&
                    template.description!.isNotEmpty)
                  Text(template.description!),
                Text(
                  '创建于 ${DateFormat('yyyy-MM-dd').format(template.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditTemplateDialog(template, repo);
                    break;
                  case 'duplicate':
                    _duplicateTemplate(template);
                    break;
                  case 'delete':
                    _confirmDeleteTemplate(template, repo);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit),
                      SizedBox(width: 8),
                      Text('编辑'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy),
                      SizedBox(width: 8),
                      Text('复制'),
                    ],
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
          ),
          // 快速开始按钮
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showTemplateDetail(template, repo),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('查看详情'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _startTraining(template),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('开始训练'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 获取类型图标
  IconData _getTypeIcon(String type) {
    return WorkoutTypeCatalog.iconOf(type);
  }

  /// 获取类型颜色
  Color _getTypeColor(String type) {
    return ChartColors.getTrainingTypeColor(type);
  }

  /// 显示模板详情
  void _showTemplateDetail(WorkoutTemplate template, TemplateRepository repo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => FutureBuilder<TemplateDetail?>(
          future: repo.getTemplateDetail(template.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LoadingIndicator(size: 24);
            }

            final detail = snapshot.data!;
            return _TemplateDetailSheet(
              template: template,
              detail: detail,
              scrollController: scrollController,
              onEdit: () {
                Navigator.pop(context);
                _showEditTemplateDialog(template, repo);
              },
              onStart: () {
                Navigator.pop(context);
                _startTraining(template);
              },
            );
          },
        ),
      ),
    );
  }

  /// 显示创建模板对话框
  Future<void> _showCreateTemplateDialog() async {
    final currentType = _templateTypes[_tabController.index]['value'] as String;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _TemplateFormDialog(initialType: currentType),
    );

    if (result != null && mounted) {
      final repo = ref.read(templateRepositoryProvider);

      try {
        await repo.createTemplate(
          name: result['name'] as String,
          type: result['type'] as String,
          description: result['description'] as String?,
          isDefault: result['isDefault'] as bool? ?? false,
        );

        setState(() {});

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('模板已创建')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('创建失败: $e')));
        }
      }
    }
  }

  /// 显示编辑模板对话框
  Future<void> _showEditTemplateDialog(
    WorkoutTemplate template,
    TemplateRepository repo,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _TemplateFormDialog(template: template),
    );

    if (result != null && mounted) {
      try {
        await repo.updateTemplate(
          template.id,
          name: result['name'] as String?,
          type: result['type'] as String?,
          description: result['description'] as String?,
          isDefault: result['isDefault'] as bool?,
        );

        setState(() {});

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('模板已更新')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('更新失败: $e')));
        }
      }
    }
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

      setState(() {});
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('模板已复制，ID: ${result.$2}')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('复制失败: $e')));
      }
    }
  }

  /// 确认删除模板
  Future<void> _confirmDeleteTemplate(
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

    if (confirmed == true && mounted) {
      final deleted = await repo.deleteTemplate(template.id);
      setState(() {});

      if (mounted) {
        final message = deleted > 0 ? '模板已删除' : '模板不存在或已删除';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  /// 开始训练
  void _startTraining(WorkoutTemplate template) {
    // 根据模板类型跳转到对应的训练页面
    switch (template.type) {
      case 'strength':
        context.push('/train/strength/new?templateId=${template.id}');
        break;
      case 'running':
        context.push('/train/running/new?templateId=${template.id}');
        break;
      case 'swimming':
        context.push('/train/swimming/new?templateId=${template.id}');
        break;
      default:
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('暂不支持该训练类型')));
    }
  }

  /// 显示信息对话框
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('训练模板说明'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('训练模板可以保存常用的训练计划，方便快速开始训练。'),
            SizedBox(height: 12),
            Text('• 按训练类型分类管理'),
            Text('• 包含预设的动作、组数、次数'),
            Text('• 支持设为默认模板'),
            SizedBox(height: 12),
            Text('创建模板后，可在训练时一键加载。'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }
}

/// 模板详情面板
class _TemplateDetailSheet extends StatelessWidget {
  final WorkoutTemplate template;
  final TemplateDetail detail;
  final ScrollController scrollController;
  final VoidCallback onEdit;
  final VoidCallback onStart;

  const _TemplateDetailSheet({
    required this.template,
    required this.detail,
    required this.scrollController,
    required this.onEdit,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListView(
        controller: scrollController,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  template.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
            ],
          ),
          if (template.description != null &&
              template.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              template.description!,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '动作列表 (${detail.exercises.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '总组数: ${detail.exercises.fold(0, (sum, e) => sum + e.sets)}',
                style: TextStyle(color: Theme.of(context).colorScheme.outline),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...detail.exercises.asMap().entries.map((entry) {
            final index = entry.key;
            final exercise = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(exercise.exerciseName),
                subtitle: Text(
                  '${exercise.sets}组 × ${exercise.reps}次'
                  '${exercise.weight != null ? ' · ${exercise.weight}kg' : ''}',
                ),
              ),
            );
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('编辑模板'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onStart,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('开始训练'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 模板表单对话框
class _TemplateFormDialog extends StatefulWidget {
  final WorkoutTemplate? template;
  final String? initialType;

  const _TemplateFormDialog({this.template, this.initialType});

  @override
  State<_TemplateFormDialog> createState() => _TemplateFormDialogState();
}

class _TemplateFormDialogState extends State<_TemplateFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _selectedType = 'strength';
  bool _isDefault = false;

  final List<Map<String, dynamic>> _types = [
    {'value': 'strength', 'label': '健身'},
    {'value': 'running', 'label': '跑步'},
    {'value': 'swimming', 'label': '游泳'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.template?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.template?.description ?? '',
    );
    _selectedType = widget.template?.type ?? widget.initialType ?? 'strength';
    _isDefault = widget.template?.isDefault ?? false;
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
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 模板名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '模板名称 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入模板名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 类型选择
              const Text('训练类型', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _types.map((type) {
                  return ChoiceChip(
                    label: Text(type['label'] as String),
                    selected: _selectedType == type['value'],
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedType = type['value'] as String);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // 描述
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '描述（可选）',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // 设为默认
              SwitchListTile(
                title: const Text('设为默认模板'),
                subtitle: const Text('新建训练时优先使用此模板'),
                value: _isDefault,
                onChanged: (value) {
                  setState(() => _isDefault = value);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(onPressed: _submit, child: const Text('保存')),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        'isDefault': _isDefault,
      });
    }
  }
}
