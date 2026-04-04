/// Regex Utility
/// Author: ZF_Clark
/// Description: Provides regular expression testing, validation, and common pattern utilities. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

/// 正则表达式工具类
/// 提供正则测试、验证和常用模式功能
class RegexUtil {
  // ==================== 常用正则模式 ====================

  /// 常用正则模式集合
  static const Map<String, String> commonPatterns = {
    '手机号(中国)': r'^1[3-9]\d{9}$',
    '邮箱': r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    'URL': r'^https?:\/\/[\w\-]+(\.[\w\-]+)+[/#?]?.*$',
    'IP地址': r'^((25[0-5]|2[0-4]\d|[01]?\d\d?)\.){3}(25[0-5]|2[0-4]\d|[01]?\d\d?)$',
    '身份证号': r'^[1-9]\d{5}(18|19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])\d{3}[\dXx]$',
    '中文': r'^[\u4e00-\u9fa5]+$',
    '日期(YYYY-MM-DD)': r'^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])$',
    '时间(HH:mm:ss)': r'^([01]\d|2[0-3]):[0-5]\d:[0-5]\d$',
    '邮编(中国)': r'^\d{6}$',
    '银行卡号': r'^[1-9]\d{12,18}$',
    'MAC地址': r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$',
    'UUID': r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    '域名': r'^[a-zA-Z0-9][-a-zA-Z0-9]*(\.[a-zA-Z0-9][-a-zA-Z0-9]*)+$',
    'HTML标签': r'<[^>]+>',
    '端口号': r'^([0-9]{1,4}|[1-5][0-9]{4}|6[0-4]\d{3}|65[0-4]\d{2}|655[0-2]\d|6553[0-5])$',
    '字母数字': r'^[a-zA-Z0-9]+$',
    '纯数字': r'^\d+$',
    '纯字母': r'^[a-zA-Z]+$',
    '密码(强)': r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d@$!%*?&]{8,}$',
    'JWT Token': r'^[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+\.[A-Za-z0-9-_]+$',
  };

  // ==================== 正则验证 ====================

  /// 验证字符串是否匹配正则
  ///
  /// [input] 输入字符串
  /// [pattern] 正则表达式
  /// [caseSensitive] 是否区分大小写
  /// 返回是否匹配
  static bool isMatch(String input, String pattern, {bool caseSensitive = true}) {
    if (input.isEmpty || pattern.isEmpty) return false;
    try {
      final regex = RegExp(pattern, caseSensitive: caseSensitive);
      return regex.hasMatch(input);
    } catch (e) {
      return false;
    }
  }

  /// 验证是否为有效的正则表达式
  ///
  /// [pattern] 正则表达式字符串
  /// 返回是否为有效正则
  static bool isValidPattern(String pattern) {
    if (pattern.isEmpty) return false;
    try {
      RegExp(pattern);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取正则表达式错误信息
  ///
  /// [pattern] 正则表达式字符串
  /// 返回错误描述，无错返回null
  static String? getPatternError(String pattern) {
    if (pattern.isEmpty) return '正则表达式不能为空';
    try {
      RegExp(pattern);
      return null;
    } on FormatException catch (e) {
      return '语法错误: ${e.message}';
    } catch (e) {
      return '未知错误: $e';
    }
  }

  // ==================== 匹配操作 ====================

  /// 查找所有匹配项
  ///
  /// [input] 输入字符串
  /// [pattern] 正则表达式
  /// 返回匹配项列表
  static List<String> findAll(String input, String pattern, {bool caseSensitive = true}) {
    if (input.isEmpty || pattern.isEmpty) return [];
    try {
      final regex = RegExp(pattern, caseSensitive: caseSensitive);
      return regex.allMatches(input).map((m) => m.group(0) ?? '').toList();
    } catch (e) {
      return [];
    }
  }

  /// 获取第一个匹配项
  ///
  /// [input] 输入字符串
  /// [pattern] 正则表达式
  /// 返回第一个匹配项，未找到返回null
  static String? firstMatch(String input, String pattern, {bool caseSensitive = true}) {
    if (input.isEmpty || pattern.isEmpty) return null;
    try {
      final regex = RegExp(pattern, caseSensitive: caseSensitive);
      final match = regex.firstMatch(input);
      return match?.group(0);
    } catch (e) {
      return null;
    }
  }

  /// 获取所有捕获组
  ///
  /// [input] 输入字符串
  /// [pattern] 正则表达式
  /// 返回捕获组列表
  static List<List<String?>> getAllGroups(String input, String pattern, {bool caseSensitive = true}) {
    if (input.isEmpty || pattern.isEmpty) return [];
    try {
      final regex = RegExp(pattern, caseSensitive: caseSensitive);
      return regex.allMatches(input).map((m) {
        return List.generate(m.groupCount + 1, (i) => m.group(i));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// 替换匹配项
  ///
  /// [input] 输入字符串
  /// [pattern] 正则表达式
  /// [replacement] 替换文本（支持$1等反向引用）
  /// 返回替换后的字符串
  static String? replace(String input, String pattern, String replacement, {bool caseSensitive = true}) {
    if (input.isEmpty || pattern.isEmpty) return input;
    try {
      final regex = RegExp(pattern, caseSensitive: caseSensitive);
      return input.replaceAll(regex, replacement);
    } catch (e) {
      return null;
    }
  }

  /// 替换所有匹配项
  ///
  /// [input] 输入字符串
  /// [pattern] 正则表达式
  /// [callback] 替换回调函数
  /// 返回替换后的字符串
  static String replaceAll(String input, String pattern, String Function(Match match) callback, {bool caseSensitive = true}) {
    if (input.isEmpty || pattern.isEmpty) return input;
    try {
      final regex = RegExp(pattern, caseSensitive: caseSensitive);
      return input.replaceAllMapped(regex, callback);
    } catch (e) {
      return input;
    }
  }

  // ==================== 分割操作 ====================

  /// 按正则分割字符串
  ///
  /// [input] 输入字符串
  /// [pattern] 正则表达式
  /// [limit] 最大分割数
  /// 返回分割后的列表
  static List<String> split(String input, String pattern, {int? limit, bool caseSensitive = true}) {
    if (input.isEmpty || pattern.isEmpty) return [input];
    try {
      final regex = RegExp(pattern, caseSensitive: caseSensitive);
      if (limit != null) {
        return regex.allMatches(input).take(limit)
            .map((m) => m.group(0) ?? '')
            .toList();
      }
      return input.split(regex);
    } catch (e) {
      return [input];
    }
  }

  /// 完整测试
  ///
  /// [input] 输入字符串
  /// [pattern] 正则表达式
  /// 返回测试结果
  static RegexTestResult test(String input, String pattern, {bool caseSensitive = true}) {
    if (input.isEmpty) {
      return RegexTestResult(
        isMatch: false,
        matches: [],
        matchDetails: [],
        error: '输入为空',
      );
    }

    if (pattern.isEmpty) {
      return RegexTestResult(
        isMatch: false,
        matches: [],
        matchDetails: [],
        error: '正则表达式为空',
      );
    }

    final error = getPatternError(pattern);
    if (error != null) {
      return RegexTestResult(
        isMatch: false,
        matches: [],
        matchDetails: [],
        error: error,
      );
    }

    try {
      final regex = RegExp(pattern, caseSensitive: caseSensitive);
      final matches = regex.allMatches(input).toList();

      if (matches.isEmpty) {
        return RegexTestResult(
          isMatch: false,
          matches: [],
          matchDetails: [],
        );
      }

      final matchStrings = matches.map((m) => m.group(0) ?? '').toList();
      final matchDetails = matches.map((m) {
        return RegexTestMatch(
          match: m.group(0) ?? '',
          start: m.start,
          end: m.end,
          groups: List.generate(m.groupCount + 1, (i) => m.group(i)),
        );
      }).toList();

      return RegexTestResult(
        isMatch: true,
        matches: matchStrings,
        matchDetails: matchDetails,
      );
    } catch (e) {
      return RegexTestResult(
        isMatch: false,
        matches: [],
        matchDetails: [],
        error: '测试失败: $e',
      );
    }
  }

  // ==================== 常用验证 ====================

  /// 验证手机号
  static bool isPhone(String phone) => isMatch(phone, commonPatterns['手机号(中国)']!);

  /// 验证邮箱
  static bool isEmail(String email) => isMatch(email, commonPatterns['邮箱']!);

  /// 验证URL
  static bool isUrl(String url) => isMatch(url, commonPatterns['URL']!);

  /// 验证IP地址
  static bool isIp(String ip) => isMatch(ip, commonPatterns['IP地址']!);

  /// 验证身份证号
  static bool isIdCard(String idCard) => isMatch(idCard, commonPatterns['身份证号']!);

  /// 验证中文
  static bool isChinese(String text) => isMatch(text, commonPatterns['中文']!);
}

/// 正则测试结果
class RegexTestResult {
  final bool isMatch;
  final List<String> matches;
  final List<RegexTestMatch> matchDetails;
  final String? error;

  RegexTestResult({
    required this.isMatch,
    required this.matches,
    required this.matchDetails,
    this.error,
  });
}

/// 单个匹配详情
class RegexTestMatch {
  final String match;
  final int start;
  final int end;
  final List<String?> groups;

  RegexTestMatch({
    required this.match,
    required this.start,
    required this.end,
    required this.groups,
  });
}
