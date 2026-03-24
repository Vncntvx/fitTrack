# FitTrack 局域网 HTTP API 文档

## 概述

FitTrack 运动追踪应用提供局域网 HTTP API 服务，使用 Dart Shelf 框架实现。Android 设备作为服务器端，向 Web 端提供 RESTful API 接口用于访问和管理运动数据。

**技术栈**: Dart Shelf / Drift (SQLite) / JSON

---

## 服务器地址

```
http://<设备IP>:<端口>
```

- 默认端口: 8080（可在应用设置中配置）
- 监听地址: `0.0.0.0`（所有网络接口）

---

## 跨域支持

API 自动包含 CORS 响应头，支持浏览器跨域访问：

| 响应头 | 值 |
|--------|-----|
| `Access-Control-Allow-Origin` | `*` |
| `Access-Control-Allow-Methods` | `GET, POST, PUT, DELETE, OPTIONS` |
| `Access-Control-Allow-Headers` | `Content-Type, Authorization` |

---

## 认证机制

局域网服务支持可选的令牌认证。当在应用中配置了访问令牌后，所有 `/api/*` 路径需要认证。

### 认证方式

支持以下三种方式传递令牌（优先级从高到低）：

#### 1. Authorization 请求头（推荐）

```
Authorization: Bearer <token>
```

#### 2. 自定义请求头

```
X-FitTrack-Token: <token>
```

#### 3. URL 查询参数（用于扫码访问）

```
?token=<token>
```

### 认证范围

| 路径 | 是否需要认证 | 说明 |
|------|-------------|------|
| `/health` | 否 | 健康检查端点 |
| `/api/*` | 是（如配置了令牌） | API 接口 |
| 其他路径（`/*`） | 否 | Web UI 静态资源 |

### 认证失败响应

```json
{
  "error": "Missing or invalid token",
  "hint": "Use Authorization: Bearer <token> or ?token=<token>"
}
```

---

## 通用响应格式

### 成功响应

HTTP 状态码 200，返回 JSON 格式数据。

### 错误响应

| HTTP 状态码 | 含义 | 响应示例 |
|-------------|------|----------|
| 400 | 请求参数错误 | `{"error": "Invalid ID"}` |
| 401 | 认证失败 | `{"error": "Missing or invalid token"}` |
| 404 | 资源不存在 | `{"error": "Workout not found"}` |
| 500 | 服务器内部错误 | `{"error": "详细的错误信息"}` |

---

## API 端点总览

| 类别 | 端点前缀 | 说明 |
|------|----------|------|
| 系统 | `/health` | 健康检查 |
| 训练记录 | `/api/workouts` | 训练会话 CRUD |
| 统计数据 | `/api/stats` | 训练统计 |
| 动作库 | `/api/exercises` | 动作管理 |
| 训练模板 | `/api/templates` | 模板管理 |
| 个人记录 | `/api/pr` | PR 记录 |
| 力量训练 | `/api/strength` | 力量训练详情 |
| 跑步记录 | `/api/running` | 跑步详情 |
| 游泳记录 | `/api/swimming` | 游泳详情 |
| 设置 | `/api/settings` | 应用设置 |
| 备份 | `/api/backup*` | 备份管理 |
| 批量操作 | `/api/bulk/*` | 批量操作 |
| 导入导出 | `/api/export/*`, `/api/import/*` | 数据导入导出 |

---

## 详细 API 规范

### 一、系统接口

#### GET /health

健康检查，无需认证。

**响应示例：**

```json
{
  "status": "ok",
  "timestamp": "2024-01-15T08:30:00.000Z"
}
```

---

### 二、训练记录 API

#### GET /api/workouts

获取所有训练记录列表。

**响应示例：**

```json
[
  {
    "id": 1,
    "datetime": "2024-01-15T07:00:00.000Z",
    "type": "running",
    "durationMinutes": 30,
    "intensity": "moderate",
    "note": "晨跑",
    "isGoalCompleted": true,
    "createdAt": "2024-01-15T07:00:00.000Z",
    "updatedAt": "2024-01-15T07:00:00.000Z"
  }
]
```

#### GET /api/workouts/{id}

获取单个训练记录详情。

**路径参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| id | integer | 训练记录 ID |

**响应示例：**

```json
{
  "id": 1,
  "datetime": "2024-01-15T07:00:00.000Z",
  "type": "running",
  "durationMinutes": 30,
  "intensity": "moderate",
  "note": "晨跑",
  "isGoalCompleted": true,
  "createdAt": "2024-01-15T07:00:00.000Z",
  "updatedAt": "2024-01-15T07:00:00.000Z"
}
```

#### POST /api/workouts

创建新的训练记录。

**请求体参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| datetime | string | 是 | ISO 8601 格式日期时间 |
| type | string | 是 | 运动类型：strength, running, swimming, cycling, jump_rope, walking, yoga, stretching, custom |
| durationMinutes | integer | 是 | 运动时长（分钟）> 0 |
| intensity | string | 是 | 运动强度：light, moderate, high |
| note | string | 否 | 备注信息 |
| isGoalCompleted | boolean | 否 | 是否完成目标，默认 false |

**请求示例：**

```json
{
  "datetime": "2024-01-15T07:00:00.000Z",
  "type": "running",
  "durationMinutes": 30,
  "intensity": "moderate",
  "note": "晨跑",
  "isGoalCompleted": true
}
```

**响应示例：**

```json
{
  "id": 1,
  "message": "Created successfully"
}
```

#### PUT /api/workouts/{id}

更新训练记录。

**路径参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| id | integer | 训练记录 ID |

**请求体参数（可选）：**

| 字段 | 类型 | 说明 |
|------|------|------|
| datetime | string | ISO 8601 格式日期时间 |
| type | string | 运动类型 |
| durationMinutes | integer | 运动时长（分钟） |
| intensity | string | 运动强度 |
| note | string | 备注信息 |
| isGoalCompleted | boolean | 是否完成目标 |

**响应示例：**

```json
{
  "message": "Updated successfully"
}
```

#### DELETE /api/workouts/{id}

删除训练记录（级联删除关联的跑步/游泳/力量详情记录）。

**响应示例：**

```json
{
  "message": "Deleted successfully"
}
```

#### GET /api/stats

获取训练统计数据。

**响应示例：**

```json
{
  "workoutDaysThisWeek": 5,
  "totalMinutesThisWeek": 180,
  "currentStreak": 12,
  "mostFrequentType": "running",
  "weeklyCount": 5,
  "totalMinutes": 2400,
  "weeklyMinutes": 180,
  "totalWorkouts": 50,
  "avgIntensity": "moderate"
}
```

---

### 三、动作库 API

#### GET /api/exercises

获取所有动作。

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| category | string | 按分类过滤（可选） |

**响应示例：**

```json
[
  {
    "id": 1,
    "name": "卧推",
    "category": "chest",
    "movementType": "compound",
    "primaryMuscles": "胸大肌",
    "secondaryMuscles": "三角肌前束, 肱三头肌",
    "defaultSets": 3,
    "defaultReps": 10,
    "defaultWeight": null,
    "isCustom": false,
    "isEnabled": true,
    "description": "平板卧推动作",
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
]
```

#### GET /api/exercises/{id}

获取单个动作详情。

**响应示例：** 同上

#### POST /api/exercises

创建新动作。

**请求体参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | 是 | 动作名称（唯一） |
| category | string | 是 | 分类：chest, back, shoulders, arms, legs, core, full_body, cardio |
| movementType | string | 否 | 动作类型：compound(复合), isolation(孤立)，默认 compound |
| primaryMuscles | string | 否 | 主要肌群（逗号分隔） |
| secondaryMuscles | string | 否 | 次要肌群（逗号分隔） |
| defaultSets | integer | 否 | 默认组数，默认 3 |
| defaultReps | integer | 否 | 默认次数，默认 10 |
| defaultWeight | number | 否 | 默认重量 |
| description | string | 否 | 动作描述 |

**响应示例：**

```json
{
  "id": 1,
  "message": "Created successfully"
}
```

#### PUT /api/exercises/{id}

更新动作。

**请求体参数（可选）：** 同创建参数

**响应示例：**

```json
{
  "message": "Updated successfully"
}
```

#### DELETE /api/exercises/{id}

删除动作。

**错误响应：**

- `400`: 动作存在训练历史引用
- `400`: 动作存在模板引用
- `404`: 动作不存在

**响应示例：**

```json
{
  "message": "Deleted successfully"
}
```

#### POST /api/exercises/bulk-delete

批量删除动作。

**请求体参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| ids | integer[] | 是 | 要删除的动作 ID 列表 |

**响应示例：**

```json
{
  "results": [
    {"id": 1, "success": true, "result": "success"},
    {"id": 2, "success": false, "result": "hasStrengthReferences"}
  ]
}
```

#### POST /api/exercises/import

导入动作。

**请求体参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| exercises | object[] | 是 | 动作对象数组 |

**响应示例：**

```json
{
  "imported": 10,
  "skipped": 2,
  "message": "Import completed"
}
```

#### GET /api/exercises/export

导出所有动作。

**响应示例：**

```json
{
  "exportDate": "2024-01-15T08:30:00.000Z",
  "count": 50,
  "exercises": [...]
}
```

---

### 四、训练模板 API

#### GET /api/templates

获取所有模板。

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| type | string | 按类型过滤（可选） |

**响应示例：**

```json
[
  {
    "id": 1,
    "name": "胸肌训练",
    "type": "strength",
    "description": "基础胸肌训练模板",
    "isDefault": false,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
]
```

#### GET /api/templates/{id}

获取模板详情（包含动作列表）。

**响应示例：**

```json
{
  "template": {
    "id": 1,
    "name": "胸肌训练",
    "type": "strength",
    "description": "基础胸肌训练模板",
    "isDefault": false,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  },
  "exercises": [
    {
      "id": 1,
      "templateId": 1,
      "exerciseId": 1,
      "exerciseName": "卧推",
      "sets": 3,
      "reps": 10,
      "weight": 60.0,
      "sortOrder": 0
    }
  ]
}
```

#### POST /api/templates

创建新模板。

**请求体参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | 是 | 模板名称 |
| type | string | 是 | 模板类型：strength, running, swimming |
| description | string | 否 | 模板描述 |
| isDefault | boolean | 否 | 是否为默认模板 |
| exercises | object[] | 否 | 初始动作列表 |

**exercises 项结构：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| exerciseId | integer | 否 | 关联的动作 ID |
| exerciseName | string | 是 | 动作名称 |
| sets | integer | 否 | 默认组数，默认 3 |
| reps | integer | 否 | 默认次数，默认 10 |
| weight | number | 否 | 默认重量 |

**响应示例：**

```json
{
  "id": 1,
  "message": "Created successfully"
}
```

#### PUT /api/templates/{id}

更新模板。

**请求体参数（可选）：**

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 模板名称 |
| type | string | 模板类型 |
| description | string | 模板描述 |
| isDefault | boolean | 是否为默认模板 |

**响应示例：**

```json
{
  "message": "Updated successfully"
}
```

#### DELETE /api/templates/{id}

删除模板。

**响应示例：**

```json
{
  "message": "Deleted successfully"
}
```

#### POST /api/templates/{id}/exercises

向模板添加动作。

**请求体参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| exerciseId | integer | 否 | 关联的动作 ID |
| exerciseName | string | 是 | 动作名称 |
| sets | integer | 否 | 默认组数，默认 3 |
| reps | integer | 否 | 默认次数，默认 10 |
| weight | number | 否 | 默认重量 |
| sortOrder | integer | 否 | 排序顺序 |

**响应示例：**

```json
{
  "id": 1,
  "message": "Exercise added"
}
```

#### DELETE /api/templates/exercises/{exerciseId}

删除模板中的动作。

**响应示例：**

```json
{
  "message": "Deleted successfully"
}
```

---

### 五、个人记录 API

#### GET /api/pr

获取所有个人记录。

**响应示例：**

```json
[
  {
    "id": 1,
    "recordType": "strength_1rm",
    "exerciseId": 1,
    "value": 100.0,
    "unit": "kg",
    "achievedAt": "2024-01-15T08:30:00.000Z",
    "sessionId": 10
  }
]
```

#### GET /api/pr/{type}

按类型获取 PR。

**路径参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| type | string | 记录类型：strength_1rm, strength_volume, running_distance, running_pace, swimming_distance |

**响应示例：** 同上

#### GET /api/pr/exercise/{exerciseId}

获取某动作的 PR 历史。

**响应示例：** 同上

#### DELETE /api/pr/{id}

删除 PR（禁止直接删除，返回错误）。

**响应：**

```json
{
  "error": "PR is derived data and cannot be deleted directly"
}
```

---

### 六、跑步记录 API

#### GET /api/running

获取所有跑步记录。

**响应示例：**

```json
[
  {
    "id": 1,
    "sessionId": 10,
    "runType": "easy",
    "distanceMeters": 5000.0,
    "durationSeconds": 1800,
    "avgPaceSeconds": 360,
    "bestPaceSeconds": 320,
    "avgHeartRate": 145,
    "maxHeartRate": 165,
    "avgCadence": 170,
    "maxCadence": 185,
    "elevationGain": 50.0,
    "elevationLoss": 45.0,
    "footwear": "Nike Pegasus",
    "weatherJson": null
  }
]
```

**跑步类型说明：**

| 类型 | 说明 |
|------|------|
| easy | 轻松跑 |
| tempo | 节奏跑 |
| interval | 间歇跑 |
| lsd | 长距离慢跑 |
| recovery | 恢复跑 |
| race | 比赛 |

#### GET /api/running/{id}

获取单个跑步记录。

**响应示例：** 同上

#### GET /api/running/{id}/splits

获取跑步分段数据。

**响应示例：**

```json
[
  {
    "id": 1,
    "runningEntryId": 1,
    "splitNumber": 1,
    "distanceMeters": 1000.0,
    "durationSeconds": 360,
    "paceSeconds": 360,
    "avgHeartRate": 145,
    "cadence": 170,
    "elevationGain": 10.0,
    "isManual": false
  }
]
```

#### GET /api/running/stats

获取跑步统计数据。

**响应示例：**

```json
{
  "totalRuns": 50,
  "totalDistanceMeters": 250000.0,
  "totalDurationSeconds": 90000,
  "weeklyDistanceMeters": 15000.0,
  "monthlyDistanceMeters": 60000.0
}
```

---

### 七、游泳记录 API

#### GET /api/swimming

获取所有游泳记录。

**响应示例：**

```json
[
  {
    "id": 1,
    "sessionId": 10,
    "environment": "pool",
    "poolLengthMeters": 25,
    "primaryStroke": "freestyle",
    "distanceMeters": 1000.0,
    "durationSeconds": 1200,
    "pacePer100m": 120,
    "trainingType": "endurance",
    "equipment": "[\"fins\", \"pull_buoy\"]"
  }
]
```

**环境类型：**

| 值 | 说明 |
|----|------|
| pool | 泳池 |
| open_water | 开放水域 |

**泳姿类型：**

| 值 | 说明 |
|----|------|
| freestyle | 自由泳 |
| breaststroke | 蛙泳 |
| backstroke | 仰泳 |
| butterfly | 蝶泳 |
| mixed | 混合 |

**训练类型：**

| 值 | 说明 |
|----|------|
| technique | 技术 |
| endurance | 耐力 |
| speed | 速度 |
| recovery | 恢复 |

#### GET /api/swimming/{id}

获取单个游泳记录。

**响应示例：** 同上

#### GET /api/swimming/{id}/sets

获取游泳分组数据。

**响应示例：**

```json
[
  {
    "id": 1,
    "swimmingEntryId": 1,
    "setType": "warmup",
    "description": "轻松游",
    "distanceMeters": 200.0,
    "durationSeconds": 240,
    "sortOrder": 0
  }
]
```

**分组类型：**

| 值 | 说明 |
|----|------|
| warmup | 热身 |
| main | 主训练 |
| cooldown | 放松 |

#### GET /api/swimming/stats

获取游泳统计数据。

**响应示例：**

```json
{
  "totalSwims": 30,
  "totalDistanceMeters": 30000.0,
  "totalDurationSeconds": 36000,
  "weeklyDistanceMeters": 2000.0,
  "monthlyDistanceMeters": 8000.0
}
```

---

### 八、力量训练 API

#### GET /api/strength/{sessionId}

获取力量训练详情。

**响应示例：**

```json
[
  {
    "id": 1,
    "sessionId": 10,
    "exerciseId": 1,
    "exerciseName": "卧推",
    "sets": 3,
    "defaultReps": 10,
    "defaultWeight": 60.0,
    "repsPerSet": "[10, 8, 6]",
    "weightPerSet": "[60.0, 65.0, 70.0]",
    "setCompleted": "[true, true, true]",
    "isWarmup": false,
    "rpe": 8,
    "restSeconds": 120,
    "sortOrder": 0,
    "note": "感觉良好"
  }
]
```

#### POST /api/strength/{sessionId}

添加力量训练动作。

**请求体参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| exerciseId | integer | 否 | 关联的动作 ID |
| exerciseName | string | 是 | 动作名称 |
| sets | integer | 否 | 组数，默认 3 |
| defaultReps | integer | 否 | 默认次数，默认 10 |
| defaultWeight | number | 否 | 默认重量 |
| repsPerSet | string | 否 | 每组次数 JSON 数组字符串 |
| weightPerSet | string | 否 | 每组重量 JSON 数组字符串 |
| setCompleted | string | 否 | 每组完成状态 JSON 数组字符串 |
| isWarmup | boolean | 否 | 是否为热身组 |
| rpe | integer | 否 | RPE 主观强度（1-10） |
| restSeconds | integer | 否 | 休息秒数 |
| note | string | 否 | 备注 |
| sortOrder | integer | 否 | 排序顺序 |

**响应示例：**

```json
{
  "id": 1,
  "message": "Entry added"
}
```

#### PUT /api/strength/entry/{entryId}

更新力量训练动作。

**请求体参数（可选）：** 同创建参数

**响应示例：**

```json
{
  "message": "Updated successfully"
}
```

#### DELETE /api/strength/entry/{entryId}

删除力量训练动作。

**响应示例：**

```json
{
  "message": "Deleted successfully"
}
```

---

### 九、设置 API

#### GET /api/settings

获取用户设置。

**响应示例：**

```json
{
  "id": 1,
  "weeklyWorkoutDaysGoal": 5,
  "weeklyWorkoutMinutesGoal": 150,
  "themeMode": "system",
  "weightUnit": "kg",
  "distanceUnit": "meters",
  "lanServiceEnabled": true,
  "lanServicePort": 8080,
  "lanServiceTokenEnabled": false,
  "defaultBackupConfigId": null,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-15T08:30:00.000Z"
}
```

**主题模式：**

| 值 | 说明 |
|----|------|
| light | 浅色模式 |
| dark | 深色模式 |
| system | 跟随系统 |

**重量单位：**

| 值 | 说明 |
|----|------|
| kg | 千克 |
| lbs | 磅 |

**距离单位：**

| 值 | 说明 |
|----|------|
| meters | 米 |
| km | 公里 |
| miles | 英里 |

#### PUT /api/settings

更新用户设置。

**请求体参数（可选）：**

| 字段 | 类型 | 说明 |
|------|------|------|
| weeklyWorkoutDaysGoal | integer | 每周运动天数目标 |
| weeklyWorkoutMinutesGoal | integer | 每周运动时长目标（分钟） |
| themeMode | string | 主题模式 |
| weightUnit | string | 重量单位 |
| distanceUnit | string | 距离单位 |
| lanServiceEnabled | boolean | 是否启用局域网服务 |
| lanServicePort | integer | 局域网服务端口 |

**响应示例：**

```json
{
  "message": "Settings updated successfully"
}
```

---

### 十、备份 API

#### GET /api/backup-configs

获取所有备份配置。

**响应示例：**

```json
[
  {
    "id": 1,
    "providerType": "webdav",
    "displayName": "我的 WebDAV",
    "endpoint": "https://dav.example.com",
    "bucketOrPath": "/backups/fittrack",
    "region": null,
    "isDefault": true,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
]
```

**提供商类型：**

| 值 | 说明 |
|----|------|
| webdav | WebDAV 协议 |
| s3 | S3 兼容服务 |

#### GET /api/backup-configs/default

获取默认备份配置。

**响应示例：** 同上

**404 响应：**

```json
{
  "error": "No default config found"
}
```

#### POST /api/backup-configs

创建备份配置。

**请求体参数（WebDAV）：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| providerType | string | 是 | webdav |
| displayName | string | 是 | 显示名称 |
| endpoint | string | 是 | WebDAV 端点 URL |
| path | string | 是 | 存储路径 |
| username | string | 否 | 用户名 |
| password | string | 否 | 密码 |
| isDefault | boolean | 否 | 是否为默认 |

**请求体参数（S3）：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| providerType | string | 是 | s3 |
| displayName | string | 是 | 显示名称 |
| endpoint | string | 是 | S3 端点 URL |
| bucket | string | 是 | 存储桶名称 |
| region | string | 否 | S3 区域 |
| accessKey | string | 否 | Access Key |
| secretKey | string | 否 | Secret Key |
| isDefault | boolean | 否 | 是否为默认 |

**响应示例：**

```json
{
  "id": 1,
  "message": "Config created successfully"
}
```

#### DELETE /api/backup-configs/{id}

删除备份配置。

**响应示例：**

```json
{
  "message": "Config deleted successfully"
}
```

#### POST /api/backup

使用默认配置执行备份。

**响应示例：**

```json
{
  "success": true,
  "path": "/backups/fittrack/backup_20240115_083000.zip",
  "checksum": "a1b2c3d4..."
}
```

#### POST /api/backup/{id}

使用指定配置执行备份。

**响应示例：** 同上

#### GET /api/backup-records

获取备份记录列表。

**查询参数：**

| 参数 | 类型 | 说明 |
|------|------|------|
| configId | integer | 按配置 ID 过滤（可选） |

**响应示例：**

```json
[
  {
    "id": 1,
    "configId": 1,
    "providerType": "webdav",
    "targetPath": "/backups/fittrack/backup_20240115_083000.zip",
    "createdAt": "2024-01-15T08:30:00.000Z",
    "status": "completed",
    "checksum": "a1b2c3d4...",
    "metadataJson": null
  }
]
```

**状态值：**

| 值 | 说明 |
|----|------|
| pending | 等待中 |
| running | 执行中 |
| completed | 已完成 |
| failed | 失败 |

#### POST /api/restore

从备份记录恢复数据。

**请求体参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| recordId | integer | 是 | 备份记录 ID |

**响应示例：**

```json
{
  "success": true
}
```

---

### 十一、批量操作 API

#### POST /api/bulk/workouts/delete

批量删除训练记录。

**请求体参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| ids | integer[] | 是 | 训练记录 ID 列表 |

**响应示例：**

```json
{
  "deleted": 5,
  "requested": 6,
  "message": "Bulk delete completed"
}
```

#### POST /api/bulk/workouts/update

批量更新训练记录。

**请求体参数：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| updates | object[] | 是 | 更新对象数组 |

**updates 项结构：**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | integer | 是 | 训练记录 ID |
| datetime | string | 否 | 日期时间 |
| type | string | 否 | 类型 |
| durationMinutes | integer | 否 | 时长 |
| intensity | string | 否 | 强度 |
| note | string | 否 | 备注 |
| isGoalCompleted | boolean | 否 | 是否完成目标 |

**响应示例：**

```json
{
  "updated": 3,
  "requested": 3,
  "message": "Bulk update completed"
}
```

---

### 十二、导入导出 API

#### GET /api/export/json

导出完整数据（JSON 格式）。

**响应示例：**

```json
{
  "version": "1.0",
  "exportDate": "2024-01-15T08:30:00.000Z",
  "trainingSessions": [...],
  "exercises": [...],
  "templates": [...],
  "personalRecords": [...],
  "settings": {...}
}
```

#### GET /api/export/csv

导出训练记录（CSV 格式）。

**响应：** 纯文本 CSV

```csv
ID,DateTime,Type,Duration,Intensity,Note,GoalCompleted
1,2024-01-15T07:00:00.000Z,running,30,moderate,"晨跑",true
```

**Content-Type:** `text/csv; charset=utf-8`

#### POST /api/import/json

导入完整数据。

**请求体参数：** 同导出 JSON 结构

**响应示例：**

```json
{
  "message": "Import completed"
}
```

---

## Web UI 资源

所有非 `/api/*` 和 `/health` 路径返回 Web UI 静态资源。这是由 Flutter Web 构建的前端应用。

| 路径 | 说明 |
|------|------|
| `/` | Web 应用首页 |
| `/index.html` | 主页面 |
| `/assets/*` | 静态资源（JS、CSS、图片等） |

---

## 调用示例

### 使用 curl

**健康检查：**

```bash
curl http://192.168.1.100:8080/health
```

**获取训练记录（带认证）：**

```bash
curl -H "Authorization: Bearer mytoken" \
  http://192.168.1.100:8080/api/workouts
```

**创建训练记录：**

```bash
curl -X POST \
  -H "Authorization: Bearer mytoken" \
  -H "Content-Type: application/json" \
  -d '{
    "datetime": "2024-01-15T07:00:00.000Z",
    "type": "running",
    "durationMinutes": 30,
    "intensity": "moderate"
  }' \
  http://192.168.1.100:8080/api/workouts
```

**导出 CSV：**

```bash
curl -H "Authorization: Bearer mytoken" \
  http://192.168.1.100:8080/api/export/csv \
  -o workouts.csv
```

### 使用 JavaScript fetch

```javascript
const baseUrl = 'http://192.168.1.100:8080';
const token = 'mytoken';

// 获取训练记录
const workouts = await fetch(`${baseUrl}/api/workouts`, {
  headers: { 'Authorization': `Bearer ${token}` }
}).then(r => r.json());

// 创建训练记录
const newWorkout = await fetch(`${baseUrl}/api/workouts`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    datetime: new Date().toISOString(),
    type: 'strength',
    durationMinutes: 45,
    intensity: 'high'
  })
}).then(r => r.json());

// 批量删除
await fetch(`${baseUrl}/api/bulk/workouts/delete`, {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ ids: [1, 2, 3] })
});
```

---

## 注意事项

1. **日期时间格式**: 所有日期时间均采用 ISO 8601 格式（如 `2024-01-15T07:00:00.000Z`）
2. **JSON 数组字符串**: 力量训练的 `repsPerSet`, `weightPerSet`, `setCompleted` 字段是 JSON 数组的字符串表示
3. **ID 生成**: 所有 ID 是自增整数，由数据库自动分配
4. **自动时间戳**: 创建和更新操作会自动维护 `createdAt` 和 `updatedAt` 字段
5. **级联删除**: 删除训练记录会自动删除关联的跑步/游泳/力量详情记录
6. **PR 自动重建**: 修改力量训练记录后会自动重新计算个人记录
