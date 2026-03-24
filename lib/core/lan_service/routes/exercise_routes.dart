import 'dart:convert';
import 'package:shelf/shelf.dart';
import '../../database/database.dart';
import '../../repositories/exercise_repository.dart';
import '../../usecases/exercise/delete_exercise_usecase.dart';
import '../response_helper.dart';

/// 动作库 API 处理器
class ExerciseApiHandler {
  final ExerciseRepository _repository;

  ExerciseApiHandler(AppDatabase db) : _repository = ExerciseRepository(db);

  /// 获取所有动作
  Future<Response> getAll(Request request) async {
    try {
      final params = request.url.queryParameters;
      final category = params['category'];

      List<Exercise> exercises;
      if (category != null && category.isNotEmpty) {
        exercises = await _repository.getByCategory(category);
      } else {
        exercises = await _repository.getAll();
      }

      return LanApiResponse.ok(
        data: exercises.map(_exerciseToJson).toList(),
        message: 'Fetched exercises successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 获取单个动作
  Future<Response> getById(Request request, String id) async {
    try {
      final exerciseId = int.tryParse(id);
      if (exerciseId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final exercise = await _repository.getById(exerciseId);
      if (exercise == null) {
        return LanApiResponse.notFound('Exercise not found');
      }

      return LanApiResponse.ok(
        data: _exerciseToJson(exercise),
        message: 'Fetched exercise successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 创建动作
  Future<Response> create(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      if (data['name'] == null || (data['name'] as String).isEmpty) {
        return LanApiResponse.badRequest('name is required');
      }
      if (data['category'] == null || (data['category'] as String).isEmpty) {
        return LanApiResponse.badRequest('category is required');
      }

      final id = await _repository.createExercise(
        name: data['name'] as String,
        category: data['category'] as String,
        movementType: data['movementType'] as String? ?? 'compound',
        primaryMuscles: data['primaryMuscles'] as String?,
        secondaryMuscles: data['secondaryMuscles'] as String?,
        defaultSets: data['defaultSets'] as int? ?? 3,
        defaultReps: data['defaultReps'] as int? ?? 10,
        defaultWeight: (data['defaultWeight'] as num?)?.toDouble(),
        description: data['description'] as String?,
      );

      return LanApiResponse.created(
        data: {'id': id},
        message: 'Created successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 更新动作
  Future<Response> update(Request request, String id) async {
    try {
      final exerciseId = int.tryParse(id);
      if (exerciseId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final success = await _repository.updateExercise(
        exerciseId,
        name: data['name'] as String?,
        category: data['category'] as String?,
        movementType: data['movementType'] as String?,
        primaryMuscles: data['primaryMuscles'] as String?,
        secondaryMuscles: data['secondaryMuscles'] as String?,
        defaultSets: data['defaultSets'] as int?,
        defaultReps: data['defaultReps'] as int?,
        defaultWeight: (data['defaultWeight'] as num?)?.toDouble(),
        isEnabled: data['isEnabled'] as bool?,
        description: data['description'] as String?,
      );

      if (!success) {
        return LanApiResponse.notFound('Exercise not found');
      }

      return LanApiResponse.ok(
        data: {'id': exerciseId},
        message: 'Updated successfully',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 删除动作
  Future<Response> delete(Request request, String id) async {
    try {
      final exerciseId = int.tryParse(id);
      if (exerciseId == null) {
        return LanApiResponse.badRequest('Invalid ID');
      }

      final useCase = DeleteExerciseUseCase(_repository);
      final result = await useCase(exerciseId);

      switch (result) {
        case DeleteExerciseResult.success:
          return LanApiResponse.ok(
            data: {'id': exerciseId},
            message: 'Deleted successfully',
          );
        case DeleteExerciseResult.hasStrengthReferences:
          return LanApiResponse.conflict(
            'Cannot delete exercise with training history',
            code: 'exercise_has_training_history',
          );
        case DeleteExerciseResult.hasTemplateReferences:
          return LanApiResponse.conflict(
            'Cannot delete exercise used in templates',
            code: 'exercise_used_in_templates',
          );
        case DeleteExerciseResult.hasPrReferences:
          return LanApiResponse.conflict(
            'Cannot delete exercise used in personal records',
            code: 'exercise_used_in_personal_records',
          );
        case DeleteExerciseResult.notFound:
          return LanApiResponse.notFound('Exercise not found');
      }
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 批量删除动作
  Future<Response> bulkDelete(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final ids = (data['ids'] as List?)?.cast<int>() ?? [];

      if (ids.isEmpty) {
        return LanApiResponse.badRequest('ids array is required');
      }

      final results = <Map<String, dynamic>>[];
      final useCase = DeleteExerciseUseCase(_repository);
      for (final id in ids) {
        final result = await useCase(id);
        results.add({
          'id': id,
          'success': result == DeleteExerciseResult.success,
          'result': result.name,
        });
      }

      return LanApiResponse.ok(
        data: {'results': results},
        message: 'Bulk delete completed',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 导出动作
  Future<Response> export(Request request) async {
    try {
      final exercises = await _repository.getAll();
      final data = {
        'exportDate': DateTime.now().toIso8601String(),
        'count': exercises.length,
        'exercises': exercises.map(_exerciseToJson).toList(),
      };

      return LanApiResponse.ok(data: data, message: 'Export completed');
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 导入动作
  Future<Response> import(Request request) async {
    try {
      final body = await request.readAsString();
      final data = jsonDecode(body) as Map<String, dynamic>;
      final exercises = data['exercises'] as List?;

      if (exercises == null || exercises.isEmpty) {
        return LanApiResponse.badRequest('exercises array is required');
      }

      var imported = 0;
      var skipped = 0;

      for (final item in exercises) {
        final exercise = item as Map<String, dynamic>;
        try {
          await _repository.createExercise(
            name: exercise['name'] as String,
            category: exercise['category'] as String,
            movementType: exercise['movementType'] as String? ?? 'compound',
            primaryMuscles: exercise['primaryMuscles'] as String?,
            secondaryMuscles: exercise['secondaryMuscles'] as String?,
            defaultSets: exercise['defaultSets'] as int? ?? 3,
            defaultReps: exercise['defaultReps'] as int? ?? 10,
            defaultWeight: (exercise['defaultWeight'] as num?)?.toDouble(),
            description: exercise['description'] as String?,
          );
          imported++;
        } catch (_) {
          skipped++;
        }
      }

      return LanApiResponse.ok(
        data: {'imported': imported, 'skipped': skipped},
        message: 'Import completed',
      );
    } catch (e) {
      return LanApiResponse.internalServerError(e.toString());
    }
  }

  /// 转换动作为 JSON
  Map<String, dynamic> _exerciseToJson(Exercise exercise) {
    return {
      'id': exercise.id,
      'name': exercise.name,
      'category': exercise.category,
      'movementType': exercise.movementType,
      'primaryMuscles': exercise.primaryMuscles,
      'secondaryMuscles': exercise.secondaryMuscles,
      'defaultSets': exercise.defaultSets,
      'defaultReps': exercise.defaultReps,
      'defaultWeight': exercise.defaultWeight,
      'isCustom': exercise.isCustom,
      'isEnabled': exercise.isEnabled,
      'description': exercise.description,
      'createdAt': exercise.createdAt.toIso8601String(),
      'updatedAt': exercise.updatedAt.toIso8601String(),
    };
  }
}
