import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_database_provider.dart';
import '../../core/providers/usecase_providers.dart';
import '../../core/usecases/training/save_workout_usecase.dart';
import '../../shared/theme/design_tokens.dart';
import '../../shared/widgets/single_select_options.dart';

/// 快速记录页面
/// 快速添加运动记录
class QuickLogPage extends ConsumerStatefulWidget {
  const QuickLogPage({super.key});

  @override
  ConsumerState<QuickLogPage> createState() => _QuickLogPageState();
}

class _QuickLogPageState extends ConsumerState<QuickLogPage> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedType = 'cycling';
  int _durationMinutes = 30;
  String _selectedIntensity = 'moderate';
  String? _note;
  bool _isGoalCompleted = false;

  final List<Map<String, dynamic>> _workoutTypes = [
    {'value': 'cycling', 'label': '骑行', 'icon': Icons.directions_bike},
    {'value': 'jump_rope', 'label': '跳绳', 'icon': Icons.sports},
    {'value': 'walking', 'label': '步行', 'icon': Icons.directions_walk},
    {'value': 'yoga', 'label': '瑜伽', 'icon': Icons.self_improvement},
    {'value': 'stretching', 'label': '拉伸', 'icon': Icons.accessibility},
    {'value': 'custom', 'label': '自定义', 'icon': Icons.sports_handball},
  ];

  final List<Map<String, dynamic>> _intensityLevels = [
    {'value': 'light', 'label': '轻度', 'color': Colors.green},
    {'value': 'moderate', 'label': '中度', 'color': Colors.orange},
    {'value': 'high', 'label': '高强度', 'color': Colors.red},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('快速记录')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildDateTimeSection(),
            const SizedBox(height: 16),
            _buildTypeSection(),
            const SizedBox(height: 16),
            _buildDurationSection(),
            const SizedBox(height: 16),
            _buildIntensitySection(),
            const SizedBox(height: 16),
            _buildNoteSection(),
            const SizedBox(height: 16),
            _buildGoalCompletedSection(),
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  /// 日期时间部分
  Widget _buildDateTimeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '日期时间',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                    onTap: _selectDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(_selectedTime.format(context)),
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 运动类型部分 - 使用 2x3 网格避免不均匀换行
  Widget _buildTypeSection() {
    final typeOptions = _workoutTypes
        .map((t) => SelectOption<String>(
              value: t['value'] as String,
              label: t['label'] as String,
              icon: t['icon'] as IconData,
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '运动类型',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            SingleSelectGrid<String>(
              options: typeOptions,
              selected: _selectedType,
              columns: 3,
              onChanged: (value) {
                setState(() => _selectedType = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 时长部分
  Widget _buildDurationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '时长',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (_durationMinutes > 5) {
                      setState(() => _durationMinutes -= 5);
                    }
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Expanded(
                  child: Text(
                    '$_durationMinutes 分钟',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() => _durationMinutes += 5);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            Slider(
              value: _durationMinutes.toDouble(),
              min: 5,
              max: 180,
              divisions: 35,
              label: '$_durationMinutes 分钟',
              onChanged: (value) {
                setState(() => _durationMinutes = value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 强度部分 - 使用 SegmentedButton (3 个选项)
  Widget _buildIntensitySection() {
    final intensityOptions = _intensityLevels
        .map((l) => SelectOption<String>(
              value: l['value'] as String,
              label: l['label'] as String,
            ))
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '运动强度',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            SingleSelectSegmented<String>(
              options: intensityOptions,
              selected: _selectedIntensity,
              onChanged: (value) {
                setState(() => _selectedIntensity = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 备注部分
  Widget _buildNoteSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '备注',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '添加备注（可选）',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _note = value,
            ),
          ],
        ),
      ),
    );
  }

  /// 目标完成部分
  Widget _buildGoalCompletedSection() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Icon(Icons.emoji_events, color: colorScheme.tertiary),
            const SizedBox(width: AppSpacing.md),
            const Expanded(
              child: Text('完成今日目标', style: TextStyle(fontSize: 16)),
            ),
            Switch(
              value: _isGoalCompleted,
              onChanged: (value) {
                setState(() => _isGoalCompleted = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 提交按钮
  Widget _buildSubmitButton() {
    return Consumer(
      builder: (context, ref, child) {
        return FilledButton.icon(
          onPressed: () => _submit(ref),
          icon: const Icon(Icons.save),
          label: const Text('保存记录', style: TextStyle(fontSize: 18)),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          ),
        );
      },
    );
  }

  /// 选择日期
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  /// 选择时间
  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  /// 提交表单
  Future<void> _submit(WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) return;

    final datetime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      final result = await ref.read(saveWorkoutUseCaseProvider)(
        SaveWorkoutParams(
          datetime: datetime,
          type: _selectedType,
          durationMinutes: _durationMinutes,
          intensity: _selectedIntensity,
          note: _note,
          isGoalCompleted: _isGoalCompleted,
        ),
      );
      if (result.$1 != SaveWorkoutResult.success) {
        throw StateError('保存失败');
      }

      // 刷新训练记录流，确保列表页能看到新数据
      ref.invalidate(trainingSessionsStreamProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('记录已保存')));

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
    }
  }
}
