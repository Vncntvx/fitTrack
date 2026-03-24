import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../database/database.dart';
import '../../repositories/template_repository.dart';
import '../../usecases/template/save_template_usecase.dart';
import '../response_helper.dart';

/// 训练模板 API 处理器
class TemplateApiHandler {
  final TemplateRepository _repository;
  final AppDatabase _db;

  TemplateApiHandler(AppDatabase db)
    : _repository = TemplateRepository(db),
      _db = db;

  /// 获取所有模板
  Future<Response> getAll(Request request) async {
    try {
      final params = request.url.queryParameters;
      final type = params['type'];

      List<WorkoutTemplate> templates;
      if (type != null && type.isNotEmpty) {
        templates = await _repository.getByType(type);
      } else {
        templates = await _repository.getAll();
      }

      return LanApiResponse.ok(
        data: templates.map(_templateToJson).toList(),
        message: 'Fetched templates successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取模板详情
  Future<Response> getById(Request request, String id) async {
    try {
      final templateId = int.tryParse(id);
      if (templateId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final detail = await _repository.getTemplateDetail(templateId);
      if (detail == null) {
        return LanApiResponse.notFound('Template not found');
      }

      return LanApiResponse.ok(
        data: {
          'template': _templateToJson(detail.template),
          'exercises': detail.exercises.map(_templateExerciseToJson).toList(),
        },
        message: 'Fetched template successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 创建模板
  Future<Response> create(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (data['name'] == null || (data['name'] as String).isEmpty) {
        return LanApiResponse.badRequest('name is required');
      }
      if (data['type'] == null || (data['type'] as String).isEmpty) {
        return LanApiResponse.badRequest('type is required');
      }

      final exercises = data['exercises'] as List?;
      final id = await SaveTemplateUseCase(_db, _repository)(
        SaveTemplateParams(
          name: data['name'] as String,
          type: data['type'] as String,
          description: data['description'] as String?,
          isDefault: data['isDefault'] as bool? ?? false,
          exercises: exercises == null
              ? const []
              : exercises.map((e) {
                  final item = e as Map<String, dynamic>;
                  return TemplateExerciseInput(
                    exerciseId: item['exerciseId'] as int?,
                    exerciseName: item['exerciseName'] as String,
                    sets: item['sets'] as int? ?? 3,
                    reps: item['reps'] as int? ?? 10,
                    weight: (item['weight'] as num?)?.toDouble(),
                  );
                }).toList(),
        ),
      );

      return LanApiResponse.created(
        data: {'id': id},
        message: 'Created successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 更新模板
  Future<Response> update(Request request, String id) async {
    try {
      final templateId = int.tryParse(id);
      if (templateId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final success = await _repository.updateTemplate(
        templateId,
        name: data['name'] as String?,
        type: data['type'] as String?,
        description: data['description'] as String?,
        isDefault: data['isDefault'] as bool?,
      );

      if (!success) {
        return LanApiResponse.notFound('Template not found');
      }

      return LanApiResponse.ok(
        data: {'id': templateId},
        message: 'Updated successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 删除模板
  Future<Response> delete(Request request, String id) async {
    try {
      final templateId = int.tryParse(id);
      if (templateId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final deleted = await _repository.deleteTemplate(templateId);
      if (deleted == 0) {
        return LanApiResponse.notFound('Template not found');
      }

      return LanApiResponse.ok(
        data: {'id': templateId},
        message: 'Deleted successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 添加模板动作
  Future<Response> addExercise(Request request, String id) async {
    try {
      final templateId = int.tryParse(id);
      if (templateId == null) {
        return LanApiResponse.badRequest('Invalid template ID');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final exerciseId = await _repository.addTemplateExercise(
        templateId: templateId,
        exerciseId: data['exerciseId'] as int?,
        exerciseName: data['exerciseName'] as String,
        sets: data['sets'] as int? ?? 3,
        reps: data['reps'] as int? ?? 10,
        weight: (data['weight'] as num?)?.toDouble(),
        sortOrder: data['sortOrder'] as int? ?? 0,
      );

      return LanApiResponse.created(
        data: {'id': exerciseId},
        message: 'Exercise added',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 删除模板动作
  Future<Response> deleteExercise(Request request, String exerciseId) async {
    try {
      final id = int.tryParse(exerciseId);
      if (id == null) {
        return LanApiResponse.badRequest('Invalid exercise ID');
      }

      await _repository.deleteTemplateExercise(id);

      return LanApiResponse.ok(
        data: {'id': id},
        message: 'Deleted successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 转换模板为 JSON
  Map<String, dynamic> _templateToJson(WorkoutTemplate template) {
    return {
      'id': template.id,
      'name': template.name,
      'type': template.type,
      'description': template.description,
      'isDefault': template.isDefault,
      'createdAt': template.createdAt.toIso8601String(),
      'updatedAt': template.updatedAt.toIso8601String(),
    };
  }

  /// 转换模板动作为 JSON
  Map<String, dynamic> _templateExerciseToJson(TemplateExercise exercise) {
    return {
      'id': exercise.id,
      'templateId': exercise.templateId,
      'exerciseId': exercise.exerciseId,
      'exerciseName': exercise.exerciseName,
      'sets': exercise.sets,
      'reps': exercise.reps,
      'weight': exercise.weight,
      'sortOrder': exercise.sortOrder,
    };
  }
}
