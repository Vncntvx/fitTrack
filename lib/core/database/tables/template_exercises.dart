import 'package:drift/drift.dart';

import 'workout_templates.dart';
import 'exercises.dart';

/// 模板动作表
/// 存储模板中包含的动作及默认设置
@TableIndex(name: 'idx_template_exercises_template', columns: {#templateId})
@TableIndex(name: 'idx_template_exercises_exercise', columns: {#exerciseId})
class TemplateExercises extends Table {
  /// 主键ID
  IntColumn get id => integer().autoIncrement()();

  /// 关联的模板ID
  /// 模板删除时级联删除模板动作
  IntColumn get templateId => integer().references(
    WorkoutTemplates,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// 关联的动作ID（可选）
  /// 动作删除受限，防止模板出现悬空引用
  IntColumn get exerciseId => integer().nullable().references(
    Exercises,
    #id,
    onDelete: KeyAction.restrict,
  )();

  /// 动作名称
  TextColumn get exerciseName => text()();

  /// 默认组数
  IntColumn get sets => integer()();

  /// 默认次数
  IntColumn get reps => integer()();

  /// 默认重量
  RealColumn get weight => real().nullable()();

  /// 排序顺序
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
