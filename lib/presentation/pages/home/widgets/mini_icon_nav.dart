/// Mini Icon Navigation
/// Author: ZF_Clark
/// Description: Compact icon-only navigation bar for collapsed sidebar state. Provides visual feedback for selection and hover states.
/// Last Modified: 2026/02/09
library;

import 'package:flutter/material.dart';

/// 小图标导航项数据
class MiniNavItem {
  /// 导航项ID
  final String id;

  /// 导航项图标
  final IconData icon;

  /// 导航项标签
  final String label;

  /// 构造函数
  const MiniNavItem({
    required this.id,
    required this.icon,
    required this.label,
  });
}

/// 小图标导航组件
/// 用于侧边栏收起状态下显示分类导航
class MiniIconNav extends StatelessWidget {
  /// 导航项列表
  final List<MiniNavItem> items;

  /// 当前选中索引
  final int selectedIndex;

  /// 选中回调
  final ValueChanged<int> onItemSelected;

  /// 构造函数
  const MiniIconNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.asMap().entries.map((entry) {
        final index = entry.key;
        final item = entry.value;
        final isSelected = index == selectedIndex;

        return _MiniNavItemWidget(
          item: item,
          isSelected: isSelected,
          onTap: () => onItemSelected(index),
        );
      }).toList(),
    );
  }
}

/// 单个导航项组件
class _MiniNavItemWidget extends StatefulWidget {
  final MiniNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _MiniNavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MiniNavItemWidget> createState() => _MiniNavItemWidgetState();
}

class _MiniNavItemWidgetState extends State<_MiniNavItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          padding: const EdgeInsets.all(12),
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
          child: Tooltip(
            message: widget.item.label,
            preferBelow: false,
            child: AnimatedScale(
              scale: _isHovered ? 1.1 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(
                widget.item.icon,
                size: 24,
                color: widget.isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
