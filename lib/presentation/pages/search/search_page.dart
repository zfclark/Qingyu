/// Search Page
/// Author: ZF_Clark
/// Description: Unified search page supporting both local and online tools with history and filtering
/// Last Modified: 2026/02/09
library;

import 'package:flutter/material.dart';
import 'package:qingyu/core/services/search_service.dart';
import 'package:qingyu/data/models/search_item_model.dart';
import 'package:qingyu/presentation/pages/home/widgets/tool_chip_widget.dart';

/// 搜索页面 - 统一的工具搜索功能
/// 支持本地工具和在线工具的混合搜索
class SearchPage extends StatefulWidget {
  /// 初始搜索关键词
  final String? initialQuery;

  /// 初始过滤器
  final SearchFilter? initialFilter;

  const SearchPage({
    super.key,
    this.initialQuery,
    this.initialFilter,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // 搜索控制器
  final TextEditingController _searchController = TextEditingController();

  // 搜索结果列表
  List<SearchItemModel> _searchResults = [];

  // 搜索结果分组
  List<SearchResultGroup> _resultGroups = [];

  // 搜索历史
  List<SearchHistoryModel> _searchHistory = [];

  // 当前过滤器
  late SearchFilter _currentFilter;

  // 页面状态
  bool _showResults = false;
  bool _showHistory = true;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.initialFilter ?? SearchFilter.defaultFilter;
    _loadSearchHistory();

    // 如果有初始查询，执行搜索
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      _performSearch(widget.initialQuery!);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 加载搜索历史
  void _loadSearchHistory() {
    setState(() {
      _searchHistory = SearchService.getSearchHistory();
    });
  }

  /// 执行搜索
  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showResults = false;
        _showHistory = true;
        _searchResults = [];
        _resultGroups = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showHistory = false;
    });

    // 执行搜索
    final results = SearchService.search(
      query,
      filter: _currentFilter,
    );

    // 分组结果
    final groups = SearchService.groupResultsByType(results);

    // 保存搜索历史
    await SearchService.addSearchHistory(query, filter: _currentFilter);

    setState(() {
      _searchResults = results;
      _resultGroups = groups;
      _showResults = true;
      _isSearching = false;
    });

    // 刷新历史记录
    _loadSearchHistory();
  }

  /// 清除搜索
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _showResults = false;
      _showHistory = true;
      _searchResults = [];
      _resultGroups = [];
    });
  }

  /// 使用历史记录搜索
  void _searchFromHistory(SearchHistoryModel history) {
    _searchController.text = history.query;
    if (history.filter != null) {
      setState(() {
        _currentFilter = history.filter!;
      });
    }
    _performSearch(history.query);
  }

  /// 删除历史记录
  Future<void> _deleteHistoryItem(String query) async {
    await SearchService.removeSearchHistoryItem(query);
    _loadSearchHistory();
  }

  /// 清除所有历史
  Future<void> _clearAllHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清除历史'),
        content: const Text('确定要清除所有搜索历史吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('清除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SearchService.clearSearchHistory();
      _loadSearchHistory();
    }
  }

  /// 显示过滤器选择
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '搜索过滤器',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              // 类型过滤
              Text(
                '工具类型',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                title: const Text('本地工具'),
                subtitle: const Text('设备上运行的工具'),
                value: _currentFilter.includeLocal,
                onChanged: (value) {
                  setModalState(() {
                    _currentFilter = _currentFilter.copyWith(
                      includeLocal: value,
                    );
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('在线工具'),
                subtitle: const Text('需要网络连接的工具'),
                value: _currentFilter.includeOnline,
                onChanged: (value) {
                  setModalState(() {
                    _currentFilter = _currentFilter.copyWith(
                      includeOnline: value,
                    );
                  });
                },
              ),
              const SizedBox(height: 16),
              // 应用按钮
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    if (_searchController.text.isNotEmpty) {
                      _performSearch(_searchController.text);
                    }
                  },
                  child: const Text('应用过滤器'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '搜索工具...',
            border: InputBorder.none,
            hintStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          style: theme.textTheme.bodyLarge,
          onChanged: (value) {
            if (value.isEmpty) {
              _clearSearch();
            }
          },
          onSubmitted: _performSearch,
        ),
        actions: [
          // 过滤器按钮
          IconButton(
            icon: Badge(
              isLabelVisible: !_currentFilter.includeLocal ||
                  !_currentFilter.includeOnline,
              smallSize: 8,
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _showFilterDialog,
            tooltip: '过滤器',
          ),
          // 搜索按钮
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildBody(colorScheme, theme),
    );
  }

  /// 构建页面主体内容
  Widget _buildBody(ColorScheme colorScheme, ThemeData theme) {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_showResults) {
      if (_searchResults.isEmpty) {
        return _buildEmptyState(colorScheme, theme);
      }
      return _buildResultsList(colorScheme, theme);
    }

    if (_showHistory && _searchHistory.isNotEmpty) {
      return _buildHistoryView(colorScheme, theme);
    }

    return _buildInitialState(colorScheme, theme);
  }

  /// 构建初始状态（显示所有分类）
  Widget _buildInitialState(ColorScheme colorScheme, ThemeData theme) {
    final allItems = SearchService.getAllSearchItems();
    final localItems = allItems
        .where((item) => item.type == SearchItemType.local)
        .take(6)
        .toList();
    final onlineItems = allItems
        .where((item) => item.type == SearchItemType.online)
        .take(6)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 本地工具推荐
        if (localItems.isNotEmpty) ...[
          _buildSectionHeader(
            '本地工具',
            Icons.computer,
            colorScheme.primary,
            localItems.length,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: localItems.map((item) => _buildItemChip(item)).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // 在线工具推荐
        if (onlineItems.isNotEmpty) ...[
          _buildSectionHeader(
            '在线工具',
            Icons.cloud,
            Colors.blue,
            onlineItems.length,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: onlineItems.map((item) => _buildItemChip(item)).toList(),
          ),
          const SizedBox(height: 24),
        ],

        // 搜索提示
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '输入关键词搜索工具，支持按名称、描述和分类搜索',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建历史记录视图
  Widget _buildHistoryView(ColorScheme colorScheme, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 历史标题
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '搜索历史',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton.icon(
              onPressed: _clearAllHistory,
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('清除'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 历史列表
        ..._searchHistory.map((history) => ListTile(
              leading: const Icon(Icons.history),
              title: Text(history.query),
              subtitle: history.filter != null &&
                      (!history.filter!.includeLocal ||
                          !history.filter!.includeOnline)
                  ? Text(
                      '${history.filter!.includeLocal ? '本地 ' : ''}${history.filter!.includeOnline ? '在线' : ''}')
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(history.timestamp),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => _deleteHistoryItem(history.query),
                  ),
                ],
              ),
              onTap: () => _searchFromHistory(history),
            )),

        const Divider(),

        // 快速访问
        Text(
          '快速访问',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildQuickAccessChips(colorScheme),
      ],
    );
  }

  /// 构建快速访问标签
  Widget _buildQuickAccessChips(ColorScheme colorScheme) {
    final quickAccessItems = [
      ('哈希计算器', Icons.calculate),
      ('文本工具', Icons.text_fields),
      ('二维码生成', Icons.qr_code),
      ('Ping测试', Icons.network_ping),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickAccessItems.map((item) {
        return ActionChip(
          avatar: Icon(item.$2, size: 18),
          label: Text(item.$1),
          onPressed: () {
            _searchController.text = item.$1;
            _performSearch(item.$1);
          },
        );
      }).toList(),
    );
  }

  /// 构建分区标题
  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color color,
    int count,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建工具标签
  Widget _buildItemChip(SearchItemModel item) {
    return ToolChipWidget(
      id: item.id,
      name: item.name,
      icon: item.icon,
      statusDotColor: item.statusColor,
      onTap: () => _navigateToItem(item),
    );
  }

  /// 构建空状态（无搜索结果）
  Widget _buildEmptyState(ColorScheme colorScheme, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            '未找到相关工具',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '尝试其他关键词或调整过滤器',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          // 显示当前过滤器状态
          if (!_currentFilter.includeLocal || !_currentFilter.includeOnline)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _currentFilter = SearchFilter.defaultFilter;
                });
                _performSearch(_searchController.text);
              },
              icon: const Icon(Icons.filter_alt_off),
              label: const Text('重置过滤器'),
            ),
        ],
      ),
    );
  }

  /// 构建搜索结果列表
  Widget _buildResultsList(ColorScheme colorScheme, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _resultGroups.length + 1, // +1 for summary
      itemBuilder: (context, index) {
        if (index == 0) {
          // 搜索结果摘要
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Text(
                  '搜索结果',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_searchResults.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                // 过滤器指示器
                if (!_currentFilter.includeLocal ||
                    !_currentFilter.includeOnline)
                  Chip(
                    label: Text(
                      '${_currentFilter.includeLocal ? '本地 ' : ''}${_currentFilter.includeOnline ? '在线' : ''}',
                      style: const TextStyle(fontSize: 10),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          );
        }

        final group = _resultGroups[index - 1];
        return _buildResultGroup(group, colorScheme, theme);
      },
    );
  }

  /// 构建结果分组
  Widget _buildResultGroup(
    SearchResultGroup group,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 分组标题
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Icon(group.icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                group.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${group.count})',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // 分组内容
        ...group.items.map((item) => _buildResultCard(item, colorScheme, theme)),
        const SizedBox(height: 16),
      ],
    );
  }

  /// 构建搜索结果卡片
  Widget _buildResultCard(
    SearchItemModel item,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () => _navigateToItem(item),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 工具图标
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (item.statusColor)?.withValues(alpha: 0.1) ??
                      colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  color: item.statusColor ?? colorScheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // 工具信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // 类型标签
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: item.type == SearchItemType.local
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.type == SearchItemType.local ? '本地' : '在线',
                            style: TextStyle(
                              fontSize: 10,
                              color: item.type == SearchItemType.local
                                  ? Colors.green
                                  : Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 分类标签
                    Row(
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.categoryName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 箭头图标
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 导航到工具页面
  void _navigateToItem(SearchItemModel item) {
    if (item.widget != null) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => item.widget!),
      );
    } else {
      // 在线工具或暂无实现的工具
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} 功能开发中...'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 格式化时间
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inHours < 1) return '${diff.inMinutes}分钟前';
    if (diff.inDays < 1) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${time.month}/${time.day}';
  }
}
