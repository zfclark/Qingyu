/// Hash History Model
/// Author: ZF_Clark
/// Description: Represents a single hash calculation record with input text, calculated hash value, algorithm used, and timestamp. Provides methods for converting between model instances and JSON strings for storage purposes.
/// Last Modified: 2026/02/08
library;

/// 哈希历史记录模型类
/// 用于存储和管理哈希计算的历史记录
class HashHistoryModel {
  /// 输入文本
  final String input;

  /// 计算后的哈希值
  final String hash;

  /// 使用的哈希算法
  final String algorithm;

  /// 计算时间戳
  final DateTime timestamp;

  /// 构造函数
  HashHistoryModel({
    required this.input,
    required this.hash,
    required this.algorithm,
    required this.timestamp,
  });

  /// 转换为JSON字符串
  ///
  /// 返回格式：input|hash|algorithm|timestamp
  String toJson() {
    return '$input|$hash|$algorithm|${timestamp.toIso8601String()}';
  }

  /// 从JSON字符串创建实例
  ///
  /// [json] JSON字符串，格式：input|hash|algorithm|timestamp
  /// 返回HashHistoryModel实例
  factory HashHistoryModel.fromJson(String json) {
    final parts = json.split('|');
    return HashHistoryModel(
      input: parts[0],
      hash: parts[1],
      algorithm: parts[2],
      timestamp: DateTime.parse(parts[3]),
    );
  }

  /// 创建副本并修改指定字段
  ///
  /// [input] 新的输入文本
  /// [hash] 新的哈希值
  /// [algorithm] 新的算法
  /// [timestamp] 新的时间戳
  /// 返回新的HashHistoryModel实例
  HashHistoryModel copyWith({
    String? input,
    String? hash,
    String? algorithm,
    DateTime? timestamp,
  }) {
    return HashHistoryModel(
      input: input ?? this.input,
      hash: hash ?? this.hash,
      algorithm: algorithm ?? this.algorithm,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'HashHistoryModel(input: $input, hash: $hash, algorithm: $algorithm, timestamp: $timestamp)';
  }
}
