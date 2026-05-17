/// BMI Utility
/// Author: ZF_Clark
/// Description: Provides BMI calculation and health assessment utilities. Pure utility class without UI dependencies.
library;

/// BMI 计算工具类
/// 提供身体质量指数计算与健康评估功能
class BmiUtil {
  /// 计算 BMI 值
  ///
  /// [weightKg] 体重（公斤）
  /// [heightCm] 身高（厘米）
  /// 返回 BMI 值，保留一位小数
  static double calculate(double weightKg, double heightCm) {
    if (heightCm <= 0 || weightKg <= 0) return 0;
    final heightM = heightCm / 100;
    final bmi = weightKg / (heightM * heightM);
    return double.parse(bmi.toStringAsFixed(1));
  }

  /// 获取 BMI 健康分类
  ///
  /// [bmi] BMI 值
  /// 返回中文分类描述
  static String getCategory(double bmi) {
    if (bmi <= 0) return '无效';
    if (bmi < 18.5) return '偏瘦';
    if (bmi < 24.0) return '正常';
    if (bmi < 28.0) return '超重';
    return '肥胖';
  }

  /// 获取健康建议
  ///
  /// [bmi] BMI 值
  /// 返回健康建议文本
  static String getHealthAdvice(double bmi) {
    if (bmi <= 0) return '请输入有效的身高体重值';
    if (bmi < 18.5) {
      return '体重偏轻，建议适当增加营养摄入，保持均衡饮食。';
    }
    if (bmi < 24.0) {
      return '体重正常，请继续保持健康的生活方式。';
    }
    if (bmi < 28.0) {
      return '体重超重，建议增加运动量，控制饮食热量摄入。';
    }
    return '体重肥胖，建议咨询专业医生或营养师，制定科学的减重计划。';
  }

  /// 获取健康风险等级
  ///
  /// [bmi] BMI 值
  /// 返回风险等级（0-3）
  static int getRiskLevel(double bmi) {
    if (bmi <= 0) return -1;
    if (bmi < 18.5) return 1;
    if (bmi < 24.0) return 0;
    if (bmi < 28.0) return 2;
    return 3;
  }

  /// 获取标准体重范围
  ///
  /// [heightCm] 身高（厘米）
  /// 返回标准体重范围的Map
  static Map<String, double> getHealthyWeightRange(double heightCm) {
    if (heightCm <= 0) return {'min': 0, 'max': 0};
    final heightM = heightCm / 100;
    final minWeight = double.parse((18.5 * heightM * heightM).toStringAsFixed(1));
    final maxWeight = double.parse((24.0 * heightM * heightM).toStringAsFixed(1));
    return {'min': minWeight, 'max': maxWeight};
  }

  /// 获取完整评估结果
  ///
  /// [weightKg] 体重（公斤）
  /// [heightCm] 身高（厘米）
  /// 返回包含所有评估信息的 Map
  static Map<String, dynamic> getFullAssessment(double weightKg, double heightCm) {
    final bmi = calculate(weightKg, heightCm);
    final category = getCategory(bmi);
    final advice = getHealthAdvice(bmi);
    final riskLevel = getRiskLevel(bmi);
    final weightRange = getHealthyWeightRange(heightCm);

    return {
      'bmi': bmi,
      'category': category,
      'advice': advice,
      'riskLevel': riskLevel,
      'healthyWeightMin': weightRange['min'],
      'healthyWeightMax': weightRange['max'],
    };
  }

  /// 颜色指示（供UI层使用）
  ///
  /// [bmi] BMI 值
  /// 返回 0x 格式的颜色整数值
  static int getCategoryColorInt(double bmi) {
    if (bmi <= 0) return 0xFF9E9E9E;
    if (bmi < 18.5) return 0xFF2196F3;
    if (bmi < 24.0) return 0xFF4CAF50;
    if (bmi < 28.0) return 0xFFFF9800;
    return 0xFFF44336;
  }
}
