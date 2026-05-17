import 'package:flutter_test/flutter_test.dart';
import 'package:qingyu/core/utils/bmi_util.dart';

void main() {
  group('BmiUtil.calculate', () {
    test('正常身高体重', () {
      // 身高170cm, 体重65kg -> BMI = 65 / (1.7*1.7) ≈ 22.5
      final result = BmiUtil.calculate(65, 170);
      expect(result, closeTo(22.5, 0.1));
    });

    test('偏瘦', () {
      // 身高170cm, 体重50kg -> BMI ≈ 17.3
      final result = BmiUtil.calculate(50, 170);
      expect(result, closeTo(17.3, 0.1));
    });

    test('超重', () {
      // 身高170cm, 体重80kg -> BMI ≈ 27.7
      final result = BmiUtil.calculate(80, 170);
      expect(result, closeTo(27.7, 0.1));
    });

    test('肥胖', () {
      // 身高160cm, 体重80kg -> BMI = 80 / (1.6*1.6) ≈ 31.3
      final result = BmiUtil.calculate(80, 160);
      expect(result, closeTo(31.2, 0.2));
    });

    test('零身高返回0', () {
      expect(BmiUtil.calculate(65, 0), equals(0));
    });

    test('零体重返回0', () {
      expect(BmiUtil.calculate(0, 170), equals(0));
    });

    test('负数返回0', () {
      expect(BmiUtil.calculate(-50, 170), equals(0));
    });
  });

  group('BmiUtil.getCategory', () {
    test('偏瘦', () {
      expect(BmiUtil.getCategory(17.0), equals('偏瘦'));
    });

    test('正常', () {
      expect(BmiUtil.getCategory(21.0), equals('正常'));
    });

    test('超重', () {
      expect(BmiUtil.getCategory(26.0), equals('超重'));
    });

    test('肥胖', () {
      expect(BmiUtil.getCategory(30.0), equals('肥胖'));
    });

    test('边界值 18.4 -> 偏瘦', () {
      expect(BmiUtil.getCategory(18.4), equals('偏瘦'));
    });

    test('边界值 18.5 -> 正常', () {
      expect(BmiUtil.getCategory(18.5), equals('正常'));
    });

    test('无效值', () {
      expect(BmiUtil.getCategory(0), equals('无效'));
    });
  });

  group('BmiUtil.getRiskLevel', () {
    test('正常 -> 0', () {
      expect(BmiUtil.getRiskLevel(21.0), equals(0));
    });

    test('偏瘦 -> 1', () {
      expect(BmiUtil.getRiskLevel(17.0), equals(1));
    });

    test('超重 -> 2', () {
      expect(BmiUtil.getRiskLevel(26.0), equals(2));
    });

    test('肥胖 -> 3', () {
      expect(BmiUtil.getRiskLevel(30.0), equals(3));
    });
  });

  group('BmiUtil.getHealthyWeightRange', () {
    test('身高170cm', () {
      final range = BmiUtil.getHealthyWeightRange(170);
      expect(range['min']!, closeTo(53.5, 0.1));
      expect(range['max']!, closeTo(69.4, 0.1));
    });

    test('零身高返回空', () {
      final range = BmiUtil.getHealthyWeightRange(0);
      expect(range['min'], equals(0));
      expect(range['max'], equals(0));
    });
  });

  group('BmiUtil.getFullAssessment', () {
    test('返回完整评估', () {
      final result = BmiUtil.getFullAssessment(65, 170);
      expect(result['bmi'], closeTo(22.5, 0.1));
      expect(result['category'], equals('正常'));
      expect(result['advice'], isNotEmpty);
      expect(result['riskLevel'], equals(0));
      expect(result['healthyWeightMin'], isA<double>());
      expect(result['healthyWeightMax'], isA<double>());
    });
  });

  group('BmiUtil.getHealthAdvice', () {
    test('偏瘦建议', () {
      final advice = BmiUtil.getHealthAdvice(17.0);
      expect(advice, contains('增加营养'));
    });

    test('正常建议', () {
      final advice = BmiUtil.getHealthAdvice(21.0);
      expect(advice, contains('保持'));
    });

    test('无效值', () {
      expect(BmiUtil.getHealthAdvice(0), contains('有效'));
    });
  });
}
