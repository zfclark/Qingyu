/// Home Page
/// Author: ZF_Clark
/// Description: Application homepage with collapsible sidebar navigation supporting two main sections: Categories and Online. Features responsive layout for desktop, tablet, and mobile.
/// Last Modified: 2026/02/09
library;

import 'package:flutter/material.dart';
import '../../../app/config/app_config.dart';
import '../../../core/services/storage_service.dart';
import '../settings/settings_page.dart';
import '../online/online_page.dart';
import '../search/search_page.dart';
import 'widgets/collapsible_sidebar.dart';
import 'widgets/category_drawer.dart';
import 'widgets/tool_card_widget.dart';

/// 导航项类型
enum NavItemType { categories, online }

/// 首页
/// 应用的主页面，采用抽屉式布局设计，包含"分类"和"在线"两个主要导航项
class HomePage extends StatefulWidget {
  final VoidCallback? onThemeChanged;

  const HomePage({super.key, this.onThemeChanged});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _favoriteTools = [];
  Map<String, bool> _categoryExpandedStates = {};

  /// 当前选中的导航项
  NavItemType _currentNavItem = NavItemType.categories;

  /// 工具分类和项目
  final Map<String, List<Map<String, dynamic>>> _toolCategories =
      AppConfig.toolCategories;

  /// 分类图标映射
  final Map<String, IconData> _categoryIcons = {
    '常用工具': Icons.star,
    '加密工具': Icons.security,
    '日常工具': Icons.calendar_today,
  };

  /// 分类颜色映射
  final Map<String, Color> _categoryColors = {
    '常用工具': Colors.amber,
    '加密工具': Colors.green,
    '日常工具': Colors.blue,
  };

  @override
  void initState() {
    super.initState();
    _loadInitialState();
  }

  /// 加载初始状态
  void _loadInitialState() {
    setState(() {
      _favoriteTools = StorageService.getFavoriteTools();
      _categoryExpandedStates = StorageService.getCategoryExpandedStates();
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
    return tools;
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

  /// 处理分类展开状态变更
  void _onCategoryExpansionChanged(String category, bool expanded) {
    setState(() {
      _categoryExpandedStates[category] = expanded;
    });
    StorageService.saveCategoryExpandedStates(_categoryExpandedStates);
  }

  /// 处理导航项切换
  void _onNavItemChanged(NavItemType type) {
    setState(() {
      _currentNavItem = type;
    });
  }

  /// 打开设置页面
  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            SettingsPage(onThemeChanged: widget.onThemeChanged),
      ),
    );
  }

  /// 打开搜索页面
  void _openSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet =
            constraints.maxWidth >= 600 && constraints.maxWidth < 900;
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return _buildMobileLayout();
        } else {
          return _buildDesktopLayout(isTablet);
        }
      },
    );
  }

  /// 构建桌面端/平板布局
  Widget _buildDesktopLayout(bool isTablet) {
    return Scaffold(
      body: Row(
        children: [
          // 侧边栏 - 新的两导航项结构
          _buildSidebar(),
          // 主内容区
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _currentNavItem == NavItemType.categories
                  ? _buildCategoriesContent()
                  : const OnlinePage(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建侧边栏
  Widget _buildSidebar() {
    return CollapsibleSidebar(
      navItems: [
        SidebarNavItem(
          id: 'categories',
          icon: Icons.category,
          label: '分类',
          onTap: () => _onNavItemChanged(NavItemType.categories),
        ),
        SidebarNavItem(
          id: 'online',
          icon: Icons.cloud,
          label: '在线',
          onTap: () => _onNavItemChanged(NavItemType.online),
        ),
      ],
      selectedIndex: _currentNavItem == NavItemType.categories ? 0 : 1,
      onIndexChanged: (index) {
        _onNavItemChanged(
          index == 0 ? NavItemType.categories : NavItemType.online,
        );
      },
      onSettingsTap: _openSettings,
    );
  }

  /// 构建分类内容页
  Widget _buildCategoriesContent() {
    final categories = _toolCategories.keys.toList();
    final favoriteTools = _getFavoriteTools();

    return Column(
      key: const ValueKey('categories'),
      children: [
        // 顶部标题栏（带搜索图标）
        _buildHeaderBar(),
        // 内容区
        Expanded(child: _buildMainContent(categories, favoriteTools)),
      ],
    );
  }

  /// 构建移动端布局
  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('清隅工具箱'),
        actions: [
          IconButton(
            onPressed: _openSearch,
            icon: const Icon(Icons.search),
            tooltip: '搜索',
          ),
          IconButton(
            onPressed: _openSettings,
            icon: const Icon(Icons.settings),
            tooltip: '设置',
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Row(
                children: [
                  Icon(Icons.apps, size: 32),
                  SizedBox(width: 12),
                  Text(
                    '清隅工具箱',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.category,
                color: _currentNavItem == NavItemType.categories
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(
                '分类',
                style: TextStyle(
                  color: _currentNavItem == NavItemType.categories
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  fontWeight: _currentNavItem == NavItemType.categories
                      ? FontWeight.bold
                      : null,
                ),
              ),
              selected: _currentNavItem == NavItemType.categories,
              onTap: () {
                _onNavItemChanged(NavItemType.categories);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.cloud,
                color: _currentNavItem == NavItemType.online
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: Text(
                '在线',
                style: TextStyle(
                  color: _currentNavItem == NavItemType.online
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  fontWeight: _currentNavItem == NavItemType.online
                      ? FontWeight.bold
                      : null,
                ),
              ),
              selected: _currentNavItem == NavItemType.online,
              onTap: () {
                _onNavItemChanged(NavItemType.online);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _currentNavItem == NavItemType.categories
            ? _buildCategoriesContent()
            : const OnlinePage(),
      ),
    );
  }

  /// 构建顶部标题栏（带搜索图标）
  Widget _buildHeaderBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: Row(
        children: [
          // 标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '清隅工具箱',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '高效实用的工具集合',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          // 搜索按钮
          IconButton.filledTonal(
            onPressed: _openSearch,
            icon: const Icon(Icons.search),
            tooltip: '搜索工具',
          ),
        ],
      ),
    );
  }

  /// 构建主内容区
  Widget _buildMainContent(
    List<String> categories,
    List<Map<String, dynamic>> favoriteTools,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 收藏工具区域
          if (favoriteTools.isNotEmpty) ...[
            _buildSectionTitle('常用工具', Icons.favorite, Colors.red),
            const SizedBox(height: 12),
            _buildFavoriteToolsGrid(favoriteTools),
            const SizedBox(height: 24),
          ],
          // 分类抽屉列表
          _buildSectionTitle('工具分类', Icons.category, Colors.blue),
          const SizedBox(height: 12),
          ...categories.map((category) {
            final tools = _filterTools(category);
            if (tools.isEmpty) return const SizedBox.shrink();

            return CategoryDrawer(
              title: category,
              icon: _categoryIcons[category] ?? Icons.folder,
              color: _categoryColors[category],
              isExpanded: _categoryExpandedStates[category] ?? false,
              onExpansionChanged: (expanded) {
                _onCategoryExpansionChanged(category, expanded);
              },
              tools: tools,
              onToolTap: (tool) => _navigateToTool(tool['widget']),
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
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// 构建收藏工具网格
  Widget _buildFavoriteToolsGrid(List<Map<String, dynamic>> favoriteTools) {
    return SizedBox(
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
              onFavoriteToggle: (isFavorite) => _toggleFavorite(tool['id']),
            ),
          );
        },
      ),
    );
  }
}
