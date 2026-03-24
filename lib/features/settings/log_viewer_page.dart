import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/logging/log_entry.dart';
import '../../core/logging/log_level.dart';
import '../../core/logging/logger_service.dart';

/// 日志查看页面
/// 用于查看、过滤和管理应用日志
class LogViewerPage extends StatefulWidget {
  const LogViewerPage({super.key});

  @override
  State<LogViewerPage> createState() => _LogViewerPageState();
}

class _LogViewerPageState extends State<LogViewerPage> {
  List<LogEntry> _logs = [];
  List<LogEntry> _filteredLogs = [];
  bool _isLoading = true;
  String _searchQuery = '';
  LogLevel? _filterLevel;
  String? _filterTag;
  final List<String> _tags = [];

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// 加载日志
  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);

    try {
      final service = LoggerService.instance;
      final filter = LogFilter(
        minLevel: _filterLevel,
        tag: _filterTag,
        keyword: _searchQuery.isEmpty ? null : _searchQuery,
      );

      final logs = await service.queryLogs(filter);
      if (!mounted) return;

      // 提取所有标签
      final tagSet = logs.map((e) => e.tag).toSet().toList()..sort();

      setState(() {
        _logs = logs;
        _filteredLogs = logs;
        _tags.clear();
        _tags.addAll(tagSet);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('加载日志失败: $e')));
    }
  }

  /// 刷新日志
  Future<void> _refreshLogs() async {
    await _loadLogs();
  }

  /// 清空日志
  Future<void> _clearLogs() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空日志'),
        content: const Text('确定要清空所有日志吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await LoggerService.instance.clearAllLogs();
      await _loadLogs();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('日志已清空')));
    }
  }

  /// 导出所有日志到剪贴板
  Future<void> _exportLogsToClipboard() async {
    try {
      final logText = _logs.map((e) => e.formattedLog).join('\n\n');

      await Clipboard.setData(ClipboardData(text: logText));
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('日志已复制到剪贴板')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('导出失败: $e')));
    }
  }

  /// 复制日志
  void _copyLog(LogEntry log) {
    Clipboard.setData(ClipboardData(text: log.formattedLog));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
  }

  /// 搜索日志
  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _applyFilters();
    });
  }

  /// 应用过滤
  void _applyFilters() {
    _filteredLogs = _logs.where((log) {
      // 级别过滤
      if (_filterLevel != null && log.level != _filterLevel) {
        return false;
      }

      // 标签过滤
      if (_filterTag != null && log.tag != _filterTag) {
        return false;
      }

      // 搜索过滤
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        return log.message.toLowerCase().contains(searchLower) ||
            log.tag.toLowerCase().contains(searchLower) ||
            (log.error?.toLowerCase().contains(searchLower) ?? false);
      }

      return true;
    }).toList();
  }

  /// 显示过滤对话框
  Future<void> _showFilterDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('过滤日志'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 级别过滤
            const Text('日志级别', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('全部'),
                  selected: _filterLevel == null,
                  onSelected: (selected) {
                    setState(() => _filterLevel = null);
                    Navigator.pop(context);
                    _applyFilters();
                  },
                ),
                ...LogLevel.values.map(
                  (level) => FilterChip(
                    label: Text(level.name),
                    selected: _filterLevel == level,
                    onSelected: (selected) {
                      setState(() => _filterLevel = selected ? level : null);
                      Navigator.pop(context);
                      _applyFilters();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 标签过滤
            if (_tags.isNotEmpty) ...[
              const Text('标签', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  FilterChip(
                    label: const Text('全部'),
                    selected: _filterTag == null,
                    onSelected: (selected) {
                      setState(() => _filterTag = null);
                      Navigator.pop(context);
                      _applyFilters();
                    },
                  ),
                  ..._tags.map(
                    (tag) => FilterChip(
                      label: Text(tag),
                      selected: _filterTag == tag,
                      onSelected: (selected) {
                        setState(() => _filterTag = selected ? tag : null);
                        Navigator.pop(context);
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  /// 显示日志详情
  void _showLogDetail(LogEntry log) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题栏
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(
                          log.level.colorValue,
                        ).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        log.level.name,
                        style: TextStyle(
                          color: Color(log.level.colorValue),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        log.tag,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () => _copyLog(log),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _formatTime(log.timestamp),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const Divider(),
                // 消息
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          log.message,
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (log.error != null) ...[
                          const SizedBox(height: 16),
                          const Text(
                            '错误详情:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SelectableText(
                              log.error!,
                              style: TextStyle(
                                color: Colors.red.shade900,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                        if (log.stackTrace != null) ...[
                          const SizedBox(height: 16),
                          const Text(
                            '堆栈跟踪:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SelectableText(
                              log.stackTrace!,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                        if (log.data != null) ...[
                          const SizedBox(height: 16),
                          const Text(
                            '附加数据:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: SelectableText(
                              _formatData(log.data!),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    return '${time.year}-${_twoDigits(time.month)}-${_twoDigits(time.day)} '
        '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}:${_twoDigits(time.second)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// 格式化数据
  String _formatData(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}: ${e.value}').join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志查看'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: const Icon(Icons.copy_all),
            onPressed: _exportLogsToClipboard,
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearLogs,
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索日志...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          // 统计信息
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '共 ${_filteredLogs.length} 条日志',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                if (_filterLevel != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(_filterLevel!.name),
                    backgroundColor: Color(
                      _filterLevel!.colorValue,
                    ).withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: Color(_filterLevel!.colorValue),
                    ),
                    onDeleted: () {
                      setState(() {
                        _filterLevel = null;
                        _applyFilters();
                      });
                    },
                  ),
                ],
                if (_filterTag != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(_filterTag!),
                    onDeleted: () {
                      setState(() {
                        _filterTag = null;
                        _applyFilters();
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          // 日志列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredLogs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '暂无日志',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshLogs,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _filteredLogs.length,
                      itemBuilder: (context, index) {
                        final log = _filteredLogs[index];
                        return _buildLogItem(log);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// 构建日志项
  Widget _buildLogItem(LogEntry log) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: InkWell(
        onTap: () => _showLogDetail(log),
        onLongPress: () => _copyLog(log),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Color(log.level.colorValue).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      log.level.shortName,
                      style: TextStyle(
                        color: Color(log.level.colorValue),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    log.tag,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${_twoDigits(log.timestamp.hour)}:${_twoDigits(log.timestamp.minute)}:${_twoDigits(log.timestamp.second)}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                log.shortDescription,
                style: const TextStyle(fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
