import 'package:drift/drift.dart';
import '../database.dart';

/// 动作库种子数据
/// 预置常见健身动作
class ExerciseSeedData {
  /// 胸部动作
  static const List<Map<String, dynamic>> chestExercises = [
    {
      'name': '卧推',
      'category': 'chest',
      'movementType': 'compound',
      'primaryMuscles': '胸大肌',
      'secondaryMuscles': '三角肌前束,肱三头肌',
      'defaultSets': 4,
      'defaultReps': 8,
      'description': '经典胸部复合动作',
    },
    {
      'name': '上斜卧推',
      'category': 'chest',
      'movementType': 'compound',
      'primaryMuscles': '胸大肌上束',
      'secondaryMuscles': '三角肌前束,肱三头肌',
      'defaultSets': 4,
      'defaultReps': 10,
    },
    {
      'name': '下斜卧推',
      'category': 'chest',
      'movementType': 'compound',
      'primaryMuscles': '胸大肌下束',
      'secondaryMuscles': '三角肌前束,肱三头肌',
      'defaultSets': 3,
      'defaultReps': 10,
    },
    {
      'name': '哑铃飞鸟',
      'category': 'chest',
      'movementType': 'isolation',
      'primaryMuscles': '胸大肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 12,
    },
    {
      'name': '上斜哑铃飞鸟',
      'category': 'chest',
      'movementType': 'isolation',
      'primaryMuscles': '胸大肌上束',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 12,
    },
    {
      'name': '器械夹胸',
      'category': 'chest',
      'movementType': 'isolation',
      'primaryMuscles': '胸大肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 15,
    },
    {
      'name': '俯卧撑',
      'category': 'chest',
      'movementType': 'compound',
      'primaryMuscles': '胸大肌',
      'secondaryMuscles': '三角肌前束,肱三头肌',
      'defaultSets': 3,
      'defaultReps': 15,
    },
    {
      'name': '双杠臂屈伸',
      'category': 'chest',
      'movementType': 'compound',
      'primaryMuscles': '胸大肌下束',
      'secondaryMuscles': '肱三头肌',
      'defaultSets': 3,
      'defaultReps': 12,
    },
  ];

  /// 背部动作
  static const List<Map<String, dynamic>> backExercises = [
    {
      'name': '硬拉',
      'category': 'back',
      'movementType': 'compound',
      'primaryMuscles': '竖脊肌,背阔肌',
      'secondaryMuscles': '臀大肌,腘绳肌',
      'defaultSets': 3,
      'defaultReps': 5,
    },
    {
      'name': '引体向上',
      'category': 'back',
      'movementType': 'compound',
      'primaryMuscles': '背阔肌',
      'secondaryMuscles': '肱二头肌,三角肌后束',
      'defaultSets': 4,
      'defaultReps': 8,
    },
    {
      'name': '杠铃划船',
      'category': 'back',
      'movementType': 'compound',
      'primaryMuscles': '背阔肌',
      'secondaryMuscles': '肱二头肌,斜方肌',
      'defaultSets': 4,
      'defaultReps': 10,
    },
    {
      'name': '单臂哑铃划船',
      'category': 'back',
      'movementType': 'compound',
      'primaryMuscles': '背阔肌',
      'secondaryMuscles': '肱二头肌',
      'defaultSets': 3,
      'defaultReps': 12,
    },
    {
      'name': '高位下拉',
      'category': 'back',
      'movementType': 'compound',
      'primaryMuscles': '背阔肌',
      'secondaryMuscles': '肱二头肌',
      'defaultSets': 4,
      'defaultReps': 10,
    },
    {
      'name': '坐姿划船',
      'category': 'back',
      'movementType': 'compound',
      'primaryMuscles': '背阔肌,菱形肌',
      'secondaryMuscles': '肱二头肌',
      'defaultSets': 4,
      'defaultReps': 12,
    },
    {
      'name': '直臂下压',
      'category': 'back',
      'movementType': 'isolation',
      'primaryMuscles': '背阔肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 15,
    },
    {
      'name': '面拉',
      'category': 'back',
      'movementType': 'isolation',
      'primaryMuscles': '三角肌后束,菱形肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 15,
    },
    {
      'name': '耸肩',
      'category': 'back',
      'movementType': 'isolation',
      'primaryMuscles': '斜方肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 12,
    },
  ];

  /// 肩部动作
  static const List<Map<String, dynamic>> shoulderExercises = [
    {
      'name': '肩上推举',
      'category': 'shoulders',
      'movementType': 'compound',
      'primaryMuscles': '三角肌前束',
      'secondaryMuscles': '肱三头肌',
      'defaultSets': 4,
      'defaultReps': 8,
    },
    {
      'name': '哑铃侧平举',
      'category': 'shoulders',
      'movementType': 'isolation',
      'primaryMuscles': '三角肌中束',
      'secondaryMuscles': '',
      'defaultSets': 4,
      'defaultReps': 12,
    },
    {
      'name': '哑铃前平举',
      'category': 'shoulders',
      'movementType': 'isolation',
      'primaryMuscles': '三角肌前束',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 12,
    },
    {
      'name': '阿诺德推举',
      'category': 'shoulders',
      'movementType': 'compound',
      'primaryMuscles': '三角肌前束,三角肌中束',
      'secondaryMuscles': '肱三头肌',
      'defaultSets': 3,
      'defaultReps': 10,
    },
    {
      'name': '反向飞鸟',
      'category': 'shoulders',
      'movementType': 'isolation',
      'primaryMuscles': '三角肌后束',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 15,
    },
    {
      'name': '史密斯推举',
      'category': 'shoulders',
      'movementType': 'compound',
      'primaryMuscles': '三角肌前束',
      'secondaryMuscles': '肱三头肌',
      'defaultSets': 4,
      'defaultReps': 8,
    },
  ];

  /// 手臂动作
  static const List<Map<String, dynamic>> armExercises = [
    {
      'name': '杠铃弯举',
      'category': 'arms',
      'movementType': 'isolation',
      'primaryMuscles': '肱二头肌',
      'secondaryMuscles': '',
      'defaultSets': 4,
      'defaultReps': 10,
    },
    {
      'name': '哑铃弯举',
      'category': 'arms',
      'movementType': 'isolation',
      'primaryMuscles': '肱二头肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 12,
    },
    {
      'name': '锤式弯举',
      'category': 'arms',
      'movementType': 'isolation',
      'primaryMuscles': '肱二头肌,肱肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 12,
    },
    {
      'name': '窄距卧推',
      'category': 'arms',
      'movementType': 'compound',
      'primaryMuscles': '肱三头肌',
      'secondaryMuscles': '胸大肌',
      'defaultSets': 4,
      'defaultReps': 8,
    },
    {
      'name': '绳索下压',
      'category': 'arms',
      'movementType': 'isolation',
      'primaryMuscles': '肱三头肌',
      'secondaryMuscles': '',
      'defaultSets': 4,
      'defaultReps': 12,
    },
    {
      'name': '哑铃臂屈伸',
      'category': 'arms',
      'movementType': 'isolation',
      'primaryMuscles': '肱三头肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 12,
    },
    {
      'name': '绳索弯举',
      'category': 'arms',
      'movementType': 'isolation',
      'primaryMuscles': '肱二头肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 15,
    },
  ];

  /// 腿部动作
  static const List<Map<String, dynamic>> legExercises = [
    {
      'name': '深蹲',
      'category': 'legs',
      'movementType': 'compound',
      'primaryMuscles': '股四头肌,臀大肌',
      'secondaryMuscles': '腘绳肌',
      'defaultSets': 4,
      'defaultReps': 8,
    },
    {
      'name': '前蹲',
      'category': 'legs',
      'movementType': 'compound',
      'primaryMuscles': '股四头肌',
      'secondaryMuscles': '臀大肌',
      'defaultSets': 4,
      'defaultReps': 8,
    },
    {
      'name': '腿举',
      'category': 'legs',
      'movementType': 'compound',
      'primaryMuscles': '股四头肌',
      'secondaryMuscles': '臀大肌',
      'defaultSets': 4,
      'defaultReps': 12,
    },
    {
      'name': '罗马尼亚硬拉',
      'category': 'legs',
      'movementType': 'compound',
      'primaryMuscles': '腘绳肌,臀大肌',
      'secondaryMuscles': '竖脊肌',
      'defaultSets': 4,
      'defaultReps': 10,
    },
    {
      'name': '腿弯举',
      'category': 'legs',
      'movementType': 'isolation',
      'primaryMuscles': '腘绳肌',
      'secondaryMuscles': '',
      'defaultSets': 4,
      'defaultReps': 12,
    },
    {
      'name': '腿屈伸',
      'category': 'legs',
      'movementType': 'isolation',
      'primaryMuscles': '股四头肌',
      'secondaryMuscles': '',
      'defaultSets': 4,
      'defaultReps': 15,
    },
    {
      'name': '站姿提踵',
      'category': 'legs',
      'movementType': 'isolation',
      'primaryMuscles': '腓肠肌',
      'secondaryMuscles': '',
      'defaultSets': 4,
      'defaultReps': 15,
    },
    {
      'name': '坐姿提踵',
      'category': 'legs',
      'movementType': 'isolation',
      'primaryMuscles': '比目鱼肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 15,
    },
    {
      'name': '保加利亚分腿蹲',
      'category': 'legs',
      'movementType': 'compound',
      'primaryMuscles': '股四头肌,臀大肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 10,
    },
    {
      'name': '弓步蹲',
      'category': 'legs',
      'movementType': 'compound',
      'primaryMuscles': '股四头肌,臀大肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 12,
    },
  ];

  /// 核心动作
  static const List<Map<String, dynamic>> coreExercises = [
    {
      'name': '卷腹',
      'category': 'core',
      'movementType': 'isolation',
      'primaryMuscles': '腹直肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 20,
    },
    {
      'name': '仰卧抬腿',
      'category': 'core',
      'movementType': 'isolation',
      'primaryMuscles': '腹直肌下部',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 15,
    },
    {
      'name': '平板支撑',
      'category': 'core',
      'movementType': 'isolation',
      'primaryMuscles': '腹横肌,腹直肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 60,
      'description': '持续时间（秒）',
    },
    {
      'name': '俄罗斯转体',
      'category': 'core',
      'movementType': 'isolation',
      'primaryMuscles': '腹斜肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 20,
    },
    {
      'name': '悬垂举腿',
      'category': 'core',
      'movementType': 'isolation',
      'primaryMuscles': '腹直肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 12,
    },
    {
      'name': '侧平板支撑',
      'category': 'core',
      'movementType': 'isolation',
      'primaryMuscles': '腹斜肌',
      'secondaryMuscles': '',
      'defaultSets': 3,
      'defaultReps': 30,
      'description': '持续时间（秒）',
    },
  ];

  /// 获取所有动作
  static List<Map<String, dynamic>> getAllExercises() {
    return [
      ...chestExercises,
      ...backExercises,
      ...shoulderExercises,
      ...armExercises,
      ...legExercises,
      ...coreExercises,
    ];
  }

  /// 种子数据总数
  static int get totalExercises => getAllExercises().length;
}

/// 种子数据导入工具
class ExerciseSeeder {
  final AppDatabase _db;

  ExerciseSeeder(this._db);

  /// 导入所有种子数据
  /// 使用 batch 批量插入，提高效率
  Future<void> seedAll() async {
    final exercises = ExerciseSeedData.getAllExercises();

    await _db.batch((batch) {
      batch.insertAll(
        _db.exercises,
        exercises.map((exerciseData) => ExercisesCompanion(
          name: Value(exerciseData['name'] as String),
          category: Value(exerciseData['category'] as String),
          movementType: Value(exerciseData['movementType'] as String),
          primaryMuscles: Value(exerciseData['primaryMuscles'] as String?),
          secondaryMuscles: Value(
            exerciseData['secondaryMuscles'] as String?,
          ),
          defaultSets: Value(exerciseData['defaultSets'] as int),
          defaultReps: Value(exerciseData['defaultReps'] as int),
          description: Value(exerciseData['description'] as String?),
          isCustom: const Value(false),
          isEnabled: const Value(true),
        )).toList(),
      );
    });
  }

  /// 检查是否已导入
  Future<bool> isSeeded() async {
    final count = await _db.select(_db.exercises).get();
    return count.isNotEmpty;
  }
}
