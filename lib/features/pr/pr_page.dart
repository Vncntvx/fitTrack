import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/providers/app_database_provider.dart';
import '../../core/database/database.dart';
import '../../shared/widgets/charts/chart_colors.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/loading_indicator.dart';

/// 个人记录页面
/// 显示用户的最佳成绩和 PR 历史
class PrPage extends ConsumerStatefulWidget {
  const PrPage({super.key});

  @override
  ConsumerState<PrPage> createState() => _PrPageState();
}

class _PrPageState extends ConsumerState<PrPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(appDatabaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人记录'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.fitness_center), text: '力量'),
            Tab(icon: Icon(Icons.directions_run), text: '有氧'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildStrengthPRs(db), _buildCardioPRs(db)],
      ),
    );
  }

  /// 力量训练 PR
  Widget _buildStrengthPRs(AppDatabase db) {
    return FutureBuilder<List<PersonalRecord>>(
      future: _getStrengthPRs(db),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error);
        }
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }

        final prs = snapshot.data!;

        if (prs.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.emoji_events,
            message: '暂无力量训练记录',
            subtitle: '开始训练后，系统会自动记录你的最佳成绩',
          );
        }

        // 将名单列表包装为可下拉刷新的区域
        return RefreshIndicator(
          onRefresh: () async {
            // 通过重新构建触发数据重新获取
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 100));
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prs.length,
            itemBuilder: (context, index) {
              return _buildStrengthPRCard(prs[index]);
            },
          ),
        );
      },
    );
  }

  /// 力量 PR 卡片
  Widget _buildStrengthPRCard(PersonalRecord pr) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.emoji_events, color: colorScheme.tertiary),
        ),
        title: Text(
          pr.value.isFinite ? '${pr.value.toStringAsFixed(1)} kg' : '- kg',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${_getPRTypeLabel(pr.recordType)} · ${dateFormat.format(pr.achievedAt)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showPRDetail(pr),
      ),
    );
  }

  /// 有氧训练 PR
  Widget _buildCardioPRs(AppDatabase db) {
    return FutureBuilder<List<PersonalRecord>>(
      future: _getCardioPRs(db),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error);
        }
        if (!snapshot.hasData) {
          return const LoadingIndicator();
        }

        final prs = snapshot.data!;

        if (prs.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.directions_run,
            message: '暂无有氧训练记录',
            subtitle: '跑步或游泳后，系统会自动记录你的最佳成绩',
          );
        }
        // 按类型分组
        final runningPRs = prs
            .where((p) => p.recordType.startsWith('running'))
            .toList();
        final swimmingPRs = prs
            .where((p) => p.recordType.startsWith('swimming'))
            .toList();
        // 将列表包装为可以下拉刷新的区域
        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
            await Future.delayed(const Duration(milliseconds: 100));
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (runningPRs.isNotEmpty) ...[
                const Text(
                  '跑步',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...runningPRs.map(
                  (pr) => _buildCardioPRCard(pr, ChartColors.running),
                ),
                const SizedBox(height: 24),
              ],
              if (swimmingPRs.isNotEmpty) ...[
                const Text(
                  '游泳',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...swimmingPRs.map(
                  (pr) => _buildCardioPRCard(pr, ChartColors.swimming),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// 有氧 PR 卡片
  Widget _buildCardioPRCard(PersonalRecord pr, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('yyyy-MM-dd');
    String valueDisplay;
    String unit;

    // 处理无效值
    if (!pr.value.isFinite) {
      valueDisplay = '-';
      unit = '';
    } else if (pr.recordType.contains('distance')) {
      if (pr.value >= 1000) {
        valueDisplay = (pr.value / 1000).toStringAsFixed(2);
        unit = '公里';
      } else {
        valueDisplay = '${pr.value.toInt()}';
        unit = '米';
      }
    } else if (pr.recordType.contains('pace')) {
      final minutes = pr.value.toInt() ~/ 60;
      final seconds = pr.value.toInt() % 60;
      valueDisplay = '$minutes:${seconds.toString().padLeft(2, '0')}';
      unit = pr.recordType.contains('swimming') ? '/100米' : '/公里';
    } else {
      valueDisplay = pr.value.toStringAsFixed(1);
      unit = pr.unit;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.emoji_events, color: color),
        ),
        title: Row(
          children: [
            Text(
              valueDisplay,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: TextStyle(fontSize: 14, color: colorScheme.outline),
            ),
          ],
        ),
        subtitle: Text(
          '${_getPRTypeLabel(pr.recordType)} · ${dateFormat.format(pr.achievedAt)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showPRDetail(pr),
      ),
    );
  }

  Widget _buildErrorState(Object? error) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      message: '加载失败',
      subtitle: error.toString(),
    );
  }

  /// 获取力量 PR 列表
  Future<List<PersonalRecord>> _getStrengthPRs(AppDatabase db) async {
    final allPRs = await db.select(db.personalRecords).get();
    return allPRs.where((p) => p.recordType.startsWith('strength')).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  /// 获取有氧 PR 列表
  Future<List<PersonalRecord>> _getCardioPRs(AppDatabase db) async {
    final allPRs = await db.select(db.personalRecords).get();
    return allPRs
        .where(
          (p) =>
              p.recordType.startsWith('running') ||
              p.recordType.startsWith('swimming'),
        )
        .toList();
  }

  /// 获取 PR 类型标签
  String _getPRTypeLabel(String recordType) {
    const labels = {
      'strength_1rm': '最大重量',
      'strength_volume': '训练容量',
      'running_distance': '最长距离',
      'running_pace': '最快配速',
      'swimming_distance': '最长距离',
      'swimming_pace': '最快配速',
    };
    return labels[recordType] ?? recordType;
  }

  /// 显示 PR 详情
  void _showPRDetail(PersonalRecord pr) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.8,
          expand: false,
          builder: (context, scrollController) {
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
                        color: colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.emoji_events,
                        color: colorScheme.tertiary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _getPRTypeLabel(pr.recordType),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '${pr.value.toStringAsFixed(1)} ${pr.unit}',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '达成于 ${DateFormat('yyyy-MM-dd').format(pr.achievedAt)}',
                          style: TextStyle(color: colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildDetailRow('记录类型', _getPRTypeLabel(pr.recordType)),
                  _buildDetailRow(
                    '记录值',
                    '${pr.value.toStringAsFixed(2)} ${pr.unit}',
                  ),
                  _buildDetailRow(
                    '达成日期',
                    DateFormat('yyyy-MM-dd HH:mm').format(pr.achievedAt),
                  ),
                  if (pr.sessionId != null)
                    _buildDetailRow('训练会话', '#${pr.sessionId}'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 详情行
  Widget _buildDetailRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colorScheme.outline)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
