/// 1RM 计算器
/// 使用多种公式计算理论最大重量
class OneRmCalculator {
  /// Epley 公式
  /// 1RM = weight × (1 + reps / 30)
  static double epley(double weight, int reps) {
    if (reps <= 0 || weight <= 0) return 0;
    if (reps == 1) return weight;
    return weight * (1 + reps / 30);
  }

  /// Brzycki 公式
  /// 1RM = weight × 36 / (37 - reps)
  static double brzycki(double weight, int reps) {
    if (reps <= 0 || weight <= 0) return 0;
    if (reps == 1) return weight;
    if (reps >= 37) return double.infinity; // 避免除零
    return weight * 36 / (37 - reps);
  }

  /// Lander 公式
  /// 1RM = (100 × weight) / (101.3 - 2.67 × reps)
  static double lander(double weight, int reps) {
    if (reps <= 0 || weight <= 0) return 0;
    if (reps == 1) return weight;
    final denominator = 101.3 - 2.67 * reps;
    if (denominator <= 0) return double.infinity;
    return (100 * weight) / denominator;
  }

  /// 计算三种公式的平均值
  static double calculateAverage(double weight, int reps) {
    if (reps <= 0 || weight <= 0) return 0;
    if (reps == 1) return weight;

    final epley1RM = epley(weight, reps);
    final brzycki1RM = brzycki(weight, reps);
    final lander1RM = lander(weight, reps);

    // 过滤掉无效值
    final validValues = [
      epley1RM,
      brzycki1RM,
      lander1RM,
    ].where((v) => v.isFinite && v > 0).toList();

    if (validValues.isEmpty) return 0;
    return validValues.reduce((a, b) => a + b) / validValues.length;
  }

  /// 根据目标次数计算建议重量
  /// 使用 Epley 公式的逆运算
  static double calculateWeightForReps(double oneRM, int targetReps) {
    if (targetReps <= 0 || oneRM <= 0) return 0;
    if (targetReps == 1) return oneRM;
    return oneRM / (1 + targetReps / 30);
  }

  /// 计算给定重量对应的预估次数
  static int estimateReps(double oneRM, double weight) {
    if (weight <= 0 || oneRM <= 0) return 0;
    if (weight >= oneRM) return 1;

    // 使用 Epley 公式逆推
    final reps = (oneRM / weight - 1) * 30;
    return reps.round().clamp(1, 30);
  }

  /// 格式化重量显示
  static String formatWeight(double weight) {
    if (weight <= 0) return '-';
    return '${weight.toStringAsFixed(1)} kg';
  }

  /// 获取各公式计算结果的详细信息
  static Map<String, double> getAllFormulas(double weight, int reps) {
    if (reps <= 0 || weight <= 0) {
      return {'epley': 0, 'brzycki': 0, 'lander': 0, 'average': 0};
    }

    return {
      'epley': epley(weight, reps),
      'brzycki': brzycki(weight, reps),
      'lander': lander(weight, reps),
      'average': calculateAverage(weight, reps),
    };
  }
}
