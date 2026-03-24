# FitTrack 数据流文档

> 本文档详细描述 FitTrack 各个核心场景的数据流动过程。
>
> **版本**: 1.0.0
> **最后更新**: 2026-03-25

---

## 目录

1. [数据流概述](#1-数据流概述)
2. [训练记录保存](#2-训练记录保存)
3. [训练记录删除](#3-训练记录删除)
4. [PR 检测与更新](#4-pr-检测与更新)
5. [备份与恢复](#5-备份与恢复)
6. [响应式数据更新](#6-响应式数据更新)
7. [LAN API 数据流](#7-lan-api-数据流)

---

## 1. 数据流概述

### 1.1 标准数据流模型

```mermaid
flowchart LR
    User["用户"] -->|操作| UI["UI Layer"]
    UI -->|调用| Provider["Provider"]
    Provider -->|创建| UC["Use Case"]
    UC -->|事务| DB["Database"]
    UC -->|查询/更新| Repo["Repository"]
    Repo -->|SQL| DB
    DB -->|结果| Repo
    Repo -->|数据| UC
    UC -->|结果| Provider
    Provider -->|状态| UI
    UI -->|展示| User
```

### 1.2 数据流原则

1. **单向数据流**：数据从 UI 流向数据库，结果流回 UI
2. **事务边界**：多步操作在事务中执行，保证原子性
3. **响应式更新**：Stream 自动推送数据变更
4. **错误传播**：错误逐层返回，UI 统一处理

---

## 2. 训练记录保存

### 2.1 力量训练保存流程

```mermaid
sequenceDiagram
    actor User
    participant UI as StrengthSessionPage
    participant Prov as saveStrengthSessionUseCaseProvider
    participant UC as SaveStrengthSessionUseCase
    participant DB as AppDatabase
    participant TR as TrainingRepository
    participant SR as StrengthEntryRepository
    participant PR as RebuildPersonalRecordsUseCase

    User->>UI: 填写训练数据<br/>点击保存
    Note over UI: 收集表单数据<br/>构建参数对象

    UI->>Prov: ref.read(useCase)
    Prov-->>UI: SaveStrengthSessionUseCase

    UI->>UC: call(params)
    Note over UC: params 包含：<br/>- startTime<br/>- exercises 列表<br/>- templateId 等

    UC->>DB: transaction(() async { ... })
    Note over DB: 开启 SQLite 事务

    alt 更新模式 (sessionId != null)
        UC->>TR: updateTraining(sessionId, ...)
        TR->>DB: UPDATE training_sessions
        DB-->>TR: 更新成功
        TR-->>UC: true
        UC->>UC: sessionId = params.sessionId
    else 新建模式 (sessionId == null)
        UC->>TR: createTraining(...)
        TR->>DB: INSERT INTO training_sessions
        DB-->>TR: 新记录 ID
        TR-->>UC: sessionId
    end

    UC->>DB: DELETE FROM strength_exercise_entries<br/>WHERE sessionId = ?
    Note over DB: 清除旧条目（更新场景）

    loop 遍历 exercises
        UC->>UC: 处理 exercise 数据<br/>- JSON 编码列表<br/>- 计算最大 RPE<br/>- 提取休息时间
        UC->>SR: addStrengthExercise(...)
        SR->>DB: INSERT INTO strength_exercise_entries
        DB-->>SR: 新条目 ID
        SR-->>UC: entryId
    end

    UC->>PR: rebuildForTrainingType('strength')
    Note over PR: 重建力量训练 PR
    PR->>DB: 查询所有力量训练记录
    DB-->>PR: 记录列表
    PR->>PR: 重新计算每个动作的 PR
    PR->>DB: UPDATE/INSERT personal_records
    DB-->>PR: 完成
    PR-->>UC: void

    DB-->>UC: COMMIT 事务
    UC-->>UI: sessionId

    UI->>UI: 导航返回首页
    UI-->>User: 显示成功提示
```

### 2.2 数据转换细节

#### 输入数据（UI）

```dart
// 用户填写的表单数据
StrengthExerciseInput {
  exerciseId: 1,
  exerciseName: "卧推",
  defaultReps: 10,
  defaultWeight: 60.0,
  repsPerSet: [10, 8, 6],
  weightPerSet: [60.0, 65.0, 70.0],
  completedSets: [true, true, true],
  rpeValues: [8, 9, 10],
  restSecondsValues: [90, 120, null],
}
```

#### 存储数据（Database）

```dart
// 转换后的数据库存储
StrengthExerciseEntriesCompanion {
  sessionId: Value(123),
  exerciseId: Value(1),
  exerciseName: Value("卧推"),
  sets: Value(3),
  defaultReps: Value(10),
  defaultWeight: Value(60.0),
  repsPerSet: Value("[10, 8, 6]"),      // JSON 编码
  weightPerSet: Value("[60.0, 65.0, 70.0]"),  // JSON 编码
  setCompleted: Value("[true, true, true]"),
  rpe: Value(10),                        // 最大值
  restSeconds: Value(90),                // 第一个非 null 值
  sortOrder: Value(0),
}
```

---

## 3. 训练记录删除

### 3.1 级联删除流程

```mermaid
sequenceDiagram
    actor User
    participant UI as HistoryPage
    participant Prov as deleteTrainingUseCaseProvider
    participant UC as DeleteTrainingUseCase
    participant DB as AppDatabase
    participant Repo as TrainingRepository
    participant PR as RebuildPersonalRecordsUseCase

    User->>UI: 点击删除按钮
    UI->>UI: 显示确认对话框

    alt 用户确认删除
        UI->>Prov: ref.read(useCase)
        Prov-->>UI: DeleteTrainingUseCase

        UI->>UC: call(sessionId)

        UC->>DB: transaction(() async { ... })
        Note over DB: 开启事务

        UC->>Repo: getById(sessionId)
        Repo->>DB: SELECT * FROM training_sessions WHERE id = ?
        DB-->>Repo: session 数据
        Repo-->>UC: TrainingSession?

        alt session == null
            UC-->>UI: DeleteTrainingResult.notFound
            UI-->>User: 显示"记录不存在"
        else session != null

            Note over UC: 根据 type 执行级联删除

            alt type == "strength"
                UC->>DB: DELETE FROM strength_exercise_entries<br/>WHERE sessionId = ?
                DB-->>UC: 删除行数
            else type == "running"
                UC->>DB: SELECT id FROM running_entries<br/>WHERE sessionId = ?
                DB-->>UC: runningEntryId
                UC->>DB: DELETE FROM running_splits<br/>WHERE runningEntryId = ?
                UC->>DB: DELETE FROM running_entries<br/>WHERE sessionId = ?
            else type == "swimming"
                UC->>DB: SELECT id FROM swimming_entries<br/>WHERE sessionId = ?
                DB-->>UC: swimmingEntryId
                UC->>DB: DELETE FROM swimming_sets<br/>WHERE swimmingEntryId = ?
                UC->>DB: DELETE FROM swimming_entries<br/>WHERE sessionId = ?
            end

            UC->>DB: DELETE FROM training_sessions<br/>WHERE id = ?
            DB-->>UC: 删除行数

            UC->>PR: rebuildForTrainingType(type)
            Note over PR: 删除后 PR 可能变化
            PR->>DB: 查询该类型所有记录
            DB-->>PR: 记录列表
            PR->>PR: 重新计算 PR
            PR->>DB: UPDATE personal_records
            DB-->>PR: 完成
            PR-->>UC: void

            DB-->>UC: COMMIT 事务
            UC-->>UI: DeleteTrainingResult.success

            UI->>UI: 刷新列表
            UI-->>User: 显示"删除成功"
        end
    else 用户取消
        UI->>UI: 关闭对话框
    end
```

### 3.2 错误处理流程

```mermaid
flowchart TD
    Start([开始删除]) --> Check{检查记录}
    Check -->|不存在| NotFound[返回 notFound]
    Check -->|存在| Transaction[开启事务]

    Transaction --> Cascade[级联删除]
    Cascade -->|失败| Rollback1[回滚事务]
    Rollback1 --> Error1[返回错误]

    Cascade -->|成功| DeleteMain[删除主记录]
    DeleteMain -->|失败| Rollback2[回滚事务]
    Rollback2 --> Error2[返回错误]

    DeleteMain -->|成功| Rebuild[重建 PR]
    Rebuild -->|失败| Rollback3[回滚事务]
    Rollback3 --> Error3[返回错误]

    Rebuild -->|成功| Commit[提交事务]
    Commit --> Success[返回 success]

    NotFound --> End([结束])
    Error1 --> End
    Error2 --> End
    Error3 --> End
    Success --> End
```

---

## 4. PR 检测与更新

### 4.1 PR 检测流程

```mermaid
sequenceDiagram
    participant UC as SaveStrengthSessionUseCase
    participant DB as AppDatabase
    participant Calc as OneRmCalculator
    participant PR as RebuildPersonalRecordsUseCase

    UC->>UC: 事务提交前
    Note over UC: 准备重建 PR

    UC->>PR: rebuildForTrainingType('strength')

    PR->>DB: DELETE FROM personal_records<br/>WHERE recordType LIKE 'strength_%'
    DB-->>PR: 删除行数
    Note over PR: 清空现有力量训练 PR

    PR->>DB: SELECT * FROM strength_exercise_entries<br/>ORDER BY exerciseId, sessionId
    DB-->>PR: 所有力量训练条目

    loop 遍历每个条目
        PR->>PR: 解析 repsPerSet<br/>解析 weightPerSet

        loop 遍历每组数据
            PR->>Calc: calculate(weight, reps)
            Calc-->>PR: estimated1RM

            PR->>PR: 计算容量 volume = weight * reps

            PR->>DB: SELECT * FROM personal_records<br/>WHERE exerciseId = ?<br/>AND recordType = ?
            DB-->>PR: 现有 PR?

            alt 新 1RM > 现有 1RM
                PR->>DB: INSERT/UPDATE personal_records<br/>recordType = 'strength_1rm'
            end

            alt 新 volume > 现有 volume
                PR->>DB: INSERT/UPDATE personal_records<br/>recordType = 'strength_volume'
            end
        end
    end

    PR-->>UC: 完成
```

### 4.2 PR 数据结构

```dart
// 个人记录表结构
PersonalRecords {
  id: 1,
  recordType: 'strength_1rm',      // 记录类型
  exerciseId: 1,                    // 关联动作
  value: 85.5,                      // 记录值（1RM 重量）
  unit: 'kg',                       // 单位
  achievedAt: 2026-03-25T10:00:00Z, // 达成时间
  sessionId: 123,                   // 关联训练会话
}
```

---

## 5. 备份与恢复

### 5.1 备份流程

```mermaid
sequenceDiagram
    actor User
    participant UI as BackupPage
    participant BS as BackupService
    participant DB as AppDatabase
    participant Prov as BackupProvider
    participant Remote as WebDAV/S3

    User->>UI: 点击立即备份
    UI->>BS: backup(configId?)

    BS->>BS: 确定目标配置<br/>（传入的 configId 或默认配置）

    BS->>DB: SELECT * FROM training_sessions
    DB-->>BS: workouts 列表

    BS->>DB: SELECT * FROM strength_exercise_entries
    DB-->>BS: strengthExercises 列表

    BS->>DB: SELECT * FROM running_entries
    DB-->>BS: runningEntries 列表

    BS->>DB: SELECT * FROM running_splits
    DB-->>BS: runningSplits 列表

    BS->>DB: SELECT * FROM swimming_entries
    DB-->>BS: swimmingEntries 列表

    BS->>DB: SELECT * FROM swimming_sets
    DB-->>BS: swimmingSets 列表

    BS->>DB: SELECT * FROM exercises
    DB-->>BS: exercises 列表

    BS->>DB: SELECT * FROM workout_templates
    DB-->>BS: templates 列表

    BS->>DB: SELECT * FROM personal_records
    DB-->>BS: personalRecords 列表

    BS->>DB: SELECT * FROM user_settings
    DB-->>BS: settings 列表

    BS->>BS: 构建备份数据结构<br/>{
      version: "2.0.0",
      exportDate: "...",
      workouts: [...],
      ...
    }

    BS->>BS: jsonEncode(data)
    BS->>BS: utf8.encode(jsonString)
    BS->>BS: sha256.convert(data)
    Note over BS: 计算校验和

    BS->>Prov: upload(remotePath, data)
    Prov->>Remote: HTTP PUT /path/to/backup.json
    Remote-->>Prov: 200 OK
    Prov-->>BS: 上传成功

    BS->>DB: INSERT INTO backup_records<br/>(configId, path, checksum, ...)
    DB-->>BS: 记录 ID

    BS-->>UI: BackupResult(success: true)
    UI-->>User: 显示"备份成功"
```

### 5.2 恢复流程

```mermaid
sequenceDiagram
    actor User
    participant UI as BackupPage
    participant BS as BackupService
    participant DB as AppDatabase
    participant Prov as BackupProvider
    participant Remote as WebDAV/S3

    User->>UI: 选择备份记录，点击恢复
    UI->>BS: restore(record)

    BS->>Prov: download(record.targetPath)
    Prov->>Remote: HTTP GET /path/to/backup.json
    Remote-->>Prov: 文件内容
    Prov-->>BS: Uint8List data

    BS->>BS: sha256.convert(data)
    BS->>BS: 计算校验和

    alt 校验和 != record.checksum
        BS-->>UI: RestoreResult(success: false,<br/>error: "校验和不匹配")
        UI-->>User: 显示"备份文件已损坏"
    else 校验和匹配
        BS->>BS: utf8.decode(data)
        BS->>BS: jsonDecode(jsonString)
        BS-->>BS: Map<String, dynamic> backupData

        BS->>DB: transaction(() async { ... })
        Note over DB: 开启事务

        BS->>DB: DELETE FROM all_tables
        Note over DB: 清空所有表

        loop 导入 workouts
            BS->>DB: INSERT INTO training_sessions
        end

        loop 导入 strengthExercises
            BS->>DB: INSERT INTO strength_exercise_entries
        end

        loop 导入其他表...
            BS->>DB: INSERT INTO ...
        end

        BS->>DB: COMMIT
        DB-->>BS: 事务完成

        BS-->>UI: RestoreResult(success: true)
        UI->>UI: 刷新所有页面
        UI-->>User: 显示"恢复成功，请重启应用"
    end
```

---

## 6. 响应式数据更新

### 6.1 Stream 数据流

```mermaid
sequenceDiagram
    participant DB as AppDatabase
    participant Repo as TrainingRepository
    participant Prov as StreamProvider
    participant UI as HistoryPage

    Note over UI: 页面初始化
    UI->>Prov: ref.watch(watchAllSessionsProvider)
    Prov->>Repo: watchAll()
    Repo->>DB: SELECT * FROM training_sessions
    DB-->>Repo: 初始数据
    Repo->>Prov: Stream<List<TrainingSession>>
    Prov->>UI: AsyncData(sessions)
    UI->>UI: 渲染列表

    Note over DB: 其他操作更新数据
    User->>UI: 添加新训练
    UI->>UC: 保存训练
    UC->>DB: INSERT INTO training_sessions
    DB->>DB: 触发变更通知

    DB-->>Repo: 数据变更事件
    Repo->>Repo: 重新查询
    Repo->>DB: SELECT * FROM training_sessions
    DB-->>Repo: 最新数据
    Repo->>Prov: Stream 推送新数据
    Prov->>UI: AsyncData(updatedSessions)
    UI->>UI: 自动更新列表
```

### 6.2 Provider 失效与刷新

```mermaid
flowchart TD
    User["用户"] -->|触发操作| Action[保存/删除操作]
    Action -->|成功| Invalidate[ref.invalidate(provider)]

    Invalidate --> Provider[Provider 状态]
    Provider -->|标记为脏| Rebuild[下次读取时重建]

    UI["UI Widget"] -->|ref.watch| Provider
    Provider -->|重建| UseCase[Use Case]
    UseCase -->|查询| DB[("Database")]
    DB -->|最新数据| UseCase
    UseCase -->|新数据| Provider
    Provider -->|更新 UI| UI
```

---

## 7. LAN API 数据流

### 7.1 API 请求处理流程

```mermaid
sequenceDiagram
    participant Browser as Web 浏览器
    participant Lan as LanServer
    participant CORS as CORS Middleware
    participant Auth as Auth Middleware
    participant Handler as API Handler
    participant Repo as Repository
    participant DB as AppDatabase

    Browser->>Lan: GET /api/workouts
    Note over Browser: Authorization: Bearer token

    Lan->>CORS: 处理跨域
    CORS->>CORS: 添加 CORS 响应头
    CORS->>Auth: 验证 Token

    alt Token 无效
        Auth-->>Lan: 401 Unauthorized
        Lan-->>Browser: 401 Unauthorized
    else Token 有效或不需要
        Auth->>Handler: 路由分发

        Handler->>Handler: 解析请求参数
        Handler->>Repo: 调用查询方法
        Repo->>DB: Drift 查询
        DB-->>Repo: 查询结果
        Repo-->>Handler: 数据对象

        Handler->>Handler: JSON 序列化
        Handler-->>Lan: Response(200, jsonBody)
        Lan-->>Browser: 200 OK<br/>Content-Type: application/json
    end
```

### 7.2 批量操作数据流

```mermaid
sequenceDiagram
    participant Browser as Web 浏览器
    participant Lan as LanServer
    participant Handler as BulkHandler
    participant UC as BulkOperationUseCase
    participant DB as AppDatabase

    Browser->>Lan: POST /api/bulk/workouts/delete
    Note over Browser: Body: { ids: [1, 2, 3] }

    Lan->>Handler: 路由匹配
    Handler->>Handler: 解析 JSON body
    Handler->>UC: call(ids)

    UC->>DB: transaction(() async { ... })

    loop 遍历每个 ID
        UC->>DB: DELETE FROM related_tables<br/>WHERE sessionId = ?
        UC->>DB: DELETE FROM training_sessions<br/>WHERE id = ?
    end

    UC->>DB: 重建 PR
    DB-->>UC: COMMIT

    UC-->>Handler: 删除结果
    Handler->>Handler: JSON 序列化
    Handler-->>Lan: Response(200, { deleted: 3 })
    Lan-->>Browser: 200 OK
```

---

## 附录：数据流优化建议

### 1. 减少不必要的数据流

```dart
// ❌ 避免：在 build 方法中创建新的 Future
@override
Widget build(BuildContext context) {
  // 每次 rebuild 都会创建新的 Future
  final future = fetchData();
  return FutureBuilder(...);
}

// ✅ 推荐：使用 Provider 缓存 Future
@riverpod
Future<Data> cachedData(Ref ref) async {
  return await fetchData();
}

@override
Widget build(BuildContext context, WidgetRef ref) {
  final asyncValue = ref.watch(cachedDataProvider);
  return AsyncValueWidget(...);
}
```

### 2. 批量操作优化

```dart
// ❌ 避免：循环中单条操作
for (final id in ids) {
  await repository.delete(id); // N 次数据库操作
}

// ✅ 推荐：批量删除
await db.transaction(() async {
  await (db.delete(table)..where((t) => t.id.isIn(ids))).go();
});
```

### 3. 分页加载

```dart
// ✅ 推荐：使用 family 实现分页
@riverpod
Future<List<TrainingSession>> paginatedSessions(
  Ref ref, {
  required int page,
  required int pageSize,
}) async {
  final repo = ref.watch(trainingRepositoryProvider);
  return await repo.getPage(page: page, pageSize: pageSize);
}
```

---

**文档结束**
