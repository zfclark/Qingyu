
/// Storage Service
/// Author: ZF_Clark
/// Description: Uses shared_preferences for lightweight local storage, providing methods for saving and retrieving hash calculation history, favorite tools, and theme mode settings. Includes cache management functionality.
/// Last Modified: 2026/02/08
library;

import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/hash_history_model.dart';
import '../../app/config/app_config.dart';

/// 存储服务类
/// 负责应用数据的本地持久化存储
class StorageService {
  static late SharedPreferences _prefs;

  /// 初始化存储服务
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 保存哈希计算历史
  /// 
  /// [history] 历史记录列表
  static Future<void> saveHashHistory(List<HashHistoryModel> history) async {
    try {
      // 限制历史记录数量
      if (history.length > AppConfig.maxHistoryRecords) {
        history = history.sublist(0, AppConfig.maxHistoryRecords);
      }

      List<String> historyJson = history.map((item) => item.toJson()).toList();
      await _prefs.setStringList(AppConfig.hashHistoryKey, historyJson);
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      print('Error saving hash history: $e');
    }
  }

  /// 获取哈希计算历史
  /// 
  /// 返回历史记录列表
  static List<HashHistoryModel> getHashHistory() {
    try {
      List<String>? historyJson = _prefs.getStringList(
        AppConfig.hashHistoryKey,
      );
      if (historyJson == null) return [];

      return historyJson.map((json) => HashHistoryModel.fromJson(json)).toList();
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      print('Error getting hash history: $e');
      return [];
    }
  }

  /// 保存收藏的工具
  /// 
  /// [toolIds] 工具ID列表
  static Future<void> saveFavoriteTools(List<String> toolIds) async {
    try {
      await _prefs.setStringList(AppConfig.favoriteToolsKey, toolIds);
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      print('Error saving favorite tools: $e');
    }
  }

  /// 获取收藏的工具
  /// 
  /// 返回工具ID列表
  static List<String> getFavoriteTools() {
    try {
      return _prefs.getStringList(AppConfig.favoriteToolsKey) ?? [];
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      print('Error getting favorite tools: $e');
      return [];
    }
  }

  /// 保存主题模式
  /// 
  /// [mode] 主题模式（light/dark/system）
  static Future<void> saveThemeMode(String mode) async {
    try {
      await _prefs.setString(AppConfig.themeModeKey, mode);
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      print('Error saving theme mode: $e');
    }
  }

  /// 获取主题模式
  /// 
  /// 返回主题模式字符串
  static String getThemeMode() {
    try {
      return _prefs.getString(AppConfig.themeModeKey) ?? 'system';
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      print('Error getting theme mode: $e');
      return 'system';
    }
  }

  /// 保存字体大小设置
  /// 
  /// [size] 字体大小（small/medium/large）
  static Future<void> saveFontSize(String size) async {
    try {
      await _prefs.setString(AppConfig.fontSizeKey, size);
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      print('Error saving font size: $e');
    }
  }

  /// 获取字体大小设置
  /// 
  /// 返回字体大小字符串
  static String getFontSize() {
    try {
      return _prefs.getString(AppConfig.fontSizeKey) ?? 'medium';
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      print('Error getting font size: $e');
      return 'medium';
    }
  }

  /// 导出所有数据为JSON格式
  /// 
  /// 返回包含所有应用数据的Map
  static Map<String, dynamic> exportData() {
    try {
      final data = {
        'hashHistory': StorageService.getHashHistory()
            .map((item) => item.toJson())
            .toList(),
        'favoriteTools': StorageService.getFavoriteTools(),
        'themeMode': StorageService.getThemeMode(),
        'fontSize': StorageService.getFontSize(),
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
      };
      return data;
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      print('Error exporting data: $e');
      return {
        'hashHistory': [],
        'favoriteTools': [],
        'themeMode': 'system',
        'fontSize': 'medium',
        'exportDate': DateTime.now().toIso8601String(),
        'appVersion': '1.0.0',
      };
    }
  }

  /// 从JSON导入数据
  /// 
  /// [data] 包含应用数据的Map
  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      // 导入哈希历史
      if (data.containsKey('hashHistory')) {
        final historyData = data['hashHistory'] as List<dynamic>;
        final historyList = historyData
            .map((item) => HashHistoryModel.fromJson(item as String))
            .toList();
        await StorageService.saveHashHistory(historyList);
      }

      // 导入收藏工具
      if (data.containsKey('favoriteTools')) {
        final favoriteTools = (data['favoriteTools'] as List<dynamic>)
            .map((item) => item as String)
            .toList();
        await StorageService.saveFavoriteTools(favoriteTools);
      }

      // 导入主题模式
      if (data.containsKey('themeMode')) {
        await StorageService.saveThemeMode(data['themeMode'] as String);
      }

      // 导入字体大小
      if (data.containsKey('fontSize')) {
        await StorageService.saveFontSize(data['fontSize'] as String);
      }
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      print('Error importing data: $e');
    }
  }

  /// 清除所有缓存
  static Future<void> clearCache() async {
    try {
      await _prefs.remove(AppConfig.hashHistoryKey);
      // 保留收藏工具、主题模式和字体大小
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      print('Error clearing cache: $e');
    }
  }
}
