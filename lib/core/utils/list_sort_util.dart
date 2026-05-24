/// List Sort Utility
/// Author: ZF_Clark
/// Description: Provides text line sorting, deduplication, and shuffling utilities. Supports alphabetical, numerical, reverse, and length-based sorting.
/// Last Modified: 2026/05/24
library;

import 'dart:math';

/// 列表排序工具类
/// 提供文本行的排序、去重和随机打乱功能
class ListSortUtil {
  static final Random _random = Random();

  /// 按字母顺序排序
  ///
  /// [lines] 文本行列表
  /// [ascending] 是否升序（默认 true）
  /// [caseSensitive] 是否区分大小写（默认 false）
  /// 返回排序后的列表
  static List<String> sortAlphabetical(
    List<String> lines, {
    bool ascending = true,
    bool caseSensitive = false,
  }) {
    final sorted = List<String>.from(lines);
    sorted.sort((a, b) {
      final sa = caseSensitive ? a : a.toLowerCase();
      final sb = caseSensitive ? b : b.toLowerCase();
      return ascending ? sa.compareTo(sb) : sb.compareTo(sa);
    });
    return sorted;
  }

  /// 按数字顺序排序
  ///
  /// [lines] 文本行列表
  /// [ascending] 是否升序（默认 true）
  /// 返回排序后的列表（无法解析为数字的行排在末尾）
  static List<String> sortNumerical(
    List<String> lines, {
    bool ascending = true,
  }) {
    final sorted = List<String>.from(lines);
    sorted.sort((a, b) {
      final na = double.tryParse(a.trim());
      final nb = double.tryParse(b.trim());
      if (na != null && nb != null) {
        return ascending ? na.compareTo(nb) : nb.compareTo(na);
      }
      if (na != null) return -1;
      if (nb != null) return 1;
      return a.compareTo(b);
    });
    return sorted;
  }

  /// 按长度排序
  ///
  /// [lines] 文本行列表
  /// [ascending] 是否升序（默认 true）
  /// 返回排序后的列表
  static List<String> sortByLength(
    List<String> lines, {
    bool ascending = true,
  }) {
    final sorted = List<String>.from(lines);
    sorted.sort((a, b) {
      final cmp = a.length.compareTo(b.length);
      return ascending ? cmp : -cmp;
    });
    return sorted;
  }

  /// 反转顺序
  ///
  /// [lines] 文本行列表
  /// 返回反转后的列表
  static List<String> reverse(List<String> lines) {
    return lines.reversed.toList();
  }

  /// 随机打乱
  ///
  /// [lines] 文本行列表
  /// 返回打乱后的列表
  static List<String> shuffle(List<String> lines) {
    final shuffled = List<String>.from(lines);
    for (int i = shuffled.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = shuffled[i];
      shuffled[i] = shuffled[j];
      shuffled[j] = temp;
    }
    return shuffled;
  }

  /// 去除重复行
  ///
  /// [lines] 文本行列表
  /// [caseSensitive] 是否区分大小写（默认 true）
  /// 返回去重后的列表（保持原始顺序）
  static List<String> removeDuplicates(
    List<String> lines, {
    bool caseSensitive = true,
  }) {
    final seen = <String>{};
    final result = <String>[];
    for (final line in lines) {
      final key = caseSensitive ? line : line.toLowerCase();
      if (seen.add(key)) {
        result.add(line);
      }
    }
    return result;
  }

  /// 去除空行
  ///
  /// [lines] 文本行列表
  /// 返回去除空行后的列表
  static List<String> removeEmptyLines(List<String> lines) {
    return lines.where((line) => line.trim().isNotEmpty).toList();
  }

  /// 去除每行首尾空白
  ///
  /// [lines] 文本行列表
  /// 返回修剪后的列表
  static List<String> trimLines(List<String> lines) {
    return lines.map((line) => line.trim()).toList();
  }

  /// 添加行号
  ///
  /// [lines] 文本行列表
  /// 返回添加行号前缀的列表
  static List<String> numberedLines(List<String> lines) {
    final width = lines.length.toString().length;
    return List.generate(
      lines.length,
      (i) => '${(i + 1).toString().padLeft(width)}. ${lines[i]}',
    );
  }
}
