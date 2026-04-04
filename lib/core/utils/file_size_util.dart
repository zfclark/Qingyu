/// File Size Utility
/// Author: ZF_Clark
/// Description: Provides file size formatting and conversion utilities. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

/// 文件大小工具类
/// 提供文件大小格式化功能
class FileSizeUtil {
  /// 单位列表
  static const List<String> units = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];

  /// 格式化文件大小
  ///
  /// [bytes] 字节数
  /// [decimals] 小数位数
  /// 返回格式化后的字符串
  static String format(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';
    
    int unitIndex = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    if (unitIndex == 0) {
      return '${size.toInt()} ${units[unitIndex]}';
    }
    
    return '${size.toStringAsFixed(decimals)} ${units[unitIndex]}';
  }

  /// 解析文件大小字符串
  ///
  /// [sizeString] 文件大小字符串，如 "1.5 MB"
  /// 返回字节数
  static int? parse(String sizeString) {
    final match = RegExp(r'^([\d.]+)\s*([KMGTP]?B)$', caseSensitive: false)
        .firstMatch(sizeString.trim());
    
    if (match == null) return null;
    
    final value = double.tryParse(match.group(1)!);
    if (value == null) return null;
    
    final unit = match.group(2)!.toUpperCase();
    final unitIndex = units.indexOf(unit);
    
    if (unitIndex == -1) return null;
    
    return (value * _pow(1024, unitIndex)).round();
  }

  /// 计算幂
  static double _pow(double base, int exp) {
    double result = 1;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  /// 获取最合适的单位
  ///
  /// [bytes] 字节数
  /// 返回单位索引
  static int getBestUnit(int bytes) {
    if (bytes <= 0) return 0;
    
    int unitIndex = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return unitIndex;
  }

  /// 字节数转KB
  static double toKB(int bytes) => bytes / 1024;
  
  /// 字节数转MB
  static double toMB(int bytes) => bytes / (1024 * 1024);
  
  /// 字节数转GB
  static double toGB(int bytes) => bytes / (1024 * 1024 * 1024);

  /// KB转字节
  static int fromKB(double kb) => (kb * 1024).round();
  
  /// MB转字节
  static int fromMB(double mb) => (mb * 1024 * 1024).round();
  
  /// GB转字节
  static int fromGB(double gb) => (gb * 1024 * 1024 * 1024).round();
}