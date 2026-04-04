/// Time Calculator Utility
/// Author: ZF_Clark
/// Description: Provides date and time calculation utilities including date difference, timestamp conversion, and age calculation. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

/// 时间计算工具类
/// 提供日期时间计算功能
class TimeCalculatorUtil {
  // ==================== 日期差异计算 ====================

  /// 计算两个日期之间的天数差
  ///
  /// [date1] 第一个日期
  /// [date2] 第二个日期
  /// 返回天数差（绝对值）
  static int daysBetween(DateTime date1, DateTime date2) {
    final d1 = DateTime(date1.year, date1.month, date1.day);
    final d2 = DateTime(date2.year, date2.month, date2.day);
    return (d1.difference(d2).inDays).abs();
  }

  /// 计算两个日期之间的时间差（详细）
  ///
  /// [date1] 第一个日期
  /// [date2] 第二个日期
  /// 返回包含各单位的Map
  static Map<String, dynamic> diffBetween(DateTime date1, DateTime date2) {
    final earlier = date1.isBefore(date2) ? date1 : date2;
    final later = date1.isBefore(date2) ? date2 : date1;

    int years = later.year - earlier.year;
    int months = later.month - earlier.month;
    int days = later.day - earlier.day;

    // 调整月份和天数
    if (days < 0) {
      months--;
      final prevMonth = DateTime(later.year, later.month, 0);
      days += prevMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    final diff = later.difference(earlier);

    return {
      'years': years,
      'months': months,
      'days': days,
      'hours': diff.inHours % 24,
      'minutes': diff.inMinutes % 60,
      'seconds': diff.inSeconds % 60,
      'totalDays': diff.inDays,
      'totalHours': diff.inHours,
      'totalMinutes': diff.inMinutes,
      'totalSeconds': diff.inSeconds,
      'isFuture': date1.isAfter(date2),
    };
  }

  /// 计算工作日天数（排除周末）
  ///
  /// [startDate] 开始日期
  /// [endDate] 结束日期
  /// [excludeHolidays] 额外需要排除的假期日期列表
  /// 返回工作日天数
  static int workDaysBetween(
    DateTime startDate,
    DateTime endDate, {
    List<DateTime>? excludeHolidays,
  }) {
    // 确保startDate不晚于endDate
    final start = startDate.isBefore(endDate) ? startDate : endDate;
    final end = startDate.isBefore(endDate) ? endDate : startDate;

    final holidays =
        excludeHolidays?.map((d) => DateTime(d.year, d.month, d.day)).toSet() ??
        {};

    int workDays = 0;
    var current = DateTime(start.year, start.month, start.day);
    final endDateOnly = DateTime(end.year, end.month, end.day);

    while (!current.isAfter(endDateOnly)) {
      if (current.weekday != DateTime.saturday &&
          current.weekday != DateTime.sunday &&
          !holidays.contains(current)) {
        workDays++;
      }
      current = current.add(const Duration(days: 1));
    }

    return workDays;
  }

  // ==================== 日期运算 ====================

  /// 日期加减
  ///
  /// [date] 基准日期
  /// [days] 加减的天数（负数表示减）
  /// 返回计算后的日期
  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  /// 日期加减月份
  ///
  /// [date] 基准日期
  /// [months] 加减的月数
  /// 返回计算后的日期
  static DateTime addMonths(DateTime date, int months) {
    var newYear = date.year;
    var newMonth = date.month + months;

    while (newMonth > 12) {
      newMonth -= 12;
      newYear++;
    }
    while (newMonth < 1) {
      newMonth += 12;
      newYear--;
    }

    final maxDay = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = date.day > maxDay ? maxDay : date.day;

    return DateTime(newYear, newMonth, newDay);
  }

  /// 日期加减年份
  ///
  /// [date] 基准日期
  /// [years] 加减的年数
  /// 返回计算后的日期
  static DateTime addYears(DateTime date, int years) {
    return DateTime(date.year + years, date.month, date.day);
  }

  /// 获取日期的开始时间（00:00:00）
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// 获取日期的结束时间（23:59:59）
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// 获取周的开始（周一）
  static DateTime startOfWeek(DateTime date) {
    final daysFromMonday = date.weekday - 1;
    return startOfDay(date.subtract(Duration(days: daysFromMonday)));
  }

  /// 获取月的开始
  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// 获取月的结束
  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
  }

  /// 获取年的开始
  static DateTime startOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// 获取年的结束
  static DateTime endOfYear(DateTime date) {
    return DateTime(date.year, 12, 31, 23, 59, 59);
  }

  // ==================== 时间戳转换 ====================

  /// DateTime转Unix时间戳（秒）
  static int toTimestamp(DateTime date) {
    return date.millisecondsSinceEpoch ~/ 1000;
  }

  /// DateTime转Unix时间戳（毫秒）
  static int toTimestampMs(DateTime date) {
    return date.millisecondsSinceEpoch;
  }

  /// Unix时间戳（秒）转DateTime
  static DateTime fromTimestamp(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
  }

  /// Unix时间戳（毫秒）转DateTime
  static DateTime fromTimestampMs(int timestamp) {
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 获取当前时间戳（秒）
  static int get nowTimestamp => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  /// 获取当前时间戳（毫秒）
  static int get nowTimestampMs => DateTime.now().millisecondsSinceEpoch;

  // ==================== 年龄计算 ====================

  /// 计算年龄
  ///
  /// [birthDate] 出生日期
  /// [atDate] 计算年龄的日期，默认为当前日期
  /// 返回年龄（岁）
  static int calculateAge(DateTime birthDate, {DateTime? atDate}) {
    final today = atDate ?? DateTime.now();
    int age = today.year - birthDate.year;

    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age < 0 ? 0 : age;
  }

  /// 计算精确年龄
  ///
  /// [birthDate] 出生日期
  /// [atDate] 计算年龄的日期
  /// 返回包含岁、月、日的Map
  static Map<String, int> calculateExactAge(
    DateTime birthDate, {
    DateTime? atDate,
  }) {
    final today = atDate ?? DateTime.now();
    int years = today.year - birthDate.year;
    int months = today.month - birthDate.month;
    int days = today.day - birthDate.day;

    if (days < 0) {
      months--;
      final prevMonth = DateTime(today.year, today.month, 0);
      days += prevMonth.day;
    }

    if (months < 0) {
      years--;
      months += 12;
    }

    return {
      'years': years < 0 ? 0 : years,
      'months': months < 0 ? 0 : months,
      'days': days < 0 ? 0 : days,
    };
  }

  /// 计算出生日期
  ///
  /// [age] 年龄
  /// [atDate] 计算日期
  /// 返回估计的出生日期范围
  static Map<String, DateTime> estimateBirthDate(int age, {DateTime? atDate}) {
    final today = atDate ?? DateTime.now();
    final earliest = DateTime(today.year - age - 1, today.month, today.day);
    final latest = DateTime(today.year - age, today.month, today.day);
    return {'earliest': earliest, 'latest': latest};
  }

  // ==================== 星期计算 ====================

  /// 获取星期几名称
  ///
  /// [date] 日期
  /// [short] 是否返回短名称
  static String getWeekdayName(DateTime date, {bool short = false}) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    const weekdaysShort = ['一', '二', '三', '四', '五', '六', '日'];
    return short ? weekdaysShort[date.weekday - 1] : weekdays[date.weekday - 1];
  }

  /// 获取星期几英文名称
  static String getWeekdayNameEn(DateTime date, {bool short = false}) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const weekdaysShort = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return short ? weekdaysShort[date.weekday - 1] : weekdays[date.weekday - 1];
  }

  /// 判断是否为周末
  static bool isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  /// 判断是否为工作日
  static bool isWorkday(DateTime date) {
    return !isWeekend(date);
  }

  /// 获取该日期在本月的第几周
  static int weekOfMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final firstWeekday = firstDayOfMonth.weekday;
    final offset = (firstWeekday - 1) % 7;
    return ((date.day + offset - 1) ~/ 7) + 1;
  }

  // ==================== 格式化 ====================

  /// 格式化日期时间
  ///
  /// [date] 日期
  /// [format] 格式字符串
  /// 返回格式化后的字符串
  static String format(DateTime date, {String format = 'yyyy-MM-dd HH:mm:ss'}) {
    String result = format;
    result = result.replaceAll('yyyy', date.year.toString().padLeft(4, '0'));
    result = result.replaceAll('MM', date.month.toString().padLeft(2, '0'));
    result = result.replaceAll('dd', date.day.toString().padLeft(2, '0'));
    result = result.replaceAll('HH', date.hour.toString().padLeft(2, '0'));
    result = result.replaceAll('mm', date.minute.toString().padLeft(2, '0'));
    result = result.replaceAll('ss', date.second.toString().padLeft(2, '0'));
    result = result.replaceAll(
      'SSS',
      date.millisecond.toString().padLeft(3, '0'),
    );
    return result;
  }

  /// 相对时间描述
  ///
  /// [date] 日期
  /// [relativeTo] 参照日期，默认为当前时间
  static String timeAgo(DateTime date, {DateTime? relativeTo}) {
    final now = relativeTo ?? DateTime.now();
    final diff = now.difference(date);

    if (diff.isNegative) {
      return '未来';
    }

    if (diff.inDays > 365) {
      return '${diff.inDays ~/ 365}年前';
    } else if (diff.inDays > 30) {
      return '${diff.inDays ~/ 30}个月前';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  // ==================== 星座 ====================

  /// 根据日期获取星座
  static String getZodiac(DateTime date) {
    final month = date.month;
    final day = date.day;

    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      return '白羊座';
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      return '金牛座';
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      return '双子座';
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      return '巨蟹座';
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      return '狮子座';
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      return '处女座';
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      return '天秤座';
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      return '天蝎座';
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      return '射手座';
    } else if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) {
      return '摩羯座';
    } else if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      return '水瓶座';
    } else {
      return '双鱼座';
    }
  }
}
