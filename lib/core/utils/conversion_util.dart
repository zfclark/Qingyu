
/// Conversion Utility
/// Author: ZF_Clark
/// Description: Provides unit conversion utilities for length, weight, temperature, and timestamp. Pure utility class without UI dependencies.
/// Last Modified: 2026/02/08
library;

/// 长度单位枚举
enum LengthUnit {
  millimeter,
  centimeter,
  meter,
  kilometer,
  inch,
  foot,
  yard,
  mile,
}

/// 重量单位枚举
enum WeightUnit {
  milligram,
  gram,
  kilogram,
  ton,
  pound,
  ounce,
}

/// 温度单位枚举
enum TemperatureUnit {
  celsius,
  fahrenheit,
  kelvin,
}

/// 转换工具类
/// 提供纯单位转换功能，不涉及任何UI操作
class ConversionUtil {
  // ==================== 长度转换 ====================

  /// 长度单位到米的转换系数
  static const Map<LengthUnit, double> _lengthToMeters = {
    LengthUnit.millimeter: 0.001,
    LengthUnit.centimeter: 0.01,
    LengthUnit.meter: 1.0,
    LengthUnit.kilometer: 1000.0,
    LengthUnit.inch: 0.0254,
    LengthUnit.foot: 0.3048,
    LengthUnit.yard: 0.9144,
    LengthUnit.mile: 1609.34,
  };

  /// 转换长度单位
  /// 
  /// [value] 输入值
  /// [from] 源单位
  /// [to] 目标单位
  /// 返回转换后的值
  static double convertLength(double value, LengthUnit from, LengthUnit to) {
    final meters = value * _lengthToMeters[from]!;
    return meters / _lengthToMeters[to]!;
  }

  /// 根据单位名称转换长度
  /// 
  /// [value] 输入值
  /// [fromUnit] 源单位名称（毫米、厘米、米、千米、英寸、英尺、码、英里）
  /// [toUnit] 目标单位名称
  /// 返回转换后的值
  static double convertLengthByName(double value, String fromUnit, String toUnit) {
    final from = _parseLengthUnit(fromUnit);
    final to = _parseLengthUnit(toUnit);
    return convertLength(value, from, to);
  }

  /// 解析长度单位名称
  static LengthUnit _parseLengthUnit(String unitName) {
    switch (unitName) {
      case '毫米':
        return LengthUnit.millimeter;
      case '厘米':
        return LengthUnit.centimeter;
      case '米':
        return LengthUnit.meter;
      case '千米':
        return LengthUnit.kilometer;
      case '英寸':
        return LengthUnit.inch;
      case '英尺':
        return LengthUnit.foot;
      case '码':
        return LengthUnit.yard;
      case '英里':
        return LengthUnit.mile;
      default:
        return LengthUnit.meter;
    }
  }

  // ==================== 重量转换 ====================

  /// 重量单位到克的转换系数
  static const Map<WeightUnit, double> _weightToGrams = {
    WeightUnit.milligram: 0.001,
    WeightUnit.gram: 1.0,
    WeightUnit.kilogram: 1000.0,
    WeightUnit.ton: 1000000.0,
    WeightUnit.pound: 453.592,
    WeightUnit.ounce: 28.3495,
  };

  /// 转换重量单位
  /// 
  /// [value] 输入值
  /// [from] 源单位
  /// [to] 目标单位
  /// 返回转换后的值
  static double convertWeight(double value, WeightUnit from, WeightUnit to) {
    final grams = value * _weightToGrams[from]!;
    return grams / _weightToGrams[to]!;
  }

  /// 根据单位名称转换重量
  /// 
  /// [value] 输入值
  /// [fromUnit] 源单位名称（毫克、克、千克、吨、磅、盎司）
  /// [toUnit] 目标单位名称
  /// 返回转换后的值
  static double convertWeightByName(double value, String fromUnit, String toUnit) {
    final from = _parseWeightUnit(fromUnit);
    final to = _parseWeightUnit(toUnit);
    return convertWeight(value, from, to);
  }

  /// 解析重量单位名称
  static WeightUnit _parseWeightUnit(String unitName) {
    switch (unitName) {
      case '毫克':
        return WeightUnit.milligram;
      case '克':
        return WeightUnit.gram;
      case '千克':
        return WeightUnit.kilogram;
      case '吨':
        return WeightUnit.ton;
      case '磅':
        return WeightUnit.pound;
      case '盎司':
        return WeightUnit.ounce;
      default:
        return WeightUnit.gram;
    }
  }

  // ==================== 温度转换 ====================

  /// 转换温度单位
  /// 
  /// [value] 输入值
  /// [from] 源单位
  /// [to] 目标单位
  /// 返回转换后的值
  static double convertTemperature(double value, TemperatureUnit from, TemperatureUnit to) {
    if (from == to) return value;

    // 先转换为摄氏度
    double celsius;
    switch (from) {
      case TemperatureUnit.celsius:
        celsius = value;
        break;
      case TemperatureUnit.fahrenheit:
        celsius = (value - 32) * 5 / 9;
        break;
      case TemperatureUnit.kelvin:
        celsius = value - 273.15;
        break;
    }

    // 再从摄氏度转换到目标单位
    switch (to) {
      case TemperatureUnit.celsius:
        return celsius;
      case TemperatureUnit.fahrenheit:
        return (celsius * 9 / 5) + 32;
      case TemperatureUnit.kelvin:
        return celsius + 273.15;
    }
  }

  /// 根据单位名称转换温度
  /// 
  /// [value] 输入值
  /// [fromUnit] 源单位名称（摄氏度、华氏度、开尔文）
  /// [toUnit] 目标单位名称
  /// 返回转换后的值
  static double convertTemperatureByName(double value, String fromUnit, String toUnit) {
    final from = _parseTemperatureUnit(fromUnit);
    final to = _parseTemperatureUnit(toUnit);
    return convertTemperature(value, from, to);
  }

  /// 解析温度单位名称
  static TemperatureUnit _parseTemperatureUnit(String unitName) {
    switch (unitName) {
      case '摄氏度':
        return TemperatureUnit.celsius;
      case '华氏度':
        return TemperatureUnit.fahrenheit;
      case '开尔文':
        return TemperatureUnit.kelvin;
      default:
        return TemperatureUnit.celsius;
    }
  }

  // ==================== 时间戳转换 ====================

  /// 将Unix时间戳（秒）转换为DateTime
  /// 
  /// [timestamp] Unix时间戳（秒）
  /// 返回DateTime对象
  static DateTime timestampToDateTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  /// 将Unix时间戳（毫秒）转换为DateTime
  /// 
  /// [timestamp] Unix时间戳（毫秒）
  /// 返回DateTime对象
  static DateTime timestampMsToDateTime(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 将DateTime转换为Unix时间戳（秒）
  /// 
  /// [dateTime] DateTime对象
  /// 返回Unix时间戳（秒）
  static int dateTimeToTimestamp(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch ~/ 1000;
  }

  /// 将DateTime转换为Unix时间戳（毫秒）
  /// 
  /// [dateTime] DateTime对象
  /// 返回Unix时间戳（毫秒）
  static int dateTimeToTimestampMs(DateTime dateTime) {
    return dateTime.millisecondsSinceEpoch;
  }

  /// 自动解析时间戳或日期字符串
  /// 
  /// [input] 输入字符串（时间戳或日期格式）
  /// 返回转换结果字符串，失败返回错误信息
  static String convertTimestamp(String input) {
    final trimmed = input.trim();

    // 尝试解析为时间戳
    if (trimmed.isNotEmpty && RegExp(r'^\d+$').hasMatch(trimmed)) {
      try {
        final timestamp = int.parse(trimmed);
        // 判断是秒还是毫秒
        DateTime date;
        if (timestamp > 9999999999) {
          // 毫秒
          date = timestampMsToDateTime(timestamp);
        } else {
          // 秒
          date = timestampToDateTime(timestamp);
        }
        return date.toString();
      } catch (e) {
        return '无效的时间戳';
      }
    }

    // 尝试解析为日期
    try {
      final date = DateTime.parse(trimmed);
      final seconds = dateTimeToTimestamp(date);
      final milliseconds = dateTimeToTimestampMs(date);
      return '$seconds (秒)\n$milliseconds (毫秒)';
    } catch (e) {
      return '无效的日期格式';
    }
  }
}
