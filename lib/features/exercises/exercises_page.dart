import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_database_provider.dart';
import '../../core/providers/usecase_providers.dart';
import '../../core/repositories/exercise_repository.dart';
import '../../core/database/database.dart';
import '../../core/usecases/exercise/delete_exercise_usecase.dart';

/// 动作库管理页面
/// 显示所有可用动作，支持搜索、筛选、添加和编辑
class ExercisesPage extends ConsumerStatefulWidget {
  const ExercisesPage({super.key});

  @override
  ConsumerState<ExercisesPage> createState() => _ExercisesPageState();
}

class _ExercisesPageState extends ConsumerState<ExercisesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {
      'value': 'chest',
      'label': '胸',
      'icon': Icons.fitness_center,
      'color': Colors.red,
    },
    {
      'value': 'back',
      'label': '背',
      'icon': Icons.backpack,
      'color': Colors.blue,
    },
    {
      'value': 'shoulders',
      'label': '肩',
      'icon': Icons.accessibility,
      'color': Colors.orange,
    },
    {
      'value': 'arms',
      'label': '臂',
      'icon': Icons.back_hand,
      'color': Colors.purple,
    },
    {
      'value': 'legs',
      'label': '腿',
      'icon': Icons.directions_run,
      'color': Colors.green,
    },
    {
      'value': 'core',
      'label': '核心',
      'icon': Icons.circle,
      'color': Colors.teal,
    },
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
      appBar: AppBar(
        title: const Text('动作库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),

          // 分类筛选
          _buildCategoryFilter(),

          // 动作列表
          Expanded(child: _buildExerciseList(repo)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddExerciseDialog(),
        icon: const Icon(Icons.add),
        label: const Text('添加动作'),
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: '搜索动作...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value.toLowerCase());
        },
      ),
    );
  }

  /// 构建分类筛选
  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          FilterChip(
            label: const Text('全部'),
            selected: _selectedCategory == null,
            onSelected: (_) {
              setState(() => _selectedCategory = null);
            },
          ),
          const SizedBox(width: 8),
          ..._categories.map(
            (cat) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                avatar: CircleAvatar(
                  backgroundColor: (cat['color'] as Color).withAlpha(50),
                  child: Icon(
                    cat['icon'] as IconData,
                    size: 14,
                    color: cat['color'] as Color,
                  ),
                ),
                label: Text(cat['label'] as String),
                selected: _selectedCategory == cat['value'],
                onSelected: (_) {
                  setState(() => _selectedCategory = cat['value'] as String);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建动作列表
  Widget _buildExerciseList(ExerciseRepository repo) {
    return FutureBuilder<List<Exercise>>(
      future: _getFilteredExercises(repo),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final exercises = snapshot.data!;

        if (exercises.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (!mounted) return;
            setState(() {});
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              return _buildExerciseCard(exercises[index], repo);
            },
          ),
        );
      },
    );
  }

  /// 获取筛选后的动作列表
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

    // 按名称排序
    exercises.sort((a, b) => a.name.compareTo(b.name));

    return exercises;
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.fitness_center, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty || _selectedCategory != null
                ? '没有找到匹配的动作'
                : '动作库为空\n点击下方按钮添加动作',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  /// 构建动作卡片
  Widget _buildExerciseCard(Exercise exercise, ExerciseRepository repo) {
    final category = _categories.firstWhere(
      (c) => c['value'] == exercise.category,
      orElse: () => {
        'label': exercise.category,
        'color': Colors.grey,
        'icon': Icons.fitness_center,
      },
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (category['color'] as Color).withAlpha(50),
          child: Icon(
            category['icon'] as IconData,
            color: category['color'] as Color,
          ),
        ),
        title: Row(
          children: [
            Text(exercise.name),
            if (exercise.isCustom) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(30),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '自定义',
                  style: TextStyle(fontSize: 10, color: Colors.blue),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(
          '${exercise.defaultSets}组 × ${exercise.defaultReps}次'
          '${exercise.defaultWeight != null ? ' · ${exercise.defaultWeight}kg' : ''}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditExerciseDialog(exercise, repo);
                break;
              case 'delete':
                _confirmDeleteExercise(exercise);
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
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showExerciseDetail(exercise),
      ),
    );
  }

  /// 显示动作详情
  void _showExerciseDetail(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => _ExerciseDetailSheet(
          exercise: exercise,
          scrollController: scrollController,
        ),
      ),
    );
  }

  /// 显示添加动作对话框
  Future<void> _showAddExerciseDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const _ExerciseFormDialog(),
    );

    if (result != null && mounted) {
      final repo = ref.read(exerciseRepositoryProvider);

      try {
        await repo.createExercise(
          name: result['name'] as String,
          category: result['category'] as String,
          defaultSets: result['defaultSets'] as int? ?? 3,
          defaultReps: result['defaultReps'] as int? ?? 10,
          defaultWeight: result['defaultWeight'] as double?,
          description: result['description'] as String?,
        );

        setState(() {});

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('动作已添加')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('添加失败: $e')));
        }
      }
    }
  }

  /// 显示编辑动作对话框
  Future<void> _showEditExerciseDialog(
    Exercise exercise,
    ExerciseRepository repo,
  ) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _ExerciseFormDialog(exercise: exercise),
    );

    if (result != null && mounted) {
      try {
        await repo.updateExercise(
          exercise.id,
          name: result['name'] as String?,
          category: result['category'] as String?,
          defaultSets: result['defaultSets'] as int?,
          defaultReps: result['defaultReps'] as int?,
          defaultWeight: result['defaultWeight'] as double?,
          description: result['description'] as String?,
        );

        setState(() {});

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('动作已更新')));
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

  /// 确认删除动作
  Future<void> _confirmDeleteExercise(Exercise exercise) async {
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

    if (confirmed == true && mounted) {
      final useCase = ref.read(deleteExerciseUseCaseProvider);
      final result = await useCase(exercise.id);

      setState(() {});

      if (mounted) {
        final message = switch (result) {
          DeleteExerciseResult.success => '动作已删除',
          DeleteExerciseResult.hasStrengthReferences =>
            '无法删除：动作已被训练记录引用',
          DeleteExerciseResult.hasTemplateReferences => '无法删除：动作已被模板引用',
          DeleteExerciseResult.hasPrReferences => '无法删除：动作已被个人记录引用',
          DeleteExerciseResult.notFound => '动作不存在',
        };
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    }
  }

  /// 显示信息对话框
  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('动作库说明'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('动作库存储所有可用的训练动作，包括系统预置和用户自定义动作。'),
            SizedBox(height: 12),
            Text('• 每个动作包含默认组数、次数和重量设置'),
            Text('• 按分类组织，方便快速查找'),
            Text('• 自定义动作会标记显示'),
            SizedBox(height: 12),
            Text('添加新动作后，可在训练时快速选择使用。'),
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

/// 动作详情表单
class _ExerciseDetailSheet extends StatelessWidget {
  final Exercise exercise;
  final ScrollController scrollController;

  const _ExerciseDetailSheet({
    required this.exercise,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final categoryLabels = {
      'chest': '胸',
      'back': '背',
      'shoulders': '肩',
      'arms': '臂',
      'legs': '腿',
      'core': '核心',
      'full_body': '全身',
      'cardio': '有氧',
    };

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
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            exercise.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            '分类',
            categoryLabels[exercise.category] ?? exercise.category,
          ),
          _buildDetailRow('默认组数', '${exercise.defaultSets} 组'),
          _buildDetailRow('默认次数', '${exercise.defaultReps} 次'),
          if (exercise.defaultWeight != null)
            _buildDetailRow('默认重量', '${exercise.defaultWeight} kg'),
          _buildDetailRow(
            '动作类型',
            exercise.movementType == 'compound' ? '复合动作' : '孤立动作',
          ),
          if (exercise.primaryMuscles != null)
            _buildDetailRow('主要肌群', exercise.primaryMuscles!),
          if (exercise.secondaryMuscles != null)
            _buildDetailRow('次要肌群', exercise.secondaryMuscles!),
          if (exercise.description != null) ...[
            const SizedBox(height: 16),
            const Text(
              '动作说明',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(exercise.description!),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label, style: TextStyle(color: Colors.grey.shade400)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

/// 动作表单对话框
class _ExerciseFormDialog extends StatefulWidget {
  final Exercise? exercise;

  const _ExerciseFormDialog({this.exercise});

  @override
  State<_ExerciseFormDialog> createState() => _ExerciseFormDialogState();
}

class _ExerciseFormDialogState extends State<_ExerciseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _setsController;
  late TextEditingController _repsController;
  late TextEditingController _weightController;
  late TextEditingController _descriptionController;
  String _selectedCategory = 'chest';

  final List<Map<String, dynamic>> _categories = [
    {'value': 'chest', 'label': '胸'},
    {'value': 'back', 'label': '背'},
    {'value': 'shoulders', 'label': '肩'},
    {'value': 'arms', 'label': '臂'},
    {'value': 'legs', 'label': '腿'},
    {'value': 'core', 'label': '核心'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.exercise?.name ?? '');
    _setsController = TextEditingController(
      text: (widget.exercise?.defaultSets ?? 3).toString(),
    );
    _repsController = TextEditingController(
      text: (widget.exercise?.defaultReps ?? 10).toString(),
    );
    _weightController = TextEditingController(
      text: widget.exercise?.defaultWeight?.toString() ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.exercise?.description ?? '',
    );
    _selectedCategory = widget.exercise?.category ?? 'chest';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exercise != null ? '编辑动作' : '添加动作'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 动作名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '动作名称 *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '请输入动作名称';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 分类选择 - 使用 SegmentedButton (6 个单字选项)
              const Text('分类', style: TextStyle(fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: _categories.map((cat) {
                  return ButtonSegment<String>(
                    value: cat['value'] as String,
                    label: Text(cat['label'] as String),
                  );
                }).toList(),
                selected: {_selectedCategory},
                onSelectionChanged: (Set<String> selection) {
                  setState(() => _selectedCategory = selection.first);
                },
                showSelectedIcon: false,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(height: 16),

              // 默认组数和次数
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _setsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '默认组数',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _repsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '默认次数',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 默认重量
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '默认重量 (kg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // 说明
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '动作说明',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
        'category': _selectedCategory,
        'defaultSets': int.tryParse(_setsController.text) ?? 3,
        'defaultReps': int.tryParse(_repsController.text) ?? 10,
        'defaultWeight': double.tryParse(_weightController.text),
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      });
    }
  }
}
