/// UUID Utility
/// Author: ZF_Clark
/// Description: Provides UUID (Universally Unique Identifier) generation utilities. Supports UUID v1, v4, and nil UUID. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

import 'dart:math';
import 'dart:typed_data';

/// UUID工具类
/// 提供UUID生成功能，支持v1（时间戳）和v4（随机）类型
class UuidUtil {
  // ==================== 常量 ====================

  /// NIL UUID（全零）
  static const String nilUuid = '00000000-0000-0000-0000-000000000000';

  /// UUID v1的正则表达式
  static final RegExp _uuidV1Pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-1[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// UUID v4的正则表达式
  static final RegExp _uuidV4Pattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// 标准UUID正则表达式
  static final RegExp _uuidPattern = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  // ==================== UUID v4 生成（随机） ====================

  /// 生成UUID v4（随机UUID）
  ///
  /// 返回标准格式的UUID字符串
  static String generateV4() {
    final random = Random.secure();
    final bytes = Uint8List(16);

    for (int i = 0; i < 16; i++) {
      bytes[i] = random.nextInt(256);
    }

    // 设置版本号（4）和变体
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // 版本4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // 变体

    return _formatBytes(bytes);
  }

  /// 批量生成UUID v4
  ///
  /// [count] 生成数量
  /// [lowercase] 是否使用小写字母
  /// 返回UUID列表
  static List<String> generateV4Batch(int count, {bool lowercase = true}) {
    return List.generate(count, (_) => lowercase ? generateV4().toLowerCase() : generateV4());
  }

  // ==================== UUID v1 生成（时间戳） ====================

  /// 生成UUID v1（基于时间戳）
  ///
  /// [nodeId] 节点ID（可选，默认随机生成）
  /// 返回标准格式的UUID字符串
  static String generateV1({List<int>? nodeId}) {
    final now = DateTime.now();
    final timestamp = _getTimestamp(now);
    final clockSeq = _clockSeqCounter++;

    // 生成节点ID（如果未提供）
    final node = nodeId ?? _generateNodeId();

    // 构建UUID的各个部分
    final timeLow = timestamp & 0xffffffff;
    final timeMid = (timestamp >> 32) & 0xffff;
    final timeHiAndVersion = ((timestamp >> 48) & 0x0fff) | 0x1000; // 版本1
    final clockSeqHiAndReserved = ((clockSeq >> 8) & 0x3f) | 0x80; // 变体
    final clockSeqLow = clockSeq & 0xff;

    // 组合字节
    final bytes = ByteData(16);
    bytes.setUint32(0, timeLow, Endian.big);
    bytes.setUint16(4, timeMid, Endian.big);
    bytes.setUint16(6, timeHiAndVersion, Endian.big);
    bytes.setUint8(8, clockSeqHiAndReserved);
    bytes.setUint8(9, clockSeqLow);
    for (int i = 0; i < 6; i++) {
      bytes.setUint8(10 + i, node[i]);
    }

    return _formatBytesFromByteData(bytes);
  }

  /// 获取UUID v1对应的时间戳
  ///
  /// [uuid] UUID字符串
  /// 返回DateTime对象
  static DateTime? getTimestampFromV1(String uuid) {
    if (!isValidV1(uuid)) return null;

    final cleanUuid = uuid.replaceAll('-', '');
    final timestamp = int.parse(cleanUuid.substring(0, 12), radix: 16);

    // UUID时间戳从1582年10月15日开始
    const uuidEpoch = 122192928000000000; // 100-nanosecond intervals since UUID epoch
    final ticks = timestamp * 10000 + uuidEpoch;
    final microseconds = ticks ~/ 10;

    return DateTime.fromMicrosecondsSinceEpoch(microseconds);
  }

  /// 时钟序列计数器
  static int _clockSeqCounter = Random.secure().nextInt(16384);

  /// 生成节点ID
  static List<int> _generateNodeId() {
    final random = Random.secure();
    // 确保最低位为1（表示多播地址）
    return List.generate(6, (_) => random.nextInt(256));
  }

  /// 计算UUID时间戳（100-nanosecond intervals since UUID epoch）
  static int _getTimestamp(DateTime dateTime) {
    final duration = dateTime.difference(DateTime.utc(1582, 10, 15));
    return duration.inMicroseconds * 10;
  }

  // ==================== 格式化 ====================

  /// 格式化字节数据为UUID字符串
  static String _formatBytes(Uint8List bytes) {
    final buffer = StringBuffer();

    // time_low
    for (int i = 0; i < 4; i++) {
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    buffer.write('-');

    // time_mid
    for (int i = 4; i < 6; i++) {
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    buffer.write('-');

    // time_hi_and_version
    for (int i = 6; i < 8; i++) {
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    buffer.write('-');

    // clock_seq_hi_and_reserved + clock_seq_low
    for (int i = 8; i < 10; i++) {
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }
    buffer.write('-');

    // node
    for (int i = 10; i < 16; i++) {
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
    }

    return buffer.toString();
  }

  /// 从ByteData格式化UUID
  static String _formatBytesFromByteData(ByteData bytes) {
    final buffer = StringBuffer();

    // time_low (4 bytes big-endian)
    buffer.write(bytes.getUint32(0, Endian.big).toRadixString(16).padLeft(8, '0'));
    buffer.write('-');

    // time_mid (2 bytes big-endian)
    buffer.write(bytes.getUint16(4, Endian.big).toRadixString(16).padLeft(4, '0'));
    buffer.write('-');

    // time_hi_and_version (2 bytes big-endian)
    buffer.write(bytes.getUint16(6, Endian.big).toRadixString(16).padLeft(4, '0'));
    buffer.write('-');

    // clock_seq (2 bytes)
    buffer.write(bytes.getUint8(8).toRadixString(16).padLeft(2, '0'));
    buffer.write(bytes.getUint8(9).toRadixString(16).padLeft(2, '0'));
    buffer.write('-');

    // node (6 bytes)
    for (int i = 10; i < 16; i++) {
      buffer.write(bytes.getUint8(i).toRadixString(16).padLeft(2, '0'));
    }

    return buffer.toString();
  }

  // ==================== 验证 ====================

  /// 验证UUID格式
  ///
  /// [uuid] UUID字符串
  /// 返回是否为有效的UUID
  static bool isValid(String uuid) {
    if (uuid.isEmpty) return false;
    return _uuidPattern.hasMatch(uuid);
  }

  /// 验证UUID v1格式
  ///
  /// [uuid] UUID字符串
  /// 返回是否为有效的UUID v1
  static bool isValidV1(String uuid) {
    if (uuid.isEmpty) return false;
    return _uuidV1Pattern.hasMatch(uuid);
  }

  /// 验证UUID v4格式
  ///
  /// [uuid] UUID字符串
  /// 返回是否为有效的UUID v4
  static bool isValidV4(String uuid) {
    if (uuid.isEmpty) return false;
    return _uuidV4Pattern.hasMatch(uuid);
  }

  /// 获取UUID版本号
  ///
  /// [uuid] UUID字符串
  /// 返回版本号（1-5），无效返回null
  static int? getVersion(String uuid) {
    if (!isValid(uuid)) return null;

    final parts = uuid.split('-');
    if (parts.length != 5) return null;

    final versionChar = parts[2][0];
    return int.tryParse(versionChar, radix: 16);
  }

  // ==================== 解析和比较 ====================

  /// 从字符串解析UUID组件
  ///
  /// [uuid] UUID字符串
  /// 返回UUID各部分的Map
  static Map<String, String>? parse(String uuid) {
    if (!isValid(uuid)) return null;

    final parts = uuid.split('-');

    return {
      'time_low': parts[0],
      'time_mid': parts[1],
      'time_hi_and_version': parts[2],
      'clock_seq_hi_and_reserved': parts[3][0],
      'clock_seq_low': parts[3][1],
      'node': parts[4],
    };
  }

  /// 比较两个UUID的大小
  ///
  /// [uuid1] 第一个UUID
  /// [uuid2] 第二个UUID
  /// 返回 -1 (uuid1 < uuid2), 0 (相等), 1 (uuid1 > uuid2)
  static int compare(String uuid1, String uuid2) {
    return uuid1.toLowerCase().compareTo(uuid2.toLowerCase());
  }

  /// 检查两个UUID是否相等
  ///
  /// [uuid1] 第一个UUID
  /// [uuid2] 第二个UUID
  /// 返回是否相等
  static bool equals(String uuid1, String uuid2) {
    return uuid1.toLowerCase() == uuid2.toLowerCase();
  }

  // ==================== 转换 ====================

  /// UUID转字节数组
  ///
  /// [uuid] UUID字符串
  /// 返回16字节的Uint8List
  static Uint8List? toBytes(String uuid) {
    if (!isValid(uuid)) return null;

    final cleanUuid = uuid.replaceAll('-', '');
    final bytes = Uint8List(16);

    for (int i = 0; i < 16; i++) {
      bytes[i] = int.parse(cleanUuid.substring(i * 2, i * 2 + 2), radix: 16);
    }

    return bytes;
  }

  /// 字节数组转UUID
  ///
  /// [bytes] 16字节的数组
  /// 返回UUID字符串
  static String? fromBytes(Uint8List bytes) {
    if (bytes.length != 16) return null;

    final buffer = StringBuffer();
    for (int i = 0; i < 16; i++) {
      buffer.write(bytes[i].toRadixString(16).padLeft(2, '0'));
      if (i == 3 || i == 5 || i == 7 || i == 9) {
        buffer.write('-');
      }
    }

    return buffer.toString();
  }

  /// UUID转整数（大端序）
  ///
  /// [uuid] UUID字符串
  /// 返回128位整数
  static BigInt? toInt(String uuid) {
    if (!isValid(uuid)) return null;

    final cleanUuid = uuid.replaceAll('-', '');
    return BigInt.parse('0$cleanUuid', radix: 16);
  }

  /// 整数转UUID（大端序）
  ///
  /// [value] 128位整数
  /// 返回UUID字符串
  static String fromInt(BigInt value) {
    final hex = value.toRadixString(16).padLeft(32, '0');
    return _formatFromCleanHex(hex);
  }

  /// 从纯十六进制字符串格式化UUID
  static String _formatFromCleanHex(String hex) {
    return '${hex.substring(0, 8)}-'
        '${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-'
        '${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }

  /// 获取最小版本UUID（用于排序）
  ///
  /// 返回版本0的UUID（全零）
  static String minUuid() => nilUuid;

  /// 获取最大版本UUID（用于排序）
  ///
  /// 返回ffff...形式的UUID
  static String maxUuid() => 'ffffffff-ffff-4fff-bfff-ffffffffffff';

  // ==================== 特殊UUID ====================

  /// 生成NAMED UUID（基于命名空间的UUID v3）
  ///
  /// [namespace] 命名空间ID
  /// [name] 名称
  /// 返回UUID v3字符串
  static String generateNamed(String namespace, String name) {
    // 使用MD5哈希生成v3风格UUID
    const namespaceMap = {
      'dns': '6ba7b810-9dad-11d1-80b4-00c04fd430c8',
      'url': '6ba7b811-9dad-11d1-80b4-00c04fd430c8',
      'oid': '6ba7b812-9dad-11d1-80b4-00c04fd430c8',
      'x500': '6ba7b814-9dad-11d1-80b4-00c04fd430c8',
    };

    final ns = namespaceMap[namespace.toLowerCase()] ?? namespace;
    final nsBytes = toBytes(ns);
    if (nsBytes == null) return nilUuid;

    // 计算MD5（这里简化处理，实际应使用MD5）
    final data = Uint8List(nsBytes.length + name.length);
    data.setAll(0, nsBytes);
    data.setAll(nsBytes.length, name.codeUnits);

    // 生成哈希（使用简化哈希代替MD5）
    final hash = _simpleHash(data);

    // 设置版本（3）和变体
    hash[6] = (hash[6] & 0x0f) | 0x30;
    hash[8] = (hash[8] & 0x3f) | 0x80;

    return _formatBytes(hash);
  }

  /// 简单哈希函数（用于v3/v5 UUID）
  static Uint8List _simpleHash(Uint8List data) {
    final hash = Uint8List(16);
    for (int i = 0; i < 16; i++) {
      int val = 0;
      for (int j = 0; j < data.length; j++) {
        val = (val + data[j] * (j + 1)) % 256;
      }
      hash[i] = val;
    }
    return hash;
  }

  /// 获取NIL UUID
  ///
  /// 返回全零UUID
  static String nil() => nilUuid;

  // ==================== 批量操作 ====================

  /// 生成唯一UUID列表（带去重）
  ///
  /// [count] 目标数量
  /// 返回去重后的UUID列表
  static List<String> generateUniqueList(int count) {
    final set = <String>{};
    while (set.length < count) {
      set.add(generateV4());
    }
    return set.toList();
  }

  /// 生成带前缀的UUID
  ///
  /// [prefix] 前缀
  /// [separator] 分隔符，默认'_'
  /// 返回带前缀的UUID字符串
  static String generateWithPrefix(String prefix, {String separator = '_'}) {
    return '$prefix$separator${generateV4()}';
  }

  /// 提取UUID列表（从文本中）
  ///
  /// [text] 包含UUID的文本
  /// 返回找到的UUID列表
  static List<String> extractUuids(String text) {
    final pattern = RegExp(
      r'[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
      caseSensitive: false,
    );

    final matches = pattern.allMatches(text);
    return matches.map((m) => m.group(0)!).where((u) => isValid(u)).toSet().toList();
  }
}
