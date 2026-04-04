/// Category Drawer
/// Author: ZF_Clark
/// Description: Collapsible category drawer with smooth expand/collapse animation. Optimized for performance.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'tool_chip_widget.dart';

/// 分类抽屉组件
/// 可展开/收起的分类容器，内部显示工具列表
class CategoryDrawer extends StatelessWidget {
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

  /// 工具数量（可选，用于显示数量徽章）
  final int? toolCount;

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
    this.toolCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = color ?? colorScheme.primary;
    final toolCount = this.toolCount ?? tools.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isExpanded
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? categoryColor.withValues(alpha: 0.2)
              : colorScheme.outline.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 抽屉头部
          InkWell(
            onTap: () => onExpansionChanged(!isExpanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  // 左侧指示条
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isExpanded
                          ? categoryColor
                          : categoryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // 分类图标
                  Icon(
                    icon,
                    size: 22,
                    color: isExpanded
                        ? categoryColor
                        : colorScheme.onSurface,
                  ),
                  const SizedBox(width: 12),
                  // 分类标题
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isExpanded
                                ? categoryColor
                                : colorScheme.onSurface,
                            fontWeight: isExpanded
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                  ),
                  // 工具数量徽章
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$toolCount',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 展开/收起箭头
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 24,
                      color: isExpanded
                          ? categoryColor
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 抽屉内容
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                children: tools.map((tool) {
                  return ToolChipWidget(
                    id: tool['id'] as String,
                    name: tool['name'] as String,
                    icon: tool['icon'] as IconData,
                    statusDotColor: tool['color'] as Color?,
                    onTap: () => onToolTap(tool),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
