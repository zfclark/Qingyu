/// Tool Card Widget
/// Author: ZF_Clark
/// Description: Reusable widget for displaying tool information. Supports favorite status toggle functionality and provides tap callback for navigation.
/// Last Modified: 2026/02/08
library;

import 'package:flutter/material.dart';

/// 工具卡片组件
/// 用于在首页展示工具信息
class ToolCardWidget extends StatefulWidget {
  /// 工具唯一标识
  final String id;

  /// 工具名称
  final String name;

  /// 工具图标
  final IconData icon;

  /// 工具描述
  final String? description;

  /// 是否已收藏
  final bool isFavorite;

  /// 点击回调
  final VoidCallback onTap;

  /// 收藏状态切换回调
  final ValueChanged<bool> onFavoriteToggle;

  /// 构造函数
  const ToolCardWidget({
    super.key,
    required this.id,
    required this.name,
    required this.icon,
    this.description,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  State<ToolCardWidget> createState() => _ToolCardWidgetState();
}

class _ToolCardWidgetState extends State<ToolCardWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      focusNode: FocusNode(),
      onShowFocusHighlight: (show) {
        if (show != _isHovered) {
          setState(() => _isHovered = show);
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Card(
            elevation: _isHovered ? 4 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _isHovered
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : null,
              ),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _isHovered ? 60 : 56,
                      height: _isHovered ? 60 : 56,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        widget.icon,
                        size: _isHovered ? 30 : 28,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (widget.description != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 4),
                        child: Text(
                          widget.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        onPressed: () =>
                            widget.onFavoriteToggle(!widget.isFavorite),
                        icon: Icon(
                          widget.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: widget.isFavorite ? Colors.red : null,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
