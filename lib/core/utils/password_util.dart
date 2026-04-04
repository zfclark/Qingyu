/// Password Utility
/// Author: ZF_Clark
/// Description: Provides random password generation utilities with customizable options. Supports length, character types, and password strength evaluation. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

import 'dart:math';

/// 密码生成工具类
/// 提供随机密码生成功能，支持长度、字符类型等自定义选项
class PasswordUtil {
  // ==================== 常量 ====================

  /// 小写字母
  static const String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';

  /// 大写字母
  static const String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// 数字
  static const String digitChars = '0123456789';

  /// 特殊字符 - 常用符号
  static const String specialCharsBasic = '!@#\$%^&*';

  /// 特殊字符 - 中等符号
  static const String specialCharsMedium = '!@#\$%^&*+-=_?';

  /// 特殊字符 - 扩展符号
  static const String specialCharsExtended = '!@#\$%^&*+-=_?[]{}|;:,.<>';

  /// 易混淆字符（去除后更易读）
  static const String ambiguousChars = 'l1IO0';

  /// 常用密码列表
  static const List<String> commonPasswords = [
    'password', '123456', '12345678', 'qwerty', 'abc123',
    'monkey', 'master', 'dragon', 'letmein', 'login',
    'admin', 'welcome', 'sunshine', 'princess', 'football',
  ];

  // ==================== 密码生成 ====================

  /// 生成随机密码
  ///
  /// [length] 密码长度
  /// [includeLowercase] 是否包含小写字母
  /// [includeUppercase] 是否包含大写字母
  /// [includeDigits] 是否包含数字
  /// [includeSpecial] 是否包含特殊字符
  /// [excludeAmbiguous] 是否排除易混淆字符
  /// 返回生成的密码字符串
  static String generate({
    int length = 16,
    bool includeLowercase = true,
    bool includeUppercase = true,
    bool includeDigits = true,
    bool includeSpecial = true,
    bool excludeAmbiguous = false,
  }) {
    if (length < 1) return '';

    // 确保至少选择一种字符类型
    if (!includeLowercase && !includeUppercase && !includeDigits && !includeSpecial) {
      includeLowercase = true;
    }

    // 构建字符池
    String charPool = '';
    final requiredChars = <String>[];

    if (includeLowercase) {
      var chars = lowercaseChars;
      if (excludeAmbiguous) {
        chars = _removeAmbiguous(chars);
      }
      charPool += chars;
      requiredChars.add(_randomChar(chars));
    }

    if (includeUppercase) {
      var chars = uppercaseChars;
      if (excludeAmbiguous) {
        chars = _removeAmbiguous(chars);
      }
      charPool += chars;
      requiredChars.add(_randomChar(chars));
    }

    if (includeDigits) {
      var chars = digitChars;
      if (excludeAmbiguous) {
        chars = _removeAmbiguous(chars);
      }
      charPool += chars;
      requiredChars.add(_randomChar(chars));
    }

    if (includeSpecial) {
      charPool += specialCharsMedium;
      requiredChars.add(_randomChar(specialCharsMedium));
    }

    if (charPool.isEmpty) return '';

    final random = Random.secure();
    final buffer = StringBuffer();

    // 先添加必需字符（确保每种类型都出现）
    for (final char in requiredChars) {
      if (buffer.length < length) {
        buffer.write(char);
      }
    }

    // 填充剩余字符
    while (buffer.length < length) {
      buffer.write(charPool[random.nextInt(charPool.length)]);
    }

    // 打乱字符顺序
    final chars = buffer.toString().split('');
    chars.shuffle(random);
    return chars.join();
  }

  /// 生成简单密码（仅字母）
  ///
  /// [length] 密码长度
  /// [mixedCase] 是否混合大小写
  /// 返回生成的密码
  static String generateSimple({int length = 12, bool mixedCase = true}) {
    final random = Random.secure();
    var chars = lowercaseChars;

    if (mixedCase) {
      chars += uppercaseChars;
    }

    return List.generate(length, (_) => chars[random.nextInt(chars.length)]).join();
  }

  /// 生成数字密码（纯数字PIN）
  ///
  /// [length] 密码长度
  /// 返回生成的密码
  static String generateNumeric({int length = 6}) {
    final random = Random.secure();
    return List.generate(length, (_) => digitChars[random.nextInt(digitChars.length)]).join();
  }

  /// 生成强密码（高安全性）
  ///
  /// [length] 密码长度，默认20
  /// 返回生成的强密码
  static String generateStrong({int length = 20}) {
    return generate(
      length: length,
      includeLowercase: true,
      includeUppercase: true,
      includeDigits: true,
      includeSpecial: true,
      excludeAmbiguous: true,
    );
  }

  /// 生成 passphrase（助记词风格的密码）
  ///
  /// [wordCount] 单词数量
  /// [separator] 分隔符
  /// [capitalize] 是否首字母大写
  /// 返回生成的 passphrase
  static String generatePassphrase({
    int wordCount = 4,
    String separator = '-',
    bool capitalize = true,
  }) {
    final random = Random.secure();
    final words = <String>[];

    for (int i = 0; i < wordCount; i++) {
      final word = _commonWords[random.nextInt(_commonWords.length)];
      words.add(capitalize ? _capitalize(word) : word);
    }

    return words.join(separator);
  }

  /// 生成密码组（多个密码）
  ///
  /// [count] 生成数量
  /// [length] 每个密码的长度
  /// 返回密码列表
  static List<String> generateBatch({
    int count = 10,
    int length = 16,
    bool includeLowercase = true,
    bool includeUppercase = true,
    bool includeDigits = true,
    bool includeSpecial = true,
    bool excludeAmbiguous = true,
  }) {
    return List.generate(count, (_) => generate(
      length: length,
      includeLowercase: includeLowercase,
      includeUppercase: includeUppercase,
      includeDigits: includeDigits,
      includeSpecial: includeSpecial,
      excludeAmbiguous: excludeAmbiguous,
    ));
  }

  // ==================== 密码强度评估 ====================

  /// 评估密码强度
  ///
  /// [password] 密码字符串
  /// 返回强度等级：0（极弱）、1（弱）、2（中等）、3（强）、4（极强）
  static int evaluateStrength(String password) {
    if (password.isEmpty) return 0;

    int score = 0;

    // 长度评分
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (password.length >= 16) score++;
    if (password.length >= 20) score++;

    // 字符类型评分
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(password)) score++;

    // 奖励：多种字符类型混合
    final typeCount = _countCharTypes(password);
    if (typeCount >= 3) score++;
    if (typeCount >= 4) score++;

    // 惩罚：重复字符
    if (RegExp(r'(.)\1{2,}').hasMatch(password)) score--;

    // 惩罚：连续字符
    if (_hasSequentialChars(password)) score--;

    // 惩罚：是常用密码
    if (isCommonPassword(password)) score = score ~/ 2;

    // 归一化到 0-4
    return score.clamp(0, 4);
  }

  /// 获取密码强度描述
  ///
  /// [password] 密码字符串
  /// 返回强度描述
  static String getStrengthLabel(String password) {
    final strength = evaluateStrength(password);
    switch (strength) {
      case 0:
        return '极弱';
      case 1:
        return '弱';
      case 2:
        return '中等';
      case 3:
        return '强';
      case 4:
        return '极强';
      default:
        return '未知';
    }
  }

  /// 获取密码强度颜色值（0xFFFFFF格式）
  ///
  /// [password] 密码字符串
  /// 返回颜色值
  static int getStrengthColor(String password) {
    final strength = evaluateStrength(password);
    switch (strength) {
      case 0:
        return 0xFFE53935; // 红色
      case 1:
        return 0xFFFF9800; // 橙色
      case 2:
        return 0xFFFFC107; // 黄色
      case 3:
        return 0xFF8BC34A; // 浅绿
      case 4:
        return 0xFF4CAF50; // 绿色
      default:
        return 0xFF9E9E9E; // 灰色
    }
  }

  /// 获取密码强度百分比
  ///
  /// [password] 密码字符串
  /// 返回 0-100 的百分比
  static int getStrengthPercent(String password) {
    return (evaluateStrength(password) / 4 * 100).round();
  }

  // ==================== 密码验证 ====================

  /// 检查是否为常用密码
  ///
  /// [password] 密码字符串
  /// 返回是否为常用密码
  static bool isCommonPassword(String password) {
    return commonPasswords.contains(password.toLowerCase());
  }

  /// 检查密码是否包含常见模式
  ///
  /// [password] 密码字符串
  /// 返回是否包含常见模式
  static bool hasCommonPattern(String password) {
    final lower = password.toLowerCase();

    // 检查键盘序列
    const keyboardPatterns = [
      'qwerty', 'asdfgh', 'zxcvbn', '123456', '098765',
      'qazwsx', '!@#\$%', 'password',
    ];

    for (final pattern in keyboardPatterns) {
      if (lower.contains(pattern)) return true;
    }

    return false;
  }

  /// 检查密码是否有重复字符
  ///
  /// [password] 密码字符串
  /// [maxRepeat] 最大允许重复次数
  /// 返回是否有过多重复
  static bool hasExcessiveRepeat(String password, {int maxRepeat = 2}) {
    return RegExp('(.)\\1{$maxRepeat,}').hasMatch(password);
  }

  /// 检查密码是否有连续字符
  ///
  /// [password] 密码字符串
  /// [length] 连续字符长度阈值
  /// 返回是否有连续字符
  static bool hasSequentialChars(String password, {int length = 3}) {
    return _hasSequentialChars(password, length: length);
  }

  // ==================== 密码建议 ====================

  /// 生成密码改进建议
  ///
  /// [password] 密码字符串
  /// 返回建议列表
  static List<String> getSuggestions(String password) {
    final suggestions = <String>[];

    if (password.length < 8) {
      suggestions.add('密码长度至少8位');
    }
    if (password.length < 12) {
      suggestions.add('建议使用12位以上的密码');
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      suggestions.add('添加小写字母');
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      suggestions.add('添加大写字母');
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      suggestions.add('添加数字');
    }
    if (!RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(password)) {
      suggestions.add('添加特殊字符');
    }
    if (isCommonPassword(password)) {
      suggestions.add('请勿使用常见密码');
    }
    if (hasCommonPattern(password)) {
      suggestions.add('避免使用键盘序列或常见模式');
    }
    if (hasExcessiveRepeat(password)) {
      suggestions.add('避免重复字符');
    }
    if (hasSequentialChars(password)) {
      suggestions.add('避免使用连续字符');
    }

    return suggestions;
  }

  /// 生成强密码建议
  ///
  /// 返回推荐的强密码
  static String generateStrongSuggestion() {
    return generateStrong();
  }

  // ==================== 辅助函数 ====================

  /// 移除易混淆字符
  static String _removeAmbiguous(String chars) {
    var result = chars;
    for (final char in ambiguousChars.split('')) {
      result = result.replaceAll(char, '');
    }
    return result;
  }

  /// 随机获取字符
  static String _randomChar(String chars) {
    final random = Random.secure();
    return chars[random.nextInt(chars.length)];
  }

  /// 首字母大写
  static String _capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }

  /// 计算密码中的字符类型数量
  static int _countCharTypes(String password) {
    int count = 0;
    if (RegExp(r'[a-z]').hasMatch(password)) count++;
    if (RegExp(r'[A-Z]').hasMatch(password)) count++;
    if (RegExp(r'[0-9]').hasMatch(password)) count++;
    if (RegExp(r'[!@#$%^&*()_+\-=\[\]{}|;:,.<>?]').hasMatch(password)) count++;
    return count;
  }

  /// 检查是否有连续字符
  static bool _hasSequentialChars(String password, {int length = 3}) {
    if (password.length < length) return false;

    // 检查字母连续
    for (int i = 0; i <= password.length - length; i++) {
      final sub = password.substring(i, i + length).toLowerCase();
      if (_isAlphabeticalSequence(sub)) return true;
    }

    // 检查数字连续
    for (int i = 0; i <= password.length - length; i++) {
      final sub = password.substring(i, i + length);
      if (RegExp(r'^\d+$').hasMatch(sub)) {
        if (_isNumericalSequence(sub)) return true;
      }
    }

    return false;
  }

  /// 检查是否为字母顺序序列
  static bool _isAlphabeticalSequence(String str) {
    for (int i = 1; i < str.length; i++) {
      final prev = str.codeUnitAt(i - 1);
      final curr = str.codeUnitAt(i);
      if (curr - prev != 1 && curr - prev != -1) {
        return false;
      }
    }
    return true;
  }

  /// 检查是否为数字顺序序列
  static bool _isNumericalSequence(String str) {
    for (int i = 1; i < str.length; i++) {
      final prev = int.tryParse(str[i - 1]) ?? 0;
      final curr = int.tryParse(str[i]) ?? 0;
      if (curr - prev != 1 && curr - prev != -1) {
        return false;
      }
    }
    return true;
  }

  // ==================== 常用单词列表（用于passphrase） ====================

  static const List<String> _commonWords = [
    'apple', 'banana', 'cherry', 'dragon', 'eagle', 'forest',
    'garden', 'hammer', 'island', 'jungle', 'kitchen', 'lemon',
    'mountain', 'nature', 'ocean', 'panda', 'queen', 'river',
    'sunset', 'thunder', 'umbrella', 'valley', 'winter', 'yellow',
    'zebra', 'anchor', 'bridge', 'castle', 'diamond', 'ember',
    'falcon', 'glacier', 'harbor', 'igloo', 'jasmine', 'kite',
    'laptop', 'marble', 'nebula', 'orange', 'palace', 'quartz',
    'rocket', 'silver', 'tower', 'unicorn', 'violet', 'window',
    'crystal', 'falcon', 'giraffe', 'horizon', 'ivory', 'jungle',
    'komodo', 'lantern', 'mango', 'nectar', 'olive', 'pepper',
    'rabbit', 'safari', 'temple', 'utopia', 'velvet', 'willow',
  ];
}
