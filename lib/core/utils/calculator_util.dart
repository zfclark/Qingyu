
/// Calculator Utility
/// Author: ZF_Clark
/// Description: Provides basic arithmetic calculation functionality including addition, subtraction, multiplication, and division. Pure utility class without UI dependencies.
/// Last Modified: 2026/02/08
library;

/// 计算器工具类
/// 提供纯计算功能，不涉及任何UI操作
class CalculatorUtil {
  /// 执行计算
  /// 
  /// [firstOperand] 第一个操作数
  /// [secondOperand] 第二个操作数
  /// [operator] 运算符（+、-、×、÷）
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
      default:
        return null;
    }
  }

  /// 格式化计算结果
  /// 
  /// [result] 计算结果
  /// 返回格式化后的字符串（整数不显示小数点）
  static String formatResult(double result) {
    if (result == result.toInt()) {
      return result.toInt().toString();
    } else {
      return result.toString();
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
    return current + '.';
  }
}
