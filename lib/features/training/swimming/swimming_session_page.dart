import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_database_provider.dart';
import '../../../core/providers/usecase_providers.dart';
import '../../../core/usecases/training/save_swimming_session_usecase.dart';

/// 游泳训练会话状态
class SwimmingSessionState {
  final int? sessionId;
  final int? templateId;
  final DateTime startTime;
  final String environment; // pool, open_water
  final int? poolLengthMeters;
  final String primaryStroke;
  final double distanceMeters;
  final int durationMinutes;
  final int durationSeconds;
  final String? trainingType;
  final Set<String> equipment;
  final List<SwimmingSetData> sets;
  final String? note;

  const SwimmingSessionState({
    this.sessionId,
    this.templateId,
    required this.startTime,
    this.environment = 'pool',
    this.poolLengthMeters = 25,
    this.primaryStroke = 'freestyle',
    this.distanceMeters = 0,
    this.durationMinutes = 0,
    this.durationSeconds = 0,
    this.trainingType,
    this.equipment = const {},
    this.sets = const [],
    this.note,
  });

  SwimmingSessionState copyWith({
    int? sessionId,
    int? templateId,
    DateTime? startTime,
    String? environment,
    int? poolLengthMeters,
    String? primaryStroke,
    double? distanceMeters,
    int? durationMinutes,
    int? durationSeconds,
    String? trainingType,
    Set<String>? equipment,
    List<SwimmingSetData>? sets,
    String? note,
  }) {
    return SwimmingSessionState(
      sessionId: sessionId ?? this.sessionId,
      templateId: templateId ?? this.templateId,
      startTime: startTime ?? this.startTime,
      environment: environment ?? this.environment,
      poolLengthMeters: poolLengthMeters ?? this.poolLengthMeters,
      primaryStroke: primaryStroke ?? this.primaryStroke,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      trainingType: trainingType ?? this.trainingType,
      equipment: equipment ?? this.equipment,
      sets: sets ?? this.sets,
      note: note ?? this.note,
    );
  }

  /// 计算每100米配速（秒）
  int get pacePer100mSeconds {
    if (distanceMeters <= 0) return 0;
    final totalSeconds = durationMinutes * 60 + durationSeconds;
    return ((totalSeconds / distanceMeters) * 100).round();
  }

  /// 格式化配速显示
  String get paceDisplay {
    if (pacePer100mSeconds <= 0) return '--:--';
    final minutes = pacePer100mSeconds ~/ 60;
    final seconds = pacePer100mSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 游泳分组数据
class SwimmingSetData {
  final String setType; // warmup, main, cooldown
  final double distanceMeters;
  final int durationSeconds;
  final String? description;

  const SwimmingSetData({
    required this.setType,
    required this.distanceMeters,
    required this.durationSeconds,
    this.description,
  });

  String get setTypeLabel {
    switch (setType) {
      case 'warmup':
        return '热身';
      case 'main':
        return '主项';
      case 'cooldown':
        return '放松';
      default:
        return setType;
    }
  }
}

/// 游泳训练状态管理
class SwimmingSessionNotifier extends StateNotifier<SwimmingSessionState> {
  final Ref _ref;

  SwimmingSessionNotifier(this._ref)
    : super(SwimmingSessionState(startTime: DateTime.now()));

  /// 从已有会话加载编辑数据
  Future<void> loadSession(int sessionId) async {
    final trainingRepo = _ref.read(trainingRepositoryProvider);
    final swimmingRepo = _ref.read(swimmingRepositoryProvider);

    final session = await trainingRepo.getById(sessionId);
    final entry = await swimmingRepo.getBySessionId(sessionId);
    if (session == null || entry == null) return;

    final sets = await swimmingRepo.getSets(entry.id);
    state = SwimmingSessionState(
      sessionId: session.id,
      templateId: session.templateId,
      startTime: session.datetime,
      environment: entry.environment,
      poolLengthMeters: entry.poolLengthMeters,
      primaryStroke: entry.primaryStroke,
      distanceMeters: entry.distanceMeters,
      durationMinutes: entry.durationSeconds ~/ 60,
      durationSeconds: entry.durationSeconds % 60,
      trainingType: entry.trainingType,
      equipment: entry.equipment == null
          ? <String>{}
          : Set<String>.from(jsonDecode(entry.equipment!) as List<dynamic>),
      sets: sets
          .map(
            (s) => SwimmingSetData(
              setType: s.setType,
              distanceMeters: s.distanceMeters,
              durationSeconds: s.durationSeconds,
              description: s.description,
            ),
          )
          .toList(),
      note: session.note,
    );
  }

  /// 设置环境
  void setEnvironment(String env) {
    state = state.copyWith(
      environment: env,
      // 开放水域时清空泳池长度
      poolLengthMeters: env == 'open_water' ? null : state.poolLengthMeters,
    );
  }

  /// 设置泳池长度
  void setPoolLength(int? meters) {
    state = state.copyWith(poolLengthMeters: meters);
  }

  /// 设置泳姿
  void setStroke(String stroke) {
    state = state.copyWith(primaryStroke: stroke);
  }

  /// 设置距离（米）
  void setDistance(double meters) {
    state = state.copyWith(distanceMeters: meters);
  }

  /// 设置时长
  void setDuration(int minutes, int seconds) {
    state = state.copyWith(durationMinutes: minutes, durationSeconds: seconds);
  }

  /// 设置训练类型
  void setTrainingType(String? type) {
    state = state.copyWith(trainingType: type);
  }

  /// 设置来源模板
  void setTemplateId(int? templateId) {
    state = state.copyWith(templateId: templateId);
  }

  /// 切换装备
  void toggleEquipment(String item) {
    final newEquipment = Set<String>.from(state.equipment);
    if (newEquipment.contains(item)) {
      newEquipment.remove(item);
    } else {
      newEquipment.add(item);
    }
    state = state.copyWith(equipment: newEquipment);
  }

  /// 添加分组
  void addSet(SwimmingSetData set) {
    state = state.copyWith(sets: [...state.sets, set]);
  }

  /// 删除分组
  void removeSet(int index) {
    final newSets = List<SwimmingSetData>.from(state.sets);
    newSets.removeAt(index);
    state = state.copyWith(sets: newSets);
  }

  /// 设置备注
  void setNote(String? note) {
    state = state.copyWith(note: note);
  }
}

/// 游泳会话 Provider
final swimmingSessionProvider =
    StateNotifierProvider.autoDispose<
      SwimmingSessionNotifier,
      SwimmingSessionState
    >((ref) {
      return SwimmingSessionNotifier(ref);
    });

/// 游泳训练会话页面
class SwimmingSessionPage extends ConsumerStatefulWidget {
  final int? sessionId;
  final int? templateId;

  const SwimmingSessionPage({super.key, this.sessionId, this.templateId});

  @override
  ConsumerState<SwimmingSessionPage> createState() =>
      _SwimmingSessionPageState();
}

class _SwimmingSessionPageState extends ConsumerState<SwimmingSessionPage> {
  final _formKey = GlobalKey<FormState>();
  final _distanceController = TextEditingController();
  final _durationMinutesController = TextEditingController();
  final _durationSecondsController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  bool _templateApplied = false;
  bool _isReadOnly = false; // 只读模式：查看历史记录时默认只读

  final List<Map<String, dynamic>> _environments = [
    {'value': 'pool', 'label': '泳池', 'icon': Icons.pool},
    {'value': 'open_water', 'label': '开放水域', 'icon': Icons.water},
  ];

  final List<int> _poolLengths = [25, 50];

  final List<Map<String, dynamic>> _strokes = [
    {'value': 'freestyle', 'label': '自由泳', 'icon': Icons.pool},
    {'value': 'breaststroke', 'label': '蛙泳', 'icon': Icons.pool},
    {'value': 'backstroke', 'label': '仰泳', 'icon': Icons.accessibility},
    {'value': 'butterfly', 'label': '蝶泳', 'icon': Icons.air},
  ];

  final List<Map<String, dynamic>> _trainingTypes = [
    {'value': 'technique', 'label': '技术'},
    {'value': 'endurance', 'label': '耐力'},
    {'value': 'speed', 'label': '速度'},
    {'value': 'recovery', 'label': '恢复'},
  ];

  final List<Map<String, dynamic>> _equipmentList = [
    {'value': 'fins', 'label': '脚蹼', 'icon': Icons.waves},
    {'value': 'paddles', 'label': '划水掌', 'icon': Icons.back_hand},
    {'value': 'kickboard', 'label': '打水板', 'icon': Icons.dashboard},
    {'value': 'pull_buoy', 'label': '浮板', 'icon': Icons.bubble_chart},
    {'value': 'snorkel', 'label': '呼吸管', 'icon': Icons.air},
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

      final notifier = ref.read(swimmingSessionProvider.notifier);
      notifier.setTemplateId(templateId);

      if (detail.exercises.isNotEmpty) {
        final first = detail.exercises.first;
        if (first.reps > 0) {
          final presetDistance = first.reps * 100;
          notifier.setDistance(presetDistance.toDouble());
          _distanceController.text = presetDistance.toString();
        }
      }

      if ((detail.template.description ?? '').isNotEmpty &&
          (ref.read(swimmingSessionProvider).note ?? '').isEmpty) {
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
          .read(swimmingSessionProvider.notifier)
          .loadSession(widget.sessionId!);
      final state = ref.read(swimmingSessionProvider);
      _distanceController.text = state.distanceMeters > 0
          ? state.distanceMeters.toInt().toString()
          : '';
      _durationMinutesController.text = state.durationMinutes > 0
          ? state.durationMinutes.toString()
          : '';
      _durationSecondsController.text = state.durationSeconds > 0
          ? state.durationSeconds.toString()
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
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(swimmingSessionProvider);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('游泳训练')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isReadOnly ? '游泳记录详情' : (widget.sessionId == null ? '游泳训练' : '编辑游泳训练')),
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
              _buildEnvironmentSelector(state),
              const SizedBox(height: 24),
              if (state.environment == 'pool') ...[
                _buildPoolLengthSelector(state),
                const SizedBox(height: 16),
              ],
              _buildStrokeSelector(state),
              const SizedBox(height: 24),
              _buildDistanceInput(state),
              const SizedBox(height: 16),
              _buildDurationInput(state),
              const SizedBox(height: 16),
              _buildPaceDisplay(state),
              const SizedBox(height: 24),
              _buildTrainingTypeSelector(state),
              const SizedBox(height: 16),
              _buildEquipmentSelector(state),
              const SizedBox(height: 24),
              _buildSetsSection(state),
              const SizedBox(height: 24),
              _buildNoteInput(state),
            ],
          ),
        ),
      ),
    );
  }

  /// 环境选择器
  Widget _buildEnvironmentSelector(SwimmingSessionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '训练环境',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: _environments.map((env) {
            return ButtonSegment(
              value: env['value'] as String,
              label: Text(env['label'] as String),
              icon: Icon(env['icon'] as IconData),
            );
          }).toList(),
          selected: {state.environment},
          onSelectionChanged: (Set<String> selection) {
            ref
                .read(swimmingSessionProvider.notifier)
                .setEnvironment(selection.first);
          },
        ),
      ],
    );
  }

  /// 泳池长度选择
  Widget _buildPoolLengthSelector(SwimmingSessionState state) {
    return Row(
      children: [
        const Text('泳池长度:', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 12),
        ..._poolLengths.map((length) {
          final isSelected = state.poolLengthMeters == length;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${length}m'),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref
                      .read(swimmingSessionProvider.notifier)
                      .setPoolLength(length);
                }
              },
            ),
          );
        }),
        ChoiceChip(
          label: const Text('自定义'),
          selected: !_poolLengths.contains(state.poolLengthMeters),
          onSelected: (selected) {
            if (selected) {
              _showCustomPoolLengthDialog();
            }
          },
        ),
      ],
    );
  }

  /// 泳姿选择器
  Widget _buildStrokeSelector(SwimmingSessionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '主要泳姿',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _strokes.map((stroke) {
            final isSelected = state.primaryStroke == stroke['value'];
            return ChoiceChip(
              avatar: Icon(stroke['icon'] as IconData, size: 18),
              label: Text(stroke['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref
                      .read(swimmingSessionProvider.notifier)
                      .setStroke(stroke['value'] as String);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 距离输入
  Widget _buildDistanceInput(SwimmingSessionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _distanceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '距离 (米)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.straighten),
          ),
          readOnly: _isReadOnly,
          validator: (value) {
            if (_isReadOnly) return null;
            final meters = double.tryParse(value ?? '');
            if (meters == null || meters <= 0) {
              return '请输入有效的距离';
            }
            return null;
          },
          onChanged: (value) {
            final meters = double.tryParse(value) ?? 0;
            ref.read(swimmingSessionProvider.notifier).setDistance(meters);
          },
        ),
        const SizedBox(height: 12),
        // 快捷距离按钮（只读模式下隐藏）
        if (!_isReadOnly)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [500, 1000, 1500, 2000].map((meters) {
              final isSelected = state.distanceMeters == meters.toDouble();
              return ChoiceChip(
                label: Text('${meters}m'),
                selected: isSelected,
                onSelected: (_) {
                  _distanceController.text = meters.toString();
                  ref
                      .read(swimmingSessionProvider.notifier)
                      .setDistance(meters.toDouble());
                },
              );
            }).toList(),
          ),
      ],
    );
  }

  /// 时长输入
  Widget _buildDurationInput(SwimmingSessionState state) {
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
                  .read(swimmingSessionProvider.notifier)
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
                  .read(swimmingSessionProvider.notifier)
                  .setDuration(state.durationMinutes, seconds);
            },
          ),
        ),
      ],
    );
  }

  /// 配速显示
  Widget _buildPaceDisplay(SwimmingSessionState state) {
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
                  '每100米配速',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  state.paceDisplay,
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

  /// 训练类型选择
  Widget _buildTrainingTypeSelector(SwimmingSessionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '训练类型',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: _trainingTypes.map((type) {
            final isSelected = state.trainingType == type['value'];
            return ChoiceChip(
              label: Text(type['label'] as String),
              selected: isSelected,
              onSelected: (selected) {
                ref
                    .read(swimmingSessionProvider.notifier)
                    .setTrainingType(selected ? type['value'] as String : null);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 装备选择
  Widget _buildEquipmentSelector(SwimmingSessionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '使用装备',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _equipmentList.map((item) {
            final isSelected = state.equipment.contains(item['value']);
            return FilterChip(
              avatar: Icon(item['icon'] as IconData, size: 16),
              label: Text(item['label'] as String),
              selected: isSelected,
              onSelected: (_) {
                ref
                    .read(swimmingSessionProvider.notifier)
                    .toggleEquipment(item['value'] as String);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 分组区域
  Widget _buildSetsSection(SwimmingSessionState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '分组训练',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: _addSet,
              icon: const Icon(Icons.add),
              label: const Text('添加分组'),
            ),
          ],
        ),
        if (state.sets.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text(
                  '暂无分组，可添加热身、主项、放松组',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          )
        else
          ...state.sets.asMap().entries.map((entry) {
            final index = entry.key;
            final setData = entry.value;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: _buildSetTypeIcon(setData.setType),
                title: Text(
                  '${setData.setTypeLabel} - ${setData.distanceMeters.toInt()}m',
                ),
                subtitle: Text(
                  '${setData.durationSeconds ~/ 60}分${setData.durationSeconds % 60}秒',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    ref.read(swimmingSessionProvider.notifier).removeSet(index);
                  },
                ),
              ),
            );
          }),
      ],
    );
  }

  /// 分组类型图标
  Widget _buildSetTypeIcon(String setType) {
    IconData icon;
    Color color;

    switch (setType) {
      case 'warmup':
        icon = Icons.wb_sunny;
        color = Colors.orange;
        break;
      case 'main':
        icon = Icons.fitness_center;
        color = Colors.blue;
        break;
      case 'cooldown':
        icon = Icons.spa;
        color = Colors.green;
        break;
      default:
        icon = Icons.pool;
        color = Colors.cyan;
    }

    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.2),
      child: Icon(icon, color: color),
    );
  }

  /// 备注输入
  Widget _buildNoteInput(SwimmingSessionState state) {
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
            .read(swimmingSessionProvider.notifier)
            .setNote(value.isEmpty ? null : value);
      },
    );
  }

  /// 显示自定义泳池长度对话框
  void _showCustomPoolLengthDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('自定义泳池长度'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '长度 (米)',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final length = int.tryParse(controller.text);
                if (length != null && length > 0) {
                  ref
                      .read(swimmingSessionProvider.notifier)
                      .setPoolLength(length);
                }
                Navigator.pop(context);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// 添加分组
  void _addSet() {
    String setType = 'main';
    final distanceController = TextEditingController();
    final minutesController = TextEditingController();
    final secondsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('添加分组'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 分组类型
                  Row(
                    children: [
                      const Text('类型: '),
                      const SizedBox(width: 8),
                      ...['warmup', 'main', 'cooldown'].map((type) {
                        final labels = {
                          'warmup': '热身',
                          'main': '主项',
                          'cooldown': '放松',
                        };
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(labels[type]!),
                            selected: setType == type,
                            onSelected: (selected) {
                              if (selected) setState(() => setType = type);
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: distanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '距离 (米)',
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
                    final distance =
                        double.tryParse(distanceController.text) ?? 0;
                    final minutes = int.tryParse(minutesController.text) ?? 0;
                    final seconds = int.tryParse(secondsController.text) ?? 0;

                    if (distance > 0) {
                      final setData = SwimmingSetData(
                        setType: setType,
                        distanceMeters: distance,
                        durationSeconds: minutes * 60 + seconds,
                      );
                      ref
                          .read(swimmingSessionProvider.notifier)
                          .addSet(setData);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('添加'),
                ),
              ],
            );
          },
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

    // 检查泳池长度（如果是泳池环境）
    final state = ref.read(swimmingSessionProvider);
    if (state.environment == 'pool' &&
        (state.poolLengthMeters == null || state.poolLengthMeters! <= 0)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入有效的泳池长度')));
      return;
    }

    try {
      final state = ref.read(swimmingSessionProvider);
      final isEditing = state.sessionId != null;
      final useCase = ref.read(saveSwimmingSessionUseCaseProvider);
      await useCase(
        SaveSwimmingSessionParams(
          sessionId: state.sessionId,
          templateId: state.templateId,
          startTime: state.startTime,
          environment: state.environment,
          primaryStroke: state.primaryStroke,
          distanceMeters: state.distanceMeters,
          durationMinutes: state.durationMinutes,
          durationSeconds: state.durationSeconds,
          poolLengthMeters: state.poolLengthMeters,
          trainingType: state.trainingType,
          equipment: state.equipment,
          note: state.note,
          sets: state.sets
              .map(
                (setData) => SwimmingSetInput(
                  setType: setData.setType,
                  distanceMeters: setData.distanceMeters,
                  durationSeconds: setData.durationSeconds,
                  description: setData.description,
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
            content: Text(isEditing ? '游泳记录已更新' : '游泳记录已保存'),
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
