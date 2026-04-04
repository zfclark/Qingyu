/// Encoding Utility
/// Author: ZF_Clark
/// Description: Provides Base64 and URL encoding/decoding utilities. Supports UTF-8, standard Base64, and URL-safe Base64. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

import 'dart:convert';

/// 编码工具类
/// 提供Base64和URL编码解码功能
class EncodingUtil {
  // ==================== Base64 编码解码 ====================

  /// Base64编码（UTF-8）
  ///
  /// [text] 输入文本
  /// 返回Base64编码字符串，失败返回null
  static String? encodeBase64(String text) {
    if (text.isEmpty) return '';
    try {
      return base64Encode(utf8.encode(text));
    } catch (e) {
      return null;
    }
  }

  /// Base64解码（UTF-8）
  ///
  /// [encodedText] Base64编码的文本
  /// 返回解码后的字符串，失败返回null
  static String? decodeBase64(String encodedText) {
    if (encodedText.isEmpty) return '';
    try {
      return utf8.decode(base64Decode(encodedText));
    } catch (e) {
      return null;
    }
  }

  /// URL安全的Base64编码
  ///
  /// [text] 输入文本
  /// 返回URL安全Base64编码字符串
  static String? encodeBase64Url(String text) {
    if (text.isEmpty) return '';
    try {
      return base64UrlEncode(utf8.encode(text));
    } catch (e) {
      return null;
    }
  }

  /// URL安全的Base64解码
  ///
  /// [encodedText] URL安全Base64编码的文本
  /// 返回解码后的字符串，失败返回null
  static String? decodeBase64Url(String encodedText) {
    if (encodedText.isEmpty) return '';
    try {
      return utf8.decode(base64Url.decode(encodedText));
    } catch (e) {
      return null;
    }
  }

  /// Base64编码（无Padding）
  ///
  /// [text] 输入文本
  /// 返回无Padding的Base64字符串
  static String? encodeBase64NoPadding(String text) {
    final encoded = encodeBase64(text);
    if (encoded == null) return null;
    return encoded.replaceAll('=', '');
  }

  /// 添加Base64 Padding
  ///
  /// [text] 无Padding的Base64字符串
  /// 返回带Padding的Base64字符串
  static String? addBase64Padding(String text) {
    if (text.isEmpty) return '';
    final padding = (4 - text.length % 4) % 4;
    return text + '=' * padding;
  }

  /// 验证Base64字符串
  ///
  /// [text] 待验证的字符串
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

  // ==================== URL 编码解码 ====================

  /// URL编码
  ///
  /// [text] 输入文本
  /// 返回URL编码字符串
  static String encodeUrl(String text) {
    if (text.isEmpty) return '';
    try {
      return Uri.encodeComponent(text);
    } catch (e) {
      return text;
    }
  }

  /// URL解码
  ///
  /// [encodedText] URL编码的文本
  /// 返回解码后的字符串，失败返回原文
  static String decodeUrl(String encodedText) {
    if (encodedText.isEmpty) return '';
    try {
      return Uri.decodeComponent(encodedText);
    } catch (e) {
      return encodedText;
    }
  }

  /// URL编码（完整版，包含query参数）
  ///
  /// [text] 输入文本
  /// 返回URL编码字符串
  static String encodeUrlFull(String text) {
    if (text.isEmpty) return '';
    try {
      return Uri.encodeFull(text);
    } catch (e) {
      return text;
    }
  }

  /// URL解码（完整版）
  ///
  /// [encodedText] URL编码的文本
  /// 返回解码后的字符串
  static String decodeUrlFull(String encodedText) {
    if (encodedText.isEmpty) return '';
    try {
      return Uri.decodeFull(encodedText);
    } catch (e) {
      return encodedText;
    }
  }

  /// 编码URL查询参数
  ///
  /// [params] 键值对Map
  /// 返回编码后的查询参数字符串
  static String encodeQueryParameters(Map<String, String> params) {
    if (params.isEmpty) return '';
    try {
      return Uri(queryParameters: params).toString().split('?').length > 1
          ? '?${Uri(queryParameters: params).query}'
          : '';
    } catch (e) {
      return '';
    }
  }

  /// 解析URL查询参数
  ///
  /// [url] URL字符串
  /// 返回键值对Map
  static Map<String, String> parseQueryParameters(String url) {
    if (url.isEmpty) return {};
    try {
      final uri = Uri.parse(url);
      return uri.queryParameters;
    } catch (e) {
      return {};
    }
  }

  // ==================== 组合操作 ====================

  /// 先Base64再URL编码
  ///
  /// [text] 输入文本
  /// 返回双重编码字符串
  static String? encodeBase64ThenUrl(String text) {
    final base64 = encodeBase64(text);
    if (base64 == null) return null;
    return encodeUrl(base64);
  }

  /// 先URL解码再Base64解码
  ///
  /// [encodedText] 双重编码的文本
  /// 返回解码后的字符串
  static String? decodeUrlThenBase64(String encodedText) {
    final urlDecoded = decodeUrl(encodedText);
    return decodeBase64(urlDecoded);
  }

  // ==================== HTML编码 ====================

  /// HTML实体编码
  ///
  /// [text] 输入文本
  /// 返回HTML实体编码字符串
  static String encodeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;')
        .replaceAll(' ', '&nbsp;');
  }

  /// HTML实体解码
  ///
  /// [encodedText] HTML实体编码的文本
  /// 返回解码后的字符串
  static String decodeHtml(String encodedText) {
    return encodedText
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&#39;', "'")
        .replaceAll('&quot;', '"')
        .replaceAll('&gt;', '>')
        .replaceAll('&lt;', '<')
        .replaceAll('&amp;', '&');
  }

  /// HTML转义检测
  ///
  /// [text] 输入文本
  /// 返回是否包含HTML实体
  static bool containsHtmlEntities(String text) {
    return text.contains('&') && text.contains(';');
  }
}
