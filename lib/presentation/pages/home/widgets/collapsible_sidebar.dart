/// Collapsible Sidebar
/// Author: ZF_Clark
/// Description: A collapsible sidebar with smooth width animation. Supports expanded and collapsed states with mini icon navigation.
/// Last Modified: 2026/02/09
library;

import 'package:flutter/material.dart';
import '../../../../core/services/storage_service.dart';
import 'mini_icon_nav.dart';

/// 侧边栏导航项
class SidebarNavItem {
  final String id;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SidebarNavItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

/// 可收起侧边栏组件
class CollapsibleSidebar extends StatefulWidget {
  /// 导航项列表
  final List<SidebarNavItem> navItems;

  /// 当前选中索引
  final int selectedIndex;

  /// 选中变更回调
  final ValueChanged<int> onIndexChanged;

  /// 展开状态变更回调
  final ValueChanged<bool>? onExpandedChanged;

  /// 设置按钮点击回调
  final VoidCallback onSettingsTap;

  /// 构造函数
  const CollapsibleSidebar({
    super.key,
    required this.navItems,
    required this.selectedIndex,
    required this.onIndexChanged,
    this.onExpandedChanged,
    required this.onSettingsTap,
  });

  @override
  State<CollapsibleSidebar> createState() => _CollapsibleSidebarState();
}

class _CollapsibleSidebarState extends State<CollapsibleSidebar> {
  bool _isExpanded = true;

  /// 展开宽度
  static const double _expandedWidth = 220;

  /// 收起宽度
  static const double _collapsedWidth = 72;

  @override
  void initState() {
    super.initState();
    _loadExpandedState();
  }

  /// 加载展开状态
  void _loadExpandedState() {
    setState(() {
      _isExpanded = StorageService.getSidebarExpanded();
    });
  }

  /// 切换展开状态
  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    StorageService.saveSidebarExpanded(_isExpanded);
    widget.onExpandedChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      width: _isExpanded ? _expandedWidth : _collapsedWidth,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // 顶部区域：Logo和切换按钮
          _buildHeader(colorScheme),
          const SizedBox(height: 8),
          // 导航区域
          Expanded(
            child: _isExpanded
                ? _buildExpandedNav(colorScheme)
                : _buildCollapsedNav(colorScheme),
          ),
          // 底部区域：设置按钮
          _buildFooter(colorScheme),
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Row(
        mainAxisAlignment: _isExpanded
            ? MainAxisAlignment.spaceBetween
            : MainAxisAlignment.center,
        children: [
          // Logo/标题
          if (_isExpanded)
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.apps,
                    size: 28,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '清隅',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            )
          else
            Icon(
              Icons.apps,
              size: 28,
              color: colorScheme.primary,
            ),
          // 切换按钮
          if (_isExpanded)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _toggleExpanded,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0 : 0.5,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.chevron_left,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建展开状态的导航
  Widget _buildExpandedNav(ColorScheme colorScheme) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: widget.navItems.length,
      itemBuilder: (context, index) {
        final item = widget.navItems[index];
        final isSelected = index == widget.selectedIndex;

        return _ExpandedNavItem(
          item: item,
          isSelected: isSelected,
          onTap: () => widget.onIndexChanged(index),
        );
      },
    );
  }

  /// 构建收起状态的导航
  Widget _buildCollapsedNav(ColorScheme colorScheme) {
    return Column(
      children: [
        // 展开按钮
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggleExpanded,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.chevron_right,
                size: 24,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 小图标导航
        Expanded(
          child: SingleChildScrollView(
            child: MiniIconNav(
              items: widget.navItems
                  .map((item) => MiniNavItem(
                        id: item.id,
                        icon: item.icon,
                        label: item.label,
                      ))
                  .toList(),
              selectedIndex: widget.selectedIndex,
              onItemSelected: widget.onIndexChanged,
            ),
          ),
        ),
      ],
    );
  }

  /// 构建底部
  Widget _buildFooter(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: _isExpanded
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onSettingsTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.settings_outlined,
                        size: 22,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '设置',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onSettingsTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.settings_outlined,
                    size: 22,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
    );
  }
}

/// 展开状态的导航项
class _ExpandedNavItem extends StatefulWidget {
  final SidebarNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExpandedNavItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_ExpandedNavItem> createState() => _ExpandedNavItemState();
}

class _ExpandedNavItemState extends State<_ExpandedNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? colorScheme.primaryContainer
                  : _isHovered
                      ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isSelected
                    ? colorScheme.primary.withValues(alpha: 0.3)
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedScale(
                  scale: _isHovered ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    widget.item.icon,
                    size: 22,
                    color: widget.isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      color: widget.isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                      fontWeight: widget.isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
