/// Storage Service
/// Author: ZF_Clark
/// Description: Uses shared_preferences for lightweight local storage, providing methods for saving and retrieving hash calculation history, favorite tools, and theme mode settings. Includes cache management functionality.
/// Last Modified: 2026/02/09
library;

import 'dart:convert';
import 'package:flutter/foundation.dart';
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
      if (kDebugMode) {
        print('Error saving hash history: $e');
      }
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

      return historyJson
          .map((json) => HashHistoryModel.fromJson(json))
          .toList();
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      if (kDebugMode) {
        print('Error getting hash history: $e');
      }
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
      if (kDebugMode) {
        print('Error saving favorite tools: $e');
      }
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
      if (kDebugMode) {
        print('Error getting favorite tools: $e');
      }
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
      if (kDebugMode) {
        print('Error saving theme mode: $e');
      }
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
      if (kDebugMode) {
        print('Error getting theme mode: $e');
      }
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
      if (kDebugMode) {
        print('Error saving font size: $e');
      }
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
      if (kDebugMode) {
        print('Error getting font size: $e');
      }
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
      if (kDebugMode) {
        print('Error exporting data: $e');
      }
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
      if (kDebugMode) {
        print('Error importing data: $e');
      }
    }
  }

  /// 清除所有缓存
  static Future<void> clearCache() async {
    try {
      await _prefs.remove(AppConfig.hashHistoryKey);
      // 保留收藏工具、主题模式和字体大小
    } catch (e) {
      // 静默处理错误，避免应用崩溃
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
    }
  }

  // ==================== 通用存储方法 ====================

  /// 获取字符串列表
  ///
  /// [key] 缓存键
  /// 返回字符串列表，如果不存在返回null
  static List<String>? getStringList(String key) {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting string list: $e');
      }
      return null;
    }
  }

  /// 保存字符串列表
  ///
  /// [key] 缓存键
  /// [value] 字符串列表
  static Future<void> setStringList(String key, List<String> value) async {
    try {
      await _prefs.setStringList(key, value);
    } catch (e) {
      if (kDebugMode) {
        print('Error setting string list: $e');
      }
    }
  }

  /// 移除指定键的数据
  ///
  /// [key] 缓存键
  static Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      if (kDebugMode) {
        print('Error removing key: $e');
      }
    }
  }

  // ==================== 抽屉布局状态存储 ====================

  /// 缓存键：侧边栏展开状态
  static const String _sidebarExpandedKey = 'sidebar_expanded';

  /// 缓存键：分类展开状态
  static const String _categoryExpandedKey = 'category_expanded_states';

  /// 缓存键：当前选中分类索引
  static const String _selectedCategoryKey = 'selected_category_index';

  /// 保存侧边栏展开状态
  ///
  /// [expanded] 是否展开
  static Future<void> saveSidebarExpanded(bool expanded) async {
    try {
      await _prefs.setBool(_sidebarExpandedKey, expanded);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving sidebar expanded state: $e');
      }
    }
  }

  /// 获取侧边栏展开状态
  ///
  /// 返回是否展开，默认为 true
  static bool getSidebarExpanded() {
    try {
      return _prefs.getBool(_sidebarExpandedKey) ?? true;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sidebar expanded state: $e');
      }
      return true;
    }
  }

  /// 保存分类展开状态
  ///
  /// [states] 分类展开状态映射表
  static Future<void> saveCategoryExpandedStates(
    Map<String, bool> states,
  ) async {
    try {
      final jsonString = jsonEncode(states);
      await _prefs.setString(_categoryExpandedKey, jsonString);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving category expanded states: $e');
      }
    }
  }

  /// 获取分类展开状态
  ///
  /// 返回分类展开状态映射表
  static Map<String, bool> getCategoryExpandedStates() {
    try {
      final jsonString = _prefs.getString(_categoryExpandedKey);
      if (jsonString == null) return {};
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      if (kDebugMode) {
        print('Error getting category expanded states: $e');
      }
      return {};
    }
  }

  /// 保存当前选中分类索引
  ///
  /// [index] 分类索引
  static Future<void> saveSelectedCategoryIndex(int index) async {
    try {
      await _prefs.setInt(_selectedCategoryKey, index);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving selected category index: $e');
      }
    }
  }

  /// 获取当前选中分类索引
  ///
  /// 返回分类索引，默认为 0
  static int getSelectedCategoryIndex() {
    try {
      return _prefs.getInt(_selectedCategoryKey) ?? 0;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting selected category index: $e');
      }
      return 0;
    }
  }
}
