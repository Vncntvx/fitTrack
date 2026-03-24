# FitTrack 模块交互关系

> 本文档描述 FitTrack 各个模块之间的依赖关系和交互方式。
>
> **版本**: 1.0.0
> **最后更新**: 2026-03-25

---

## 目录

1. [模块关系总览](#1-模块关系总览)
2. [层级交互](#2-层级交互)
3. [核心模块依赖图](#3-核心模块依赖图)
4. [数据模块交互](#4-数据模块交互)
5. [服务模块交互](#5-服务模块交互)
6. [UI 模块交互](#6-ui-模块交互)
7. [交叉关注点](#7-交叉关注点)

---

## 1. 模块关系总览

### 1.1 架构层次图

```mermaid
flowchart TB
    subgraph Presentation["表现层"]
        UI["UI Layer (features/)"]
        Web["Web Admin (web/)"]
    end

    subgraph State["状态层"]
        Riverpod["Riverpod Providers (core/providers/)"]
    end

    subgraph Business["业务层"]
        UseCase["Use Case Layer (core/usecases/)"]
        Service["Services (core/services/)"]
    end

    subgraph DataAccess["数据访问层"]
        Repo["Repository Layer (core/repositories/)"]
    end

    subgraph Data["数据层"]
        DB["Database (core/database/)"]
    end

    subgraph Infrastructure["基础设施层"]
        Lan["LAN Service (core/lan_service/)"]
        Backup["Backup Service (core/backup/)"]
        Log["Logging (core/logging/)"]
        Network["Network (core/network/)"]
    end

    UI --> Riverpod
    Web --> Riverpod
    Riverpod --> UseCase
    Riverpod --> Repo
    UseCase --> Repo
    UseCase --> DB
    UseCase --> Service
    Repo --> DB

    Lan --> Repo
    Lan --> DB
    Backup --> DB
    Backup --> Network
    Log --> DB
```

### 1.2 依赖方向规则

```
┌─────────────────────────────────────────────┐
│  UI Layer (features/, web/)                  │
│  ↓ 依赖 Riverpod                             │
├─────────────────────────────────────────────┤
│  State Layer (providers/)                    │
│  ↓ 依赖 Use Case / Repository                │
├─────────────────────────────────────────────┤
│  Business Layer (usecases/, services/)       │
│  ↓ 依赖 Repository / Database                │
├─────────────────────────────────────────────┤
│  Data Access Layer (repositories/)           │
│  ↓ 依赖 Database                             │
├─────────────────────────────────────────────┤
│  Data Layer (database/)                      │
└─────────────────────────────────────────────┘
```

**关键规则**：
- 上层可以依赖下层，下层不能依赖上层
- 同层模块可以相互依赖（但应尽量避免）
- UI 禁止直接调用 Repository（必须通过 Use Case）

---

## 2. 层级交互

### 2.1 UI 层 → Provider 层

```mermaid
flowchart LR
    subgraph UI["UI 层"]
        T[TodayPage]
        H[HistoryPage]
        S[StatsPage]
    end

    subgraph Provider["Provider 层"]
        DP1[todayDashboardProvider]
        DP2[overviewStatsProvider]
        DP3[runningStatsProvider]
        UP[deleteTrainingUseCaseProvider]
    end

    subgraph UC["Use Case"]
        U1[GetTodayDashboardUseCase]
        U2[GetOverviewStatsUseCase]
        U3[DeleteTrainingUseCase]
    end

    T -->|watch| DP1
    H -->|read| UP
    S -->|watch| DP2
    S -->|watch| DP3

    DP1 --> U1
    DP2 --> U2
    DP3 --> U2
    UP --> U3
```

**交互模式**：

| 场景 | 方法 | 用途 |
|------|------|------|
| 显示数据 | `ref.watch(provider)` | 监听数据变化，自动重建 |
| 执行操作 | `ref.read(useCaseProvider)` | 一次性获取 Use Case 实例 |
| 触发刷新 | `ref.invalidate(provider)` | 标记 Provider 为脏，下次重建 |
| 响应式流 | `ref.watch(streamProvider)` | 监听 Stream 数据流 |

### 2.2 Provider 层 → Use Case 层

```dart
// Repository Provider
@riverpod
TrainingRepository trainingRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return TrainingRepository(db);
}

// Use Case Provider
@riverpod
DeleteTrainingUseCase deleteTrainingUseCase(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  final repo = ref.watch(trainingRepositoryProvider);
  final prRebuilder = ref.watch(rebuildPersonalRecordsUseCaseProvider);
  return DeleteTrainingUseCase(repo, db, prRebuilder);
}

// Data Provider
@riverpod
Future<TodayDashboardData> todayDashboard(Ref ref, {
  required DateTime referenceDate,
}) async {
  final useCase = ref.watch(getTodayDashboardUseCaseProvider);
  return await useCase(GetTodayDashboardParams(...));
}
```

### 2.3 Use Case 层 → Repository 层

```dart
class DeleteTrainingUseCase extends UseCase<DeleteTrainingResult, int> {
  final TrainingRepository _repository;  // 依赖 Repository
  final AppDatabase _db;                  // 依赖 Database

  @override
  Future<DeleteTrainingResult> call(int id) async {
    return await _db.transaction(() async {
      // 使用 Repository 查询
      final session = await _repository.getById(id);
      if (session == null) return DeleteTrainingResult.notFound;

      // 执行删除
      await _repository.delete(id);

      return DeleteTrainingResult.success;
    });
  }
}
```

### 2.4 Repository 层 → Database 层

```dart
class TrainingRepository {
  final AppDatabase _db;  // 依赖 Database

  Future<TrainingSession?> getById(int id) async {
    // 使用 Drift ORM 查询
    return await (_db.select(_db.trainingSessions)
          ..where((w) => w.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<List<TrainingSession>> watchAll() {
    // 使用 Drift 的响应式查询
    return _db.select(_db.trainingSessions).watch();
  }
}
```

---

## 3. 核心模块依赖图

### 3.1 Use Case 依赖关系

```mermaid
flowchart TB
    subgraph TrainingUC["训练 Use Cases"]
        STS[SaveStrengthSessionUseCase]
        SRS[SaveRunningSessionUseCase]
        SWS[SaveSwimmingSessionUseCase]
        DT[DeleteTrainingUseCase]
        SW[SaveWorkoutUseCase]
    end

    subgraph PRUC["PR Use Cases"]
        RPR[RebuildPersonalRecordsUseCase]
        CSP[CheckStrengthPrUseCase]
        CRP[CheckRunningPrUseCase]
        CSwP[CheckSwimmingPrUseCase]
    end

    subgraph OtherUC["其他 Use Cases"]
        DE[DeleteExerciseUseCase]
        ST[SaveTemplateUseCase]
        DT2[DuplicateTemplateUseCase]
        GS[GetTodayDashboardUseCase]
    end

    subgraph Repos["Repositories"]
        TR[TrainingRepository]
        SER[StrengthEntryRepository]
        RR[RunningRepository]
        SWR[SwimmingRepository]
        ER[ExerciseRepository]
        TPR[TemplateRepository]
    end

    STS --> TR
    STS --> SER
    STS --> RPR
    SRS --> TR
    SRS --> RR
    SRS --> RPR
    SWS --> TR
    SWS --> SWR
    SWS --> RPR
    DT --> TR
    DT --> RPR
    SW --> TR

    RPR --> TR
    RPR --> SER
    RPR --> RR
    RPR --> SWR
    CSP --> SER
    CRP --> RR
    CSwP --> SWR

    DE --> ER
    ST --> TPR
    DT2 --> TPR
    GS --> TR
    GS --> TPR
```

### 3.2 Repository 依赖关系

```mermaid
flowchart TB
    subgraph Repositories["Repository 层"]
        TR[TrainingRepository]
        SER[StrengthEntryRepository]
        RR[RunningRepository]
        SWR[SwimmingRepository]
        ER[ExerciseRepository]
        TPR[TemplateRepository]
        SR[StatsRepository]
        SETR[SettingsRepository]
        BCR[BackupConfigRepository]
    end

    subgraph Database["数据库表"]
        TS[training_sessions]
        SE[strength_exercise_entries]
        RE[running_entries]
        RS[running_splits]
        SWE[swimming_entries]
        SWS[swimming_sets]
        EX[exercises]
        WT[workout_templates]
        TE[template_exercises]
        PR[personal_records]
        US[user_settings]
        BC[backup_configurations]
    end

    TR --> TS
    SER --> SE
    RR --> RE
    RR --> RS
    SWR --> SWE
    SWR --> SWS
    ER --> EX
    TPR --> WT
    TPR --> TE
    SR --> TS
    SR --> SE
    SETR --> US
    BCR --> BC
```

### 3.3 LAN 服务依赖关系

```mermaid
flowchart TB
    subgraph LanServer["LAN Server"]
        Server[LanServer]
        Router[Shelf Router]

        subgraph Middleware["中间件"]
            CORS[CORS Middleware]
            Auth[Auth Middleware]
        end

        subgraph Handlers["路由处理器"]
            WH[WorkoutHandler]
            EH[ExerciseHandler]
            TH[TemplateHandler]
            PH[PrHandler]
            RH[RunningHandler]
            SH[SwimmingHandler]
            BH[BackupHandler]
            BuH[BulkHandler]
        end
    end

    subgraph DataAccess["数据访问"]
        Repos["Repositories"]
        Services["Services"]
    end

    Server --> Router
    Router --> Middleware
    Middleware --> Handlers

    WH --> Repos
    EH --> Repos
    TH --> Repos
    PH --> Repos
    RH --> Repos
    SH --> Repos
    BH --> Services
    BuH --> Services
```

---

## 4. 数据模块交互

### 4.1 数据库表关系

```mermaid
erDiagram
    TRAINING_SESSIONS ||--o{ STRENGTH_EXERCISE_ENTRIES : "1:N 包含"
    TRAINING_SESSIONS ||--o{ RUNNING_ENTRIES : "1:1 包含"
    TRAINING_SESSIONS ||--o{ SWIMMING_ENTRIES : "1:1 包含"
    RUNNING_ENTRIES ||--o{ RUNNING_SPLITS : "1:N 包含"
    SWIMMING_ENTRIES ||--o{ SWIMMING_SETS : "1:N 包含"

    WORKOUT_TEMPLATES ||--o{ TEMPLATE_EXERCISES : "1:N 包含"
    WORKOUT_TEMPLATES ||--o{ TRAINING_SESSIONS : "1:N 使用"

    EXERCISES ||--o{ STRENGTH_EXERCISE_ENTRIES : "1:N 引用"
    EXERCISES ||--o{ TEMPLATE_EXERCISES : "1:N 引用"
    EXERCISES ||--o{ PERSONAL_RECORDS : "1:N 关联"

    TRAINING_SESSIONS ||--o{ PERSONAL_RECORDS : "1:N 达成"
    BACKUP_CONFIGURATIONS ||--o{ BACKUP_RECORDS : "1:N 生成"

    TRAINING_SESSIONS {
        int id PK
        datetime datetime
        string type
        int templateId FK
    }

    STRENGTH_EXERCISE_ENTRIES {
        int id PK
        int sessionId FK
        int exerciseId FK
    }

    RUNNING_ENTRIES {
        int id PK
        int sessionId FK
    }

    RUNNING_SPLITS {
        int id PK
        int runningEntryId FK
    }

    SWIMMING_ENTRIES {
        int id PK
        int sessionId FK
    }

    SWIMMING_SETS {
        int id PK
        int swimmingEntryId FK
    }

    EXERCISES {
        int id PK
        string name
    }

    WORKOUT_TEMPLATES {
        int id PK
        string name
        string type
    }

    TEMPLATE_EXERCISES {
        int id PK
        int templateId FK
        int exerciseId FK
    }

    PERSONAL_RECORDS {
        int id PK
        int exerciseId FK
        int sessionId FK
    }

    BACKUP_CONFIGURATIONS {
        int id PK
        string providerType
    }

    BACKUP_RECORDS {
        int id PK
        int configId FK
    }
```

### 4.2 级联删除关系

| 父表 | 子表 | 删除行为 |
|------|------|----------|
| training_sessions | strength_exercise_entries | 级联删除 |
| training_sessions | running_entries | 级联删除 |
| running_entries | running_splits | 级联删除 |
| training_sessions | swimming_entries | 级联删除 |
| swimming_entries | swimming_sets | 级联删除 |
| workout_templates | training_sessions | setNull |
| workout_templates | template_exercises | 级联删除 |
| exercises | strength_exercise_entries | 级联删除 |
| exercises | template_exercises | 级联删除 |
| exercises | personal_records | 级联删除 |

---

## 5. 服务模块交互

### 5.1 备份服务交互

```mermaid
flowchart TB
    subgraph BackupService["备份服务"]
        BS[BackupService]
        BF[BackupProviderFactory]
    end

    subgraph Providers["存储提供商"]
        BP[BackupProvider Interface]
        WebDAV[WebDavProvider]
        S3[S3Provider]
    end

    subgraph External["外部存储"]
        WebDAVServer["WebDAV Server"]
        S3Server["S3 Object Storage"]
    end

    subgraph Data["数据层"]
        DB[("SQLite Database")]
    end

    BS -->|使用| BF
    BF -->|创建| BP
    BP -->|实现| WebDAV
    BP -->|实现| S3

    BS -->|导出/导入| DB
    WebDAV -->|HTTP| WebDAVServer
    S3 -->|HTTP| S3Server
```

### 5.2 LAN 服务交互

```mermaid
flowchart TB
    subgraph App["FitTrack App"]
        UI["UI Layer"]
        LanServer["LanServer"]
    end

    subgraph External["外部访问"]
        Browser["Web Browser"]
        OtherDevice["Other Devices"]
    end

    subgraph Data["数据层"]
        DB[("SQLite")]
    end

    UI -->|控制| LanServer
    LanServer -->|查询/修改| DB

    Browser -->|HTTP| LanServer
    OtherDevice -->|HTTP| LanServer
```

### 5.3 日志服务交互

```mermaid
flowchart TB
    subgraph Logging["日志服务"]
        LS[LoggerService]
        LL[LogLevel]
    end

    subgraph AppComponents["应用组件"]
        UI["UI"]
        UC["Use Cases"]
        Repo["Repositories"]
        Lan["LAN Service"]
    end

    subgraph Storage["存储"]
        DB[("SQLite")]
    end

    UI -->|记录日志| LS
    UC -->|记录日志| LS
    Repo -->|记录日志| LS
    Lan -->|记录日志| LS

    LS -->|保存日志| DB
```

---

## 6. UI 模块交互

### 6.1 Feature 模块关系

```mermaid
flowchart TB
    subgraph Features["Feature 模块"]
        subgraph Core["核心功能"]
            T[Today]
            TR[Training]
            H[History]
        end

        subgraph Management["管理功能"]
            EX[Exercises]
            TP[Templates]
            PR[PR Page]
            ST[Settings]
        end

        subgraph Analysis["分析功能"]
            S[Stats]
        end

        subgraph DataMgmt["数据管理"]
            BK[Backup]
        end
    end

    subgraph Shared["共享组件"]
        W[Shared Widgets]
        Th[Theme]
    end

    T -->|导航| TR
    T -->|导航| H
    T -->|导航| S
    T -->|导航| ST

    TR -->|使用| EX
    TR -->|使用| TP

    H -->|编辑| TR

    EX --> PR
    TP --> TR

    ST --> EX
    ST --> TP
    ST --> PR
    ST --> BK

    T --> W
    TR --> W
    H --> W
    S --> W
    EX --> W
    TP --> W
    PR --> W
    ST --> W
    BK --> W

    T --> Th
    TR --> Th
    H --> Th
    S --> Th
    EX --> Th
    TP --> Th
    PR --> Th
    ST --> Th
    BK --> Th
```

### 6.2 Web Admin 模块关系

```mermaid
flowchart TB
    subgraph WebAdmin["Web Admin"]
        D[Dashboard]
        E[Export/Import]
        EX2[Exercises]
        TP2[Templates]
        PR2[PR Page]
        BK2[Backup]
        SI[System Info]
    end

    subgraph Navigation["导航"]
        D --> E
        D --> EX2
        D --> TP2
        D --> PR2
        D --> BK2
        D --> SI
    end
```

---

## 7. 交叉关注点

### 7.1 错误处理流

```mermaid
flowchart TB
    subgraph ErrorSources["错误来源"]
        Network["网络错误"]
        DB["数据库错误"]
        Logic["业务逻辑错误"]
        Validation["验证错误"]
    end

    subgraph ErrorHandling["错误处理层"]
        UC["Use Case 层"]
        Repo["Repository 层"]
        UI["UI 层"]
    end

    subgraph ErrorDisplay["错误展示"]
        AsyncValue["AsyncValueWidget"]
        SnackBar["SnackBar"]
        Dialog["Dialog"]
    end

    Network --> UC
    DB --> Repo
    Logic --> UC
    Validation --> UC

    UC -->|枚举结果| UI
    Repo -->|nullable/异常| UC
    UI --> AsyncValue
    UI --> SnackBar
    UI --> Dialog
```

### 7.2 主题切换流

```mermaid
flowchart TB
    subgraph ThemeSystem["主题系统"]
        TN[ThemeModeNotifier]
        CTM[currentThemeModeProvider]
        AT[AppTheme]
    end

    subgraph Data["数据层"]
        SR[SettingsRepository]
        DB[("user_settings")]
    end

    subgraph UI["UI 层"]
        App["WorkoutTrackerApp"]
        Pages["All Pages"]
    end

    TN -->|保存/读取| SR
    SR -->|持久化| DB
    TN --> CTM
    CTM -->|watch| App
    AT -->|定义| App
    App -->|theme| Pages
```

### 7.3 全局错误捕获

```mermaid
flowchart TB
    subgraph ErrorTypes["错误类型"]
        FE[FlutterError]
        PE[PlatformError]
        ZE[ZoneError]
    end

    subgraph Handlers["错误处理器"]
        FH[FlutterError.onError]
        PH[PlatformDispatcher.onError]
        ZH[runZonedGuarded]
    end

    subgraph Logger["日志服务"]
        LS[LoggerService]
        DB[("log_entries")]
    end

    FE --> FH
    PE --> PH
    ZE --> ZH

    FH --> LS
    PH --> LS
    ZH --> LS

    LS --> DB
```

---

## 附录：模块接口清单

### Use Case 接口

| Use Case | 输入 | 输出 | 依赖 |
|----------|------|------|------|
| DeleteTrainingUseCase | int sessionId | DeleteTrainingResult | TrainingRepository, AppDatabase, RebuildPersonalRecordsUseCase |
| SaveStrengthSessionUseCase | SaveStrengthSessionParams | int sessionId | TrainingRepository, StrengthEntryRepository, AppDatabase, RebuildPersonalRecordsUseCase |
| SaveRunningSessionUseCase | SaveRunningSessionParams | int sessionId | TrainingRepository, RunningRepository, AppDatabase, RebuildPersonalRecordsUseCase |
| SaveSwimmingSessionUseCase | SaveSwimmingSessionParams | int sessionId | TrainingRepository, SwimmingRepository, AppDatabase, RebuildPersonalRecordsUseCase |
| DeleteExerciseUseCase | int exerciseId | DeleteExerciseResult | ExerciseRepository |
| SaveTemplateUseCase | SaveTemplateParams | int templateId | TemplateRepository, AppDatabase |
| RebuildPersonalRecordsUseCase | String type | void | TrainingRepository, StrengthEntryRepository, RunningRepository, SwimmingRepository, AppDatabase |
| GetTodayDashboardUseCase | GetTodayDashboardParams | TodayDashboardData | TrainingRepository, StatsRepository, SettingsRepository |

### Repository 接口

| Repository | 主要方法 |
|------------|----------|
| TrainingRepository | getById, getAll, getByDateRange, getByType, getRecent, createTraining, updateTraining, deleteTraining, watchAll, watchByType |
| StrengthEntryRepository | addStrengthExercise, getStrengthExercises, updateStrengthExercise, deleteStrengthExercise |
| RunningRepository | createEntry, getBySessionId, updateEntry, deleteEntry, addSplit, getSplits |
| SwimmingRepository | createEntry, getBySessionId, updateEntry, deleteEntry, addSet, getSets |
| ExerciseRepository | getAll, getById, create, update, delete, getByCategory |
| TemplateRepository | getAll, getById, create, update, delete, duplicate, getExercises |
| StatsRepository | getOverviewStats, getRunningStats, getSwimmingStats, getExerciseStats |
| SettingsRepository | getSettings, updateSettings, getThemeMode, updateThemeMode |

### Provider 接口

| Provider | 类型 | 用途 |
|----------|------|------|
| appDatabaseProvider | Singleton | 数据库实例 |
| trainingRepositoryProvider | Factory | TrainingRepository 实例 |
| deleteTrainingUseCaseProvider | Factory | DeleteTrainingUseCase 实例 |
| todayDashboardProvider | AutoDispose | 今日页数据 |
| overviewStatsProvider | AutoDispose | 总览统计数据 |
| themeModeProvider | KeepAlive | 主题模式状态 |

---

**文档结束**
