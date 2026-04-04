/// Timestamp Utility
/// Author: ZF_Clark
/// Description: Provides timestamp conversion utilities. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

/// 时间戳工具类
/// 提供各种时间戳转换功能
class TimestampUtil {
  /// 获取当前时间戳（秒）
  static int get nowSeconds => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// 获取当前时间戳（毫秒）
  static int get nowMs => DateTime.now().millisecondsSinceEpoch;

  /// 秒时间戳转DateTime
  static DateTime fromSeconds(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  /// 毫秒时间戳转DateTime
  static DateTime fromMs(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// DateTime转秒时间戳
  static int toSeconds(DateTime dt) => dt.millisecondsSinceEpoch ~/ 1000;

  /// DateTime转毫秒时间戳
  static int toMs(DateTime dt) => dt.millisecondsSinceEpoch;

  /// 获取今天开始的时间戳（秒）
  static int get todayStartSeconds {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch ~/ 1000;
  }

  /// 获取今天结束的时间戳（秒）
  static int get todayEndSeconds {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59).millisecondsSinceEpoch ~/ 1000;
  }

  /// 获取本周开始的时间戳（秒，周一）
  static int get weekStartSeconds {
    final now = DateTime.now();
    final weekday = now.weekday;
    return DateTime(now.year, now.month, now.day - weekday + 1).millisecondsSinceEpoch ~/ 1000;
  }

  /// 获取本月开始的时间戳（秒）
  static int get monthStartSeconds {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1).millisecondsSinceEpoch ~/ 1000;
  }

  /// 格式化时间戳（秒）
  ///
  /// [timestamp] Unix时间戳（秒）
  /// [format] 格式
  static String formatSeconds(int timestamp, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    return fromSeconds(timestamp).toString().substring(0, 19).replaceAll('T', ' ');
  }

  /// 格式化时间戳（毫秒）
  ///
  /// [timestamp] Unix时间戳（毫秒）
  /// [format] 格式
  static String formatMs(int timestamp, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    return fromMs(timestamp).toString().substring(0, 19).replaceAll('T', ' ');
  }

  /// 解析日期字符串为时间戳（秒）
  ///
  /// [dateString] 日期字符串，支持多种格式
  /// 返回时间戳（秒），失败返回null
  static int? parseToSeconds(String dateString) {
    try {
      final dt = DateTime.parse(dateString);
      return toSeconds(dt);
    } catch (e) {
      return null;
    }
  }

  /// 相对时间描述
  ///
  /// [timestamp] Unix时间戳（秒）
  static String timeAgo(int timestamp) {
    final now = DateTime.now();
    final target = fromSeconds(timestamp);
    final diff = now.difference(target);

    if (diff.inDays > 365) return '${diff.inDays ~/ 365}年前';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}个月前';
    if (diff.inDays > 0) return '${diff.inDays}天前';
    if (diff.inHours > 0) return '${diff.inHours}小时前';
    if (diff.inMinutes > 0) return '${diff.inMinutes}分钟前';
    return '刚刚';
  }
}