import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../database/database.dart';
import '../../repositories/settings_repository.dart';
import '../response_helper.dart';

/// 设置 API 处理器
class SettingsApiHandler {
  final SettingsRepository _repository;

  SettingsApiHandler(AppDatabase db) : _repository = SettingsRepository(db);

  /// 获取设置
  Future<Response> getSettings(Request request) async {
    try {
      final settings = await _repository.getOrCreateSettings();
      return LanApiResponse.ok(
        data: _settingsToJson(settings),
        message: 'Fetched settings successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 更新设置
  Future<Response> updateSettings(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (data['weeklyWorkoutDaysGoal'] != null) {
        await _repository.updateWeeklyDaysGoal(
          data['weeklyWorkoutDaysGoal'] as int,
        );
      }

      if (data['weeklyWorkoutMinutesGoal'] != null) {
        await _repository.updateWeeklyMinutesGoal(
          data['weeklyWorkoutMinutesGoal'] as int,
        );
      }

      if (data['themeMode'] != null) {
        await _repository.updateThemeMode(data['themeMode'] as String);
      }

      if (data['weightUnit'] != null) {
        await _repository.updateWeightUnit(data['weightUnit'] as String);
      }

      if (data['distanceUnit'] != null) {
        await _repository.updateDistanceUnit(data['distanceUnit'] as String);
      }

      if (data['lanServiceEnabled'] != null) {
        await _repository.updateLanService(
          enabled: data['lanServiceEnabled'] as bool,
          port: data['lanServicePort'] as int?,
        );
      }

      return LanApiResponse.ok(
        data: const {},
        message: 'Settings updated successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 转换设置为 JSON
  Map<String, dynamic> _settingsToJson(UserSetting settings) {
    return {
      'id': settings.id,
      'weeklyWorkoutDaysGoal': settings.weeklyWorkoutDaysGoal,
      'weeklyWorkoutMinutesGoal': settings.weeklyWorkoutMinutesGoal,
      'themeMode': settings.themeMode,
      'weightUnit': settings.weightUnit,
      'distanceUnit': settings.distanceUnit,
      'lanServiceEnabled': settings.lanServiceEnabled,
      'lanServicePort': settings.lanServicePort,
      'lanServiceTokenEnabled': settings.lanServiceTokenEnabled,
      'defaultBackupConfigId': settings.defaultBackupConfigId,
      'createdAt': settings.createdAt.toIso8601String(),
      'updatedAt': settings.updatedAt.toIso8601String(),
    };
  }
}
