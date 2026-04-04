/// Number Base Utility
/// Author: ZF_Clark
/// Description: Provides number base conversion utilities for binary, octal, decimal, and hexadecimal. Supports integer and floating point numbers. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

import 'dart:math' as math;

/// 进制转换工具类
/// 提供二进制、八进制、十进制、十六进制之间的转换功能
class NumberBaseUtil {
  // ==================== 常量 ====================

  /// 支持的进制列表
  static const List<int> supportedBases = [2, 8, 10, 16];

  /// 进制名称映射
  static const Map<int, String> baseNames = {
    2: '二进制',
    8: '八进制',
    10: '十进制',
    16: '十六进制',
  };

  /// 进制符号
  static const Map<int, String> baseSymbols = {
    2: '0b',
    8: '0o',
    10: '',
    16: '0x',
  };

  // ==================== 基础转换 ====================

  /// 任意进制转换为十进制
  ///
  /// [input] 输入字符串
  /// [fromBase] 源进制 (2, 8, 10, 16)
  /// 返回十进制整数，失败返回null
  static int? toDecimal(String input, int fromBase) {
    if (input.isEmpty) return null;
    
    // 移除前缀
    final cleanInput = _removePrefix(input).toUpperCase();

    try {
      return int.parse(cleanInput, radix: fromBase);
    } catch (e) {
      return null;
    }
  }

  /// 十进制转换为任意进制
  ///
  /// [value] 十进制整数
  /// [toBase] 目标进制 (2, 8, 10, 16)
  /// [uppercase] 是否使用大写字母（十六进制）
  /// 返回转换后的字符串，失败返回null
  static String? fromDecimal(int value, int toBase, {bool uppercase = true}) {
    if (value < 0) {
      final negResult = fromDecimal(-value, toBase, uppercase: uppercase);
      if (negResult == null) return null;
      return '-$negResult';
    }

    try {
      final result = value.toRadixString(toBase);
      return uppercase ? result.toUpperCase() : result.toLowerCase();
    } catch (e) {
      return null;
    }
  }

  /// 任意进制之间转换
  ///
  /// [input] 输入字符串
  /// [fromBase] 源进制
  /// [toBase] 目标进制
  /// [uppercase] 是否使用大写字母
  /// 返回转换后的字符串，失败返回null
  static String? convert(String input, int fromBase, int toBase, {bool uppercase = true}) {
    if (input.isEmpty) return null;
    
    final decimal = toDecimal(input, fromBase);
    if (decimal == null) return null;

    return fromDecimal(decimal, toBase, uppercase: uppercase);
  }

  // ==================== 进制字符串验证 ====================

  /// 验证字符串是否为有效的指定进制数
  ///
  /// [input] 输入字符串
  /// [base] 进制
  /// 返回是否为有效数
  static bool isValid(String input, int base) {
    if (input.isEmpty) return false;
    
    final cleanInput = _removePrefix(input);
    if (cleanInput.isEmpty) return false;

    try {
      int.parse(cleanInput, radix: base);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 验证十六进制字符串（支持小数）
  ///
  /// [input] 输入字符串
  /// 返回是否为有效的十六进制数
  static bool isValidHex(String input) {
    if (input.isEmpty) return false;
    
    // 允许小数点
    final pattern = RegExp(r'^[0-9A-Fa-f.]+$');
    return pattern.hasMatch(input);
  }

  /// 移除进制前缀
  static String _removePrefix(String input) {
    if (input.startsWith('0x') || input.startsWith('0X')) {
      return input.substring(2);
    }
    if (input.startsWith('0b') || input.startsWith('0B')) {
      return input.substring(2);
    }
    if (input.startsWith('0o') || input.startsWith('0O')) {
      return input.substring(2);
    }
    return input;
  }

  // ==================== 小数转换 ====================

  /// 任意进制小数转换为十进制小数
  ///
  /// [input] 输入字符串（不含前缀）
  /// [fromBase] 源进制
  /// 返回十进制浮点数，失败返回null
  static double? fractionalToDecimal(String input, int fromBase) {
    if (input.isEmpty) return 0.0;

    try {
      double result = 0;
      for (int i = 0; i < input.length; i++) {
        final digit = int.parse(input[i], radix: fromBase);
        result += digit / math.pow(fromBase, i + 1);
      }
      return result;
    } catch (e) {
      return null;
    }
  }

  /// 十进制小数转换为任意进制小数
  ///
  /// [value] 十进制浮点数
  /// [toBase] 目标进制
  /// [precision] 小数精度（位数）
  /// [uppercase] 是否使用大写字母
  /// 返回转换后的字符串，失败返回null
  static String? decimalToFractional(double value, int toBase, {int precision = 10, bool uppercase = true}) {
    if (value < 0) {
      final negResult = decimalToFractional(-value, toBase, precision: precision, uppercase: uppercase);
      if (negResult == null) return null;
      return '-$negResult';
    }

    try {
      final intPart = value.floor();
      final fracPart = value - intPart;

      final intStr = intPart == 0 ? '0' : intPart.toRadixString(toBase);
      final fracDigits = <String>[];
      
      var remainder = fracPart;
      for (int i = 0; i < precision && remainder > 0; i++) {
        remainder *= toBase;
        final digit = remainder.floor();
        remainder -= digit;
        fracDigits.add(digit.toRadixString(toBase));
      }

      if (fracDigits.isEmpty) {
        return uppercase ? intStr.toUpperCase() : intStr.toLowerCase();
      }

      final result = '$intStr.${fracDigits.join()}';
      return uppercase ? result.toUpperCase() : result.toLowerCase();
    } catch (e) {
      return null;
    }
  }

  /// 带小数的任意进制数转换
  ///
  /// [input] 输入字符串
  /// [fromBase] 源进制
  /// [toBase] 目标进制
  /// [precision] 小数精度
  /// [uppercase] 是否使用大写字母
  /// 返回转换后的字符串，失败返回null
  static String? convertWithFraction(String input, int fromBase, int toBase, 
      {int precision = 10, bool uppercase = true}) {
    if (input.isEmpty) return null;

    // 检查是否有小数点
    if (input.contains('.')) {
      final parts = input.split('.');
      if (parts.length != 2) return null;

      final intPart = toDecimal(parts[0], fromBase);
      final fracPart = fractionalToDecimal(parts[1], fromBase);

      if (intPart == null || fracPart == null) return null;

      final resultInt = fromDecimal(intPart, toBase, uppercase: uppercase) ?? '';
      final resultFrac = decimalToFractional(fracPart, toBase, precision: precision, uppercase: uppercase) ?? '0';

      return '$resultInt.$resultFrac';
    } else {
      // 整数
      final decimal = toDecimal(input, fromBase);
      if (decimal == null) return null;
      return fromDecimal(decimal, toBase, uppercase: uppercase);
    }
  }

  // ==================== 格式化输出 ====================

  /// 格式化数字（添加分隔符）
  ///
  /// [value] 整数
  /// [separator] 分隔符，默认','
  /// 返回格式化后的字符串
  static String formatWithSeparator(int value, {String separator = ','}) {
    final str = value.abs().toString();
    final buffer = StringBuffer();
    final isNegative = value < 0;

    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(separator);
      }
      buffer.write(str[i]);
    }

    return isNegative ? '-${buffer.toString()}' : buffer.toString();
  }

  /// 获取带前缀的格式化字符串
  ///
  /// [value] 整数
  /// [base] 进制
  /// [addPrefix] 是否添加前缀
  /// [separator] 分隔符
  /// 返回格式化后的字符串
  static String formatWithBase(int value, int base, 
      {bool addPrefix = true, String separator = ','}) {
    final converted = fromDecimal(value, base) ?? '';
    final formatted = addPrefix 
        ? '${baseSymbols[base] ?? ''}${formatWithSeparator(int.tryParse(converted) ?? 0, separator: separator)}'
        : formatWithSeparator(int.tryParse(converted) ?? 0, separator: separator);
    return formatted;
  }

  // ==================== 批量转换 ====================

  /// 转换为所有支持的进制
  ///
  /// [input] 输入字符串
  /// [fromBase] 源进制
  /// [uppercase] 是否使用大写字母
  /// 返回包含所有进制转换结果的Map
  static Map<int, String>? convertToAll(String input, int fromBase, {bool uppercase = true}) {
    if (input.isEmpty) return null;

    // 分离整数和小数部分
    String intPart, fracPart;
    bool hasFraction = false;

    if (input.contains('.')) {
      final parts = input.split('.');
      intPart = parts[0];
      fracPart = parts.length > 1 ? parts[1] : '';
      hasFraction = fracPart.isNotEmpty;
    } else {
      intPart = input;
      fracPart = '';
    }

    final intDecimal = toDecimal(intPart, fromBase);
    double? fracDecimal;
    if (hasFraction) {
      fracDecimal = fractionalToDecimal(fracPart, fromBase);
    }

    if (intDecimal == null) return null;

    final result = <int, String>{};

    for (final base in supportedBases) {
      if (hasFraction && fracDecimal != null) {
        final intStr = fromDecimal(intDecimal, base, uppercase: uppercase) ?? '';
        final fracStr = decimalToFractional(fracDecimal, base, uppercase: uppercase) ?? '0';
        result[base] = '$intStr.$fracStr';
      } else {
        result[base] = fromDecimal(intDecimal, base, uppercase: uppercase) ?? '';
      }
    }

    return result;
  }

  /// 获取快速转换表（用于显示）
  ///
  /// [count] 生成的数量
  /// [fromBase] 源进制
  /// [toBase] 目标进制
  /// 返回转换表列表
  static List<Map<String, String>> getConversionTable(int count, int fromBase, int toBase) {
    final table = <Map<String, String>>[];

    for (int i = 0; i < count; i++) {
      final from = fromDecimal(i, fromBase) ?? '';
      final to = fromDecimal(i, toBase) ?? '';
      table.add({
        'dec': fromDecimal(i, 10)?.toString() ?? '',
        'from': from,
        'to': to,
      });
    }

    return table;
  }

  // ==================== 位运算 ====================

  /// 对数字执行按位与运算
  ///
  /// [a] 第一个数（十进制）
  /// [b] 第二个数（十进制）
  /// 返回按位与结果
  static int bitwiseAnd(int a, int b) {
    return a & b;
  }

  /// 对数字执行按位或运算
  ///
  /// [a] 第一个数（十进制）
  /// [b] 第二个数（十进制）
  /// 返回按位或结果
  static int bitwiseOr(int a, int b) {
    return a | b;
  }

  /// 对数字执行按位异或运算
  ///
  /// [a] 第一个数（十进制）
  /// [b] 第二个数（十进制）
  /// 返回按位异或结果
  static int bitwiseXor(int a, int b) {
    return a ^ b;
  }

  /// 对数字执行按位取反运算
  ///
  /// [value] 输入数（十进制）
  /// [bits] 位数（用于确定取反范围）
  /// 返回按位取反结果
  static int bitwiseNot(int value, {int bits = 32}) {
    final mask = (1 << bits) - 1;
    return (~value) & mask;
  }

  /// 左移运算
  ///
  /// [value] 输入数（十进制）
  /// [shift] 移位数
  /// 返回左移结果
  static int shiftLeft(int value, int shift) {
    return value << shift;
  }

  /// 右移运算
  ///
  /// [value] 输入数（十进制）
  /// [shift] 移位数
  /// 返回右移结果
  static int shiftRight(int value, int shift) {
    return value >> shift;
  }

  // ==================== 位计数 ====================

  /// 计算二进制中1的个数（汉明权重）
  ///
  /// [value] 输入数
  /// 返回1的个数
  static int countBits(int value) {
    int count = 0;
    int v = value.abs();
    while (v > 0) {
      if ((v & 1) == 1) count++;
      v >>= 1;
    }
    return count;
  }

  /// 计算二进制中0的个数
  ///
  /// [value] 输入数
  /// [bits] 位数
  /// 返回0的个数
  static int countZeros(int value, {int bits = 32}) {
    return bits - countBits(value);
  }

  /// 检查是否为2的幂
  ///
  /// [value] 输入数
  /// 返回是否为2的幂
  static bool isPowerOfTwo(int value) {
    return value > 0 && (value & (value - 1)) == 0;
  }

  /// 获取二进制补码表示
  ///
  /// [value] 输入数
  /// [bits] 位数
  /// 返回二进制补码字符串
  static String getTwosComplement(int value, {int bits = 8}) {
    if (value >= 0) {
      return (fromDecimal(value, 2) ?? '').padLeft(bits, '0');
    } else {
      final absValue = value.abs();
      final complement = (~absValue) & ((1 << bits) - 1);
      return (fromDecimal(complement, 2) ?? '').padLeft(bits, '0');
    }
  }

  // ==================== 罗马数字转换 ====================

  /// 十进制转换为罗马数字
  ///
  /// [value] 十进制数（1-3999）
  /// 返回罗马数字字符串
  static String? toRoman(int value) {
    if (value < 1 || value > 3999) return null;

    const romanValues = [1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1];
    const romanSymbols = ['M', 'CM', 'D', 'CD', 'C', 'XC', 'L', 'XL', 'X', 'IX', 'V', 'IV', 'I'];

    final buffer = StringBuffer();
    var num = value;

    for (int i = 0; i < romanValues.length; i++) {
      while (num >= romanValues[i]) {
        buffer.write(romanSymbols[i]);
        num -= romanValues[i];
      }
    }

    return buffer.toString();
  }

  /// 罗马数字转换为十进制
  ///
  /// [roman] 罗马数字字符串
  /// 返回十进制数，失败返回null
  static int? fromRoman(String roman) {
    if (roman.isEmpty) return null;

    const romanValues = {
      'I': 1,
      'V': 5,
      'X': 10,
      'L': 50,
      'C': 100,
      'D': 500,
      'M': 1000,
    };

    final upperRoman = roman.toUpperCase();
    int result = 0;
    int prevValue = 0;

    for (int i = upperRoman.length - 1; i >= 0; i--) {
      final char = upperRoman[i];
      final value = romanValues[char];
      if (value == null) return null;

      if (value < prevValue) {
        result -= value;
      } else {
        result += value;
      }
      prevValue = value;
    }

    return result;
  }
}
