/// Diff Utility
/// Author: ZF_Clark
/// Description: Provides text comparison and diff utilities. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

/// 文本对比工具类
/// 提供文本差异比较功能
class DiffUtil {
  /// 比较两个文本并返回差异
  ///
  /// [text1] 原始文本
  /// [text2] 新文本
  /// 返回差异列表
  static List<DiffResult> compare(String text1, String text2) {
    final lines1 = text1.split('\n');
    final lines2 = text2.split('\n');
    
    final result = <DiffResult>[];
    final maxLines = lines1.length > lines2.length ? lines1.length : lines2.length;
    
    for (int i = 0; i < maxLines; i++) {
      final line1 = i < lines1.length ? lines1[i] : null;
      final line2 = i < lines2.length ? lines2[i] : null;
      
      if (line1 == line2) {
        result.add(DiffResult(
          type: DiffType.unchanged,
          lineNumber: i + 1,
          oldContent: line1,
          newContent: line2,
        ));
      } else if (line1 == null) {
        result.add(DiffResult(
          type: DiffType.added,
          lineNumber: i + 1,
          oldContent: null,
          newContent: line2,
        ));
      } else if (line2 == null) {
        result.add(DiffResult(
          type: DiffType.removed,
          lineNumber: i + 1,
          oldContent: line1,
          newContent: null,
        ));
      } else {
        result.add(DiffResult(
          type: DiffType.modified,
          lineNumber: i + 1,
          oldContent: line1,
          newContent: line2,
        ));
      }
    }
    
    return result;
  }

  /// 获取统计信息
  ///
  /// [diffResults] 差异结果列表
  /// 返回统计Map
  static Map<String, int> getStats(List<DiffResult> diffResults) {
    int added = 0;
    int removed = 0;
    int modified = 0;
    int unchanged = 0;
    
    for (final result in diffResults) {
      switch (result.type) {
        case DiffType.added:
          added++;
          break;
        case DiffType.removed:
          removed++;
          break;
        case DiffType.modified:
          modified++;
          break;
        case DiffType.unchanged:
          unchanged++;
          break;
      }
    }
    
    return {
      'added': added,
      'removed': removed,
      'modified': modified,
      'unchanged': unchanged,
      'total': diffResults.length,
    };
  }

  /// 获取统一格式差异
  ///
  /// [text1] 原始文本
  /// [text2] 新文本
  /// 返回统一格式差异字符串
  static String getUnifiedDiff(String text1, String text2) {
    final results = compare(text1, text2);
    final buffer = StringBuffer();
    
    for (final result in results) {
      switch (result.type) {
        case DiffType.added:
          buffer.writeln('+ ${result.newContent ?? ''}');
          break;
        case DiffType.removed:
          buffer.writeln('- ${result.oldContent ?? ''}');
          break;
        case DiffType.modified:
          buffer.writeln('- ${result.oldContent ?? ''}');
          buffer.writeln('+ ${result.newContent ?? ''}');
          break;
        case DiffType.unchanged:
          buffer.writeln('  ${result.oldContent ?? ''}');
          break;
      }
    }
    
    return buffer.toString();
  }
}

/// 差异类型
enum DiffType { unchanged, added, removed, modified }

/// 差异结果
class DiffResult {
  final DiffType type;
  final int lineNumber;
  final String? oldContent;
  final String? newContent;

  DiffResult({
    required this.type,
    required this.lineNumber,
    this.oldContent,
    this.newContent,
  });
}