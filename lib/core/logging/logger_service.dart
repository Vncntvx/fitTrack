import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'log_level.dart';
import 'log_entry.dart';

/// 日志服务
/// 管理应用日志的记录、存储和查询
class LoggerService {
  static LoggerService? _instance;
  static LoggerService get instance => _instance ??= LoggerService();

  /// 当前日志级别阈值
  /// 低于此级别的日志不会被记录
  LogLevel _minLevel = LogLevel.debug;
  LogLevel get minLevel => _minLevel;

  /// 日志文件最大大小（字节）
  static const int _maxFileSize = 5 * 1024 * 1024; // 5MB

  /// 最大保留日志天数
  static const int _maxRetentionDays = 7;

  /// 日志目录路径
  Directory? _logDir;

  /// 当前日志文件
  File? _currentLogFile;

  /// 内存中的日志缓存（用于快速访问最近日志）
  final List<LogEntry> _memoryCache = [];

  /// 最大内存缓存条目数
  static const int _maxMemoryCacheSize = 1000;

  /// 日志写入控制器
  final _logController = StreamController<LogEntry>.broadcast();
  Stream<LogEntry> get logStream => _logController.stream;

  /// 是否已初始化
  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// 初始化日志服务
  Future<void> initialize({LogLevel minLevel = LogLevel.debug}) async {
    if (_initialized) return;

    _minLevel = minLevel;

    try {
      final appDir = await getApplicationSupportDirectory();
      _logDir = Directory('${appDir.path}/logs');

      if (!await _logDir!.exists()) {
        await _logDir!.create(recursive: true);
      }

      // 获取或创建当天的日志文件
      _currentLogFile = await _getOrCreateLogFile();

      // 清理过期日志
      await _cleanupOldLogs();

      _initialized = true;

      // 记录服务启动
      await log(
        level: LogLevel.info,
        tag: 'LoggerService',
        message: '日志服务已初始化',
        data: {'logDir': _logDir!.path, 'minLevel': minLevel.name},
      );
    } catch (e) {
      // 如果初始化失败，使用备用方案（仅内存日志）
      _initialized = true;
      await log(
        level: LogLevel.error,
        tag: 'LoggerService',
        message: '日志服务初始化失败: $e',
      );
    }
  }

  /// 记录日志
  Future<void> log({
    required LogLevel level,
    required String tag,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) async {
    // 检查日志级别
    if (level.priority < _minLevel.priority) return;

    // 创建日志条目
    final entry = LogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_${_generateRandomId()}',
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
      data: data,
    );

    // 添加到内存缓存
    _addToMemoryCache(entry);

    // 通知监听器
    _logController.add(entry);

    // 写入文件
    await _writeToFile(entry);

    // 调试输出（开发时）
    _debugPrint(entry);
  }

  /// 快捷方法：调试日志
  Future<void> debug(
    String tag,
    String message, {
    Map<String, dynamic>? data,
  }) async {
    await log(level: LogLevel.debug, tag: tag, message: message, data: data);
  }

  /// 快捷方法：信息日志
  Future<void> info(
    String tag,
    String message, {
    Map<String, dynamic>? data,
  }) async {
    await log(level: LogLevel.info, tag: tag, message: message, data: data);
  }

  /// 快捷方法：警告日志
  Future<void> warning(
    String tag,
    String message, {
    Object? error,
    Map<String, dynamic>? data,
  }) async {
    await log(
      level: LogLevel.warning,
      tag: tag,
      message: message,
      error: error,
      data: data,
    );
  }

  /// 快捷方法：错误日志
  Future<void> error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) async {
    await log(
      level: LogLevel.error,
      tag: tag,
      message: message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// 快捷方法：严重错误日志
  Future<void> fatal(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) async {
    await log(
      level: LogLevel.fatal,
      tag: tag,
      message: message,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  /// 设置日志级别
  Future<void> setMinLevel(LogLevel level) async {
    _minLevel = level;
    await log(
      level: LogLevel.info,
      tag: 'LoggerService',
      message: '日志级别已设置为: ${level.name}',
    );
  }

  /// 获取内存缓存中的所有日志
  List<LogEntry> getMemoryLogs() {
    return List.unmodifiable(_memoryCache);
  }

  /// 查询日志（支持过滤）
  Future<List<LogEntry>> queryLogs(LogFilter filter) async {
    final results = <LogEntry>[];

    // 先检查内存缓存
    for (final entry in _memoryCache) {
      if (filter.matches(entry)) {
        results.add(entry);
      }
    }

    // 如果内存不够，从文件读取
    if (results.length < 100) {
      final fileLogs = await _readLogsFromFiles(filter);
      results.addAll(fileLogs);
    }

    // 按时间排序（最新的在前）
    results.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return results;
  }

  /// 获取所有日志文件
  Future<List<File>> getLogFiles() async {
    if (_logDir == null) return [];

    final files = await _logDir!
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.log'))
        .map((entity) => entity as File)
        .toList();

    // 按修改时间排序（最新的在前）
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

    return files;
  }

  /// 获取当前日志文件大小
  Future<int> getCurrentLogFileSize() async {
    if (_currentLogFile == null) return 0;
    try {
      return await _currentLogFile!.length();
    } catch (e) {
      return 0;
    }
  }

  /// 清空所有日志
  Future<void> clearAllLogs() async {
    _memoryCache.clear();

    if (_logDir != null && await _logDir!.exists()) {
      await _logDir!.delete(recursive: true);
      await _logDir!.create(recursive: true);
    }

    _currentLogFile = await _getOrCreateLogFile();

    await log(level: LogLevel.info, tag: 'LoggerService', message: '所有日志已清空');
  }

  /// 导出日志到文件
  Future<String?> exportLogs(String exportPath) async {
    try {
      final logFiles = await getLogFiles();
      if (logFiles.isEmpty) return null;

      final exportFile = File(exportPath);
      final buffer = StringBuffer();

      buffer.writeln('=== FitTrack 日志导出 ===');
      buffer.writeln('导出时间: ${DateTime.now()}');
      buffer.writeln('');

      for (final logFile in logFiles.reversed) {
        buffer.writeln('--- ${logFile.path.split('/').last} ---');
        final content = await logFile.readAsString();
        buffer.writeln(content);
        buffer.writeln('');
      }

      await exportFile.writeAsString(buffer.toString());
      return exportPath;
    } catch (e) {
      await error('LoggerService', '导出日志失败', error: e);
      return null;
    }
  }

  /// 获取日志统计信息
  Future<Map<String, dynamic>> getLogStats() async {
    final stats = {
      'totalInMemory': _memoryCache.length,
      'totalFiles': 0,
      'totalSize': 0,
      'errorCount': _memoryCache.where((e) => e.level == LogLevel.error).length,
      'warningCount': _memoryCache
          .where((e) => e.level == LogLevel.warning)
          .length,
    };

    final files = await getLogFiles();
    stats['totalFiles'] = files.length;

    for (final file in files) {
      stats['totalSize'] = (stats['totalSize'] as int) + await file.length();
    }

    return stats;
  }

  /// 关闭日志服务
  Future<void> dispose() async {
    await log(level: LogLevel.info, tag: 'LoggerService', message: '日志服务正在关闭');

    await _logController.close();
    _instance = null;
  }

  // ===== 私有方法 =====

  /// 获取或创建当天的日志文件
  Future<File> _getOrCreateLogFile() async {
    final now = DateTime.now();
    final fileName =
        'fittrack_${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}.log';
    final file = File('${_logDir!.path}/$fileName');

    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(
        '=== FitTrack 日志文件 ${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} ===\n\n',
      );
    }

    return file;
  }

  /// 写入日志到文件
  Future<void> _writeToFile(LogEntry entry) async {
    try {
      if (_currentLogFile == null) return;

      // 检查文件大小，如果超过限制则创建新文件
      final fileSize = await _currentLogFile!.length();
      if (fileSize > _maxFileSize) {
        _currentLogFile = await _getOrCreateLogFile();
      }

      // 写入日志（优先 JSON 行，便于后续解析）
      final line = '${jsonEncode(entry.toJson())}\n';
      await _currentLogFile!.writeAsString(
        line,
        mode: FileMode.append,
        flush: true,
      );
    } catch (e) {
      // 文件写入失败时静默处理，避免无限循环
      debugPrint('日志写入失败: $e');
    }
  }

  /// 添加到内存缓存
  void _addToMemoryCache(LogEntry entry) {
    _memoryCache.add(entry);

    // 保持缓存大小在限制内
    if (_memoryCache.length > _maxMemoryCacheSize) {
      _memoryCache.removeAt(0);
    }
  }

  /// 从文件读取日志
  Future<List<LogEntry>> _readLogsFromFiles(LogFilter filter) async {
    final results = <LogEntry>[];

    try {
      final files = await getLogFiles();

      for (final file in files.take(7)) {
        // 只读取最近7天的文件
        final content = await file.readAsString();
        final lines = content.split('\n');

        for (final line in lines) {
          if (line.trim().isEmpty) continue;

          try {
            // 先尝试 JSON 行格式，再回退历史文本格式
            final entry = _parseJsonLogLine(line) ?? _parseLogLine(line);
            if (entry != null && filter.matches(entry)) {
              results.add(entry);
            }
          } catch (e) {
            // 解析失败的行跳过，继续处理下一行
            continue;
          }
        }
      }
    } catch (e) {
      debugPrint('读取日志文件失败: $e');
    }

    return results;
  }

  /// 解析日志行
  LogEntry? _parseLogLine(String line) {
    try {
      // 简单解析格式: [2024-01-15 10:30:45.123][INFO][Tag] Message
      final regex = RegExp(
        r'\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d{3})\]\[(\w+)\]\[(\w+)\] (.+)',
      );
      final match = regex.firstMatch(line);

      if (match != null) {
        final timestamp = DateTime.parse(match.group(1)!);
        final levelStr = match.group(2)!;
        final tag = match.group(3)!;
        final message = match.group(4)!;

        LogLevel level = LogLevel.info;
        switch (levelStr) {
          case 'DEBUG':
            level = LogLevel.debug;
            break;
          case 'INFO':
            level = LogLevel.info;
            break;
          case 'WARN':
            level = LogLevel.warning;
            break;
          case 'ERROR':
            level = LogLevel.error;
            break;
          case 'FATAL':
            level = LogLevel.fatal;
            break;
        }

        return LogEntry(
          id: '${timestamp.millisecondsSinceEpoch}_${_generateRandomId()}',
          timestamp: timestamp,
          level: level,
          tag: tag,
          message: message,
        );
      }
    } catch (e) {
      // 日志行解析失败，返回 null
      return null;
    }
    return null;
  }

  LogEntry? _parseJsonLogLine(String line) {
    try {
      final raw = jsonDecode(line);
      if (raw is! Map<String, dynamic>) return null;
      return LogEntry.fromJson(raw);
    } catch (e) {
      // JSON 解析失败，返回 null
      return null;
    }
  }

  /// 清理过期日志
  Future<void> _cleanupOldLogs() async {
    try {
      if (_logDir == null) return;

      final cutoffDate = DateTime.now().subtract(
        const Duration(days: _maxRetentionDays),
      );
      final files = await _logDir!.list().toList();

      for (final entity in files) {
        if (entity is File && entity.path.endsWith('.log')) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('清理过期日志失败: $e');
    }
  }

  /// 调试输出
  void _debugPrint(LogEntry entry) {
    // 在开发模式下输出到控制台
    assert(() {
      debugPrint('[${entry.level.shortName}][${entry.tag}] ${entry.message}');
      if (entry.error != null) {
        debugPrint('  Error: ${entry.error}');
      }
      return true;
    }());
  }

  /// 生成随机ID
  String _generateRandomId() {
    return '${DateTime.now().microsecond}${(1000 + DateTime.now().millisecond)}';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
