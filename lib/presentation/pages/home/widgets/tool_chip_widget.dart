/// Tool Chip Widget
/// Author: ZF_Clark
/// Description: Capsule-shaped tool button with icon, text and status indicator dot. Optimized for performance.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';

/// 工具胶囊按钮组件
/// 用于在分类抽屉中展示工具，采用圆角胶囊形状设计
class ToolChipWidget extends StatelessWidget {
  /// 工具唯一标识
  final String id;

  /// 工具名称
  final String name;

  /// 工具图标
  final IconData icon;

  /// 点击回调
  final VoidCallback onTap;

  /// 状态点颜色（可选）
  final Color? statusDotColor;

  /// 构造函数
  const ToolChipWidget({
    super.key,
    required this.id,
    required this.name,
    required this.icon,
    required this.onTap,
    this.statusDotColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasStatusDot = statusDotColor != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              if (hasStatusDot) ...[
                const SizedBox(width: 6),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusDotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
