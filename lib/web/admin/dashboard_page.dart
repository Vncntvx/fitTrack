import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../core/database/database.dart';
import '../../core/providers/app_database_provider.dart';
import '../../core/providers/usecase_providers.dart';
import '../../core/repositories/training_repository.dart';
import '../../core/repositories/stats_repository.dart';
import '../../shared/workout/workout_type_catalog.dart';

/// Web 管理后台仪表板页面
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(trainingRepositoryProvider);
    final statsRepo = ref.watch(statsRepositoryProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(trainingRepositoryProvider);
          ref.invalidate(statsRepositoryProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildHeader(() {
              ref.invalidate(trainingRepositoryProvider);
              ref.invalidate(statsRepositoryProvider);
            }),
            const SizedBox(height: 24),
            _buildStatsRow(repo, statsRepo),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildRecentWorkouts(context, repo)),
                const SizedBox(width: 24),
                Expanded(child: _buildTypeDistribution(repo)),
              ],
            ),
            const SizedBox(height: 24),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  /// 页面头部
  Widget _buildHeader(VoidCallback onRefresh) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '仪表板',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text('训练数据总览', style: TextStyle(color: Colors.grey)),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: onRefresh,
          tooltip: '刷新数据',
        ),
      ],
    );
  }

  /// 统计行
  Widget _buildStatsRow(TrainingRepository repo, StatsRepository statsRepo) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getStats(repo, statsRepo),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = snapshot.data!;

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                '本周训练',
                '${stats['weeklyCount']} 次',
                Icons.fitness_center,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                '本周时长',
                '${stats['weeklyMinutes']} 分钟',
                Icons.timer,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                '连续训练',
                '${stats['streak']} 天',
                Icons.local_fire_department,
                Colors.red,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                '总训练数',
                '${stats['totalCount']} 次',
                Icons.history,
                Colors.green,
              ),
            ),
          ],
        );
      },
    );
  }

  /// 统计卡片
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  /// 最近训练列表
  Widget _buildRecentWorkouts(BuildContext context, TrainingRepository repo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '最近训练',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go('/records'),
                  child: const Text('查看全部'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<dynamic>>(
              future: _getRecentSessions(repo),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sessions = snapshot.data!;

                if (sessions.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('暂无训练记录'),
                    ),
                  );
                }

                return Column(
                  children: sessions.take(5).map((session) {
                    final s = session as dynamic;
                    return _buildWorkoutListTile(s);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 训练列表项
  Widget _buildWorkoutListTile(TrainingSession session) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _getTypeColor(session.type).withValues(alpha: 0.2),
        child: Icon(
          _getTypeIcon(session.type),
          color: _getTypeColor(session.type),
          size: 20,
        ),
      ),
      title: Text(_getTypeLabel(session.type)),
      subtitle: Text(
        '${session.durationMinutes} 分钟',
        style: TextStyle(color: Colors.grey.shade600),
      ),
      trailing: Text(
        _formatDate(session.datetime),
        style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      ),
    );
  }

  /// 训练类型分布
  Widget _buildTypeDistribution(TrainingRepository repo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '训练类型分布',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            FutureBuilder<Map<String, int>>(
              future: _getTypeDistribution(repo),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('暂无数据'),
                    ),
                  );
                }

                final data = snapshot.data!;

                return SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: data.entries.toList().asMap().entries.map((e) {
                        final color = _getTypeColor(e.value.key);
                        return PieChartSectionData(
                          color: color,
                          value: e.value.value.toDouble(),
                          title: '${e.value.value}',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, int>>(
              future: _getTypeDistribution(repo),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                final data = snapshot.data!;
                return Column(
                  children: data.entries.map((entry) {
                    return _buildLegendRow(
                      _getTypeLabel(entry.key),
                      entry.value,
                      _getTypeColor(entry.key),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 图例行
  Widget _buildLegendRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text('$count 次', style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  /// 快速操作按钮
  Widget _buildQuickActions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Web 门户',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildActionSection('应用功能', [
              _buildActionButton(
                '今日概览',
                Icons.today,
                Colors.blue,
                () => context.go('/'),
              ),
              _buildActionButton(
                '训练历史',
                Icons.history,
                Colors.orange,
                () => context.go('/records'),
              ),
              _buildActionButton(
                '统计分析',
                Icons.bar_chart,
                Colors.green,
                () => context.go('/records'),
              ),
              _buildActionButton(
                '训练中心',
                Icons.play_arrow,
                Colors.indigo,
                () => context.go('/train'),
              ),
              _buildActionButton(
                '快速记录',
                Icons.edit_note,
                Colors.teal,
                () => context.go('/train/quick'),
              ),
              _buildActionButton(
                '设置中心',
                Icons.settings,
                Colors.grey,
                () => context.go('/me'),
              ),
              _buildActionButton(
                '动作库',
                Icons.fitness_center,
                Colors.red,
                () => context.go('/me/exercises'),
              ),
              _buildActionButton(
                '训练模板',
                Icons.description,
                Colors.cyan,
                () => context.go('/me/templates'),
              ),
              _buildActionButton(
                '个人记录',
                Icons.emoji_events,
                Colors.amber,
                () => context.go('/me/pr'),
              ),
              _buildActionButton(
                '备份恢复',
                Icons.restore,
                Colors.brown,
                () => context.go('/me/backup'),
              ),
            ]),
            const SizedBox(height: 20),
            _buildActionSection('高级管理', [
              _buildActionButton(
                '数据总表',
                Icons.table_chart,
                Colors.deepPurple,
                () => context.go('/admin/table'),
              ),
              _buildActionButton(
                'Web 动作管理',
                Icons.inventory_2,
                Colors.pink,
                () => context.go('/admin/exercises'),
              ),
              _buildActionButton(
                'Web 模板管理',
                Icons.view_module,
                Colors.lightBlue,
                () => context.go('/admin/templates'),
              ),
              _buildActionButton(
                'PR 后台',
                Icons.workspace_premium,
                Colors.deepOrange,
                () => context.go('/admin/pr'),
              ),
              _buildActionButton(
                '导入导出',
                Icons.import_export,
                Colors.purple,
                () => context.go('/admin/export'),
              ),
              _buildActionButton(
                '备份管理',
                Icons.backup,
                Colors.teal,
                () => context.go('/admin/backup'),
              ),
              _buildActionButton(
                '系统信息',
                Icons.info,
                Colors.blueGrey,
                () => context.go('/admin/system'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection(String title, List<Widget> actions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 12, runSpacing: 12, children: actions),
      ],
    );
  }

  /// 操作按钮
  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  /// 获取统计数据
  Future<Map<String, dynamic>> _getStats(
    TrainingRepository repo,
    StatsRepository statsRepo,
  ) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );

    final weeklyCount = await statsRepo.countUniqueDaysThisWeek(weekStartDate);
    final weeklyMinutes = await statsRepo.getWeeklyTotalMinutes(weekStartDate);
    final streak = await statsRepo.getCurrentStreak();
    final all = await repo.getAll();

    return {
      'weeklyCount': weeklyCount,
      'weeklyMinutes': weeklyMinutes,
      'streak': streak,
      'totalCount': all.length,
    };
  }

  /// 获取最近会话
  Future<List<dynamic>> _getRecentSessions(TrainingRepository repo) async {
    final sessions = await repo.getAll();
    return sessions.take(5).toList();
  }

  /// 获取类型分布
  Future<Map<String, int>> _getTypeDistribution(TrainingRepository repo) async {
    final sessions = await repo.getAll();
    final distribution = <String, int>{};

    for (final session in sessions) {
      distribution[session.type] = (distribution[session.type] ?? 0) + 1;
    }

    return distribution;
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// 获取类型标签
  String _getTypeLabel(String type) {
    return WorkoutTypeCatalog.labelOf(type);
  }

  /// 获取类型颜色
  Color _getTypeColor(String type) {
    return WorkoutTypeCatalog.colorOf(type);
  }

  /// 获取类型图标
  IconData _getTypeIcon(String type) {
    return WorkoutTypeCatalog.iconOf(type);
  }
}
