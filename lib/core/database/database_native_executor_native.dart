import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

/// 原生平台按指定路径打开数据库，供前台服务与测试复用。
QueryExecutor openNativeDatabase(String path) {
  return NativeDatabase(File(path), logStatements: false);
}
