import 'log_level.dart';

/// 日志条目类
/// 表示单条日志记录
class LogEntry {
  /// 日志ID（时间戳+随机数）
  final String id;

  /// 日志时间
  final DateTime timestamp;

  /// 日志级别
  final LogLevel level;

  /// 日志标签/模块名
  final String tag;

  /// 日志消息
  final String message;

  /// 错误对象（如果有）
  final String? error;

  /// 堆栈跟踪（如果有）
  final String? stackTrace;

  /// 附加数据（可选）
  final Map<String, dynamic>? data;

  LogEntry({
    required this.id,
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
    this.data,
  });

  /// 从JSON创建日志条目
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      id: json['id'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      level: LogLevel.values[json['level'] as int],
      tag: json['tag'] as String,
      message: json['message'] as String,
      error: json['error'] as String?,
      stackTrace: json['stackTrace'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'level': level.index,
      'tag': tag,
      'message': message,
      'error': error,
      'stackTrace': stackTrace,
      'data': data,
    };
  }

  /// 获取格式化的日志文本（用于显示和文件存储）
  String get formattedLog {
    final buffer = StringBuffer();
    buffer.write('[${_formatTime(timestamp)}]');
    buffer.write('[${level.shortName}]');
    buffer.write('[$tag]');
    buffer.write(' $message');

    if (error != null) {
      buffer.write('\n  Error: $error');
    }

    if (stackTrace != null) {
      buffer.write('\n  StackTrace:\n$stackTrace');
    }

    return buffer.toString();
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    return '${time.year}-${_twoDigits(time.month)}-${_twoDigits(time.day)} '
        '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}:${_twoDigits(time.second)}.'
        '${time.millisecond.toString().padLeft(3, '0')}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  /// 简短描述（用于列表显示）
  String get shortDescription {
    if (message.length > 50) {
      return '${message.substring(0, 50)}...';
    }
    return message;
  }

  @override
  String toString() {
    return 'LogEntry{${level.shortName}, $tag, $message}';
  }
}

/// 日志过滤条件
class LogFilter {
  /// 最低日志级别（只显示该级别及以上的日志）
  final LogLevel? minLevel;

  /// 标签过滤（只显示指定标签的日志）
  final String? tag;

  /// 关键词过滤
  final String? keyword;

  /// 开始时间
  final DateTime? startTime;

  /// 结束时间
  final DateTime? endTime;

  const LogFilter({
    this.minLevel,
    this.tag,
    this.keyword,
    this.startTime,
    this.endTime,
  });

  /// 检查日志条目是否符合过滤条件
  bool matches(LogEntry entry) {
    // 级别过滤
    if (minLevel != null && entry.level.priority < minLevel!.priority) {
      return false;
    }

    // 标签过滤
    if (tag != null && entry.tag != tag) {
      return false;
    }

    // 关键词过滤
    if (keyword != null && keyword!.isNotEmpty) {
      final searchText = '${entry.tag} ${entry.message} ${entry.error ?? ''}'
          .toLowerCase();
      if (!searchText.contains(keyword!.toLowerCase())) {
        return false;
      }
    }

    // 时间范围过滤
    if (startTime != null && entry.timestamp.isBefore(startTime!)) {
      return false;
    }
    if (endTime != null && entry.timestamp.isAfter(endTime!)) {
      return false;
    }

    return true;
  }
}
