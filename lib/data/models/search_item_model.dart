/// Search Item Model
/// Author: ZF_Clark
/// Description: Unified search item model representing both local and online tools
/// Last Modified: 2026/02/09
library;

import 'package:flutter/material.dart';

/// 搜索项类型枚举
enum SearchItemType {
  /// 本地工具
  local,
  /// 在线工具
  online,
}

/// 统一搜索项模型
/// 用于表示分类工具和在线工具的通用数据结构
class SearchItemModel {
  /// 唯一标识符
  final String id;

  /// 显示名称
  final String name;

  /// 描述信息
  final String description;

  /// 图标
  final IconData icon;

  /// 所属分类名称
  final String categoryName;

  /// 搜索项类型（本地/在线）
  final SearchItemType type;

  /// 关联的Widget页面（本地工具）
  final Widget? widget;

  /// 状态指示颜色
  final Color? statusColor;

  /// 附加数据（用于扩展）
  final Map<String, dynamic>? extraData;

  /// 构造函数
  const SearchItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.categoryName,
    required this.type,
    this.widget,
    this.statusColor,
    this.extraData,
  });

  /// 从Map创建实例（用于从配置转换）
  factory SearchItemModel.fromMap(
    Map<String, dynamic> map, {
    required String categoryName,
    required SearchItemType type,
  }) {
    return SearchItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      icon: map['icon'] as IconData,
      categoryName: categoryName,
      type: type,
      widget: map['widget'] as Widget?,
      statusColor: map['color'] as Color?,
      extraData: map,
    );
  }

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryName': categoryName,
      'type': type.name,
    };
  }

  /// 创建副本并修改指定字段
  SearchItemModel copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    String? categoryName,
    SearchItemType? type,
    Widget? widget,
    Color? statusColor,
    Map<String, dynamic>? extraData,
  }) {
    return SearchItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      categoryName: categoryName ?? this.categoryName,
      type: type ?? this.type,
      widget: widget ?? this.widget,
      statusColor: statusColor ?? this.statusColor,
      extraData: extraData ?? this.extraData,
    );
  }

  @override
  String toString() {
    return 'SearchItemModel(id: $id, name: $name, type: $type, category: $categoryName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchItemModel && other.id == id && other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}

/// 搜索结果分组模型
class SearchResultGroup {
  /// 分组类型
  final SearchItemType type;

  /// 分组标题
  final String title;

  /// 分组图标
  final IconData icon;

  /// 搜索结果列表
  final List<SearchItemModel> items;

  /// 构造函数
  const SearchResultGroup({
    required this.type,
    required this.title,
    required this.icon,
    required this.items,
  });

  /// 是否为空分组
  bool get isEmpty => items.isEmpty;

  /// 项目数量
  int get count => items.length;
}

/// 搜索历史记录模型
class SearchHistoryModel {
  /// 搜索关键词
  final String query;

  /// 搜索时间戳
  final DateTime timestamp;

  /// 搜索过滤器（可选）
  final SearchFilter? filter;

  /// 构造函数
  const SearchHistoryModel({
    required this.query,
    required this.timestamp,
    this.filter,
  });

  /// 转换为JSON字符串
  String toJson() {
    return '$query|${timestamp.toIso8601String()}|${filter?.toString() ?? ''}';
  }

  /// 从JSON字符串创建实例
  factory SearchHistoryModel.fromJson(String json) {
    final parts = json.split('|');
    return SearchHistoryModel(
      query: parts[0],
      timestamp: DateTime.parse(parts[1]),
      filter: parts.length > 2 && parts[2].isNotEmpty
          ? SearchFilter.fromString(parts[2])
          : null,
    );
  }
}

/// 搜索过滤器模型
class SearchFilter {
  /// 是否包含本地工具
  final bool includeLocal;

  /// 是否包含在线工具
  final bool includeOnline;

  /// 指定分类过滤（空表示所有分类）
  final List<String>? categories;

  /// 构造函数
  const SearchFilter({
    this.includeLocal = true,
    this.includeOnline = true,
    this.categories,
  });

  /// 默认过滤器（搜索所有）
  static const SearchFilter defaultFilter = SearchFilter();

  /// 仅搜索本地工具
  static const SearchFilter localOnly = SearchFilter(
    includeLocal: true,
    includeOnline: false,
  );

  /// 仅搜索在线工具
  static const SearchFilter onlineOnly = SearchFilter(
    includeLocal: false,
    includeOnline: true,
  );

  /// 创建副本并修改指定字段
  SearchFilter copyWith({
    bool? includeLocal,
    bool? includeOnline,
    List<String>? categories,
  }) {
    return SearchFilter(
      includeLocal: includeLocal ?? this.includeLocal,
      includeOnline: includeOnline ?? this.includeOnline,
      categories: categories ?? this.categories,
    );
  }

  @override
  String toString() {
    return '${includeLocal ? 'L' : ''}${includeOnline ? 'O' : ''}:${categories?.join(',') ?? ''}';
  }

  /// 从字符串解析过滤器
  static SearchFilter fromString(String str) {
    final parts = str.split(':');
    final flags = parts[0];
    return SearchFilter(
      includeLocal: flags.contains('L'),
      includeOnline: flags.contains('O'),
      categories: parts.length > 1 && parts[1].isNotEmpty
          ? parts[1].split(',')
          : null,
    );
  }
}
