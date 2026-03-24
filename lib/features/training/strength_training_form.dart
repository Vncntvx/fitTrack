import 'package:flutter/material.dart';

import '../../core/database/database.dart';

/// 力量训练详情表单
/// 用于记录力量训练的组数、次数、重量等
class StrengthTrainingForm extends StatefulWidget {
  final List<StrengthExerciseEntry> initialExercises;
  final Function(List<StrengthExerciseEntry>) onChanged;

  const StrengthTrainingForm({
    super.key,
    this.initialExercises = const [],
    required this.onChanged,
  });

  @override
  State<StrengthTrainingForm> createState() => _StrengthTrainingFormState();
}

class _StrengthTrainingFormState extends State<StrengthTrainingForm> {
  late List<Map<String, dynamic>> _exercises;

  /// 重量输入控制器，避免每次 build 创建新控制器导致光标重置
  final Map<int, TextEditingController> _weightControllers = {};

  final List<String> _commonExercises = [
    '深蹲',
    '卧推',
    '硬拉',
    '引体向上',
    '俯卧撑',
    '哑铃弯举',
    '肩上推举',
    '腿举',
    '划船',
    '卷腹',
  ];

  @override
  void initState() {
    super.initState();
    _exercises = widget.initialExercises.asMap().entries.map((entry) {
      final e = entry.value;
      // 初始化重量输入控制器
      _weightControllers[entry.key] = TextEditingController(
        text: e.defaultWeight?.toString() ?? '',
      );
      return {
        'id': e.id,
        'name': e.exerciseName,
        'sets': e.sets,
        'reps': e.defaultReps,
        'weight': e.defaultWeight,
      };
    }).toList();
  }

  @override
  void dispose() {
    // 释放所有控制器
    for (final controller in _weightControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  '力量训练详情',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addExercise,
                  icon: const Icon(Icons.add),
                  label: const Text('添加练习'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_exercises.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    '点击"添加练习"记录力量训练',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ..._exercises.asMap().entries.map((entry) {
                return _buildExerciseItem(entry.key, entry.value);
              }),
          ],
        ),
      ),
    );
  }

  /// 构建练习项
  Widget _buildExerciseItem(int index, Map<String, dynamic> exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildNameField(index, exercise)),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeExercise(index),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNumberField(
                    '组数',
                    exercise['sets']?.toString() ?? '3',
                    (value) => _updateExercise(
                      index,
                      'sets',
                      int.tryParse(value) ?? 3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildNumberField(
                    '次数',
                    exercise['reps']?.toString() ?? '10',
                    (value) => _updateExercise(
                      index,
                      'reps',
                      int.tryParse(value) ?? 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildWeightField(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建名称输入字段
  Widget _buildNameField(int index, Map<String, dynamic> exercise) {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: exercise['name'] ?? ''),
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _commonExercises;
        }
        return _commonExercises.where((option) {
          return option.toLowerCase().contains(
            textEditingValue.text.toLowerCase(),
          );
        });
      },
      onSelected: (value) {
        _updateExercise(index, 'name', value);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(
            labelText: '练习名称',
            hintText: '输入练习名称',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _updateExercise(index, 'name', value);
          },
        );
      },
    );
  }

  /// 构建数字输入字段
  Widget _buildNumberField(
    String label,
    String initialValue,
    Function(String) onChanged, {
    bool isOptional = false,
  }) {
    return TextField(
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: initialValue),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }

  /// 构建重量输入字段（使用持久的 TextEditingController 避免光标重置）
  Widget _buildWeightField(int index) {
    // 确保控制器存在
    _weightControllers.putIfAbsent(
      index,
      () => TextEditingController(),
    );

    return TextField(
      keyboardType: TextInputType.number,
      controller: _weightControllers[index],
      decoration: const InputDecoration(
        labelText: '重量(kg)',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        _updateExercise(index, 'weight', double.tryParse(value));
      },
    );
  }

  /// 添加练习
  void _addExercise() {
    setState(() {
      _exercises.add({'name': '', 'sets': 3, 'reps': 10, 'weight': null});
    });
    _notifyChange();
  }

  /// 删除练习
  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
      // 释放被删除项的控制器
      _weightControllers[index]?.dispose();
      _weightControllers.remove(index);
      // 重建控制器映射以匹配新索引
      final newControllers = <int, TextEditingController>{};
      for (final entry in _weightControllers.entries) {
        if (entry.key < index) {
          newControllers[entry.key] = entry.value;
        } else if (entry.key > index) {
          newControllers[entry.key - 1] = entry.value;
        }
      }
      _weightControllers
        ..clear()
        ..addAll(newControllers);
    });
    _notifyChange();
  }

  /// 更新练习
  void _updateExercise(int index, String field, dynamic value) {
    setState(() {
      _exercises[index][field] = value;
    });
    _notifyChange();
  }

  /// 通知变更
  void _notifyChange() {
    final entries = _exercises.asMap().entries.map((entry) {
      return StrengthExerciseEntry(
        id: entry.value['id'] ?? 0,
        sessionId: 0, // 将由 Repository 设置
        exerciseName: entry.value['name'] ?? '',
        sets: entry.value['sets'] ?? 3,
        defaultReps: entry.value['reps'] ?? 10,
        defaultWeight: entry.value['weight'],
        isWarmup: false,
        sortOrder: entry.key,
      );
    }).toList();

    widget.onChanged(entries);
  }
}
