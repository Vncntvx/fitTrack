import 'package:drift/drift.dart';
import '../database/database.dart';

/// 设置 Repository
/// 提供用户设置的读写操作
class SettingsRepository {
  final AppDatabase _db;

  SettingsRepository(this._db);

  /// 获取或创建设置（使用事务解决竞态条件）
  Future<UserSetting> getOrCreateSettings() async {
    return await _db.transaction(() async {
      final existing = await (_db.select(
        _db.userSettings,
      )..limit(1)).getSingleOrNull();

      if (existing != null) {
        return existing;
      }

      // 创建默认设置
      await _db.into(_db.userSettings).insert(const UserSettingsCompanion());

      return await (_db.select(
        _db.userSettings,
      )..limit(1)).getSingle();
    });
  }

  /// 获取设置
  Future<UserSetting?> getSettings() async {
    return await (_db.select(_db.userSettings)..limit(1)).getSingleOrNull();
  }

  /// 更新每周运动天数目标
  Future<bool> updateWeeklyDaysGoal(int days) async {
    // 确保设置存在
    final settings = await getOrCreateSettings();

    // 使用 write 进行部分更新
    final rowsAffected =
        await (_db.update(
          _db.userSettings,
        )..where((s) => s.id.equals(settings.id))).write(
          UserSettingsCompanion(
            weeklyWorkoutDaysGoal: Value(days),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  /// 更新每周运动分钟目标
  Future<bool> updateWeeklyMinutesGoal(int minutes) async {
    final settings = await getOrCreateSettings();

    final rowsAffected =
        await (_db.update(
          _db.userSettings,
        )..where((s) => s.id.equals(settings.id))).write(
          UserSettingsCompanion(
            weeklyWorkoutMinutesGoal: Value(minutes),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  /// 更新主题模式
  Future<bool> updateThemeMode(String themeMode) async {
    final settings = await getOrCreateSettings();

    final rowsAffected =
        await (_db.update(
          _db.userSettings,
        )..where((s) => s.id.equals(settings.id))).write(
          UserSettingsCompanion(
            themeMode: Value(themeMode),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  /// 更新局域网服务设置
  Future<bool> updateLanService({required bool enabled, int? port}) async {
    final settings = await getOrCreateSettings();

    final companion = UserSettingsCompanion(
      lanServiceEnabled: Value(enabled),
      updatedAt: Value(DateTime.now()),
    );

    // 如果提供了端口，也更新
    final rowsAffected =
        await (_db.update(
          _db.userSettings,
        )..where((s) => s.id.equals(settings.id))).write(
          port != null
              ? companion.copyWith(lanServicePort: Value(port))
              : companion,
        );
    return rowsAffected > 0;
  }

  /// 更新默认备份配置
  Future<bool> updateDefaultBackupConfig(int? configId) async {
    final settings = await getOrCreateSettings();

    final rowsAffected =
        await (_db.update(
          _db.userSettings,
        )..where((s) => s.id.equals(settings.id))).write(
          UserSettingsCompanion(
            defaultBackupConfigId: Value(configId),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  /// 监听设置变化（响应式）
  Stream<UserSetting?> watchSettings() {
    return (_db.select(_db.userSettings)..limit(1)).watchSingleOrNull();
  }

  /// 获取每周运动天数目标
  Future<int> getWeeklyDaysGoal() async {
    final settings = await getSettings();
    return settings?.weeklyWorkoutDaysGoal ?? 3;
  }

  /// 获取每周运动分钟目标
  Future<int> getWeeklyMinutesGoal() async {
    final settings = await getSettings();
    return settings?.weeklyWorkoutMinutesGoal ?? 150;
  }

  /// 获取主题模式
  Future<String> getThemeMode() async {
    final settings = await getSettings();
    return settings?.themeMode ?? 'system';
  }

  /// 获取重量单位
  Future<String> getWeightUnit() async {
    final settings = await getSettings();
    return settings?.weightUnit ?? 'kg';
  }

  /// 获取距离单位
  Future<String> getDistanceUnit() async {
    final settings = await getSettings();
    return settings?.distanceUnit ?? 'km';
  }

  /// 获取局域网服务是否启用
  Future<bool> isLanServiceEnabled() async {
    final settings = await getSettings();
    return settings?.lanServiceEnabled ?? false;
  }

  /// 获取局域网服务端口
  Future<int> getLanServicePort() async {
    final settings = await getSettings();
    return settings?.lanServicePort ?? 8080;
  }

  /// 获取局域网服务令牌是否启用
  Future<bool> isLanServiceTokenEnabled() async {
    final settings = await getSettings();
    return settings?.lanServiceTokenEnabled ?? false;
  }

  /// 更新局域网服务令牌启用状态
  Future<bool> updateLanServiceTokenEnabled(bool enabled) async {
    final settings = await getOrCreateSettings();

    final rowsAffected =
        await (_db.update(
          _db.userSettings,
        )..where((s) => s.id.equals(settings.id))).write(
          UserSettingsCompanion(
            lanServiceTokenEnabled: Value(enabled),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  /// 更新重量单位
  Future<bool> updateWeightUnit(String unit) async {
    if (unit != 'kg' && unit != 'lbs') {
      throw ArgumentError.value(unit, 'unit', '重量单位仅支持 kg 或 lbs');
    }
    final settings = await getOrCreateSettings();

    final rowsAffected =
        await (_db.update(
          _db.userSettings,
        )..where((s) => s.id.equals(settings.id))).write(
          UserSettingsCompanion(
            weightUnit: Value(unit),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }

  /// 更新距离单位
  Future<bool> updateDistanceUnit(String unit) async {
    if (unit != 'km' && unit != 'mi') {
      throw ArgumentError.value(unit, 'unit', '距离单位仅支持 km 或 mi');
    }
    final settings = await getOrCreateSettings();

    final rowsAffected =
        await (_db.update(
          _db.userSettings,
        )..where((s) => s.id.equals(settings.id))).write(
          UserSettingsCompanion(
            distanceUnit: Value(unit),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return rowsAffected > 0;
  }
}
