/// Random Utility
/// Author: ZF_Clark
/// Description: Provides random number and string generation utilities with customizable options. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

import 'dart:math';

/// 随机数工具类
/// 提供随机数生成功能
class RandomUtil {
  static final Random _secureRandom = Random.secure();
  static final Random _normalRandom = Random();

  // ==================== 基础随机数 ====================

  /// 生成随机整数
  ///
  /// [min] 最小值（包含）
  /// [max] 最大值（包含）
  /// [secure] 是否使用安全随机
  static int nextInt(int min, int max, {bool secure = false}) {
    final random = secure ? _secureRandom : _normalRandom;
    return min + random.nextInt(max - min + 1);
  }

  /// 生成随机浮点数
  ///
  /// [min] 最小值
  /// [max] 最大值
  /// [secure] 是否使用安全随机
  static double nextDouble({double min = 0.0, double max = 1.0, bool secure = false}) {
    final random = secure ? _secureRandom : _normalRandom;
    return min + random.nextDouble() * (max - min);
  }

  /// 生成随机布尔值
  ///
  /// [trueProbability] 为true的概率（0-1）
  static bool nextBool({double trueProbability = 0.5}) {
    return _secureRandom.nextDouble() < trueProbability;
  }

  // ==================== 批量随机数 ====================

  /// 生成多个随机整数
  ///
  /// [count] 生成数量
  /// [min] 最小值
  /// [max] 最大值
  /// [unique] 是否唯一
  static List<int> generateIntList(int count, int min, int max, {bool unique = false}) {
    if (unique && count > (max - min + 1)) {
      count = max - min + 1;
    }

    final result = <int>[];
    if (unique) {
      final set = <int>{};
      while (set.length < count) {
        set.add(nextInt(min, max));
      }
      result.addAll(set);
    } else {
      for (int i = 0; i < count; i++) {
        result.add(nextInt(min, max));
      }
    }
    return result;
  }

  /// 生成随机浮点数列表
  ///
  /// [count] 生成数量
  /// [min] 最小值
  /// [max] 最大值
  static List<double> generateDoubleList(int count, double min, double max) {
    return List.generate(count, (_) => nextDouble(min: min, max: max));
  }

  // ==================== 随机字符串 ====================

  /// 生成随机字符串
  ///
  /// [length] 字符串长度
  /// [charset] 字符集
  static String generateString(int length, {String charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'}) {
    return List.generate(length, (_) => charset[nextInt(0, charset.length - 1)]).join();
  }

  /// 生成随机字母字符串
  ///
  /// [length] 字符串长度
  /// [lowercaseOnly] 是否仅小写
  static String generateAlphabetical(int length, {bool lowercaseOnly = false}) {
    final charset = lowercaseOnly
        ? 'abcdefghijklmnopqrstuvwxyz'
        : 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
    return generateString(length, charset: charset);
  }

  /// 生成随机数字字符串
  ///
  /// [length] 字符串长度
  /// [allowLeadingZero] 是否允许前导零
  static String generateNumeric(int length, {bool allowLeadingZero = true}) {
    if (!allowLeadingZero && length > 1) {
      final first = nextInt(1, 9);
      final rest = List.generate(length - 1, (_) => nextInt(0, 9)).join();
      return '$first$rest';
    }
    return generateString(length, charset: '0123456789');
  }

  /// 生成随机字母数字字符串
  ///
  /// [length] 字符串长度
  static String generateAlphanumeric(int length) {
    return generateString(length, charset: 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789');
  }

  /// 生成随机Hex字符串
  ///
  /// [length] 字符串长度（字节数）
  static String generateHex(int length) {
    return generateString(length * 2, charset: '0123456789ABCDEF');
  }

  // ==================== 特殊随机 ====================

  /// 从列表中随机选择
  ///
  /// [list] 选择列表
  static T? pickOne<T>(List<T> list) {
    if (list.isEmpty) return null;
    return list[nextInt(0, list.length - 1)];
  }

  /// 从列表中随机选择多个
  ///
  /// [list] 选择列表
  /// [count] 选择数量
  /// [unique] 是否唯一选择
  static List<T> pickMany<T>(List<T> list, int count, {bool unique = true}) {
    if (list.isEmpty) return [];
    if (!unique || count >= list.length) {
      final shuffled = List<T>.from(list)..shuffle(_normalRandom);
      return shuffled.take(count).toList();
    }

    final result = <T>{};
    while (result.length < count) {
      final picked = pickOne(list);
      if (picked != null) result.add(picked);
    }
    return result.toList();
  }

  /// 打乱列表顺序
  ///
  /// [list] 待打乱列表
  static List<T> shuffle<T>(List<T> list) {
    final result = List<T>.from(list);
    result.shuffle(_normalRandom);
    return result;
  }

  // ==================== 范围随机 ====================

  /// 生成随机IPv4地址
  static String generateIPv4() {
    return '${nextInt(1, 255)}.${nextInt(0, 255)}.${nextInt(0, 255)}.${nextInt(1, 255)}';
  }

  /// 生成随机颜色（HEX格式）
  static String generateColor({bool includeHash = true}) {
    final r = nextInt(0, 255);
    final g = nextInt(0, 255);
    final b = nextInt(0, 255);
    final prefix = includeHash ? '#' : '';
    return '$prefix${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  /// 生成随机MAC地址
  static String generateMacAddress({String separator = ':'}) {
    return List.generate(6, (_) => nextInt(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(separator);
  }

  /// 生成随机布尔数组
  ///
  /// [length] 数组长度
  /// [trueProbability] true的概率
  static List<bool> generateBoolArray(int length, {double trueProbability = 0.5}) {
    return List.generate(length, (_) => nextBool(trueProbability: trueProbability));
  }

  // ==================== 统计分布 ====================

  /// 生成正态分布随机数
  ///
  /// [mean] 均值
  /// [stdDev] 标准差
  static double nextGaussian({double mean = 0.0, double stdDev = 1.0}) {
    final u1 = _normalRandom.nextDouble();
    final u2 = _normalRandom.nextDouble();
    final z0 = sqrt(-2.0 * log(u1)) * cos(2 * pi * u2);
    return mean + z0 * stdDev;
  }

  /// 生成指定范围的正态分布随机数
  ///
  /// [min] 最小值
  /// [max] 最大值
  /// [mean] 均值
  /// [stdDev] 标准差
  static int nextGaussianInt(int min, int max, {double mean = 0.0, double stdDev = 1.0}) {
    final value = nextGaussian(mean: mean, stdDev: stdDev);
    return value.clamp(min.toDouble(), max.toDouble()).round();
  }

  /// 生成随机百分比（0-100）
  static int randomPercent() {
    return nextInt(0, 100);
  }

  /// 生成随机概率（0.0-1.0）
  static double randomProbability() {
    return nextDouble(min: 0.0, max: 1.0);
  }
}
