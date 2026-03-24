# 运动追踪应用开发文档

本文档包含运动追踪应用的开发环境配置、项目结构、编码规范和常用操作指南。

---

## 环境要求

### Flutter 版本
- Flutter: 3.41 或更高版本
- Dart: 3.11 或更高版本

### 验证环境
```bash
# 检查 Flutter 环境
flutter doctor

# 检查 Flutter 版本
flutter --version

# 检查 Dart 版本
dart --version
```

### 支持的运行平台
- Android (API 21+)
- Web (Chrome, Firefox, Safari)
- iOS (开发中)

---

## 开发环境配置

### 1. 安装 Flutter

根据官方文档安装 Flutter SDK:
https://flutter.dev/docs/get-started/install

### 2. 克隆项目

```bash
git clone <项目仓库地址>
cd fittrack
```

### 3. 安装依赖

```bash
flutter pub get
```

### 4. 代码生成

本项目使用代码生成工具生成 Riverpod 和 Drift 的相关代码。

```bash
# 生成代码（一次性）
flutter pub run build_runner build

# 监听文件变化并自动生成（推荐开发时使用）
flutter pub run build_runner watch
```

### 5. 运行应用

```bash
# 运行调试版本
flutter run

# 指定设备运行
flutter run -d <设备ID>

# 以 Web 模式运行
flutter run -d chrome
```

---

## 项目结构

```
fittrack/
├── android/                    # Android 平台代码
├── ios/                        # iOS 平台代码
├── web/                        # Web 平台代码
├── lib/                        # 主代码目录
│   ├── app.dart                # 应用根组件
│   ├── main.dart               # 应用入口
│   ├── core/                   # 核心功能
│   │   ├── backup/             # 备份相关
│   │   ├── database/           # 数据库 (Drift)
│   │   │   ├── tables/         # 数据表定义
│   │   │   └── database.dart   # 数据库配置
│   │   ├── lan_service/        # 局域网服务
│   │   │   ├── routes/         # API 路由
│   │   │   └── middleware/     # 中间件
│   │   ├── providers/          # Riverpod Providers
│   │   ├── repositories/       # 数据仓库
│   │   ├── router/             # 路由配置
│   │   └── secure_storage/     # 安全存储
│   ├── features/               # 功能模块
│   │   ├── backup/             # 备份功能页面
│   │   ├── history/            # 历史记录页面
│   │   ├── quick_log/          # 快速记录页面
│   │   ├── settings/           # 设置页面
│   │   ├── stats/              # 统计页面
│   │   └── today/              # 今日页面
│   ├── shared/                 # 共享组件
│   │   ├── theme/              # 主题配置
│   │   └── widgets/            # 通用组件
│   └── web/                    # Web 管理界面
│       └── admin/              # 管理后台页面
├── test/                       # 测试代码
├── pubspec.yaml                # 依赖配置
└── analysis_options.yaml       # 代码分析配置
```

---

## 编码规范

### 通用规范

1. **代码注释**: 所有代码注释使用中文
2. **命名规范**: 使用小写下划线命名法 (snake_case) 作为文件名
3. **类命名**: 使用大驼峰命名法 (PascalCase)
4. **函数和变量**: 使用小驼峰命名法 (camelCase)

### Riverpod 使用规范

#### Provider 定义

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'example_provider.g.dart';  // 代码生成文件

/// Provider 文档注释
@riverpod
class ExampleNotifier extends _$ExampleNotifier {
  @override
  FutureOr<ReturnType> build() async {
    // 初始化逻辑
    return initialValue;
  }

  /// 方法文档注释
  Future<void> someMethod() async {
    // 方法实现
  }
}

/// 简单的 Provider
@riverpod
ReturnType exampleProvider(ExampleProviderRef ref) {
  return value;
}
```

#### Provider 使用

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听 Provider
    final asyncValue = ref.watch(exampleNotifierProvider);

    // 读取 Provider（不监听变化）
    final value = ref.read(exampleProvider);

    return asyncValue.when(
      data: (data) => Text('$data'),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('错误: $error'),
    );
  }
}
```

### Drift 数据库规范

#### 表定义

```dart
import 'package:drift/drift.dart';

/// 表的中文说明
class TableNames extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 字段中文说明
  TextColumn get name => text()();

  /// 可空字段
  TextColumn get description => text().nullable()();

  /// 带默认值的字段
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();

  /// 创建时间
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}
```

#### 数据库操作

```dart
// 查询数据
final results = await db.select(db.tableNames).get();

// 条件查询
final result = await (db.select(db.tableNames)
  ..where((t) => t.id.equals(id)))
  .getSingleOrNull();

// 插入数据
await db.into(db.tableNames).insert(
  TableNamesCompanion(name: Value('名称')),
);

// 更新数据
await db.update(db.tableNames).replace(
  TableNamesCompanion(id: Value(id), name: Value('新名称')),
);

// 删除数据
await (db.delete(db.tableNames)
  ..where((t) => t.id.equals(id)))
  .go();

// 响应式查询
Stream<List<TableName>> watchAll() {
  return db.select(db.tableNames).watch();
}
```

### Repository 模式

```dart
/// 仓库类中文说明
class ExampleRepository {
  final AppDatabase _db;

  ExampleRepository(this._db);

  /// 创建记录
  Future<int> create({required String name}) async {
    return await _db.into(_db.tableNames).insert(
      TableNamesCompanion(name: Value(name)),
    );
  }

  /// 查询所有记录
  Future<List<TableName>> getAll() async {
    return await _db.select(_db.tableNames).get();
  }

  /// 响应式查询
  Stream<List<TableName>> watchAll() {
    return _db.select(_db.tableNames).watch();
  }
}
```

### 页面组件规范

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 页面中文说明
class ExamplePage extends ConsumerWidget {
  const ExamplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('页面标题')),
      body: BodyContent(),
    );
  }
}
```

---

## 测试指南

### 运行测试

```bash
# 运行所有测试
flutter test

# 运行特定测试文件
flutter test test/widget_test.dart

# 运行测试并显示覆盖率
flutter test --coverage
```

### 测试代码规范

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('功能分组', () {
    test('测试描述', () {
      // 测试代码
      expect(actualValue, expectedValue);
    });

    testWidgets('Widget 测试', (WidgetTester tester) async {
      // 构建 Widget
      await tester.pumpWidget(const MyWidget());

      // 验证结果
      expect(find.text('预期文本'), findsOneWidget);
    });
  });
}
```

### 测试原则

1. **TDD 工作流**: 先写测试，再写实现
2. **每个功能提交**: 每个功能完成后提交 Git
3. **测试覆盖率**: 核心业务逻辑需要测试覆盖

---

## 构建命令

### Android 构建

```bash
# 构建 APK（调试版）
flutter build apk --debug

# 构建 APK（发布版）
flutter build apk --release

# 构建 App Bundle（发布版）
flutter build appbundle --release
```

### Web 构建

```bash
# 构建 Web（调试版）
flutter build web --debug

# 构建 Web（发布版）
flutter build web --release

# 构建 Web 并指定基础路径
flutter build web --base-href /app/
```

### 其他命令

```bash
# 清理构建缓存
flutter clean

# 重新安装依赖
flutter pub get

# 代码分析
flutter analyze

# 格式化代码
dart format .

# 检查依赖更新
flutter pub outdated
```

---

## Git 工作流

### 分支策略

- `main`: 主分支，稳定版本
- `develop`: 开发分支，日常开发
- `feature/*`: 功能分支，单个功能开发
- `bugfix/*`: 修复分支，问题修复

### 提交规范

```bash
# 功能开发
git commit -m "feat: 添加用户登录功能"

# 问题修复
git commit -m "fix: 修复数据库查询错误"

# 代码重构
git commit -m "refactor: 优化 Repository 结构"

# 测试代码
git commit -m "test: 添加单元测试"

# 文档更新
git commit -m "docs: 更新 API 文档"
```

### 开发流程

1. **创建功能分支**
   ```bash
   git checkout -b feature/功能名称
   ```

2. **开发并提交**
   ```bash
   # 开发代码...
   git add .
   git commit -m "feat: 功能描述"
   ```

3. **合并到开发分支**
   ```bash
   git checkout develop
   git merge feature/功能名称
   ```

4. **每个功能提交**: 每完成一个功能后立即提交代码

---

## 常用依赖说明

### 核心依赖

| 依赖包 | 版本 | 用途 |
|--------|------|------|
| flutter | SDK | Flutter 框架 |
| drift | ^2.18.0 | 数据库 ORM |
| riverpod | ^2.5.0 | 状态管理 |
| shelf | ^1.4.2 | HTTP 服务器 |
| go_router | ^13.0.0 | 路由管理 |
| fl_chart | ^0.68.0 | 图表组件 |

### 开发依赖

| 依赖包 | 版本 | 用途 |
|--------|------|------|
| drift_dev | ^2.18.0 | Drift 代码生成 |
| riverpod_generator | ^2.4.0 | Riverpod 代码生成 |
| build_runner | ^2.4.0 | 代码生成工具 |
| mockito | ^5.4.0 | 测试 Mock |

---

## 常见问题

### 代码生成失败

```bash
# 清理并重新生成
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### 数据库迁移

修改表结构后需要:
1. 更新 `schemaVersion`
2. 添加迁移逻辑
3. 重新生成代码

```dart
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
  onUpgrade: (migrator, from, to) async {
    if (from < 2) {
      // 执行迁移
    }
  },
);
```

### 依赖冲突

```bash
# 检查依赖冲突
flutter pub deps

# 强制更新依赖
flutter pub upgrade --major-versions
```

---

## 开发检查清单

- [ ] 代码注释使用中文
- [ ] 添加必要的文档注释
- [ ] 运行代码生成工具
- [ ] 执行代码分析 (`flutter analyze`)
- [ ] 格式化代码 (`dart format`)
- [ ] 运行测试 (`flutter test`)
- [ ] 提交 Git 并写清楚提交信息

---

## 相关链接

- [Flutter 官方文档](https://flutter.dev/docs)
- [Riverpod 文档](https://riverpod.dev/)
- [Drift 文档](https://drift.simonbinder.eu/)
- [Dart 语言文档](https://dart.dev/guides)
