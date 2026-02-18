/// Tool Chip Widget
/// Author: ZF_Clark
/// Description: Capsule-shaped tool button with icon, text and status indicator dot. Supports hover effects and tap callbacks.
/// Last Modified: 2026/02/09
library;

import 'package:flutter/material.dart';

/// 工具胶囊按钮组件
/// 用于在分类抽屉中展示工具，采用圆角胶囊形状设计
class ToolChipWidget extends StatefulWidget {
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
  State<ToolChipWidget> createState() => _ToolChipWidgetState();
}

class _ToolChipWidgetState extends State<ToolChipWidget> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasStatusDot = widget.statusDotColor != null;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isPressed
                ? colorScheme.primaryContainer.withValues(alpha: 0.5)
                : _isHovered
                ? colorScheme.primaryContainer.withValues(alpha: 0.3)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: _isHovered
                  ? colorScheme.primary.withValues(alpha: 0.3)
                  : colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 工具图标
              AnimatedScale(
                scale: _isHovered ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Icon(
                  widget.icon,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              // 工具名称
              Flexible(
                child: Text(
                  widget.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: _isHovered
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              // 状态指示点（仅当颜色不为null时显示）
              if (hasStatusDot) ...[
                const SizedBox(width: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: widget.statusDotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.statusDotColor!.withValues(alpha: 0.4),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
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
