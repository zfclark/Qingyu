/// Data Export Utility
/// Author: ZF_Clark
/// Description: Provides data export and import functionality for mobile and web platforms. Supports JSON file format for data backup and restore.
/// Last Modified: 2026/02/19
library;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'platform_util.dart';

/// 数据导出工具类
/// 提供跨平台的数据导出和导入功能
class DataExportUtil {
  /// 导出数据到文件
  ///
  /// [data] 要导出的数据Map
  /// [fileName] 文件名（不含扩展名）
  /// 返回导出的文件路径，失败返回null
  static Future<String?> exportToFile(
    Map<String, dynamic> data,
    String fileName,
  ) async {
    try {
      final jsonString = const JsonEncoder.withIndent('  ').convert(data);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fullFileName = '${fileName}_$timestamp.json';

      if (kIsWeb) {
        // Web平台：使用下载方式
        return _exportForWeb(jsonString, fullFileName);
      } else if (PlatformUtil.isMobilePlatform()) {
        // 移动平台：使用分享功能
        return _exportForMobile(jsonString, fullFileName);
      } else if (PlatformUtil.isDesktopPlatform()) {
        // 桌面平台：保存到文件
        return _exportForDesktop(jsonString, fullFileName);
      }

      return null;
    } catch (e) {
      debugPrint('Export failed: $e');
      return null;
    }
  }

  /// Web平台导出实现
  static Future<String?> _exportForWeb(String content, String fileName) async {
    // Web平台的导出逻辑需要通过web专用文件实现
    // 这里返回文件名，实际下载逻辑在web专用文件中处理
    return fileName;
  }

  /// 移动平台导出实现
  static Future<String?> _exportForMobile(
    String content,
    String fileName,
  ) async {
    try {
      // 获取临时目录
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(content);

      // 使用分享功能
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: '清隅工具箱数据备份',
        text: '这是您的应用数据备份文件',
      );

      return file.path;
    } catch (e) {
      debugPrint('Mobile export failed: $e');
      return null;
    }
  }

  /// 桌面平台导出实现
  static Future<String?> _exportForDesktop(
    String content,
    String fileName,
  ) async {
    try {
      // 让用户选择保存位置
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: '保存数据备份',
        fileName: fileName,
      );

      if (outputPath == null) {
        return null;
      }

      final file = File(outputPath);
      await file.writeAsString(content);

      return outputPath;
    } catch (e) {
      debugPrint('Desktop export failed: $e');
      return null;
    }
  }

  /// 从文件导入数据
  ///
  /// 返回导入的数据Map，失败返回null
  static Future<Map<String, dynamic>?> importFromFile() async {
    try {
      if (kIsWeb) {
        // Web平台：使用文件选择器
        return _importForWeb();
      } else if (PlatformUtil.isMobilePlatform()) {
        // 移动平台：使用文件选择器
        return _importForMobile();
      } else if (PlatformUtil.isDesktopPlatform()) {
        // 桌面平台：使用文件选择器
        return _importForDesktop();
      }

      return null;
    } catch (e) {
      debugPrint('Import failed: $e');
      return null;
    }
  }

  /// Web平台导入实现
  static Future<Map<String, dynamic>?> _importForWeb() async {
    // Web平台的导入逻辑需要通过web专用文件实现
    return null;
  }

  /// 移动平台导入实现
  static Future<Map<String, dynamic>?> _importForMobile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      if (file.path == null) {
        return null;
      }

      final content = await File(file.path!).readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Mobile import failed: $e');
      return null;
    }
  }

  /// 桌面平台导入实现
  static Future<Map<String, dynamic>?> _importForDesktop() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.isEmpty) {
        return null;
      }

      final file = result.files.first;
      if (file.path == null) {
        return null;
      }

      final content = await File(file.path!).readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Desktop import failed: $e');
      return null;
    }
  }

  /// 验证导入数据的格式
  ///
  /// [data] 要验证的数据
  /// 返回是否为有效的数据格式
  static bool validateImportData(Map<String, dynamic> data) {
    // 检查必需的字段
    if (!data.containsKey('appVersion')) {
      return false;
    }

    // 检查数据结构
    if (data.containsKey('hashHistory') && data['hashHistory'] is! List) {
      return false;
    }

    if (data.containsKey('favoriteTools') && data['favoriteTools'] is! List) {
      return false;
    }

    if (data.containsKey('themeMode') &&
        !['light', 'dark', 'system'].contains(data['themeMode'])) {
      return false;
    }

    if (data.containsKey('fontSize') &&
        !['small', 'medium', 'large'].contains(data['fontSize'])) {
      return false;
    }

    return true;
  }
}
