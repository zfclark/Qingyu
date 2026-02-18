/// UI Utility
/// Author: ZF_Clark
/// Description: Provides common UI components and utilities including styled cards, snack bars, and other reusable widgets.
/// Last Modified: 2026/02/19
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 通用UI工具类
/// 提供可复用的UI组件和辅助方法
class UiUtil {
  /// 显示SnackBar消息
  ///
  /// [context] 上下文
  /// [message] 消息内容
  /// [duration] 显示时长，默认3秒
  /// [action] 操作按钮（可选）
  static void showSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
      ),
    );
  }

  /// 显示成功消息
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// 显示错误消息
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示警告消息
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// 样式化卡片组件
/// 提供统一风格的卡片样式
class StyledCard extends StatelessWidget {
  /// 子组件
  final Widget child;

  /// 内边距
  final EdgeInsetsGeometry? padding;

  /// 外边距
  final EdgeInsetsGeometry? margin;

  /// 阴影高度
  final double? elevation;

  /// 背景颜色
  final Color? color;

  /// 点击回调
  final VoidCallback? onTap;

  const StyledCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation ?? 0,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: margin ?? const EdgeInsets.all(16),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: card,
      );
    }

    return card;
  }
}

/// 样式化输入框组件
class StyledTextField extends StatelessWidget {
  /// 控制器
  final TextEditingController? controller;

  /// 提示文本
  final String? hintText;

  /// 标签文本
  final String? labelText;

  /// 最大行数
  final int? maxLines;

  /// 最小行数
  final int? minLines;

  /// 键盘类型
  final TextInputType? keyboardType;

  /// 输入格式
  final List<TextInputFormatter>? inputFormatters;

  /// 文本变化回调
  final ValueChanged<String>? onChanged;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  /// 是否启用
  final bool enabled;

  /// 前缀图标
  final Widget? prefixIcon;

  /// 后缀图标
  final Widget? suffixIcon;

  /// 后缀文本
  final String? suffixText;

  const StyledTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        suffixText: suffixText,
      ),
    );
  }
}

/// 样式化按钮组件
class StyledButton extends StatelessWidget {
  /// 按钮文本
  final String text;

  /// 点击回调
  final VoidCallback? onPressed;

  /// 图标
  final IconData? icon;

  /// 是否为主要按钮
  final bool isPrimary;

  /// 是否加载中
  final bool isLoading;

  /// 是否扩展填充
  final bool expanded;

  const StyledButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isLoading = false,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonChild = isLoading
        ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          );

    final style = ElevatedButton.styleFrom(
      minimumSize: const Size(48, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: style,
          child: buttonChild,
        ),
      );
    }

    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: style,
      child: buttonChild,
    );
  }
}

/// 空状态组件
class EmptyState extends StatelessWidget {
  /// 图标
  final IconData icon;

  /// 标题
  final String title;

  /// 描述
  final String? description;

  /// 操作按钮
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
