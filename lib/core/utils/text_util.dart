
/// Text Utility
/// Author: ZF_Clark
/// Description: Provides text manipulation utilities including case conversion, whitespace removal, character statistics, and Base64 encoding/decoding. Pure utility class without UI dependencies.
/// Last Modified: 2026/02/08
library;

import 'dart:convert';

/// 文本大小写类型枚举
enum TextCaseType {
  uppercase,
  lowercase,
  capitalize,
}

/// 文本工具类
/// 提供纯文本处理功能，不涉及任何UI操作
class TextUtil {
  // ==================== 大小写转换 ====================

  /// 转换文本大小写
  ///
  /// [text] 输入文本
  /// [type] 转换类型（大写、小写、首字母大写）
  /// 返回转换后的文本
  static String convertCase(String text, TextCaseType type) {
    if (text.isEmpty) return '';

    switch (type) {
      case TextCaseType.uppercase:
        return text.toUpperCase();
      case TextCaseType.lowercase:
        return text.toLowerCase();
      case TextCaseType.capitalize:
        return _capitalizeWords(text);
    }
  }

  /// 将每个单词的首字母大写
  ///
  /// [text] 输入文本
  /// 返回首字母大写的文本
  static String _capitalizeWords(String text) {
    if (text.isEmpty) return '';

    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  // ==================== 空格和空白处理 ====================

  /// 移除所有空格
  ///
  /// [text] 输入文本
  /// 返回移除空格后的文本
  static String removeSpaces(String text) {
    return text.replaceAll(' ', '');
  }

  /// 移除所有换行符
  ///
  /// [text] 输入文本
  /// 返回移除换行符后的文本
  static String removeNewlines(String text) {
    return text.replaceAll(RegExp(r'[\r\n]'), '');
  }

  /// 移除所有空白字符（包括空格、制表符、换行符等）
  ///
  /// [text] 输入文本
  /// 返回移除所有空白后的文本
  static String removeAllWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s'), '');
  }

  /// 移除多余空白（将多个连续空白合并为单个空格）
  ///
  /// [text] 输入文本
  /// 返回处理后的文本
  static String removeExtraWhitespace(String text) {
    return text.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // ==================== 字符统计 ====================

  /// 统计单词数量
  ///
  /// [text] 输入文本
  /// 返回单词数量
  static int countWords(String text) {
    if (text.trim().isEmpty) return 0;
    // 按空白字符分割并过滤空字符串
    return text
        .trim()
        .split(RegExp(r'\s+'))
        .where((s) => s.isNotEmpty)
        .length;
  }

  /// 统计行数
  ///
  /// [text] 输入文本
  /// 返回行数
  static int countLines(String text) {
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'[\r\n]')).length;
  }

  /// 统计空格数量
  ///
  /// [text] 输入文本
  /// 返回空格数量
  static int countSpaces(String text) {
    return text.split(' ').length - 1;
  }

  /// 统计标点符号数量
  ///
  /// [text] 输入文本
  /// 返回标点符号数量
  static int countPunctuation(String text) {
    // 匹配常见中英文标点符号
    final punctuationPattern = RegExp(r'[\p{P}\p{S}]', unicode: true);
    return punctuationPattern.allMatches(text).length;
  }

  /// 获取详细统计信息
  ///
  /// [text] 输入文本
  /// 返回包含各项统计数据的Map
  static Map<String, int> getDetailedStats(String text) {
    return {
      'characters': text.length,
      'words': countWords(text),
      'lines': countLines(text),
      'spaces': countSpaces(text),
      'punctuation': countPunctuation(text),
    };
  }

  // ==================== Base64编解码 ====================

  /// Base64编码
  ///
  /// [text] 输入文本
  /// 返回Base64编码后的字符串，失败返回null
  static String? encodeBase64(String text) {
    if (text.isEmpty) return '';
    try {
      final bytes = utf8.encode(text);
      return base64Encode(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Base64解码
  ///
  /// [base64Text] Base64编码的文本
  /// 返回解码后的字符串，失败返回null
  static String? decodeBase64(String base64Text) {
    if (base64Text.isEmpty) return '';
    try {
      final bytes = base64Decode(base64Text);
      return utf8.decode(bytes);
    } catch (e) {
      return null;
    }
  }

  /// URL安全的Base64编码
  ///
  /// [text] 输入文本
  /// 返回URL安全的Base64编码字符串
  static String? encodeBase64Url(String text) {
    if (text.isEmpty) return '';
    try {
      final bytes = utf8.encode(text);
      return base64UrlEncode(bytes);
    } catch (e) {
      return null;
    }
  }

  // ==================== 文本清理和格式化 ====================

  /// 移除HTML标签
  ///
  /// [text] 包含HTML的文本
  /// 返回纯文本
  static String removeHtmlTags(String text) {
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// 反转文本
  ///
  /// [text] 输入文本
  /// 返回反转后的文本
  static String reverse(String text) {
    return text.split('').reversed.join();
  }

  /// 检查是否为有效的Base64字符串
  ///
  /// [text] 待检查的文本
  /// 返回是否为有效的Base64
  static bool isValidBase64(String text) {
    if (text.isEmpty) return false;
    try {
      base64Decode(text);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 计算文本的字节长度（UTF-8编码）
  ///
  /// [text] 输入文本
  /// 返回字节长度
  static int getByteLength(String text) {
    return utf8.encode(text).length;
  }
}