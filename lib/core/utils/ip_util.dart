/// IP Utility
/// Author: ZF_Clark
/// Description: Provides IP address parsing, validation, and classification utilities. Supports IPv4 and IPv6 format detection, private/public range checking.
/// Last Modified: 2026/05/24
library;

/// IP 地址工具类
/// 提供 IPv4/IPv6 地址的验证、解析和分类功能
class IpUtil {
  /// 验证 IPv4 地址格式
  ///
  /// [address] IPv4 地址字符串
  /// 返回是否为有效的 IPv4 地址
  static bool isValidIPv4(String address) {
    final parts = address.split('.');
    if (parts.length != 4) return false;
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) return false;
      if (part.length > 1 && part.startsWith('0')) return false;
    }
    return true;
  }

  /// 验证 IPv6 地址格式
  ///
  /// [address] IPv6 地址字符串
  /// 返回是否为有效的 IPv6 地址
  static bool isValidIPv6(String address) {
    if (address.contains('::')) {
      final parts = address.split('::');
      if (parts.length > 2) return false;
      final left = parts[0].isEmpty ? <String>[] : parts[0].split(':');
      final right = parts.length > 1 && parts[1].isNotEmpty
          ? parts[1].split(':')
          : <String>[];
      if (left.length + right.length > 7) return false;
      for (final p in [...left, ...right]) {
        if (p.isEmpty) return false;
        final val = int.tryParse(p, radix: 16);
        if (val == null || val < 0 || val > 0xFFFF) return false;
      }
      return true;
    }
    final parts = address.split(':');
    if (parts.length != 8) return false;
    for (final part in parts) {
      if (part.isEmpty) return false;
      final val = int.tryParse(part, radix: 16);
      if (val == null || val < 0 || val > 0xFFFF) return false;
    }
    return true;
  }

  /// 验证 IP 地址格式（IPv4 或 IPv6）
  ///
  /// [address] IP 地址字符串
  /// 返回是否为有效的 IP 地址
  static bool isValidIP(String address) {
    return isValidIPv4(address) || isValidIPv6(address);
  }

  /// 判断是否为私有 IPv4 地址
  ///
  /// [address] IPv4 地址字符串
  /// 返回是否为私有地址（RFC 1918）
  static bool isPrivateIPv4(String address) {
    if (!isValidIPv4(address)) return false;
    final parts = address.split('.').map(int.parse).toList();
    // 10.0.0.0/8
    if (parts[0] == 10) return true;
    // 172.16.0.0/12
    if (parts[0] == 172 && parts[1] >= 16 && parts[1] <= 31) return true;
    // 192.168.0.0/16
    if (parts[0] == 192 && parts[1] == 168) return true;
    return false;
  }

  /// 判断是否为回环地址
  ///
  /// [address] IP 地址字符串
  /// 返回是否为回环地址
  static bool isLoopback(String address) {
    if (isValidIPv4(address)) {
      return address.startsWith('127.');
    }
    if (isValidIPv6(address)) {
      return address == '::1' || address == '0:0:0:0:0:0:0:1';
    }
    return false;
  }

  /// 判断是否为链路本地地址
  ///
  /// [address] IP 地址字符串
  /// 返回是否为链路本地地址
  static bool isLinkLocal(String address) {
    if (isValidIPv4(address)) {
      final parts = address.split('.').map(int.parse).toList();
      return parts[0] == 169 && parts[1] == 254;
    }
    if (isValidIPv6(address)) {
      final expanded = expandIPv6(address).toLowerCase();
      return expanded.startsWith('fe80');
    }
    return false;
  }

  /// 获取 IPv4 地址分类
  ///
  /// [address] IPv4 地址字符串
  /// 返回地址类别（A/B/C/D/E）
  static String getIPv4Class(String address) {
    if (!isValidIPv4(address)) return 'Invalid';
    final first = int.parse(address.split('.')[0]);
    if (first >= 0 && first <= 127) return 'A';
    if (first >= 128 && first <= 191) return 'B';
    if (first >= 192 && first <= 223) return 'C';
    if (first >= 224 && first <= 239) return 'D';
    return 'E';
  }

  /// 解析 IPv4 地址
  ///
  /// [address] IPv4 地址字符串
  /// 返回包含地址详细信息的 Map，无效地址返回 null
  static Map<String, dynamic>? parseIPv4(String address) {
    if (!isValidIPv4(address)) return null;
    return {
      'address': address,
      'isValid': true,
      'type': 'IPv4',
      'isPrivate': isPrivateIPv4(address),
      'isLoopback': isLoopback(address),
      'isLinkLocal': isLinkLocal(address),
      'classType': getIPv4Class(address),
    };
  }

  /// 展开 IPv6 地址的缩写形式
  ///
  /// [address] IPv6 地址字符串
  /// 返回完整的 IPv6 地址
  static String expandIPv6(String address) {
    if (!isValidIPv6(address)) return address;
    if (!address.contains('::')) {
      return address.split(':').map((g) => g.padLeft(4, '0')).join(':');
    }
    final parts = address.split('::');
    final left = parts[0].isEmpty ? <String>[] : parts[0].split(':');
    final right = parts.length > 1 && parts[1].isNotEmpty
        ? parts[1].split(':')
        : <String>[];
    final missing = 8 - left.length - right.length;
    final expanded = [
      ...left,
      ...List.filled(missing, '0000'),
      ...right,
    ];
    return expanded.map((g) => g.padLeft(4, '0')).join(':');
  }

  /// 解析 IPv6 地址
  ///
  /// [address] IPv6 地址字符串
  /// 返回包含地址详细信息的 Map，无效地址返回 null
  static Map<String, dynamic>? parseIPv6(String address) {
    if (!isValidIPv6(address)) return null;
    final expanded = expandIPv6(address);
    final groups = expanded.split(':');
    final isAllZeros = groups.every((g) => g == '0000');
    return {
      'address': address,
      'isValid': true,
      'type': 'IPv6',
      'isPrivate': expanded.startsWith('fc00') || expanded.startsWith('fd00'),
      'isLoopback': isLoopback(address),
      'isLinkLocal': isLinkLocal(address),
      'fullForm': expanded,
      'isAllZeros': isAllZeros,
    };
  }

  /// 解析 IP 地址（自动识别 IPv4/IPv6）
  ///
  /// [address] IP 地址字符串
  /// 返回包含地址详细信息的 Map，无效地址返回 null
  static Map<String, dynamic>? parse(String address) {
    if (isValidIPv4(address)) return parseIPv4(address);
    if (isValidIPv6(address)) return parseIPv6(address);
    return null;
  }

  /// 获取地址范围描述
  ///
  /// [address] IP 地址字符串
  /// 返回地址范围的中文描述
  static String getScopeDescription(String address) {
    if (isLoopback(address)) return '回环地址';
    if (isLinkLocal(address)) return '链路本地';
    if (isValidIPv4(address) && isPrivateIPv4(address)) return '私有地址';
    if (isValidIPv6(address)) {
      final expanded = expandIPv6(address).toLowerCase();
      if (expanded.startsWith('fc00') || expanded.startsWith('fd00')) {
        return '私有地址';
      }
    }
    return '公网地址';
  }
}
