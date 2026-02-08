/// Home Page
/// Author: ZF_Clark
/// Description: Application homepage that displays tool categories, provides search functionality, shows favorite tools, and handles navigation to individual tool pages.
/// Last Modified: 2026/02/08
library;

import 'package:flutter/material.dart';
import '../../../app/config/app_config.dart';
import '../../../core/services/storage_service.dart';
import '../settings/settings_page.dart';
import 'widgets/tool_card_widget.dart';

/// 首页
/// 应用的主页面，展示工具列表和分类
class HomePage extends StatefulWidget {
  final VoidCallback? onThemeChanged;

  const HomePage({super.key, this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _favoriteTools = [];
  int _currentIndex = 0;

  /// 工具分类和项目
  final Map<String, List<Map<String, dynamic>>> _toolCategories =
      AppConfig.toolCategories;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  /// 从存储加载收藏的工具
  void _loadFavorites() {
    setState(() {
      _favoriteTools = StorageService.getFavoriteTools();
    });
  }

  /// 切换收藏状态
  void _toggleFavorite(String toolId) {
    setState(() {
      if (_favoriteTools.contains(toolId)) {
        _favoriteTools.remove(toolId);
      } else {
        _favoriteTools.add(toolId);
      }
      StorageService.saveFavoriteTools(_favoriteTools);
    });
  }

  /// 根据搜索关键词过滤工具
  List<Map<String, dynamic>> _filterTools(String category) {
    final tools = _toolCategories[category] ?? [];
    if (_searchQuery.isEmpty) return tools;

    return tools.where((tool) {
      return tool['name']?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
          false ||
              tool['description']?.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ??
          false;
    }).toList();
  }

  /// 获取收藏的工具
  List<Map<String, dynamic>> _getFavoriteTools() {
    final allTools = _toolCategories.values
        .expand((category) => category)
        .toList();
    final favoriteTools = allTools.where((tool) {
      return _favoriteTools.contains(tool['id']);
    }).toList();

    // 去重
    final uniqueFavorites = <Map<String, dynamic>>[];
    final seenIds = <String>{};
    for (final tool in favoriteTools) {
      if (!seenIds.contains(tool['id'])) {
        seenIds.add(tool['id']!);
        uniqueFavorites.add(tool);
      }
    }

    return uniqueFavorites;
  }

  /// 导航到工具页面
  void _navigateToTool(Widget toolWidget) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => toolWidget),
    );
  }

  @override
  Widget build(BuildContext context) {
    final favoriteTools = _getFavoriteTools();
    final categories = _toolCategories.keys.toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWebDesktop = constraints.maxWidth >= 600;

        return Scaffold(
          appBar: AppBar(
            title: const Text('清隅工具箱'),
            actions: [
              if (isWebDesktop) ...[
                // Web端顶部导航项
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 1;
                    });
                  },
                  child: const Text('分类'),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                  child: const Text('我的'),
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          SettingsPage(onThemeChanged: widget.onThemeChanged),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 搜索栏
                TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: '搜索工具...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),

                // 收藏工具区域
                if (favoriteTools.isNotEmpty && _searchQuery.isEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '常用工具',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 170,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: favoriteTools.length,
                          itemBuilder: (context, index) {
                            final tool = favoriteTools[index];
                            return SizedBox(
                              width: 140,
                              child: ToolCardWidget(
                                id: tool['id'],
                                name: tool['name'],
                                icon: tool['icon'],
                                description: tool['description'],
                                isFavorite: true,
                                onTap: () => _navigateToTool(tool['widget']),
                                onFavoriteToggle: (isFavorite) =>
                                    _toggleFavorite(tool['id']),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),

                // 工具分类
                Column(
                  children: categories.map((category) {
                    final tools = _filterTools(category);

                    if (tools.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount;
                            double childAspectRatio;

                            // 根据屏幕宽度动态调整列数
                            if (constraints.maxWidth >= 1200) {
                              crossAxisCount = 4;
                              childAspectRatio = 0.9;
                            } else if (constraints.maxWidth >= 800) {
                              crossAxisCount = 3;
                              childAspectRatio = 0.85;
                            } else if (constraints.maxWidth >= 600) {
                              crossAxisCount = 2;
                              childAspectRatio = 0.85;
                            } else {
                              crossAxisCount = 1;
                              childAspectRatio = 0.3;
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: childAspectRatio,
                                  ),
                              itemCount: tools.length,
                              itemBuilder: (context, toolIndex) {
                                final tool = tools[toolIndex];
                                return ToolCardWidget(
                                  id: tool['id'],
                                  name: tool['name'],
                                  icon: tool['icon'],
                                  description: tool['description'],
                                  isFavorite: _favoriteTools.contains(
                                    tool['id'],
                                  ),
                                  onTap: () => _navigateToTool(tool['widget']),
                                  onFavoriteToggle: (isFavorite) =>
                                      _toggleFavorite(tool['id']),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // 只在移动设备上显示底部导航栏
          bottomNavigationBar: !isWebDesktop
              ? BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: '首页',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.category),
                      label: '分类',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: '我的',
                    ),
                  ],
                )
              : null,
        );
      },
    );
  }
}
