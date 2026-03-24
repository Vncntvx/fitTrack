# AGENTS.md

> 本文档为 AI 助手提供项目关键上下文，包含架构规范和最佳实践。

---

## 项目概述

运动追踪 (FitTrack) 是 Flutter 健身记录应用，支持力量训练、跑步、游泳等运动。采用本地优先架构，数据存储在 SQLite，通过局域网 HTTP 服务向 Web 端提供接口。

**技术栈**: Flutter 3.32+ / Dart 3.11+ / Riverpod 3.x / Drift 2.x / Shelf / go_router

---

## 分层架构

```text
UI (features/) → Riverpod → Use Case (usecases/) → Repository (repositories/) → Drift (SQLite)
```

**核心原则**: Use Case 封装业务逻辑，Repository 仅负责数据访问。禁止跨层调用。

---

## Use Case 规范

### 基类

```dart
abstract class UseCase<T, P> {
  Future<T> call(P params);
}
```

### 创建时机

**必须创建**: 多步数据库操作、协调多个 Repository、业务规则验证、Read-Compare-Write/Check-Then-Act 模式

**无需创建**: 简单 CRUD、单表查询

### 实现要点

1. **结果枚举**: 使用枚举明确返回结果（如 `DeleteTrainingResult.success`）
2. **参数对象**: 复杂操作使用参数类封装
3. **强制事务**: 所有多步操作必须使用 `_db.transaction()`
4. **竞态防护**: Read-Compare-Write 和 Check-Then-Act 必须在事务内执行

### 现有 Use Cases

`DeleteTrainingUseCase` | `DeleteExerciseUseCase` | `SaveStrengthSessionUseCase` | `SaveRunningSessionUseCase` | `SaveSwimmingSessionUseCase` | `CheckStrengthPrUseCase` | `CheckRunningPrUseCase` | `CheckSwimmingPrUseCase`

---

## Repository 规范

**仅负责**: CRUD、简单查询、响应式数据流 (`watchAll()`)

**禁止包含**: 业务逻辑验证、多步操作协调、跨表操作

---

## 数据库规范

### 外键约束

**强制要求**: 所有外键必须使用 `.references()`，明确指定 `onDelete` 行为。

### 索引规范

**强制要求**: 高频查询字段使用 `@TableIndex`。组合索引：等值查询在前，范围/排序在后。

### 查询优化

**禁止**在 Dart 内存中进行数据库聚合，必须使用 SQL 聚合函数。

### 级联删除

删除父记录时必须在事务中级联删除子记录。

---

## 状态管理

### Provider 组织

**文件**: `lib/core/providers/usecase_providers.dart`

使用 `@riverpod` 代码生成，禁止手动定义 Provider。

### UI 调用模式

```dart
// ✅ 通过 Use Case 执行业务操作
final useCase = ref.read(deleteTrainingUseCaseProvider);
// ❌ 禁止 UI 直接调用 Repository 执行业务操作
```

---

## UI 规范

### 共享组件

**强制使用**: `LoadingIndicator`（加载）、`EmptyStateWidget`（空状态）、`AsyncValueWidget`（AsyncValue 处理）。禁止各页面重复实现。

### 图表样式

必须使用 `ChartColors`/`ChartTheme`，禁止硬编码颜色。

### Material 3

所有 UI 必须使用 Material 3 (`useMaterial3: true`)。

---

## 错误处理

- **Use Case**: 使用枚举返回结果
- **Repository**: nullable 返回类型表示记录不存在，`ArgumentError` 验证参数
- **UI**: 使用 `AsyncValueWidget` 统一处理，支持重试
- **全局**: `main.dart` 已配置 `FlutterError.onError` 和 `PlatformDispatcher.instance.onError`

---

## 测试规范

**推荐**使用真实数据库进行集成测试，而非 mock。每个测试使用独立临时数据库，测试后清理资源。

---

## 编码规范

- **注释**: 中文
- **文件**: `snake_case.dart`
- **类**: `PascalCase`
- **变量/函数**: `camelCase`
- **私有成员**: `_`前缀
- **提交**: `feat:`/`fix:`/`refactor:`/`test:`/`docs:`

---

## 关键文件

| 文件 | 用途 |
|------|------|
| `lib/core/usecases/base/usecase.dart` | Use Case 基类 |
| `lib/core/usecases/*/` | Use Case 实现 |
| `lib/core/repositories/*.dart` | 数据仓库 |
| `lib/core/providers/usecase_providers.dart` | Providers |
| `lib/core/database/tables/*.dart` | 数据表定义 |
| `lib/shared/widgets/async_value_widget.dart` | AsyncValue 处理 |
| `lib/shared/widgets/charts/` | 图表样式 |

---

## 构建命令

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run
```

---

## 模拟器部署

创建新emulators(API 36 arm)或使用现有emulators `fittrack_api36_arm`。启动模拟器后，使用 `flutter run` 部署应用。

```bash
flutter emulators --launch fittrack_api36_arm
flutter run
```
