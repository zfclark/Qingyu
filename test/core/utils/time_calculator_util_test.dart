import 'package:flutter_test/flutter_test.dart';
import 'package:qingyu/core/utils/time_calculator_util.dart';

void main() {
  group('TimeCalculatorUtil.addDays', () {
    test('正天数', () {
      final date = DateTime(2024, 1, 1);
      final result = TimeCalculatorUtil.addDays(date, 10);
      expect(result, equals(DateTime(2024, 1, 11)));
    });

    test('负天数', () {
      final date = DateTime(2024, 1, 11);
      final result = TimeCalculatorUtil.addDays(date, -10);
      expect(result, equals(DateTime(2024, 1, 1)));
    });

    test('零天数', () {
      final date = DateTime(2024, 1, 1);
      final result = TimeCalculatorUtil.addDays(date, 0);
      expect(result, equals(date));
    });
  });

  group('TimeCalculatorUtil.addMonths', () {
    test('正月', () {
      final date = DateTime(2024, 1, 1);
      final result = TimeCalculatorUtil.addMonths(date, 3);
      expect(result, equals(DateTime(2024, 4, 1)));
    });

    test('跨年', () {
      final date = DateTime(2024, 10, 1);
      final result = TimeCalculatorUtil.addMonths(date, 6);
      expect(result, equals(DateTime(2025, 4, 1)));
    });

    test('负月', () {
      final date = DateTime(2024, 6, 1);
      final result = TimeCalculatorUtil.addMonths(date, -3);
      expect(result, equals(DateTime(2024, 3, 1)));
    });

    test('月底溢出处理 (1月31日+1月)', () {
      final date = DateTime(2024, 1, 31);
      final result = TimeCalculatorUtil.addMonths(date, 1);
      // 2月没有31日，应处理为2月29日（闰年）
      expect(result, equals(DateTime(2024, 2, 29)));
    });
  });

  group('TimeCalculatorUtil.addYears', () {
    test('正年', () {
      final date = DateTime(2024, 6, 15);
      final result = TimeCalculatorUtil.addYears(date, 5);
      expect(result, equals(DateTime(2029, 6, 15)));
    });

    test('负年', () {
      final date = DateTime(2024, 6, 15);
      final result = TimeCalculatorUtil.addYears(date, -5);
      expect(result, equals(DateTime(2019, 6, 15)));
    });

    test('闰年2月29日+1年', () {
      final date = DateTime(2024, 2, 29);
      final result = TimeCalculatorUtil.addYears(date, 1);
      // Dart DateTime 自动处理，2025年没有2月29日，自动进到3月1日
      expect(result, equals(DateTime(2025, 3, 1)));
    });
  });

  group('TimeCalculatorUtil.workDaysBetween', () {
    test('同一天工作日', () {
      // 2024-01-01 是周一
      final mon = DateTime(2024, 1, 1);
      expect(TimeCalculatorUtil.workDaysBetween(mon, mon), equals(1));
    });

    test('周一到周五 (5个工作日)', () {
      final mon = DateTime(2024, 1, 1);
      final fri = DateTime(2024, 1, 5);
      expect(TimeCalculatorUtil.workDaysBetween(mon, fri), equals(5));
    });

    test('跨周末 (周一到下周一)', () {
      final mon = DateTime(2024, 1, 1);
      final nextMon = DateTime(2024, 1, 8);
      // 6个工作日（去掉周六日）
      expect(TimeCalculatorUtil.workDaysBetween(mon, nextMon), equals(6));
    });

    test('周末之间无工作日', () {
      // 2024-01-06 周六, 2024-01-07 周日
      final sat = DateTime(2024, 1, 6);
      final sun = DateTime(2024, 1, 7);
      expect(TimeCalculatorUtil.workDaysBetween(sat, sun), equals(0));
    });

    test('开始日期晚于结束日期', () {
      final mon = DateTime(2024, 1, 8);
      final fri = DateTime(2024, 1, 1);
      // 应该返回正值
      expect(TimeCalculatorUtil.workDaysBetween(mon, fri), greaterThan(0));
    });
  });

  group('TimeCalculatorUtil.daysBetween', () {
    test('同一天', () {
      final d = DateTime(2024, 6, 1);
      expect(TimeCalculatorUtil.daysBetween(d, d), equals(0));
    });

    test('间隔10天', () {
      final d1 = DateTime(2024, 6, 1);
      final d2 = DateTime(2024, 6, 11);
      expect(TimeCalculatorUtil.daysBetween(d1, d2), equals(10));
    });

    test('跨年', () {
      final d1 = DateTime(2024, 12, 31);
      final d2 = DateTime(2025, 1, 1);
      expect(TimeCalculatorUtil.daysBetween(d1, d2), equals(1));
    });
  });

  group('TimeCalculatorUtil.diffBetween', () {
    test('详细时间差', () {
      final d1 = DateTime(2024, 1, 1);
      final d2 = DateTime(2024, 6, 15);
      final result = TimeCalculatorUtil.diffBetween(d1, d2);
      expect(result['days'], isA<int>());
      expect(result['totalDays'], isA<int>());
      expect(result['isFuture'], isA<bool>());
    });
  });

  group('TimeCalculatorUtil.calculateExactAge', () {
    test('精确年龄', () {
      final birth = DateTime(2000, 1, 1);
      final now = DateTime(2024, 6, 15);
      final age = TimeCalculatorUtil.calculateExactAge(birth, atDate: now);
      expect(age['years'], equals(24));
      expect(age['months'], isA<int>());
      expect(age['days'], isA<int>());
    });
  });

  group('TimeCalculatorUtil.isWeekend', () {
    test('周六是周末', () {
      expect(TimeCalculatorUtil.isWeekend(DateTime(2024, 1, 6)), isTrue);
    });

    test('周一是工作日', () {
      expect(TimeCalculatorUtil.isWeekend(DateTime(2024, 1, 1)), isFalse);
    });
  });
}
