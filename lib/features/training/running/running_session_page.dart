import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_database_provider.dart';
import '../../../core/providers/usecase_providers.dart';
import '../../../core/usecases/training/save_running_session_usecase.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../shared/widgets/single_select_options.dart';

/// 跑步训练会话状态
class RunningSessionState {
  final int? sessionId;
  final int? templateId;
  final DateTime startTime;
  final bool isRunning;
  final int elapsedSeconds;
  final String runType;
  final double distanceKm;
  final int durationMinutes;
  final int durationSeconds;
  final int? avgHeartRate;
  final int? maxHeartRate;
  final int? avgCadence;
  final double? elevationGain;
  final List<RunningSplitData> splits;
  final String? note;

  const RunningSessionState({
    this.sessionId,
    this.templateId,
    required this.startTime,
    this.isRunning = false,
    this.elapsedSeconds = 0,
    this.runType = 'easy',
    this.distanceKm = 0,
    this.durationMinutes = 0,
    this.durationSeconds = 0,
    this.avgHeartRate,
    this.maxHeartRate,
    this.avgCadence,
    this.elevationGain,
    this.splits = const [],
    this.note,
  });

  RunningSessionState copyWith({
    int? sessionId,
    int? templateId,
    DateTime? startTime,
    bool? isRunning,
    int? elapsedSeconds,
    String? runType,
    double? distanceKm,
    int? durationMinutes,
    int? durationSeconds,
    int? avgHeartRate,
    int? maxHeartRate,
    int? avgCadence,
    double? elevationGain,
    List<RunningSplitData>? splits,
    String? note,
  }) {
    return RunningSessionState(
      sessionId: sessionId ?? this.sessionId,
      templateId: templateId ?? this.templateId,
      startTime: startTime ?? this.startTime,
      isRunning: isRunning ?? this.isRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      runType: runType ?? this.runType,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      avgCadence: avgCadence ?? this.avgCadence,
      elevationGain: elevationGain ?? this.elevationGain,
      splits: splits ?? this.splits,
      note: note ?? this.note,
    );
  }

  /// 计算平均配速（秒/公里）
  int get avgPaceSeconds {
    if (distanceKm <= 0) return 0;
    final totalSeconds = durationMinutes * 60 + durationSeconds;
    return (totalSeconds / distanceKm).round();
  }

  /// 格式化配速显示
  String get paceDisplay {
    if (avgPaceSeconds <= 0) return '--:--';
    final minutes = avgPaceSeconds ~/ 60;
    final seconds = avgPaceSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 分段数据
class RunningSplitData {
  final int splitNumber;
  final double distanceKm;
  final int durationSeconds;
  final int? heartRate;
  final int? cadence;

  const RunningSplitData({
    required this.splitNumber,
    required this.distanceKm,
    required this.durationSeconds,
    this.heartRate,
    this.cadence,
  });

  /// 配速（秒/公里）
  int get paceSeconds {
    if (distanceKm <= 0) return 0;
    return (durationSeconds / distanceKm).round();
  }

  /// 格式化配速
  String get paceDisplay {
    if (paceSeconds <= 0) return '--:--';
    final minutes = paceSeconds ~/ 60;
    final seconds = paceSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 跑步训练状态管理
class RunningSessionNotifier extends StateNotifier<RunningSessionState> {
  final Ref _ref;
  Timer? _timer;

  RunningSessionNotifier(this._ref)
    : super(RunningSessionState(startTime: DateTime.now()));

  /// 从已有会话加载编辑数据
  Future<void> loadSession(int sessionId) async {
    final trainingRepo = _ref.read(trainingRepositoryProvider);
    final runningRepo = _ref.read(runningRepositoryProvider);

    final session = await trainingRepo.getById(sessionId);
    final entry = await runningRepo.getBySessionId(sessionId);
    if (session == null || entry == null) return;

    final splits = await runningRepo.getSplits(entry.id);
    state = RunningSessionState(
      sessionId: session.id,
      templateId: session.templateId,
      startTime: session.datetime,
      runType: entry.runType,
      distanceKm: entry.distanceMeters / 1000,
      durationMinutes: entry.durationSeconds ~/ 60,
      durationSeconds: entry.durationSeconds % 60,
      avgHeartRate: entry.avgHeartRate,
      maxHeartRate: entry.maxHeartRate,
      avgCadence: entry.avgCadence,
      elevationGain: entry.elevationGain,
      note: session.note,
      splits: splits
          .map(
            (s) => RunningSplitData(
              splitNumber: s.splitNumber,
              distanceKm: s.distanceMeters / 1000,
              durationSeconds: s.durationSeconds,
              heartRate: s.avgHeartRate,
              cadence: s.cadence,
            ),
          )
          .toList(),
    );
  }

  /// 开始计时
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

  /// 更新跑步类型
  void setRunType(String type) {
    state = state.copyWith(runType: type);
  }

  /// 设置来源模板
  void setTemplateId(int? templateId) {
    state = state.copyWith(templateId: templateId);
  }

  /// 更新距离（公里）
  void setDistance(double km) {
    state = state.copyWith(distanceKm: km);
  }

  /// 更新时长（分钟和秒）
  void setDuration(int minutes, int seconds) {
    state = state.copyWith(durationMinutes: minutes, durationSeconds: seconds);
  }

  /// 更新心率
  void setHeartRate(int? avg, int? max) {
    state = state.copyWith(avgHeartRate: avg, maxHeartRate: max);
  }

  /// 更新步频
  void setCadence(int? cadence) {
    state = state.copyWith(avgCadence: cadence);
  }

  /// 更新爬升
  void setElevation(double? gain) {
    state = state.copyWith(elevationGain: gain);
  }

  /// 更新备注
  void setNote(String? note) {
    state = state.copyWith(note: note);
  }

  /// 添加分段
  void addSplit(RunningSplitData split) {
    state = state.copyWith(splits: [...state.splits, split]);
  }

  /// 删除分段
  void removeSplit(int index) {
    final newSplits = List<RunningSplitData>.from(state.splits);
    newSplits.removeAt(index);
    state = state.copyWith(splits: newSplits);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// 跑步会话 Provider
final runningSessionProvider =
    StateNotifierProvider.autoDispose<
      RunningSessionNotifier,
      RunningSessionState
    >((ref) {
      return RunningSessionNotifier(ref);
    });

/// 跑步训练会话页面
class RunningSessionPage extends ConsumerStatefulWidget {
  final int? sessionId;
  final int? templateId;

  const RunningSessionPage({super.key, this.sessionId, this.templateId});

  @override
  ConsumerState<RunningSessionPage> createState() => _RunningSessionPageState();
}

class _RunningSessionPageState extends ConsumerState<RunningSessionPage> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _durationMinutesController = TextEditingController();
  final _durationSecondsController = TextEditingController();
  final _avgHeartRateController = TextEditingController();
  final _maxHeartRateController = TextEditingController();
  final _avgCadenceController = TextEditingController();
  final _elevationGainController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  bool _templateApplied = false;
  bool _isReadOnly = false; // 只读模式：查看历史记录时默认只读

  final List<Map<String, dynamic>> _runTypes = [
    {
      'value': 'easy',
      'label': '轻松跑',
      'icon': Icons.directions_run,
      'color': Colors.green,
    },
    {
      'value': 'tempo',
      'label': '节奏跑',
      'icon': Icons.speed,
      'color': Colors.orange,
    },
    {
      'value': 'interval',
      'label': '间歇跑',
      'icon': Icons.flash_on,
      'color': Colors.red,
    },
    {'value': 'lsd', 'label': '长距离', 'icon': Icons.route, 'color': Colors.blue},
    {
      'value': 'recovery',
      'label': '恢复跑',
      'icon': Icons.healing,
      'color': Colors.teal,
    },
    {
      'value': 'race',
      'label': '比赛',
      'icon': Icons.emoji_events,
      'color': Colors.amber,
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.sessionId != null) {
      _loadSession();
    } else if (widget.templateId != null) {
      _applyTemplate(widget.templateId!);
    }
  }

  Future<void> _applyTemplate(int templateId) async {
    setState(() => _isLoading = true);
    try {
      final templateRepo = ref.read(templateRepositoryProvider);
      final detail = await templateRepo.getTemplateDetail(templateId);
      if (detail == null) return;

      final notifier = ref.read(runningSessionProvider.notifier);
      notifier.setTemplateId(templateId);
      if ((detail.template.description ?? '').isNotEmpty &&
          (ref.read(runningSessionProvider).note ?? '').isEmpty) {
        notifier.setNote(detail.template.description);
        _noteController.text = detail.template.description!;
      }
      _templateApplied = true;
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadSession() async {
    setState(() => _isLoading = true);
    try {
      await ref
          .read(runningSessionProvider.notifier)
          .loadSession(widget.sessionId!);
      final state = ref.read(runningSessionProvider);
      _distanceController.text = state.distanceKm > 0
          ? state.distanceKm.toStringAsFixed(2)
          : '';
      _durationMinutesController.text = state.durationMinutes > 0
          ? state.durationMinutes.toString()
          : '';
      _durationSecondsController.text = state.durationSeconds > 0
          ? state.durationSeconds.toString()
          : '';
      _avgHeartRateController.text = state.avgHeartRate?.toString() ?? '';
      _maxHeartRateController.text = state.maxHeartRate?.toString() ?? '';
      _avgCadenceController.text = state.avgCadence?.toString() ?? '';
      _elevationGainController.text = state.elevationGain != null
          ? state.elevationGain!.toStringAsFixed(0)
          : '';
      _noteController.text = state.note ?? '';
      // 加载历史记录时默认进入只读模式
      setState(() => _isReadOnly = true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _durationMinutesController.dispose();
    _durationSecondsController.dispose();
    _avgHeartRateController.dispose();
    _maxHeartRateController.dispose();
    _avgCadenceController.dispose();
    _elevationGainController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(runningSessionProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('跑步训练')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isReadOnly ? '跑步记录详情' : (widget.sessionId == null ? '跑步训练' : '编辑跑步训练')),
        actions: [
          if (_isReadOnly)
            TextButton(
              onPressed: () => setState(() => _isReadOnly = false),
              child: const Text('编辑'),
            )
          else
            TextButton(onPressed: _saveSession, child: const Text('保存')),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_templateApplied)
                const Card(
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.description),
                    title: Text('已加载模板配置'),
                  ),
                ),
              if (_templateApplied) const SizedBox(height: 12),
              _buildRunTypeSelector(state),
              const SizedBox(height: 24),
              _buildDistanceInput(state),
              const SizedBox(height: 16),
              _buildDurationInput(state),
              const SizedBox(height: 16),
              _buildPaceDisplay(state),
              const SizedBox(height: 24),
              _buildOptionalFields(state),
              const SizedBox(height: 24),
              _buildSplitsSection(state),
              const SizedBox(height: 24),
              _buildNoteInput(state),
            ],
          ),
        ),
      ),
    );
  }

  /// 跑步类型选择器 - 使用 2x3 网格避免不均匀换行
  Widget _buildRunTypeSelector(RunningSessionState state) {
    final typeOptions = _runTypes
        .map((t) => SelectOption<String>(
              value: t['value'] as String,
              label: t['label'] as String,
              icon: t['icon'] as IconData,
            ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '跑步类型',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        SingleSelectGrid<String>(
          options: typeOptions,
          selected: state.runType,
          columns: 3,
          onChanged: (value) {
            ref.read(runningSessionProvider.notifier).setRunType(value);
          },
          enabled: !_isReadOnly,
        ),
      ],
    );
  }

  /// 距离输入
  Widget _buildDistanceInput(RunningSessionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _distanceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '距离 (公里)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.straighten),
          ),
          readOnly: _isReadOnly,
          validator: (value) {
            if (_isReadOnly) return null;
            final km = double.tryParse(value ?? '');
            if (km == null || km <= 0) {
              return '请输入有效的距离';
            }
            return null;
          },
          onChanged: (value) {
            final km = double.tryParse(value) ?? 0;
            ref.read(runningSessionProvider.notifier).setDistance(km);
          },
        ),
        const SizedBox(height: 12),
        // 快捷距离按钮（只读模式下隐藏）
        if (!_isReadOnly)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [3, 5, 10, 21.1, 42.2].map((km) {
              final isSelected = state.distanceKm == km.toDouble();
              return ChoiceChip(
                label: Text(km == km.roundToDouble() ? '${km.toInt()}' : '$km'),
                selected: isSelected,
                onSelected: (_) {
                  _distanceController.text = km.toString();
                  ref.read(runningSessionProvider.notifier).setDistance(km.toDouble());
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  /// 时长输入
  Widget _buildDurationInput(RunningSessionState state) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _durationMinutesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '分钟',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timer),
            ),
            readOnly: _isReadOnly,
            validator: (value) {
              if (_isReadOnly) return null;
              final minutes = int.tryParse(value ?? '');
              if (minutes == null || minutes <= 0) {
                return '请输入有效的时长';
              }
              return null;
            },
            onChanged: (value) {
              final minutes = int.tryParse(value) ?? 0;
              ref
                  .read(runningSessionProvider.notifier)
                  .setDuration(minutes, state.durationSeconds);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextFormField(
            controller: _durationSecondsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '秒',
              border: OutlineInputBorder(),
            ),
            readOnly: _isReadOnly,
            onChanged: (value) {
              final seconds = int.tryParse(value) ?? 0;
              ref
                  .read(runningSessionProvider.notifier)
                  .setDuration(state.durationMinutes, seconds);
            },
          ),
        ),
      ],
    );
  }

  /// 配速显示
  Widget _buildPaceDisplay(RunningSessionState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.speed, size: 32),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '平均配速',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${state.paceDisplay} /公里',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 可选字段
  Widget _buildOptionalFields(RunningSessionState state) {
    return ExpansionTile(
      title: const Text('高级选项'),
      leading: const Icon(Icons.settings),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _avgHeartRateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '平均心率 (bpm)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final hr = int.tryParse(value);
                        ref
                            .read(runningSessionProvider.notifier)
                            .setHeartRate(hr, state.maxHeartRate);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _maxHeartRateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '最大心率 (bpm)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final hr = int.tryParse(value);
                        ref
                            .read(runningSessionProvider.notifier)
                            .setHeartRate(state.avgHeartRate, hr);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _avgCadenceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '平均步频 (spm)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final cadence = int.tryParse(value);
                        ref
                            .read(runningSessionProvider.notifier)
                            .setCadence(cadence);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _elevationGainController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: '累计爬升 (米)',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        final gain = double.tryParse(value);
                        ref
                            .read(runningSessionProvider.notifier)
                            .setElevation(gain);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 分段记录
  Widget _buildSplitsSection(RunningSessionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '分段记录',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _addSplit,
              icon: const Icon(Icons.add),
              label: const Text('添加分段'),
            ),
          ],
        ),
        if (state.splits.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('暂无分段记录', style: TextStyle(color: Colors.grey)),
              ),
            ),
          )
        else
          ...state.splits.asMap().entries.map((entry) {
            final index = entry.key;
            final split = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text('${split.distanceKm} km'),
                subtitle: Text('配速: ${split.paceDisplay}/km'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ref
                        .read(runningSessionProvider.notifier)
                        .removeSplit(index);
                  },
                ),
              ),
            );
          }),
      ],
    );
  }

  /// 备注输入
  Widget _buildNoteInput(RunningSessionState state) {
    return TextField(
      controller: _noteController,
      decoration: const InputDecoration(
        labelText: '备注',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.note),
      ),
      maxLines: 2,
      onChanged: (value) {
        ref
            .read(runningSessionProvider.notifier)
            .setNote(value.isEmpty ? null : value);
      },
    );
  }

  /// 添加分段
  void _addSplit() {
    showDialog(
      context: context,
      builder: (context) {
        final distanceController = TextEditingController();
        final minutesController = TextEditingController();
        final secondsController = TextEditingController();

        return AlertDialog(
          title: const Text('添加分段'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: distanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: '距离 (公里)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minutesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '分钟',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: secondsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: '秒',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final distance = double.tryParse(distanceController.text) ?? 0;
                final minutes = int.tryParse(minutesController.text) ?? 0;
                final seconds = int.tryParse(secondsController.text) ?? 0;

                if (distance > 0) {
                  final state = ref.read(runningSessionProvider);
                  final split = RunningSplitData(
                    splitNumber: state.splits.length + 1,
                    distanceKm: distance,
                    durationSeconds: minutes * 60 + seconds,
                  );
                  ref.read(runningSessionProvider.notifier).addSplit(split);
                }
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  /// 保存训练
  Future<void> _saveSession() async {
    // 验证表单
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 检查配速是否有效
    final state = ref.read(runningSessionProvider);
    if (state.avgPaceSeconds <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('配速必须大于0')));
      return;
    }

    try {
      final notifier = ref.read(runningSessionProvider.notifier);
      notifier.pauseTimer();
      final state = ref.read(runningSessionProvider);
      final isEditing = state.sessionId != null;
      final useCase = ref.read(saveRunningSessionUseCaseProvider);
      await useCase(
        SaveRunningSessionParams(
          sessionId: state.sessionId,
          templateId: state.templateId,
          startTime: state.startTime,
          runType: state.runType,
          distanceKm: state.distanceKm,
          durationMinutes: state.durationMinutes,
          durationSeconds: state.durationSeconds,
          avgHeartRate: state.avgHeartRate,
          maxHeartRate: state.maxHeartRate,
          avgCadence: state.avgCadence,
          elevationGain: state.elevationGain,
          note: state.note,
          splits: state.splits
              .map(
                (split) => RunningSplitInput(
                  splitNumber: split.splitNumber,
                  distanceKm: split.distanceKm,
                  durationSeconds: split.durationSeconds,
                  heartRate: split.heartRate,
                  cadence: split.cadence,
                ),
              )
              .toList(),
        ),
      );

      // 刷新训练记录列表
      ref.invalidate(trainingSessionsStreamProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? '跑步记录已更新' : '跑步记录已保存'),
          ),
        );
        context.go('/records');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    }
  }
}
