/// Storage service for local data persistence
/// Author: ZF_Clark
/// Description: Uses shared_preferences for lightweight local storage, providing methods for saving and retrieving hash calculation history, favorite tools, and theme mode settings. Includes cache management functionality
/// Last Modified: 2026/02/04
/// Version: V0.1
library;

import 'package:shared_preferences/shared_preferences.dart';
import '../models/hash_history.dart';
import '../../core/app_config.dart';

class StorageService {
  static late SharedPreferences _prefs;

  /// Initialize storage service
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save hash calculation history
  static Future<void> saveHashHistory(List<HashHistory> history) async {
    try {
      // Limit history records
      if (history.length > AppConfig.maxHistoryRecords) {
        history = history.sublist(0, AppConfig.maxHistoryRecords);
      }

      List<String> historyJson = history.map((item) => item.toJson()).toList();
      await _prefs.setStringList(AppConfig.hashHistoryKey, historyJson);
    } catch (e) {
      // Handle error silently to avoid app crashes
      print('Error saving hash history: $e');
    }
  }

  /// Get hash calculation history
  static List<HashHistory> getHashHistory() {
    try {
      List<String>? historyJson = _prefs.getStringList(
        AppConfig.hashHistoryKey,
      );
      if (historyJson == null) return [];

      return historyJson.map((json) => HashHistory.fromJson(json)).toList();
    } catch (e) {
      // Handle error silently to avoid app crashes
      print('Error getting hash history: $e');
      return [];
    }
  }

  /// Save favorite tools
  static Future<void> saveFavoriteTools(List<String> toolIds) async {
    try {
      await _prefs.setStringList(AppConfig.favoriteToolsKey, toolIds);
    } catch (e) {
      // Handle error silently to avoid app crashes
      print('Error saving favorite tools: $e');
    }
  }

  /// Get favorite tools
  static List<String> getFavoriteTools() {
    try {
      return _prefs.getStringList(AppConfig.favoriteToolsKey) ?? [];
    } catch (e) {
      // Handle error silently to avoid app crashes
      print('Error getting favorite tools: $e');
      return [];
    }
  }

  /// Save theme mode
  static Future<void> saveThemeMode(String mode) async {
    try {
      await _prefs.setString(AppConfig.themeModeKey, mode);
    } catch (e) {
      // Handle error silently to avoid app crashes
      print('Error saving theme mode: $e');
    }
  }

  /// Get theme mode
  static String getThemeMode() {
    try {
      return _prefs.getString(AppConfig.themeModeKey) ?? 'system';
    } catch (e) {
      // Handle error silently to avoid app crashes
      print('Error getting theme mode: $e');
      return 'system';
    }
  }

  /// Save font size setting
  static Future<void> saveFontSize(String size) async {
    try {
      await _prefs.setString(AppConfig.fontSizeKey, size);
    } catch (e) {
      // Handle error silently to avoid app crashes
      print('Error saving font size: $e');
    }
  }

  /// Get font size setting
  static String getFontSize() {
    try {
      return _prefs.getString(AppConfig.fontSizeKey) ?? 'medium';
    } catch (e) {
      // Handle error silently to avoid app crashes
      print('Error getting font size: $e');
      return 'medium';
    }
  }

  /// Export all data as JSON
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
      // Handle error silently to avoid app crashes
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

  /// Import data from JSON
  static Future<void> importData(Map<String, dynamic> data) async {
    try {
      // Import hash history
      if (data.containsKey('hashHistory')) {
        final historyData = data['hashHistory'] as List<dynamic>;
        final historyList = historyData
            .map((item) => HashHistory.fromJson(item as String))
            .toList();
        await StorageService.saveHashHistory(historyList);
      }

      // Import favorite tools
      if (data.containsKey('favoriteTools')) {
        final favoriteTools = (data['favoriteTools'] as List<dynamic>)
            .map((item) => item as String)
            .toList();
        await StorageService.saveFavoriteTools(favoriteTools);
      }

      // Import theme mode
      if (data.containsKey('themeMode')) {
        await StorageService.saveThemeMode(data['themeMode'] as String);
      }

      // Import font size
      if (data.containsKey('fontSize')) {
        await StorageService.saveFontSize(data['fontSize'] as String);
      }
    } catch (e) {
      // Handle error silently to avoid app crashes
      print('Error importing data: $e');
    }
  }

  /// Clear all cache
  static Future<void> clearCache() async {
    try {
      await _prefs.remove(AppConfig.hashHistoryKey);
      // Keep favorite tools, theme mode, and font size
    } catch (e) {
      // Handle error silently to avoid app crashes
      print('Error clearing cache: $e');
    }
  }
}
