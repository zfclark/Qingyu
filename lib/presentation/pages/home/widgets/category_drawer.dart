/// Category Drawer
/// Author: ZF_Clark
/// Description: Collapsible category drawer with smooth expand/collapse animation. Displays tool chips when expanded.
/// Last Modified: 2026/02/09
library;

import 'package:flutter/material.dart';
import 'tool_chip_widget.dart';

/// 分类抽屉组件
/// 可展开/收起的分类容器，内部显示工具列表
class CategoryDrawer extends StatefulWidget {
  /// 分类标题
  final String title;

  /// 分类图标
  final IconData icon;

  /// 分类颜色（可选）
  final Color? color;

  /// 是否展开
  final bool isExpanded;

  /// 展开状态变更回调
  final ValueChanged<bool> onExpansionChanged;

  /// 工具列表
  final List<Map<String, dynamic>> tools;

  /// 工具点击回调
  final Function(Map<String, dynamic> tool) onToolTap;

  /// 构造函数
  const CategoryDrawer({
    super.key,
    required this.title,
    required this.icon,
    this.color,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.tools,
    required this.onToolTap,
  });

  @override
  State<CategoryDrawer> createState() => _CategoryDrawerState();
}

class _CategoryDrawerState extends State<CategoryDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic),
    );

    if (widget.isExpanded) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(CategoryDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 获取分类颜色
  Color _getCategoryColor(BuildContext context) {
    if (widget.color != null) return widget.color!;
    return Theme.of(context).colorScheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _getCategoryColor(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.isExpanded
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.isExpanded
              ? categoryColor.withValues(alpha: 0.2)
              : colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 抽屉头部
          MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: GestureDetector(
              onTap: () => widget.onExpansionChanged(!widget.isExpanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: _isHovered
                      ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // 左侧指示条
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: widget.isExpanded
                            ? categoryColor
                            : categoryColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 分类图标
                    AnimatedScale(
                      scale: _isHovered ? 1.1 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(
                        widget.icon,
                        size: 22,
                        color: widget.isExpanded
                            ? categoryColor
                            : colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 分类标题
                    Expanded(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: widget.isExpanded
                                  ? categoryColor
                                  : colorScheme.onSurface,
                              fontWeight: widget.isExpanded
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                      ),
                    ),
                    // 展开/收起箭头
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 24,
                        color: widget.isExpanded
                            ? categoryColor
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 抽屉内容
          ClipRect(
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              heightFactor: widget.isExpanded ? 1.0 : 0.0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: widget.isExpanded ? 1.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _buildToolsGrid(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建工具网格
  Widget _buildToolsGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: widget.tools.map((tool) {
        return ToolChipWidget(
          id: tool['id'] as String,
          name: tool['name'] as String,
          icon: tool['icon'] as IconData,
          statusDotColor: tool['color'] as Color?,
          onTap: () => widget.onToolTap(tool),
        );
      }).toList(),
    );
  }
}
