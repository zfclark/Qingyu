/// Search Service
/// Author: ZF_Clark
/// Description: Unified search service for both local and online tools with history management and filtering capabilities
/// Last Modified: 2026/02/09
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../app/config/app_config.dart';
import '../../data/models/search_item_model.dart';
import 'storage_service.dart';

/// 统一搜索服务类
/// 提供搜索功能、历史记录管理和搜索过滤
class SearchService {
  /// 缓存键：搜索历史
  static const String _searchHistoryKey = 'search_history';

  /// 最大历史记录数量
  static const int _maxHistoryCount = 20;

  /// 获取所有可搜索项（本地+在线）
  static List<SearchItemModel> getAllSearchItems() {
    final items = <SearchItemModel>[];

    // 添加本地工具
    AppConfig.toolCategories.forEach((categoryName, tools) {
      for (final tool in tools) {
        items.add(
          SearchItemModel.fromMap(
            tool,
            categoryName: categoryName,
            type: SearchItemType.local,
          ),
        );
      }
    });

    // 添加在线工具
    AppConfig.onlineTools.forEach((categoryName, tools) {
      for (final tool in tools) {
        items.add(
          SearchItemModel.fromMap(
            tool,
            categoryName: categoryName,
            type: SearchItemType.online,
          ),
        );
      }
    });

    return items;
  }

  /// 执行搜索
  ///
  /// [query] 搜索关键词
  /// [filter] 搜索过滤器（可选）
  /// 返回搜索结果列表
  static List<SearchItemModel> search(
    String query, {
    SearchFilter? filter,
  }) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final allItems = getAllSearchItems();
    final effectiveFilter = filter ?? SearchFilter.defaultFilter;

    return allItems.where((item) {
      // 应用类型过滤
      if (item.type == SearchItemType.local && !effectiveFilter.includeLocal) {
        return false;
      }
      if (item.type == SearchItemType.online && !effectiveFilter.includeOnline) {
        return false;
      }

      // 应用分类过滤
      if (effectiveFilter.categories != null &&
          effectiveFilter.categories!.isNotEmpty) {
        if (!effectiveFilter.categories!.contains(item.categoryName)) {
          return false;
        }
      }

      // 执行关键词匹配
      final nameMatch = item.name.toLowerCase().contains(lowerQuery);
      final descMatch = item.description.toLowerCase().contains(lowerQuery);
      final categoryMatch = item.categoryName.toLowerCase().contains(lowerQuery);

      return nameMatch || descMatch || categoryMatch;
    }).toList();
  }

  /// 按类型分组搜索结果
  ///
  /// [results] 搜索结果列表
  /// 返回分组后的结果
  static List<SearchResultGroup> groupResultsByType(
    List<SearchItemModel> results,
  ) {
    final localItems =
        results.where((item) => item.type == SearchItemType.local).toList();
    final onlineItems =
        results.where((item) => item.type == SearchItemType.online).toList();

    return [
      SearchResultGroup(
        type: SearchItemType.local,
        title: '本地工具',
        icon: Icons.computer,
        items: localItems,
      ),
      SearchResultGroup(
        type: SearchItemType.online,
        title: '在线工具',
        icon: Icons.cloud,
        items: onlineItems,
      ),
    ].where((group) => !group.isEmpty).toList();
  }

  /// 按分类分组搜索结果
  ///
  /// [results] 搜索结果列表
  /// 返回按分类分组的Map
  static Map<String, List<SearchItemModel>> groupResultsByCategory(
    List<SearchItemModel> results,
  ) {
    final grouped = <String, List<SearchItemModel>>{};

    for (final item in results) {
      if (!grouped.containsKey(item.categoryName)) {
        grouped[item.categoryName] = [];
      }
      grouped[item.categoryName]!.add(item);
    }

    return grouped;
  }

  /// 获取搜索建议
  ///
  /// [query] 当前输入
  /// [limit] 最大建议数量
  /// 返回建议列表
  static List<String> getSuggestions(String query, {int limit = 5}) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    final allItems = getAllSearchItems();

    // 收集匹配的名称和分类
    final suggestions = <String>{};

    for (final item in allItems) {
      if (item.name.toLowerCase().contains(lowerQuery)) {
        suggestions.add(item.name);
      }
      if (item.categoryName.toLowerCase().contains(lowerQuery)) {
        suggestions.add(item.categoryName);
      }
    }

    return suggestions.take(limit).toList();
  }

  // ==================== 搜索历史管理 ====================

  /// 获取搜索历史
  ///
  /// 返回历史记录列表（按时间倒序）
  static List<SearchHistoryModel> getSearchHistory() {
    try {
      final historyJson =
          StorageService.getStringList(_searchHistoryKey) ?? [];
      return historyJson
          .map((json) => SearchHistoryModel.fromJson(json))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading search history: $e');
      }
      return [];
    }
  }

  /// 添加搜索历史
  ///
  /// [query] 搜索关键词
  /// [filter] 使用的过滤器
  static Future<void> addSearchHistory(
    String query, {
    SearchFilter? filter,
  }) async {
    if (query.isEmpty) return;

    try {
      var history = getSearchHistory();

      // 移除重复项
      history.removeWhere((item) => item.query == query);

      // 添加新记录
      history.insert(
        0,
        SearchHistoryModel(
          query: query,
          timestamp: DateTime.now(),
          filter: filter,
        ),
      );

      // 限制数量
      if (history.length > _maxHistoryCount) {
        history = history.sublist(0, _maxHistoryCount);
      }

      // 保存
      await StorageService.setStringList(
        _searchHistoryKey,
        history.map((item) => item.toJson()).toList(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error saving search history: $e');
      }
    }
  }

  /// 清除搜索历史
  static Future<void> clearSearchHistory() async {
    try {
      await StorageService.remove(_searchHistoryKey);
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing search history: $e');
      }
    }
  }

  /// 删除单条历史记录
  ///
  /// [query] 要删除的关键词
  static Future<void> removeSearchHistoryItem(String query) async {
    try {
      var history = getSearchHistory();
      history.removeWhere((item) => item.query == query);

      await StorageService.setStringList(
        _searchHistoryKey,
        history.map((item) => item.toJson()).toList(),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error removing search history item: $e');
      }
    }
  }

  // ==================== 快捷搜索方法 ====================

  /// 搜索本地工具
  static List<SearchItemModel> searchLocal(String query) {
    return search(query, filter: SearchFilter.localOnly);
  }

  /// 搜索在线工具
  static List<SearchItemModel> searchOnline(String query) {
    return search(query, filter: SearchFilter.onlineOnly);
  }

  /// 按分类搜索
  static List<SearchItemModel> searchByCategory(
    String query,
    String category,
  ) {
    return search(
      query,
      filter: SearchFilter(categories: [category]),
    );
  }
}
