/// JSON Utility
/// Author: ZF_Clark
/// Description: Provides JSON formatting, validation, and compression utilities. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

import 'dart:convert';

/// JSON工具类
/// 提供JSON格式化、验证、压缩等功能
class JsonUtil {
  // ==================== 格式化 ====================

  /// 格式化JSON字符串（美化输出）
  ///
  /// [jsonString] 输入的JSON字符串
  /// [indent] 缩进空格数，默认2
  /// 返回格式化后的JSON字符串，失败返回null
  static String? format(String jsonString, {int indent = 2}) {
    if (jsonString.isEmpty) return null;

    try {
      final decoded = json.decode(jsonString);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (e) {
      return null;
    }
  }

  /// 压缩JSON字符串（去除空白）
  ///
  /// [jsonString] 输入的JSON字符串
  /// 返回压缩后的JSON字符串，失败返回null
  static String? compress(String jsonString) {
    if (jsonString.isEmpty) return null;

    try {
      final decoded = json.decode(jsonString);
      return json.encode(decoded);
    } catch (e) {
      return null;
    }
  }

  // ==================== 验证 ====================

  /// 验证字符串是否为有效的JSON
  ///
  /// [jsonString] 待验证的字符串
  /// 返回是否为有效的JSON
  static bool isValid(String jsonString) {
    if (jsonString.isEmpty) return false;

    try {
      json.decode(jsonString);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取JSON解析错误信息
  ///
  /// [jsonString] 待验证的字符串
  /// 返回错误信息，无错误返回null
  static String? getError(String jsonString) {
    if (jsonString.isEmpty) return '输入为空';

    try {
      json.decode(jsonString);
      return null;
    } on FormatException catch (e) {
      return 'JSON格式错误: ${e.message}';
    } catch (e) {
      return '未知错误: $e';
    }
  }

  // ==================== 路径查询 ====================

  /// 从JSON中获取指定路径的值
  ///
  /// [jsonString] JSON字符串
  /// [path] 点分隔的路径，如 "data.user.name"
  /// 返回查询结果，失败返回null
  static dynamic queryPath(String jsonString, String path) {
    if (jsonString.isEmpty || path.isEmpty) return null;

    try {
      final decoded = json.decode(jsonString);
      final parts = path.split('.');
      dynamic current = decoded;

      for (final part in parts) {
        if (current is Map) {
          current = current[part];
        } else if (current is List) {
          final index = int.tryParse(part);
          if (index != null && index >= 0 && index < current.length) {
            current = current[index];
          } else {
            return null;
          }
        } else {
          return null;
        }
      }

      return current;
    } catch (e) {
      return null;
    }
  }

  // ==================== 统计信息 ====================

  /// 获取JSON统计信息
  ///
  /// [jsonString] JSON字符串
  /// 返回包含键数量、数组长度等信息的Map
  static Map<String, int>? getStats(String jsonString) {
    if (jsonString.isEmpty) return null;

    try {
      final decoded = json.decode(jsonString);
      return _countElements(decoded);
    } catch (e) {
      return null;
    }
  }

  /// 递归统计元素数量
  static Map<String, int> _countElements(dynamic value) {
    int keys = 0;
    int arrays = 0;
    int strings = 0;
    int numbers = 0;
    int booleans = 0;
    int nulls = 0;

    void traverse(dynamic v) {
      if (v is Map) {
        keys += v.keys.length;
        for (final val in v.values) {
          traverse(val);
        }
      } else if (v is List) {
        arrays++;
        for (final item in v) {
          traverse(item);
        }
      } else if (v is String) {
        strings++;
      } else if (v is num) {
        numbers++;
      } else if (v is bool) {
        booleans++;
      } else if (v == null) {
        nulls++;
      }
    }

    traverse(value);

    return {
      'keys': keys,
      'arrays': arrays,
      'strings': strings,
      'numbers': numbers,
      'booleans': booleans,
      'nulls': nulls,
      'totalKeys': keys + strings + numbers + booleans + nulls,
    };
  }

  // ==================== 合并与比较 ====================

  /// 合并两个JSON对象
  ///
  /// [json1] 第一个JSON字符串
  /// [json2] 第二个JSON字符串
  /// [keepDuplicates] 是否保留重复键（false时json2覆盖json1）
  /// 返回合并后的JSON字符串，失败返回null
  static String? merge(String json1, String json2, {bool keepDuplicates = false}) {
    if (json1.isEmpty && json2.isEmpty) return null;

    try {
      final decoded1 = json1.isEmpty ? <String, dynamic>{} : json.decode(json1) as Map<String, dynamic>;
      final decoded2 = json2.isEmpty ? <String, dynamic>{} : json.decode(json2) as Map<String, dynamic>;

      if (!keepDuplicates) {
        return json.encode({...decoded1, ...decoded2});
      } else {
        final merged = <String, dynamic>{};
        for (final key in decoded1.keys) {
          merged[key] = decoded1[key];
        }
        for (final key in decoded2.keys) {
          if (!merged.containsKey(key)) {
            merged[key] = decoded2[key];
          }
        }
        return json.encode(merged);
      }
    } catch (e) {
      return null;
    }
  }

  /// 比较两个JSON是否相等
  ///
  /// [json1] 第一个JSON字符串
  /// [json2] 第二个JSON字符串
  /// 返回是否相等
  static bool equals(String json1, String json2) {
    if (json1.isEmpty && json2.isEmpty) return true;
    if (json1.isEmpty || json2.isEmpty) return false;

    try {
      final decoded1 = json.decode(json1);
      final decoded2 = json.decode(json2);
      return _deepEquals(decoded1, decoded2);
    } catch (e) {
      return false;
    }
  }

  /// 深度比较两个值
  static bool _deepEquals(dynamic a, dynamic b) {
    if (a is Map && b is Map) {
      if (a.keys.length != b.keys.length) return false;
      for (final key in a.keys) {
        if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) {
          return false;
        }
      }
      return true;
    } else if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (int i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) return false;
      }
      return true;
    } else {
      return a == b;
    }
  }

  // ==================== 路径操作 ====================

  /// 从JSON中删除指定路径的值
  ///
  /// [jsonString] JSON字符串
  /// [path] 点分隔的路径
  /// 返回修改后的JSON字符串，失败返回null
  static String? deletePath(String jsonString, String path) {
    if (jsonString.isEmpty || path.isEmpty) return null;

    try {
      final decoded = json.decode(jsonString);
      final parts = path.split('.');
      final lastPart = parts.removeLast();

      dynamic current = decoded;
      for (final part in parts) {
        if (current is Map) {
          current = current[part];
        } else if (current is List) {
          final index = int.tryParse(part);
          if (index != null) {
            current = current[index];
          } else {
            return null;
          }
        } else {
          return null;
        }
      }

      if (current is Map) {
        current.remove(lastPart);
      } else if (current is List) {
        final index = int.tryParse(lastPart);
        if (index != null && index >= 0 && index < current.length) {
          current.removeAt(index);
        } else {
          return null;
        }
      }

      return json.encode(decoded);
    } catch (e) {
      return null;
    }
  }

  // ==================== 排序 ====================

  /// 按键排序JSON对象
  ///
  /// [jsonString] JSON字符串
  /// [recursive] 是否递归排序嵌套对象
  /// 返回排序后的JSON字符串，失败返回null
  static String? sortKeys(String jsonString, {bool recursive = true}) {
    if (jsonString.isEmpty) return null;

    try {
      final decoded = json.decode(jsonString);
      final sorted = _sortMapKeys(decoded as Map<String, dynamic>, recursive);
      return const JsonEncoder.withIndent('  ').convert(sorted);
    } catch (e) {
      return null;
    }
  }

  /// 递归排序Map的键
  static Map<String, dynamic> _sortMapKeys(Map<String, dynamic> map, bool recursive) {
    final sorted = <String, dynamic>{};

    final keys = map.keys.toList()..sort();
    for (final key in keys) {
      final value = map[key];
      if (recursive && value is Map<String, dynamic>) {
        sorted[key] = _sortMapKeys(value, recursive);
      } else if (recursive && value is List) {
        sorted[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _sortMapKeys(item, recursive);
          }
          return item;
        }).toList();
      } else {
        sorted[key] = value;
      }
    }

    return sorted;
  }
}
