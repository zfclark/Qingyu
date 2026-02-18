/// Hash Utility
/// Author: ZF_Clark
/// Description: Provides hash calculation functionality for multiple algorithms including SHA1, SHA256, SHA512, and MD5. Supports both text and file hashing. Pure utility class without UI dependencies.
/// Last Modified: 2026/02/09
library;

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

/// 哈希算法类型枚举
enum HashAlgorithm { sha1, sha256, sha512, md5 }

/// 哈希工具类
/// 提供计算功能
class HashUtil {
  /// 支持的算法名称列表
  static const List<String> supportedAlgorithms = [
    'SHA1',
    'SHA256',
    'SHA512',
    'MD5',
  ];

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

  // ==================== 文件哈希计算 ====================

  /// 计算文件的哈希值
  ///
  /// [file] 要计算哈希的文件
  /// [algorithm] 算法名称，可选值：SHA1, SHA256, SHA512, MD5
  /// 返回计算后的哈希字符串
  static Future<String> calculateFileHash(File file, String algorithm) async {
    if (!await file.exists()) return '';

    final bytes = await file.readAsBytes();
    return _calculateHashFromBytes(bytes, algorithm);
  }

  /// 从字节数组计算哈希值
  ///
  /// [bytes] 字节数组
  /// [algorithm] 算法名称
  /// 返回计算后的哈希字符串
  static String _calculateHashFromBytes(Uint8List bytes, String algorithm) {
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

  /// 分块计算文件哈希（适用于大文件）
  ///
  /// [file] 要计算哈希的文件
  /// [algorithm] 算法名称
  /// [chunkSize] 每次读取的块大小（默认 64KB）
  /// [onProgress] 进度回调函数，参数为进度百分比（0-100）
  /// 返回计算后的哈希字符串
  static Future<String> calculateFileHashChunked(
    File file,
    String algorithm, {
    int chunkSize = 64 * 1024, // 64KB
    void Function(int progress)? onProgress,
  }) async {
    if (!await file.exists()) return '';

    final fileLength = await file.length();
    int bytesRead = 0;

    // 创建哈希转换器
    late final Hash hasher;
    switch (algorithm.toUpperCase()) {
      case 'SHA1':
        hasher = sha1;
        break;
      case 'SHA256':
        hasher = sha256;
        break;
      case 'SHA512':
        hasher = sha512;
        break;
      case 'MD5':
        hasher = md5;
        break;
      default:
        hasher = sha256;
    }

    // 创建输出累积器
    final output = AccumulatorSink<Digest>();
    final input = hasher.startChunkedConversion(output);

    // 分块读取文件
    final stream = file.openRead();
    await for (final chunk in stream) {
      input.add(chunk);
      bytesRead += chunk.length;

      // 报告进度
      if (onProgress != null && fileLength > 0) {
        final progress = (bytesRead / fileLength * 100).toInt();
        onProgress(progress);
      }
    }

    input.close();
    final digest = output.events.single;

    return digest.toString();
  }

  /// 从字节数组计算哈希值（支持进度回调）
  ///
  /// [bytes] 要计算哈希的字节数组
  /// [algorithm] 算法名称
  /// [chunkSize] 每次处理的块大小（默认 64KB）
  /// [onProgress] 进度回调函数，参数为进度百分比（0-100）
  /// 返回计算后的哈希字符串
  static String calculateHashFromBytes(
    Uint8List bytes,
    String algorithm, {
    int chunkSize = 64 * 1024, // 64KB
    void Function(int progress)? onProgress,
  }) {
    if (bytes.isEmpty) return '';

    final bytesLength = bytes.length;
    int bytesProcessed = 0;

    // 创建哈希转换器
    late final Hash hasher;
    switch (algorithm.toUpperCase()) {
      case 'SHA1':
        hasher = sha1;
        break;
      case 'SHA256':
        hasher = sha256;
        break;
      case 'SHA512':
        hasher = sha512;
        break;
      case 'MD5':
        hasher = md5;
        break;
      default:
        hasher = sha256;
    }

    // 创建输出累积器
    final output = AccumulatorSink<Digest>();
    final input = hasher.startChunkedConversion(output);

    // 分块处理字节数组
    int start = 0;
    while (start < bytesLength) {
      final end = start + chunkSize;
      final chunk = bytes.sublist(start, end > bytesLength ? bytesLength : end);
      input.add(chunk);
      bytesProcessed += chunk.length;

      // 报告进度
      if (onProgress != null && bytesLength > 0) {
        final progress = (bytesProcessed / bytesLength * 100).toInt();
        onProgress(progress);
      }

      start = end;
    }

    input.close();
    final digest = output.events.single;

    return digest.toString();
  }

  /// 计算文件SHA256哈希（快捷方法）
  ///
  /// [file] 要计算哈希的文件
  /// 返回SHA256哈希字符串
  static Future<String> calculateFileSHA256(File file) {
    return calculateFileHash(file, 'SHA256');
  }

  /// 计算文件MD5哈希（快捷方法）
  ///
  /// [file] 要计算哈希的文件
  /// 返回MD5哈希字符串
  static Future<String> calculateFileMD5(File file) {
    return calculateFileHash(file, 'MD5');
  }

  /// 验证文件哈希值是否匹配
  ///
  /// [file] 要验证的文件
  /// [expectedHash] 期望的哈希值
  /// [algorithm] 使用的算法
  /// 返回是否匹配
  static Future<bool> verifyFileHash(
    File file,
    String expectedHash,
    String algorithm,
  ) async {
    final actualHash = await calculateFileHash(file, algorithm);
    return actualHash.toLowerCase() == expectedHash.toLowerCase();
  }

  /// 格式化文件大小
  ///
  /// [bytes] 字节数
  /// 返回格式化后的字符串（如：1.5 MB）
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
