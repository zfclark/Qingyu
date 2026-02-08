
/// Hash Utility
/// Author: ZF_Clark
/// Description: Provides hash calculation functionality for multiple algorithms including SHA1, SHA256, SHA512, and MD5. Pure utility class without UI dependencies.
/// Last Modified: 2026/02/08
library;

import 'dart:convert';
import 'package:crypto/crypto.dart';

/// 哈希算法类型枚举
enum HashAlgorithm {
  sha1,
  sha256,
  sha512,
  md5,
}

/// 哈希工具类
/// 提供纯计算功能，不涉及任何UI操作
class HashUtil {
  /// 支持的算法名称列表
  static const List<String> supportedAlgorithms = ['SHA1', 'SHA256', 'SHA512', 'MD5'];

  /// 根据算法名称计算哈希值
  /// 
  /// [input] 输入文本
  /// [algorithm] 算法名称，可选值：SHA1, SHA256, SHA512, MD5
  /// 返回计算后的哈希字符串
  static String calculateHash(String input, String algorithm) {
    if (input.isEmpty) return '';

    final bytes = utf8.encode(input);

    switch (algorithm.toUpperCase()) {
      case 'SHA1':
        return sha1.convert(bytes).toString();
      case 'SHA256':
        return sha256.convert(bytes).toString();
      case 'SHA512':
        return sha512.convert(bytes).toString();
      case 'MD5':
        return md5.convert(bytes).toString();
      default:
        return sha256.convert(bytes).toString();
    }
  }

  /// 使用枚举类型计算哈希值
  /// 
  /// [input] 输入文本
  /// [algorithm] 哈希算法枚举
  /// 返回计算后的哈希字符串
  static String calculateHashByEnum(String input, HashAlgorithm algorithm) {
    if (input.isEmpty) return '';

    final bytes = utf8.encode(input);

    switch (algorithm) {
      case HashAlgorithm.sha1:
        return sha1.convert(bytes).toString();
      case HashAlgorithm.sha256:
        return sha256.convert(bytes).toString();
      case HashAlgorithm.sha512:
        return sha512.convert(bytes).toString();
      case HashAlgorithm.md5:
        return md5.convert(bytes).toString();
    }
  }

  /// 计算SHA256哈希（快捷方法）
  /// 
  /// [input] 输入文本
  /// 返回SHA256哈希字符串
  static String calculateSHA256(String input) {
    return calculateHash(input, 'SHA256');
  }

  /// 计算MD5哈希（快捷方法）
  /// 
  /// [input] 输入文本
  /// 返回MD5哈希字符串
  static String calculateMD5(String input) {
    return calculateHash(input, 'MD5');
  }

  /// 验证哈希值是否匹配
  /// 
  /// [input] 原始输入文本
  /// [expectedHash] 期望的哈希值
  /// [algorithm] 使用的算法
  /// 返回是否匹配
  static bool verifyHash(String input, String expectedHash, String algorithm) {
    final actualHash = calculateHash(input, algorithm);
    return actualHash.toLowerCase() == expectedHash.toLowerCase();
  }
}
