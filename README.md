# FitTrack - 运动追踪

<p align="center">
  <img src="assets/icon/app_icon.png" alt="FitTrack 图标" width="120">
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.41+-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3.11+-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License"></a>
</p>

---

## 简介

FitTrack 是一款基于 Flutter 开发的个人健身记录应用，采用**移动优先、本地优先**的架构设计。所有数据存储在本地 SQLite 数据库中，无需联网即可使用。通过内置的局域网 HTTP 服务，你可以在电脑上通过浏览器便捷地管理训练数据。

### 核心特性

- **多类型训练记录** - 支持力量训练、跑步、游泳、骑行、瑜伽等多种运动类型
- **今日概览** - 快速查看今日训练状态和周目标进度
- **历史记录** - 按日期浏览所有训练历史，支持筛选和搜索
- **数据统计** - 可视化图表展示训练趋势和进度
- **动作库** - 内置 100+ 预设动作，支持自定义添加
- **训练模板** - 快速创建可复用的训练计划
- **个人记录 (PR)** - 自动追踪和记录最佳成绩
- **局域网 Web 管理界面** - 通过浏览器访问完整的管理后台
- **云备份** - 支持 WebDAV 和 S3 兼容存储

---

## 支持的运动类型

| 类型 | 功能描述 |
|------|----------|
| 力量训练 | 完整记录动作、组数、次数、重量、RPE、休息时间 |
| 跑步 | 距离、时长、配速、分段计时、心率、海拔 |
| 游泳 | 距离、趟数、泳姿、泳池长度、配速 |
| 骑行 | 时长、强度记录 |
| 瑜伽 | 时长、强度记录 |
| 其他 | 自定义运动类型 |

---

## 技术栈

| 类别 | 技术 | 版本 |
|------|------|------|
| 框架 | Flutter | 3.41+ |
| 语言 | Dart | 3.11+ |
| 状态管理 | Riverpod | ^2.5.0 |
| 数据库 | Drift (SQLite ORM) | ^2.18.0 |
| HTTP 服务 | Shelf | ^1.4.2 |
| 路由 | go_router | ^13.0.0 |
| 图表 | fl_chart | ^0.68.0 |
| 后台服务 | flutter_background_service | ^5.0.0 |
| 安全存储 | flutter_secure_storage | ^9.0.0 |
| 网络信息 | network_info_plus | ^5.0.0 |
| 二维码 | qr_flutter | ^4.1.0 |
| 备份 | webdav_plus, minio | ^1.2.0, ^3.5.0 |
| 加密 | crypto | ^3.0.3 |

---

## 项目结构

```
lib/
├── main.dart              # 应用入口，初始化日期格式和日志
├── app.dart               # 根组件，配置主题和路由
├── core/                  # 核心层
│   ├── database/          # Drift 数据库
│   │   ├── database.dart  # 数据库配置与迁移
│   │   ├── tables/        # 数据表定义（13张表）
│   │   └── seed/          # 动作库种子数据
│   ├── lan_service/       # 局域网 HTTP 服务
│   │   ├── lan_server.dart    # Shelf HTTP 服务器
│   │   ├── foreground_service.dart  # Android 前台服务
│   │   ├── routes/        # API 路由
│   │   └── middleware/    # 认证/CORS 中间件
│   ├── backup/            # 备份服务
│   │   ├── backup_service.dart
│   │   └── providers/     # WebDAV/S3 备份提供商
│   ├── repositories/      # 数据仓库层
│   ├── providers/         # Riverpod Providers
│   ├── network/           # 网络信息服务
│   ├── secure_storage/    # 安全存储
│   ├── logging/           # 日志服务
│   ├── services/          # 业务服务（PR 计算）
│   └── router/            # go_router 路由配置
├── features/              # 功能模块
│   ├── today/             # 今日概览页
│   ├── training/          # 训练模块
│   │   ├── strength/      # 力量训练
│   │   ├── running/       # 跑步训练
│   │   ├── swimming/      # 游泳训练
│   │   └── quick_log_page.dart  # 简单记录
│   ├── history/           # 历史记录
│   ├── stats/             # 统计分析
│   ├── settings/          # 设置页面
│   ├── exercises/         # 动作库管理
│   ├── templates/         # 训练模板
│   ├── pr/                # 个人记录
│   └── backup/            # 备份页面
├── web/admin/             # Web 管理界面
└── shared/                # 共享资源
    ├── theme/             # Material 3 主题
    └── widgets/           # 通用组件
```

---

## 数据库架构

应用使用 Drift (SQLite ORM) 管理 **13 张数据表**：

| 表名 | 用途 |
|------|------|
| `UserSettings` | 用户设置（周目标、主题、单位、LAN 配置） |
| `TrainingSessions` | 训练记录主表 |
| `StrengthExerciseEntries` | 力量训练详情 |
| `Exercises` | 动作库（预设动作种子数据） |
| `WorkoutTemplates` | 训练模板 |
| `TemplateExercises` | 模板-动作关联 |
| `RunningEntries` | 跑步记录 |
| `RunningSplits` | 跑步分段数据 |
| `SwimmingEntries` | 游泳记录 |
| `SwimmingSets` | 游泳组数据 |
| `PersonalRecords` | 个人最佳记录 |
| `BackupConfigurations` | 备份配置 |
| `BackupRecords` | 备份历史记录 |

---

## 架构设计

### 分层架构

```
┌─────────────────────────────────────────────────────┐
│                    UI Layer                          │
│     (features/ - Widgets, Pages)                    │
├─────────────────────────────────────────────────────┤
│                 State Management                     │
│     (Riverpod Providers, Notifiers)                 │
├─────────────────────────────────────────────────────┤
│                  Repository Layer                    │
│     (repositories/ - 数据访问抽象)                   │
├─────────────────────────────────────────────────────┤
│                   Data Layer                         │
│     (Drift Database, Secure Storage)                │
└─────────────────────────────────────────────────────┘
```

### 局域网服务架构

```
┌──────────────┐     HTTP/JSON      ┌──────────────┐
│   Web 浏览器  │ ←───────────────→ │  LAN Server  │
└──────────────┘   (Token 认证)      │   (Shelf)    │
                                     └──────┬───────┘
                                            │
                                     ┌──────▼───────┐
                                     │ AppDatabase  │
                                     │   (SQLite)   │
                                     └──────────────┘
```

- **Android 前台服务**保持 LAN 服务在后台运行
- **Token 认证**保护 API 端点
- **Web UI** 由 Flutter Web 构建产物同步到 `assets/webapp/` 后提供

---

## 安装与运行

### 环境要求

- Flutter SDK 3.41 或更高版本
- Dart SDK 3.11 或更高版本
- Android SDK (API 21+)

### 安装步骤

```bash
# 1. 克隆仓库
git clone https://github.com/Vncntvx/fitTrack
cd fitTrack

# 2. 安装依赖
flutter pub get

# 3. 生成代码 (Drift、Riverpod 代码生成)
dart run build_runner build --delete-conflicting-outputs

# 4. 运行应用
flutter run
```

### 构建发布版本

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release
```

---

## 使用指南

### 首次使用

1. 打开应用，进入**今日**页面
2. 点击底部浮动按钮 **「开始训练」**
3. 选择运动类型（健身、跑步、游泳等）
4. 填写训练详情并保存
5. 在**历史**页面查看所有记录

### 启用局域网服务

1. 进入 **设置** → **局域网服务**
2. 开启服务开关
3. 应用会显示本地访问地址和二维码
4. 在同一 WiFi 下的电脑浏览器中访问该地址
5. 输入显示的 Token 完成认证

### 配置云备份

1. 进入 **设置** → **备份设置**
2. 选择备份方式：**WebDAV** 或 **S3**
3. 填写服务器地址、密钥等信息
4. 执行备份或恢复操作

---

## API 端点

局域网服务默认端口: `8080` (可配置)

| 端点 | 方法 | 描述 |
|------|------|------|
| `/health` | GET | 健康检查（无需认证） |
| `/api/workouts` | GET/POST | 运动记录列表/创建 |
| `/api/workouts/:id` | GET/PUT/DELETE | 单条运动记录 |
| `/api/stats` | GET | 统计数据 |
| `/api/settings` | GET/PUT | 用户设置 |
| `/api/backup-configs` | GET/POST/DELETE | 备份配置 |

**认证**: `Authorization: Bearer <token>`

---

## 开发指南

### 代码生成

```bash
# 单次生成
dart run build_runner build --delete-conflicting-outputs

# 监听模式（开发时推荐）
dart run build_runner watch

# 清理并重新生成
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### 代码检查与测试

```bash
# 静态分析
flutter analyze

# 格式化代码
dart format .

# 运行单元测试
flutter test

# 运行集成测试（需要连接设备）
flutter test integration_test/
```

### 编码规范

- 代码注释使用**中文**
- 文件命名：小写下划线 (`snake_case.dart`)
- 类命名：大驼峰 (`PascalCase`)
- 变量/函数：小驼峰 (`camelCase`)

### 提交规范

```
feat: 添加新功能
fix: 修复问题
refactor: 代码重构
test: 测试代码
docs: 文档更新
```

---

## 相关文档

- `AGENTS.md` - AI 助手项目上下文
- `docs/architecture.md` - 详细架构文档
- `docs/api.md` - API 文档
- `docs/backup.md` - 备份功能说明
- `docs/development.md` - 开发指南

---

## 参与贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'feat: Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 打开 Pull Request

---

## 开源协议

本项目采用 [MIT](LICENSE) 协议开源。

---

## 致谢

感谢以下开源项目：

- [Flutter](https://flutter.dev)
- [Riverpod](https://riverpod.dev)
- [Drift](https://drift.simonbinder.eu/)
- [Shelf](https://pub.dev/packages/shelf)
- [fl_chart](https://github.com/imaNNeo/fl_chart)

---

## 作者

- **Wenjie Xu**
- Email: <wenjie.xu.cn@outlook.com>
- GitHub: [@Vncntvx](https://github.com/Vncntvx)

<p align="center">
  Made with ❤️ for fitness enthusiasts
</p>
