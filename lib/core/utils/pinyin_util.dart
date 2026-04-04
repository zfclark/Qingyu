/// Pinyin Utility
/// Author: ZF_Clark
/// Description: Provides Chinese pinyin conversion utilities. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

/// 中文拼音工具类
/// 提供汉字转拼音功能
class PinyinUtil {
  /// 拼音映射表（简化版）
  static const Map<String, String> _pinyinMap = {
    '啊': 'a', '八': 'ba', '擦': 'ca', '大': 'da', '饿': 'e',
    '发': 'fa', '噶': 'ga', '哈': 'ha', '击': 'ji', '科': 'ke',
    '了': 'le', '妈': 'ma', '那': 'na', '哦': 'o', '怕': 'pa',
    '七': 'qi', '然': 'ran', '三': 'san', '他': 'ta', '五': 'wu',
    '西': 'xi', '一': 'yi', '在': 'zai', '中': 'zhong',
    // 更多常用字...
  };

  /// 汉字转拼音
  ///
  /// [text] 中文文本
  /// [spaceBetween] 是否在每个字之间加空格
  /// 返回拼音字符串
  static String convert(String text, {bool spaceBetween = false}) {
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final pinyin = _getPinyin(char);
      
      if (pinyin != null) {
        buffer.write(pinyin);
      } else {
        buffer.write(char);
      }
      
      if (spaceBetween && i < text.length - 1) {
        buffer.write(' ');
      }
    }
    
    return buffer.toString();
  }

  /// 获取单个汉字的拼音
  static String? _getPinyin(String char) {
    // 简单实现，实际需要完整拼音库
    return _pinyinMap[char];
  }

  /// 获取首字母
  ///
  /// [text] 中文文本
  /// 返回首字母缩写
  static String getInitials(String text) {
    final pinyin = convert(text);
    if (pinyin.isEmpty) return '';
    
    final initials = StringBuffer();
    final words = pinyin.split(' ');
    
    for (final word in words) {
      if (word.isNotEmpty) {
        initials.write(word[0].toUpperCase());
      }
    }
    
    return initials.toString();
  }

  /// 判断是否为汉字
  ///
  /// [char] 字符
  /// 返回是否为汉字
  static bool isChinese(String char) {
    if (char.isEmpty) return false;
    final code = char.codeUnitAt(0);
    return code >= 0x4E00 && code <= 0x9FA5;
  }

  /// 统计汉字数量
  ///
  /// [text] 文本
  /// 返回汉字数量
  static int countChineseChars(String text) {
    int count = 0;
    for (final char in text.split('')) {
      if (isChinese(char)) count++;
    }
    return count;
  }
}