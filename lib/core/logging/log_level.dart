/// 日志级别枚举
/// 定义日志的严重程度，从低到高排列
enum LogLevel {
  /// 调试信息 - 详细的开发调试信息
  debug,

  /// 普通信息 - 一般性的操作记录
  info,

  /// 警告 - 需要注意但非致命的问题
  warning,

  /// 错误 - 操作失败或异常情况
  error,

  /// 严重错误 - 导致功能不可用的错误
  fatal,
}

/// 日志级别扩展
extension LogLevelExtension on LogLevel {
  /// 获取日志级别的中文名称
  String get name {
    switch (this) {
      case LogLevel.debug:
        return '调试';
      case LogLevel.info:
        return '信息';
      case LogLevel.warning:
        return '警告';
      case LogLevel.error:
        return '错误';
      case LogLevel.fatal:
        return '严重';
    }
  }

  /// 获取日志级别的英文缩写
  String get shortName {
    switch (this) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }

  /// 获取日志级别对应的颜色值（用于UI显示）
  int get colorValue {
    switch (this) {
      case LogLevel.debug:
        return 0xFF9E9E9E; // 灰色
      case LogLevel.info:
        return 0xFF2196F3; // 蓝色
      case LogLevel.warning:
        return 0xFFFF9800; // 橙色
      case LogLevel.error:
        return 0xFFE91E63; // 红色
      case LogLevel.fatal:
        return 0xFFB71C1C; // 深红色
    }
  }

  /// 获取日志级别的优先级数值（用于比较）
  int get priority {
    switch (this) {
      case LogLevel.debug:
        return 0;
      case LogLevel.info:
        return 1;
      case LogLevel.warning:
        return 2;
      case LogLevel.error:
        return 3;
      case LogLevel.fatal:
        return 4;
    }
  }
}
