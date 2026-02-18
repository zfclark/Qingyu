/// Online Page
/// Author: ZF_Clark
/// Description: Online tools page with extensible architecture for network-based tools.
/// Last Modified: 2026/02/09
library;

import 'package:flutter/material.dart';
import '../../../app/config/app_config.dart';
import '../../../data/models/search_item_model.dart';
import '../home/widgets/category_drawer.dart';
import '../search/search_page.dart';

/// 在线页面
/// 展示在线工具，支持工具分类和扩展接口
class OnlinePage extends StatefulWidget {
  const OnlinePage({super.key});

  @override
  State<OnlinePage> createState() => _OnlinePageState();
}

class _OnlinePageState extends State<OnlinePage> {
  /// 分类展开状态
  final Map<String, bool> _categoryExpandedStates = {};

  @override
  void initState() {
    super.initState();
    _loadExpandedStates();
  }

  /// 加载展开状态
  void _loadExpandedStates() {
    // 可以在这里从存储加载状态
    setState(() {
      // 默认第一个分类展开
      if (AppConfig.onlineTools.isNotEmpty) {
        _categoryExpandedStates[AppConfig.onlineTools.keys.first] = true;
      }
    });
  }

  /// 处理分类展开状态变更
  void _onCategoryExpansionChanged(String category, bool expanded) {
    setState(() {
      _categoryExpandedStates[category] = expanded;
    });
  }

  /// 导航到工具页面
  void _navigateToTool(Widget toolWidget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => toolWidget),
    );
  }

  /// 显示工具加载中提示
  void _showLoadingTool(String toolName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('正在加载 $toolName...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 打开统一搜索页面
  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SearchPage(
          initialFilter: SearchFilter.onlineOnly,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = AppConfig.onlineTools.keys.toList();

    return Scaffold(
      body: Column(
        children: [
          // 顶部搜索栏（点击后跳转到统一搜索）
          _buildSearchBar(),
          // 内容区
          Expanded(
            child: _buildMainContent(categories),
          ),
        ],
      ),
    );
  }

  /// 构建搜索栏
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withAlpha(25),
          ),
        ),
      ),
      child: InkWell(
        onTap: _openSearch,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withAlpha(128),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withAlpha(25),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.search,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Text(
                '搜索在线工具...',
                style: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withAlpha(153),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建主内容区
  Widget _buildMainContent(List<String> categories) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 页面标题
          _buildSectionTitle('在线工具', Icons.cloud, Colors.blue),
          const SizedBox(height: 16),
          // 分类抽屉列表
          ...categories.map((category) {
            final tools = AppConfig.onlineTools[category] ?? [];
            if (tools.isEmpty) return const SizedBox.shrink();

            return CategoryDrawer(
              title: category,
              icon: _getCategoryIcon(category),
              color: _getCategoryColor(category),
              isExpanded: _categoryExpandedStates[category] ?? false,
              onExpansionChanged: (expanded) {
                _onCategoryExpansionChanged(category, expanded);
              },
              tools: tools,
              onToolTap: (tool) {
                final widget = tool['widget'];
                if (widget != null && widget is Widget) {
                  _navigateToTool(widget);
                } else {
                  _showLoadingTool(tool['name'] ?? '工具');
                }
              },
            );
          }),
        ],
      ),
    );
  }

  /// 构建区块标题
  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  /// 获取分类图标
  IconData _getCategoryIcon(String category) {
    final iconMap = {
      '网络工具': Icons.network_check,
      '在线服务': Icons.cloud,
      'API工具': Icons.api,
    };
    return iconMap[category] ?? Icons.folder;
  }

  /// 获取分类颜色
  Color _getCategoryColor(String category) {
    final colorMap = {
      '网络工具': Colors.blue,
      '在线服务': Colors.green,
      'API工具': Colors.purple,
    };
    return colorMap[category] ?? Colors.grey;
  }
}