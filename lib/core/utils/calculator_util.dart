/// Calculator Utility
/// Author: ZF_Clark
/// Description: Provides basic and scientific arithmetic calculation functionality. Supports addition, subtraction, multiplication, division, and trigonometric/logarithmic functions. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

import 'dart:math' as math;

/// 计算器工具类
/// 提供纯计算功能，不涉及任何UI操作
class CalculatorUtil {
  // ==================== 基础运算 ====================

  /// 执行计算
  ///
  /// [firstOperand] 第一个操作数
  /// [secondOperand] 第二个操作数
  /// [operator] 运算符（+、-、×、÷、^）
  /// 返回计算结果，除零错误返回null
  static double? calculate(double firstOperand, double secondOperand, String operator) {
    switch (operator) {
      case '+':
        return firstOperand + secondOperand;
      case '-':
        return firstOperand - secondOperand;
      case '×':
      case '*':
        return firstOperand * secondOperand;
      case '÷':
      case '/':
        if (secondOperand == 0) return null;
        return firstOperand / secondOperand;
      case '^':
      case 'pow':
        return math.pow(firstOperand, secondOperand).toDouble();
      default:
        return null;
    }
  }

  /// 格式化计算结果
  ///
  /// [result] 计算结果
  /// [precision] 精度（小数位数）
  /// 返回格式化后的字符串（整数不显示小数点）
  static String formatResult(double result, {int precision = 10}) {
    if (result.isNaN) return 'NaN';
    if (result.isInfinite) return result.isNegative ? '-∞' : '∞';

    // 处理极大或极小的数字使用科学计数法
    if (result.abs() >= 1e10 || (result != 0 && result.abs() < 1e-6)) {
      return result.toStringAsExponential(precision);
    }

    if (result == result.toInt()) {
      return result.toInt().toString();
    } else {
      // 移除尾随零
      String formatted = result.toStringAsFixed(precision);
      if (formatted.contains('.')) {
        formatted = formatted.replaceAll(RegExp(r'0+$'), '');
        formatted = formatted.replaceAll(RegExp(r'\.$'), '');
      }
      return formatted;
    }
  }

  /// 计算百分比
  ///
  /// [value] 输入值
  /// 返回百分比值（除以100）
  static double calculatePercentage(double value) {
    return value / 100;
  }

  /// 切换符号
  ///
  /// [value] 输入值
  /// 返回符号切换后的值
  static double toggleSign(double value) {
    return -value;
  }

  /// 解析数字字符串
  ///
  /// [value] 数字字符串
  /// 返回解析后的double值，失败返回0
  static double parseNumber(String value) {
    try {
      return double.parse(value);
    } catch (e) {
      return 0;
    }
  }

  /// 追加数字
  ///
  /// [current] 当前显示值
  /// [digit] 要追加的数字
  /// [isNewOperation] 是否为新操作
  /// 返回追加后的字符串
  static String appendDigit(String current, String digit, bool isNewOperation) {
    if (isNewOperation) {
      return digit;
    } else {
      if (current == '0') {
        return digit;
      } else {
        return current + digit;
      }
    }
  }

  /// 添加小数点
  ///
  /// [current] 当前显示值
  /// 返回添加小数点后的字符串
  static String addDecimal(String current) {
    if (current.contains('.')) return current;
    return '$current.';
  }

  // ==================== 科学计算函数 ====================

  /// 平方根
  ///
  /// [value] 输入值
  /// 返回平方根结果
  static double sqrt(double value) {
    if (value < 0) return double.nan;
    return math.sqrt(value);
  }

  /// 平方
  ///
  /// [value] 输入值
  /// 返回平方结果
  static double square(double value) {
    return value * value;
  }

  /// 立方
  ///
  /// [value] 输入值
  /// 返回立方结果
  static double cube(double value) {
    return value * value * value;
  }

  /// 正弦（弧度）
  ///
  /// [value] 输入值（弧度）
  /// 返回正弦结果
  static double sin(double value) {
    return math.sin(value);
  }

  /// 余弦（弧度）
  ///
  /// [value] 输入值（弧度）
  /// 返回余弦结果
  static double cos(double value) {
    return math.cos(value);
  }

  /// 正切（弧度）
  ///
  /// [value] 输入值（弧度）
  /// 返回正切结果
  static double tan(double value) {
    return math.tan(value);
  }

  /// 反正弦（返回弧度）
  ///
  /// [value] 输入值
  /// 返回反正弦结果
  static double asin(double value) {
    if (value < -1 || value > 1) return double.nan;
    return math.asin(value);
  }

  /// 反余弦（返回弧度）
  ///
  /// [value] 输入值
  /// 返回反余弦结果
  static double acos(double value) {
    if (value < -1 || value > 1) return double.nan;
    return math.acos(value);
  }

  /// 反正切（返回弧度）
  ///
  /// [value] 输入值
  /// 返回反正切结果
  static double atan(double value) {
    return math.atan(value);
  }

  /// 弧度转角度
  ///
  /// [radians] 弧度值
  /// 返回角度值
  static double radiansToDegrees(double radians) {
    return radians * 180 / math.pi;
  }

  /// 角度转弧度
  ///
  /// [degrees] 角度值
  /// 返回弧度值
  static double degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// 自然对数
  ///
  /// [value] 输入值
  /// 返回自然对数结果
  static double ln(double value) {
    if (value <= 0) return double.nan;
    return math.log(value);
  }

  /// 常用对数（底数10）
  ///
  /// [value] 输入值
  /// 返回常用对数结果
  static double log(double value) {
    if (value <= 0) return double.nan;
    return math.log(value) / math.ln10;
  }

  /// 任意底数的对数
  ///
  /// [value] 输入值
  /// [base] 底数
  /// 返回对数结果
  static double logBase(double value, double base) {
    if (value <= 0 || base <= 0 || base == 1) return double.nan;
    return math.log(value) / math.log(base);
  }

  /// e的幂
  ///
  /// [value] 指数
  /// 返回e^value
  static double exp(double value) {
    return math.exp(value);
  }

  /// 倒数
  ///
  /// [value] 输入值
  /// 返回1/value
  static double reciprocal(double value) {
    if (value == 0) return double.nan;
    return 1 / value;
  }

  /// 阶乘
  ///
  /// [n] 非负整数
  /// 返回n!
  static double factorial(int n) {
    if (n < 0) return double.nan;
    if (n > 170) return double.infinity;
    if (n == 0 || n == 1) return 1;

    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  /// 绝对值
  ///
  /// [value] 输入值
  /// 返回绝对值
  static double abs(double value) {
    return value.abs();
  }

  /// 向下取整
  ///
  /// [value] 输入值
  /// 返回最大的小于等于value的整数
  static double floor(double value) {
    return value.floorToDouble();
  }

  /// 向上取整
  ///
  /// [value] 输入值
  /// 返回最小的大于等于value的整数
  static double ceil(double value) {
    return value.ceilToDouble();
  }

  /// 四舍五入
  ///
  /// [value] 输入值
  /// 返回四舍五入后的整数
  static double round(double value) {
    return value.roundToDouble();
  }

  /// 幂运算
  ///
  /// [base] 底数
  /// [exponent] 指数
  /// 返回base^exponent
  static double power(double base, double exponent) {
    return math.pow(base, exponent).toDouble();
  }

  /// 10的幂
  ///
  /// [exponent] 指数
  /// 返回10^exponent
  static double powerOf10(double exponent) {
    return math.pow(10, exponent).toDouble();
  }

  /// 2的幂
  ///
  /// [exponent] 指数
  /// 返回2^exponent
  static double powerOf2(double exponent) {
    return math.pow(2, exponent).toDouble();
  }

  /// 立方根
  ///
  /// [value] 输入值
  /// 返回立方根
  static double cbrt(double value) {
    return math.pow(value, 1/3).toDouble();
  }

  /// 双曲正弦
  ///
  /// [value] 输入值
  /// 返回sinh(value)
  static double sinh(double value) {
    return (math.exp(value) - math.exp(-value)) / 2;
  }

  /// 双曲余弦
  ///
  /// [value] 输入值
  /// 返回cosh(value)
  static double cosh(double value) {
    return (math.exp(value) + math.exp(-value)) / 2;
  }

  /// 双曲正切
  ///
  /// [value] 输入值
  /// 返回tanh(value)
  static double tanh(double value) {
    final pos = math.exp(value);
    final neg = math.exp(-value);
    return (pos - neg) / (pos + neg);
  }

  /// 反双曲正弦
  ///
  /// [value] 输入值
  /// 返回asinh(value)
  static double asinh(double value) {
    return math.log(value + math.sqrt(value * value + 1));
  }

  /// 反双曲余弦
  ///
  /// [value] 输入值
  /// 返回acosh(value)
  static double acosh(double value) {
    return math.log(value + math.sqrt(value * value - 1));
  }

  /// 反双曲正切
  ///
  /// [value] 输入值
  /// 返回atanh(value)
  static double atanh(double value) {
    return (math.log(1 + value) - math.log(1 - value)) / 2;
  }

  /// 获取π的值
  static double get pi => math.pi;

  /// 获取e的值
  static double get e => math.e;

  /// 获取黄金比例
  static double get goldenRatio => (1 + math.sqrt(5)) / 2;

  // ==================== 表达式解析（扩展） ====================

  /// 简单表达式求值（仅支持加减乘除）
  ///
  /// [expression] 表达式字符串，如 "2+3*4"
  /// 返回计算结果，计算失败返回null
  static double? evaluateExpression(String expression) {
    try {
      // 移除空格
      expression = expression.replaceAll(' ', '');

      // 简单实现：先处理乘除
      while (expression.contains('×') || expression.contains('÷')) {
        final multMatch = RegExp(r'(-?[\d.]+)\×(-?[\d.]+)').firstMatch(expression);
        if (multMatch != null) {
          final a = double.parse(multMatch.group(1)!);
          final b = double.parse(multMatch.group(2)!);
          final result = a * b;
          expression = expression.replaceFirst(multMatch.group(0)!, result.toString());
          continue;
        }

        final divMatch = RegExp(r'(-?[\d.]+)\÷(-?[\d.]+)').firstMatch(expression);
        if (divMatch != null) {
          final a = double.parse(divMatch.group(1)!);
          final b = double.parse(divMatch.group(2)!);
          if (b == 0) return null;
          final result = a / b;
          expression = expression.replaceFirst(divMatch.group(0)!, result.toString());
        }
      }

      // 再处理加减
      final parts = expression.split(RegExp(r'(?<=[+-])'));
      double result = 0;
      String currentOp = '+';

      for (final part in parts) {
        if (part.isEmpty) continue;
        final match = RegExp(r'^([+-]?)([\d.]+)$').firstMatch(part);
        if (match != null) {
          final sign = match.group(1) == '-' ? -1.0 : 1.0;
          final value = double.parse(match.group(2)!);
          if (currentOp == '+') {
            result += sign * value;
          } else {
            result -= sign * value;
          }
        } else if (part.startsWith('+')) {
          currentOp = '+';
        } else if (part.startsWith('-')) {
          currentOp = '-';
        }
      }

      return result;
    } catch (e) {
      return null;
    }
  }
}
