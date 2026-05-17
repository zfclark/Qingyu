import 'package:flutter_test/flutter_test.dart';
import 'package:qingyu/core/utils/decibel_util.dart';

void main() {
  group('DecibelUtil.amplitudeToDB', () {
    test('零振幅返回0', () {
      expect(DecibelUtil.amplitudeToDB(0), equals(0));
    });

    test('负振幅返回0', () {
      expect(DecibelUtil.amplitudeToDB(-0.5), equals(0));
    });

    test('极小幅振幅产生低分贝', () {
      // clamp最低值0.0001对应40dB，0振幅对应0dB
      expect(DecibelUtil.amplitudeToDB(0), equals(0));
      expect(DecibelUtil.amplitudeToDB(0.0001), closeTo(40.0, 0.1));
    });

    test('小幅振幅产生中等分贝', () {
      final db = DecibelUtil.amplitudeToDB(0.001);
      // 120 + 20*log10(0.001) = 60dB
      expect(db, greaterThan(50));
      expect(db, lessThan(70));
    });

    test('大幅振幅产生高分贝', () {
      final db = DecibelUtil.amplitudeToDB(1.0);
      expect(db, greaterThan(80));
      expect(db, lessThanOrEqualTo(120));
    });

    test('振幅 1.0 约等于 120dB', () {
      // 120 + 20*log10(1.0) = 120
      expect(DecibelUtil.amplitudeToDB(1.0), closeTo(120.0, 0.1));
    });
  });

  group('DecibelUtil.getDBLevel', () {
    test('0-30 -> 安静', () {
      expect(DecibelUtil.getDBLevel(0), equals('安静'));
      expect(DecibelUtil.getDBLevel(15), equals('安静'));
      expect(DecibelUtil.getDBLevel(29.9), equals('安静'));
    });

    test('30-50 -> 正常', () {
      expect(DecibelUtil.getDBLevel(30), equals('正常'));
      expect(DecibelUtil.getDBLevel(40), equals('正常'));
    });

    test('50-70 -> 较吵', () {
      expect(DecibelUtil.getDBLevel(50), equals('较吵'));
      expect(DecibelUtil.getDBLevel(60), equals('较吵'));
    });

    test('70-90 -> 吵闹', () {
      expect(DecibelUtil.getDBLevel(70), equals('吵闹'));
      expect(DecibelUtil.getDBLevel(80), equals('吵闹'));
    });

    test('90+ -> 刺耳', () {
      expect(DecibelUtil.getDBLevel(90), equals('刺耳'));
      expect(DecibelUtil.getDBLevel(120), equals('刺耳'));
    });

    test('负数 -> 未知', () {
      expect(DecibelUtil.getDBLevel(-1), equals('未知'));
    });
  });

  group('DecibelUtil.getDBColorInt', () {
    test('安静为绿色', () {
      expect(DecibelUtil.getDBColorInt(15), equals(0xFF4CAF50));
    });

    test('刺耳为红色', () {
      expect(DecibelUtil.getDBColorInt(100), equals(0xFFF44336));
    });
  });

  group('DecibelUtil.needsHearingProtection', () {
    test('85+ 需要保护', () {
      expect(DecibelUtil.needsHearingProtection(85), isTrue);
      expect(DecibelUtil.needsHearingProtection(90), isTrue);
    });

    test('< 85 不需要', () {
      expect(DecibelUtil.needsHearingProtection(50), isFalse);
      expect(DecibelUtil.needsHearingProtection(84.9), isFalse);
    });
  });

  group('DecibelUtil.getSafeExposureMinutes', () {
    test('80以下安全', () {
      expect(DecibelUtil.getSafeExposureMinutes(70), equals(-1));
    });

    test('85分贝 120分钟', () {
      expect(DecibelUtil.getSafeExposureMinutes(85), equals(120));
    });

    test('100分贝 5分钟', () {
      expect(DecibelUtil.getSafeExposureMinutes(100), equals(5));
    });
  });

  group('DecibelUtil.averageDB', () {
    test('空列表', () {
      expect(DecibelUtil.averageDB([]), equals(0));
    });

    test('单值', () {
      expect(DecibelUtil.averageDB([0.1]), greaterThan(0));
    });

    test('多值平均', () {
      // 提供相同振幅，平均值应等于每个单独值
      final single = DecibelUtil.amplitudeToDB(0.01);
      final avg = DecibelUtil.averageDB([0.01, 0.01, 0.01]);
      expect(avg, closeTo(single, 0.1));
    });
  });
}
