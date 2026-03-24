import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_database_provider.dart';
import '../../../core/database/database.dart';
import '../../../core/providers/usecase_providers.dart';
import '../../../core/usecases/training/save_strength_session_usecase.dart';

/// 力量训练会话状态
class StrengthSessionState {
  final int? sessionId;
  final int? templateId;
  final DateTime startTime;
  final bool isRunning;
  final int elapsedSeconds;
  final List<ExerciseSetGroup> exercises;
  final int? restingExerciseIndex;
  final int restRemainingSeconds;

  const StrengthSessionState({
    this.sessionId,
    this.templateId,
    required this.startTime,
    this.isRunning = false,
    this.elapsedSeconds = 0,
    this.exercises = const [],
    this.restingExerciseIndex,
    this.restRemainingSeconds = 0,
  });

  StrengthSessionState copyWith({
    int? sessionId,
    int? templateId,
    DateTime? startTime,
    bool? isRunning,
    int? elapsedSeconds,
    List<ExerciseSetGroup>? exercises,
    int? restingExerciseIndex,
    int? restRemainingSeconds,
    bool clearResting = false,
  }) {
    return StrengthSessionState(
      sessionId: sessionId ?? this.sessionId,
      templateId: templateId ?? this.templateId,
      startTime: startTime ?? this.startTime,
      isRunning: isRunning ?? this.isRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      exercises: exercises ?? this.exercises,
      restingExerciseIndex: clearResting
          ? null
          : (restingExerciseIndex ?? this.restingExerciseIndex),
      restRemainingSeconds: restRemainingSeconds ?? this.restRemainingSeconds,
    );
  }

  /// 计算总训练容量（重量 × 次数 × 组数）
  double get totalVolume {
    double volume = 0;
    for (final exercise in exercises) {
      for (int i = 0; i < exercise.sets.length; i++) {
        if (exercise.sets[i].completed) {
          // 安全检查数组边界
          final weight = (exercise.weightPerSet.length > i)
              ? exercise.weightPerSet[i]
              : exercise.defaultWeight;
          final reps = (exercise.repsPerSet.length > i)
              ? exercise.repsPerSet[i]
              : exercise.defaultReps;
          volume += weight * reps;
        }
      }
    }
    return volume;
  }

  /// 已完成的组数
  int get completedSets {
    int count = 0;
    for (final exercise in exercises) {
      for (final set in exercise.sets) {
        if (set.completed) count++;
      }
    }
    return count;
  }

  /// 总组数
  int get totalSets {
    int count = 0;
    for (final exercise in exercises) {
      count += exercise.sets.length;
    }
    return count;
  }
}

/// 动作组数据
class ExerciseSetGroup {
  final int? entryId;
  final int? exerciseId;
  final String name;
  final int defaultSets;
  final int defaultReps;
  final double defaultWeight;
  final List<SetData> sets;
  final List<double> weightPerSet;
  final List<int> repsPerSet;
  final bool isExpanded;

  const ExerciseSetGroup({
    this.entryId,
    this.exerciseId,
    required this.name,
    this.defaultSets = 3,
    this.defaultReps = 10,
    this.defaultWeight = 0,
    this.sets = const [],
    this.weightPerSet = const [],
    this.repsPerSet = const [],
    this.isExpanded = true,
  });

  ExerciseSetGroup copyWith({
    int? entryId,
    int? exerciseId,
    String? name,
    int? defaultSets,
    int? defaultReps,
    double? defaultWeight,
    List<SetData>? sets,
    List<double>? weightPerSet,
    List<int>? repsPerSet,
    bool? isExpanded,
  }) {
    return ExerciseSetGroup(
      entryId: entryId ?? this.entryId,
      exerciseId: exerciseId ?? this.exerciseId,
      name: name ?? this.name,
      defaultSets: defaultSets ?? this.defaultSets,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      sets: sets ?? this.sets,
      weightPerSet: weightPerSet ?? this.weightPerSet,
      repsPerSet: repsPerSet ?? this.repsPerSet,
      isExpanded: isExpanded ?? this.isExpanded,
    );
  }
}

/// 单组数据
class SetData {
  final int setIndex;
  final bool completed;
  final int? rpe;
  final int? restSeconds;

  const SetData({
    required this.setIndex,
    this.completed = false,
    this.rpe,
    this.restSeconds,
  });

  SetData copyWith({
    int? setIndex,
    bool? completed,
    int? rpe,
    int? restSeconds,
  }) {
    return SetData(
      setIndex: setIndex ?? this.setIndex,
      completed: completed ?? this.completed,
      rpe: rpe ?? this.rpe,
      restSeconds: restSeconds ?? this.restSeconds,
    );
  }
}

/// 训练会话状态管理
class StrengthSessionNotifier extends StateNotifier<StrengthSessionState> {
  final Ref _ref;
  Timer? _timer;
  Timer? _restTimer;

  StrengthSessionNotifier(this._ref)
    : super(StrengthSessionState(startTime: DateTime.now()));

  /// 开始训练计时
  void startTimer() {
    if (_timer != null) return;

    state = state.copyWith(isRunning: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
  }

  /// 暂停计时
  void pauseTimer() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isRunning: false);
  }

  /// 切换计时状态
  void toggleTimer() {
    if (state.isRunning) {
      pauseTimer();
    } else {
      startTimer();
    }
  }

  /// 开始休息计时
  void startRestTimer(int exerciseIndex, int seconds) {
    state = state.copyWith(
      restingExerciseIndex: exerciseIndex,
      restRemainingSeconds: seconds,
    );
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.restRemainingSeconds <= 1) {
        _restTimer?.cancel();
        _restTimer = null;
        state = state.copyWith(clearResting: true, restRemainingSeconds: 0);
      } else {
        state = state.copyWith(
          restRemainingSeconds: state.restRemainingSeconds - 1,
        );
      }
    });
  }

  /// 取消休息计时
  void cancelRestTimer() {
    _restTimer?.cancel();
    _restTimer = null;
    state = state.copyWith(clearResting: true, restRemainingSeconds: 0);
  }

  /// 添加动作
  void addExercise(Exercise exercise) {
    final sets = List.generate(
      exercise.defaultSets,
      (i) => SetData(setIndex: i),
    );
    final weightPerSet = List.generate(
      exercise.defaultSets,
      (i) => exercise.defaultWeight ?? 0,
    );
    final repsPerSet = List.generate(
      exercise.defaultSets,
      (i) => exercise.defaultReps,
    );

    final newExercise = ExerciseSetGroup(
      exerciseId: exercise.id,
      name: exercise.name,
      defaultSets: exercise.defaultSets,
      defaultReps: exercise.defaultReps,
      defaultWeight: exercise.defaultWeight ?? 0,
      sets: sets,
      weightPerSet: weightPerSet,
      repsPerSet: repsPerSet,
    );

    state = state.copyWith(exercises: [...state.exercises, newExercise]);
  }

  /// 设置来源模板
  void setTemplateId(int? templateId) {
    state = state.copyWith(templateId: templateId);
  }

  /// 添加自定义动作
  void addCustomExercise(String name, int sets, int reps, double weight) {
    final setData = List.generate(sets, (i) => SetData(setIndex: i));
    final weightPerSet = List.generate(sets, (i) => weight);
    final repsPerSet = List.generate(sets, (i) => reps);

    final newExercise = ExerciseSetGroup(
      name: name,
      defaultSets: sets,
      defaultReps: reps,
      defaultWeight: weight,
      sets: setData,
      weightPerSet: weightPerSet,
      repsPerSet: repsPerSet,
    );

    state = state.copyWith(exercises: [...state.exercises, newExercise]);
  }

  /// 删除动作
  void removeExercise(int index) {
    final newExercises = List<ExerciseSetGroup>.from(state.exercises);
    newExercises.removeAt(index);
    state = state.copyWith(exercises: newExercises);
  }

  /// 切换动作展开状态
  void toggleExerciseExpanded(int index) {
    final newExercises = List<ExerciseSetGroup>.from(state.exercises);
    newExercises[index] = newExercises[index].copyWith(
      isExpanded: !newExercises[index].isExpanded,
    );
    state = state.copyWith(exercises: newExercises);
  }

  /// 更新组完成状态
  void updateSetCompletion(int exerciseIndex, int setIndex, bool completed) {
    final newExercises = List<ExerciseSetGroup>.from(state.exercises);
    final exercise = newExercises[exerciseIndex];
    final newSets = List<SetData>.from(exercise.sets);
    newSets[setIndex] = newSets[setIndex].copyWith(completed: completed);
    newExercises[exerciseIndex] = exercise.copyWith(sets: newSets);
    state = state.copyWith(exercises: newExercises);

    // 如果完成了组，开始休息计时
    if (completed && exerciseIndex < state.exercises.length - 1) {
      final restSeconds = newSets[setIndex].restSeconds ?? 90;
      startRestTimer(exerciseIndex, restSeconds);
    }
  }

  /// 更新组RPE
  void updateSetRpe(int exerciseIndex, int setIndex, int rpe) {
    final newExercises = List<ExerciseSetGroup>.from(state.exercises);
    final exercise = newExercises[exerciseIndex];
    final newSets = List<SetData>.from(exercise.sets);
    newSets[setIndex] = newSets[setIndex].copyWith(rpe: rpe);
    newExercises[exerciseIndex] = exercise.copyWith(sets: newSets);
    state = state.copyWith(exercises: newExercises);
  }

  /// 更新组休息时间
  void updateSetRestSeconds(int exerciseIndex, int setIndex, int seconds) {
    final newExercises = List<ExerciseSetGroup>.from(state.exercises);
    final exercise = newExercises[exerciseIndex];
    final newSets = List<SetData>.from(exercise.sets);
    newSets[setIndex] = newSets[setIndex].copyWith(restSeconds: seconds);
    newExercises[exerciseIndex] = exercise.copyWith(sets: newSets);
    state = state.copyWith(exercises: newExercises);
  }

  /// 更新组重量
  void updateSetWeight(int exerciseIndex, int setIndex, double weight) {
    final newExercises = List<ExerciseSetGroup>.from(state.exercises);
    final exercise = newExercises[exerciseIndex];
    final newWeightPerSet = List<double>.from(exercise.weightPerSet);
    if (setIndex < newWeightPerSet.length) {
      newWeightPerSet[setIndex] = weight;
    }
    newExercises[exerciseIndex] = exercise.copyWith(
      weightPerSet: newWeightPerSet,
    );
    state = state.copyWith(exercises: newExercises);
  }

  /// 更新组次数
  void updateSetReps(int exerciseIndex, int setIndex, int reps) {
    final newExercises = List<ExerciseSetGroup>.from(state.exercises);
    final exercise = newExercises[exerciseIndex];
    final newRepsPerSet = List<int>.from(exercise.repsPerSet);
    if (setIndex < newRepsPerSet.length) {
      newRepsPerSet[setIndex] = reps;
    }
    newExercises[exerciseIndex] = exercise.copyWith(repsPerSet: newRepsPerSet);
    state = state.copyWith(exercises: newExercises);
  }

  /// 添加组
  void addSet(int exerciseIndex) {
    final newExercises = List<ExerciseSetGroup>.from(state.exercises);
    final exercise = newExercises[exerciseIndex];
    final newSets = [...exercise.sets, SetData(setIndex: exercise.sets.length)];
    final newWeightPerSet = [...exercise.weightPerSet, exercise.defaultWeight];
    final newRepsPerSet = [...exercise.repsPerSet, exercise.defaultReps];
    newExercises[exerciseIndex] = exercise.copyWith(
      sets: newSets,
      weightPerSet: newWeightPerSet,
      repsPerSet: newRepsPerSet,
      defaultSets: exercise.defaultSets + 1,
    );
    state = state.copyWith(exercises: newExercises);
  }

  /// 删除组
  void removeSet(int exerciseIndex, int setIndex) {
    final newExercises = List<ExerciseSetGroup>.from(state.exercises);
    final exercise = newExercises[exerciseIndex];
    if (exercise.sets.length <= 1) return;

    final newSets = List<SetData>.from(exercise.sets)..removeAt(setIndex);
    final newWeightPerSet = List<double>.from(exercise.weightPerSet)
      ..removeAt(setIndex);
    final newRepsPerSet = List<int>.from(exercise.repsPerSet)
      ..removeAt(setIndex);

    // 重新索引
    for (int i = 0; i < newSets.length; i++) {
      newSets[i] = newSets[i].copyWith(setIndex: i);
    }

    newExercises[exerciseIndex] = exercise.copyWith(
      sets: newSets,
      weightPerSet: newWeightPerSet,
      repsPerSet: newRepsPerSet,
      defaultSets: exercise.defaultSets - 1,
    );
    state = state.copyWith(exercises: newExercises);
  }

  /// 从已有会话加载
  Future<void> loadFromSession(TrainingSession session) async {
    final strengthRepo = _ref.read(strengthEntryRepositoryProvider);

    final entries = await strengthRepo.getStrengthExercises(session.id);
    final exercises = entries.map((entry) {
      final repsPerSet = entry.repsPerSet != null
          ? (jsonDecode(entry.repsPerSet!) as List<dynamic>)
                .map((v) => (v as num).toInt())
                .toList()
          : List<int>.generate(entry.sets, (_) => entry.defaultReps);
      final weightPerSet = entry.weightPerSet != null
          ? (jsonDecode(entry.weightPerSet!) as List<dynamic>)
                .map((v) => (v as num).toDouble())
                .toList()
          : List<double>.generate(entry.sets, (_) => entry.defaultWeight ?? 0);
      final completedList = entry.setCompleted != null
          ? (jsonDecode(entry.setCompleted!) as List<dynamic>)
                .map((v) => v as bool)
                .toList()
          : List<bool>.generate(entry.sets, (_) => false);

      final sets = List.generate(entry.sets, (i) {
        return SetData(
          setIndex: i,
          completed: i < completedList.length ? completedList[i] : false,
          rpe: entry.rpe,
          restSeconds: entry.restSeconds,
        );
      });

      return ExerciseSetGroup(
        entryId: entry.id,
        exerciseId: entry.exerciseId,
        name: entry.exerciseName,
        defaultSets: entry.sets,
        defaultReps: entry.defaultReps,
        defaultWeight: entry.defaultWeight ?? 0,
        sets: sets,
        weightPerSet: weightPerSet,
        repsPerSet: repsPerSet,
      );
    }).toList();

    state = StrengthSessionState(
      sessionId: session.id,
      templateId: session.templateId,
      startTime: session.datetime,
      elapsedSeconds: session.durationMinutes * 60,
      exercises: exercises,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }
}

/// 训练会话 Provider
final strengthSessionProvider =
    StateNotifierProvider.autoDispose<
      StrengthSessionNotifier,
      StrengthSessionState
    >((ref) {
      return StrengthSessionNotifier(ref);
    });

/// 力量训练会话页面
class StrengthSessionPage extends ConsumerStatefulWidget {
  final int? sessionId;
  final int? templateId;

  const StrengthSessionPage({super.key, this.sessionId, this.templateId});

  @override
  ConsumerState<StrengthSessionPage> createState() =>
      _StrengthSessionPageState();
}

class _StrengthSessionPageState extends ConsumerState<StrengthSessionPage> {
  bool _isLoading = false;
  bool _templateApplied = false;
  bool _isReadOnly = false; // 只读模式：查看历史记录时默认只读
  final Map<String, TextEditingController> _weightControllers = {};
  final Map<String, TextEditingController> _repsControllers = {};

  @override
  void initState() {
    super.initState();
    if (widget.sessionId != null) {
      _loadSession();
    } else if (widget.templateId != null) {
      _applyTemplate(widget.templateId!);
    }
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(trainingRepositoryProvider);
      final session = await repo.getById(widget.sessionId!);
      if (session != null && mounted) {
        await ref
            .read(strengthSessionProvider.notifier)
            .loadFromSession(session);
        // 加载历史记录时默认进入只读模式
        setState(() => _isReadOnly = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _applyTemplate(int templateId) async {
    setState(() => _isLoading = true);
    try {
      final templateRepo = ref.read(templateRepositoryProvider);
      final detail = await templateRepo.getTemplateDetail(templateId);
      if (detail == null) return;

      final notifier = ref.read(strengthSessionProvider.notifier);
      notifier.setTemplateId(templateId);
      for (final item in detail.exercises) {
        notifier.addCustomExercise(
          item.exerciseName,
          item.sets,
          item.reps,
          item.weight ?? 0,
        );
      }
      _templateApplied = true;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _weightControllers.values) {
      controller.dispose();
    }
    for (final controller in _repsControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(strengthSessionProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('健身训练')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmation(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isReadOnly ? '训练详情' : '健身训练'),
          actions: [
            if (_isReadOnly)
              TextButton(
                onPressed: () => setState(() => _isReadOnly = false),
                child: const Text('编辑'),
              )
            else if (state.exercises.isNotEmpty)
              TextButton(
                onPressed: () => _showCompleteDialog(context),
                child: const Text('完成'),
              ),
          ],
        ),
        body: Column(
          children: [
            if (_templateApplied)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Card(
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.description),
                    title: Text('已加载模板动作'),
                  ),
                ),
              ),
            _buildTimerCard(state),
            _buildStatsRow(state),
            Expanded(child: _buildExerciseList(state)),
            if (!_isReadOnly) ...[
              _buildRestTimer(state),
              _buildAddExerciseButton(),
            ],
          ],
        ),
      ),
    );
  }

  /// 计时器卡片
  Widget _buildTimerCard(StrengthSessionState state) {
    final hours = state.elapsedSeconds ~/ 3600;
    final minutes = (state.elapsedSeconds % 3600) ~/ 60;
    final seconds = state.elapsedSeconds % 60;
    final timeStr = hours > 0
        ? '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}'
        : '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isRunning ? Icons.pause_circle : Icons.play_circle,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Text(
              timeStr,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
            // 只读模式下隐藏计时器控制按钮
            if (!_isReadOnly) ...[
              const SizedBox(width: 16),
              IconButton(
                onPressed: () =>
                    ref.read(strengthSessionProvider.notifier).toggleTimer(),
                icon: Icon(
                  state.isRunning ? Icons.pause : Icons.play_arrow,
                  size: 32,
                ),
                tooltip: state.isRunning ? '暂停' : '开始',
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 统计行
  Widget _buildStatsRow(StrengthSessionState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            '容量',
            '${state.totalVolume.toStringAsFixed(1)} kg',
            Icons.fitness_center,
          ),
          _buildStatItem(
            '组数',
            '${state.completedSets}/${state.totalSets}',
            Icons.checklist,
          ),
          _buildStatItem('动作', '${state.exercises.length}', Icons.list),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  /// 动作列表
  Widget _buildExerciseList(StrengthSessionState state) {
    if (state.exercises.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fitness_center, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '点击下方按钮添加动作',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.exercises.length,
      itemBuilder: (context, index) {
        return _buildExerciseCard(state.exercises[index], index);
      },
    );
  }

  /// 动作卡片
  Widget _buildExerciseCard(ExerciseSetGroup exercise, int exerciseIndex) {
    final notifier = ref.read(strengthSessionProvider.notifier);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          // 动作标题行
          ListTile(
            title: Text(
              exercise.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${exercise.sets.length}组 × 默认${exercise.defaultReps}次 ${exercise.defaultWeight > 0 ? "× ${exercise.defaultWeight}kg" : ""}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    exercise.isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                  ),
                  onPressed: () =>
                      notifier.toggleExerciseExpanded(exerciseIndex),
                ),
                // 只读模式下隐藏删除按钮
                if (!_isReadOnly)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDeleteExercise(exerciseIndex),
                  ),
              ],
            ),
            onTap: () => notifier.toggleExerciseExpanded(exerciseIndex),
          ),
          // 展开的组列表
          if (exercise.isExpanded) ...[
            const Divider(height: 1),
            ...List.generate(exercise.sets.length, (setIndex) {
              return _buildSetRow(exercise, exerciseIndex, setIndex);
            }),
            // 只读模式下隐藏添加组按钮
            if (!_isReadOnly)
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton.icon(
                  onPressed: () => notifier.addSet(exerciseIndex),
                  icon: const Icon(Icons.add),
                  label: const Text('添加组'),
                ),
              ),
          ],
        ],
      ),
    );
  }

  /// 组行
  Widget _buildSetRow(
    ExerciseSetGroup exercise,
    int exerciseIndex,
    int setIndex,
  ) {
    final set = exercise.sets[setIndex];
    final weight = setIndex < exercise.weightPerSet.length
        ? exercise.weightPerSet[setIndex]
        : exercise.defaultWeight;
    final reps = setIndex < exercise.repsPerSet.length
        ? exercise.repsPerSet[setIndex]
        : exercise.defaultReps;
    final notifier = ref.read(strengthSessionProvider.notifier);
    final rowKey =
        '${exercise.entryId ?? exercise.name}_${exerciseIndex}_$setIndex';
    final weightController = _weightControllers.putIfAbsent(
      rowKey,
      () => TextEditingController(text: weight > 0 ? weight.toString() : ''),
    );
    final repsController = _repsControllers.putIfAbsent(
      rowKey,
      () => TextEditingController(text: reps.toString()),
    );
    final currentWeight = double.tryParse(weightController.text);
    if (currentWeight != weight &&
        !(weight == 0 && weightController.text.isEmpty)) {
      final weightText = weight > 0 ? weight.toString() : '';
      weightController.text = weightText;
      weightController.selection = TextSelection.fromPosition(
        TextPosition(offset: weightController.text.length),
      );
    }
    final currentReps = int.tryParse(repsController.text);
    if (currentReps != reps) {
      repsController.text = reps.toString();
      repsController.selection = TextSelection.fromPosition(
        TextPosition(offset: repsController.text.length),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: set.completed ? Colors.green.withAlpha(26) : null,
        border: Border(bottom: BorderSide(color: Colors.grey.withAlpha(51))),
      ),
      child: Row(
        children: [
          // 完成状态（只读模式下显示图标而非复选框）
          if (_isReadOnly)
            Icon(
              set.completed ? Icons.check_circle : Icons.radio_button_unchecked,
              color: set.completed ? Colors.green : Colors.grey,
            )
          else
            Checkbox(
              value: set.completed,
              onChanged: (value) {
                notifier.updateSetCompletion(
                  exerciseIndex,
                  setIndex,
                  value ?? false,
                );
              },
            ),
          // 组号
          SizedBox(
            width: 40,
            child: Text(
              '第${setIndex + 1}组',
              style: TextStyle(
                fontWeight: set.completed ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 重量（只读模式下显示文本）
          SizedBox(
            width: 70,
            child: _isReadOnly
                ? Text(
                    weight > 0 ? '${weight}kg' : '-',
                    style: const TextStyle(fontSize: 14),
                  )
                : TextField(
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    controller: weightController,
                    decoration: const InputDecoration(
                      hintText: '重量',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onChanged: (value) {
                      // 实时保存，避免输入丢失
                      final w = double.tryParse(value);
                      if (w != null && w >= 0) {
                        notifier.updateSetWeight(exerciseIndex, setIndex, w);
                      }
                    },
                  ),
          ),
          const SizedBox(width: 8),
          // 次数（只读模式下显示文本）
          SizedBox(
            width: 50,
            child: _isReadOnly
                ? Text(
                    '$reps次',
                    style: const TextStyle(fontSize: 14),
                  )
                : TextField(
                    keyboardType: TextInputType.number,
                    controller: repsController,
                    decoration: const InputDecoration(
                      hintText: '次数',
                      isDense: true,
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(fontSize: 14),
                    onChanged: (value) {
                      // 实时保存，避免输入丢失
                      final r = int.tryParse(value);
                      if (r != null && r >= 0) {
                        notifier.updateSetReps(exerciseIndex, setIndex, r);
                      }
                    },
                  ),
          ),
          const SizedBox(width: 8),
          // RPE 选择器（只读模式下显示文本）
          if (!_isReadOnly) _buildRpeSelector(exerciseIndex, setIndex, set.rpe),
          // 只读模式下显示 RPE
          if (_isReadOnly && set.rpe != null)
            Text(
              'RPE ${set.rpe}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          const SizedBox(width: 8),
          // 删除组（只读模式下隐藏）
          if (!_isReadOnly)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.grey),
              onPressed: () => notifier.removeSet(exerciseIndex, setIndex),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  /// RPE 选择器
  Widget _buildRpeSelector(int exerciseIndex, int setIndex, int? currentRpe) {
    return GestureDetector(
      onTap: () => _showRpePicker(exerciseIndex, setIndex, currentRpe),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          currentRpe != null ? 'RPE $currentRpe' : 'RPE',
          style: TextStyle(
            fontSize: 12,
            color: currentRpe != null ? null : Colors.grey,
          ),
        ),
      ),
    );
  }

  /// 显示 RPE 选择器
  void _showRpePicker(int exerciseIndex, int setIndex, int? currentRpe) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择 RPE (主观强度感受)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(10, (index) {
                  final rpe = index + 1;
                  final isSelected = currentRpe == rpe;
                  return ChoiceChip(
                    label: Text('$rpe'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        ref
                            .read(strengthSessionProvider.notifier)
                            .updateSetRpe(exerciseIndex, setIndex, rpe);
                      }
                      Navigator.pop(context);
                    },
                  );
                }),
              ),
              const SizedBox(height: 8),
              const Text(
                '1-3: 很轻松 | 4-6: 中等 | 7-8: 较难 | 9-10: 极限',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 休息计时器
  Widget _buildRestTimer(StrengthSessionState state) {
    if (state.restingExerciseIndex == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('休息中...', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            '${state.restRemainingSeconds}秒',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          TextButton(
            onPressed: () =>
                ref.read(strengthSessionProvider.notifier).cancelRestTimer(),
            child: const Text('跳过'),
          ),
        ],
      ),
    );
  }

  /// 添加动作按钮
  Widget _buildAddExerciseButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: _showAddExerciseSheet,
        icon: const Icon(Icons.add),
        label: const Text('添加动作'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  /// 显示添加动作面板
  void _showAddExerciseSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return _AddExerciseSheet(scrollController: scrollController);
          },
        );
      },
    );
  }

  /// 确认删除动作
  void _confirmDeleteExercise(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('删除动作'),
          content: const Text('确定要删除这个动作吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                ref
                    .read(strengthSessionProvider.notifier)
                    .removeExercise(index);
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }

  /// 显示完成对话框
  void _showCompleteDialog(BuildContext context) {
    String intensity = 'moderate';
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('完成训练'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('运动强度'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('轻度'),
                        selected: intensity == 'light',
                        onSelected: (selected) {
                          setDialogState(() => intensity = 'light');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('中度'),
                        selected: intensity == 'moderate',
                        onSelected: (selected) {
                          setDialogState(() => intensity = 'moderate');
                        },
                      ),
                      ChoiceChip(
                        label: const Text('高强度'),
                        selected: intensity == 'high',
                        onSelected: (selected) {
                          setDialogState(() => intensity = 'high');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: '备注（可选）',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _completeTraining(intensity, noteController.text);
                  },
                  child: const Text('保存'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 完成训练
  Future<void> _completeTraining(String intensity, String? note) async {
    final wasEditing = ref.read(strengthSessionProvider).sessionId != null;
    final notifier = ref.read(strengthSessionProvider.notifier);
    notifier.pauseTimer();
    notifier.cancelRestTimer();
    final state = ref.read(strengthSessionProvider);
    final useCase = ref.read(saveStrengthSessionUseCaseProvider);
    await useCase(
      SaveStrengthSessionParams(
        sessionId: state.sessionId,
        templateId: state.templateId,
        startTime: state.startTime,
        elapsedSeconds: state.elapsedSeconds,
        intensity: intensity,
        note: note,
        exercises: state.exercises
            .map(
              (exercise) => StrengthExerciseInput(
                exerciseId: exercise.exerciseId,
                exerciseName: exercise.name,
                defaultReps: exercise.defaultReps,
                defaultWeight: exercise.defaultWeight,
                repsPerSet: exercise.repsPerSet,
                weightPerSet: exercise.weightPerSet,
                completedSets: exercise.sets
                    .map((set) => set.completed)
                    .toList(),
                rpeValues: exercise.sets.map((set) => set.rpe).toList(),
                restSecondsValues: exercise.sets
                    .map((set) => set.restSeconds)
                    .toList(),
              ),
            )
            .toList(),
      ),
    );

    // 刷新训练记录和动作列表
    ref.invalidate(trainingSessionsStreamProvider);
    ref.invalidate(exercisesStreamProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasEditing ? '训练已更新' : '训练已保存'),
        ),
      );
      context.go('/records');
    }
  }

  /// 退出确认
  Future<bool> _showExitConfirmation(BuildContext context) async {
    final state = ref.read(strengthSessionProvider);
    if (state.exercises.isEmpty && state.elapsedSeconds < 60) {
      return true;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('退出训练'),
          content: const Text('当前训练尚未保存，确定要退出吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('继续训练'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('放弃'),
            ),
          ],
        );
      },
    );

    return shouldExit ?? false;
  }
}

/// 添加动作面板
class _AddExerciseSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const _AddExerciseSheet({required this.scrollController});

  @override
  ConsumerState<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends ConsumerState<_AddExerciseSheet> {
  String _searchQuery = '';
  String? _selectedCategory;
  bool _showCustomForm = false;

  final _nameController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _repsController = TextEditingController(text: '10');
  final _weightController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'value': 'chest', 'label': '胸'},
    {'value': 'back', 'label': '背'},
    {'value': 'shoulders', 'label': '肩'},
    {'value': 'arms', 'label': '臂'},
    {'value': 'legs', 'label': '腿'},
    {'value': 'core', 'label': '核心'},
  ];

  @override
  Widget build(BuildContext context) {
    if (_showCustomForm) {
      return _buildCustomForm();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '添加动作',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _showCustomForm = true),
                icon: const Icon(Icons.add),
                label: const Text('自定义'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 搜索框
          TextField(
            decoration: InputDecoration(
              hintText: '搜索动作...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) =>
                setState(() => _searchQuery = value.toLowerCase()),
          ),
          const SizedBox(height: 12),
          // 分类筛选
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('全部'),
                selected: _selectedCategory == null,
                onSelected: (selected) {
                  setState(() => _selectedCategory = null);
                },
              ),
              ..._categories.map((cat) {
                return ChoiceChip(
                  label: Text(cat['label'] as String),
                  selected: _selectedCategory == cat['value'],
                  onSelected: (selected) {
                    setState(
                      () => _selectedCategory = selected
                          ? cat['value'] as String
                          : null,
                    );
                  },
                );
              }),
            ],
          ),
          const SizedBox(height: 12),
          // 动作列表
          Expanded(child: _buildExerciseList()),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    final repo = ref.watch(exerciseRepositoryProvider);

    return FutureBuilder<List<Exercise>>(
      future: _selectedCategory != null
          ? repo.getByCategory(_selectedCategory!)
          : repo.getEnabled(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var exercises = snapshot.data!;
        if (_searchQuery.isNotEmpty) {
          exercises = exercises
              .where((e) => e.name.toLowerCase().contains(_searchQuery))
              .toList();
        }

        if (exercises.isEmpty) {
          return const Center(child: Text('暂无动作，点击"自定义"添加'));
        }

        return ListView.builder(
          controller: widget.scrollController,
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return ListTile(
              title: Text(exercise.name),
              subtitle: Text(
                '${exercise.defaultSets}组 × ${exercise.defaultReps}次'
                '${exercise.defaultWeight != null ? " × ${exercise.defaultWeight}kg" : ""}',
              ),
              trailing: _buildCategoryBadge(exercise.category),
              onTap: () {
                ref
                    .read(strengthSessionProvider.notifier)
                    .addExercise(exercise);
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryBadge(String category) {
    final categoryLabels = {
      'chest': '胸',
      'back': '背',
      'shoulders': '肩',
      'arms': '臂',
      'legs': '腿',
      'core': '核心',
    };

    final categoryColors = {
      'chest': Colors.red,
      'back': Colors.blue,
      'shoulders': Colors.orange,
      'arms': Colors.purple,
      'legs': Colors.green,
      'core': Colors.teal,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (categoryColors[category] ?? Colors.grey).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        categoryLabels[category] ?? category,
        style: TextStyle(
          fontSize: 12,
          color: categoryColors[category] ?? Colors.grey,
        ),
      ),
    );
  }

  Widget _buildCustomForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(() => _showCustomForm = false),
                icon: const Icon(Icons.arrow_back),
              ),
              const Text(
                '自定义动作',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '动作名称',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _setsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '组数',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '次数',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: '重量(kg)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _addCustomExercise,
              child: const Text('添加'),
            ),
          ),
        ],
      ),
    );
  }

  void _addCustomExercise() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入动作名称')));
      return;
    }

    final sets = int.tryParse(_setsController.text) ?? 3;
    final reps = int.tryParse(_repsController.text) ?? 10;
    final weight = double.tryParse(_weightController.text) ?? 0;

    ref
        .read(strengthSessionProvider.notifier)
        .addCustomExercise(name, sets, reps, weight);

    Navigator.pop(context);
  }
}
