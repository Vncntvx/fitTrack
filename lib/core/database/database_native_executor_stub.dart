import 'package:drift/drift.dart';

/// Web 等不支持 FFI 的平台不允许直接按路径打开本地数据库。
QueryExecutor openNativeDatabase(String path) {
  throw UnsupportedError('当前平台不支持按路径打开本地数据库: $path');
}
