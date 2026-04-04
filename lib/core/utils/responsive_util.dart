/// Responsive Layout Utility
/// Author: ZF_Clark
/// Description: Provides responsive layout utilities for cross-platform consistency between web and mobile. Supports breakpoint detection and adaptive layouts.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';

/// 响应式布局工具类
/// 提供跨平台响应式布局支持
class ResponsiveUtil {
  /// 断点定义
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  /// 获取当前屏幕类型
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return getScreenTypeFromWidth(width);
  }

  /// 根据宽度获取屏幕类型
  static ScreenType getScreenTypeFromWidth(double width) {
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else if (width < desktopBreakpoint) {
      return ScreenType.desktop;
    } else {
      return ScreenType.largeDesktop;
    }
  }

  /// 判断是否为移动端
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  /// 判断是否为平板
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  /// 判断是否为桌面端
  static bool isDesktop(BuildContext context) {
    final type = getScreenType(context);
    return type == ScreenType.desktop || type == ScreenType.largeDesktop;
  }

  /// 判断是否为平板或更大
  static bool isTabletOrLarger(BuildContext context) {
    final type = getScreenType(context);
    return type != ScreenType.mobile;
  }

  /// 获取侧边栏宽度
  static double getSidebarWidth(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return 0;
      case ScreenType.tablet:
        return 180;
      case ScreenType.desktop:
        return 220;
      case ScreenType.largeDesktop:
        return 260;
    }
  }

  /// 获取内容区域最大宽度
  static double getMaxContentWidth(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return double.infinity;
      case ScreenType.tablet:
        return 800;
      case ScreenType.desktop:
        return 1000;
      case ScreenType.largeDesktop:
        return 1200;
    }
  }

  /// 获取网格列数
  static int getGridColumns(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return 2;
      case ScreenType.tablet:
        return 3;
      case ScreenType.desktop:
        return 4;
      case ScreenType.largeDesktop:
        return 5;
    }
  }

  /// 响应式构建器
  static Widget builder({
    required BuildContext context,
    Widget Function(BuildContext context)? mobile,
    Widget Function(BuildContext context)? tablet,
    Widget Function(BuildContext context)? desktop,
    Widget Function(BuildContext context)? largeDesktop,
    Widget Function(BuildContext context)? tabletOrLarger,
    Widget Function(BuildContext context)? mobileOrTablet,
  }) {
    final type = getScreenType(context);

    if (type == ScreenType.mobile) {
      return mobile?.call(context) ??
             tabletOrLarger?.call(context) ??
             desktop?.call(context) ??
             const SizedBox();
    } else if (type == ScreenType.tablet) {
      return tablet?.call(context) ??
             tabletOrLarger?.call(context) ??
             mobile?.call(context) ??
             const SizedBox();
    } else if (type == ScreenType.desktop) {
      return desktop?.call(context) ??
             tabletOrLarger?.call(context) ??
             tablet?.call(context) ??
             const SizedBox();
    } else {
      return largeDesktop?.call(context) ??
             desktop?.call(context) ??
             tabletOrLarger?.call(context) ??
             const SizedBox();
    }
  }

  /// 获取内边距
  static EdgeInsets getPadding(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return const EdgeInsets.all(12);
      case ScreenType.tablet:
        return const EdgeInsets.all(16);
      case ScreenType.desktop:
        return const EdgeInsets.all(24);
      case ScreenType.largeDesktop:
        return const EdgeInsets.all(32);
    }
  }

  /// 获取卡片内边距
  static EdgeInsets getCardPadding(BuildContext context) {
    final type = getScreenType(context);
    switch (type) {
      case ScreenType.mobile:
        return const EdgeInsets.all(12);
      case ScreenType.tablet:
        return const EdgeInsets.all(16);
      default:
        return const EdgeInsets.all(16);
    }
  }
}

/// 屏幕类型枚举
enum ScreenType {
  mobile,
  tablet,
  desktop,
  largeDesktop,
}

/// 响应式组件
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ScreenType type) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = ResponsiveUtil.getScreenTypeFromWidth(constraints.maxWidth);
        return builder(context, type);
      },
    );
  }
}

/// 响应式栅格组件
class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 12,
    this.runSpacing = 12,
    this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = ResponsiveUtil.getScreenTypeFromWidth(constraints.maxWidth);
        int columns;
        
        switch (type) {
          case ScreenType.mobile:
            columns = mobileColumns ?? 2;
            break;
          case ScreenType.tablet:
            columns = tabletColumns ?? 3;
            break;
          default:
            columns = desktopColumns ?? 4;
        }

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            final availableWidth = constraints.maxWidth - (spacing * (columns - 1));
            final itemWidth = availableWidth / columns;
            return SizedBox(
              width: itemWidth,
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

/// 响应式文本组件
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? mobileStyle;
  final TextStyle? tabletStyle;
  final TextStyle? desktopStyle;
  final TextAlign? textAlign;

  const ResponsiveText({
    super.key,
    required this.text,
    this.mobileStyle,
    this.tabletStyle,
    this.desktopStyle,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final type = ResponsiveUtil.getScreenTypeFromWidth(constraints.maxWidth);
        TextStyle? style;

        switch (type) {
          case ScreenType.mobile:
            style = mobileStyle;
            break;
          case ScreenType.tablet:
            style = tabletStyle ?? mobileStyle;
            break;
          default:
            style = desktopStyle ?? tabletStyle ?? mobileStyle;
        }

        return Text(
          text,
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
}

/// 响应式边距组件
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets? mobilePadding;
  final EdgeInsets? tabletPadding;
  final EdgeInsets? desktopPadding;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobilePadding,
    this.tabletPadding,
    this.desktopPadding,
  });

  @override
  Widget build(BuildContext context) {
    final type = ResponsiveUtil.getScreenType(context);
    EdgeInsets padding;

    switch (type) {
      case ScreenType.mobile:
        padding = mobilePadding ?? const EdgeInsets.all(12);
        break;
      case ScreenType.tablet:
        padding = tabletPadding ?? const EdgeInsets.all(16);
        break;
      default:
        padding = desktopPadding ?? const EdgeInsets.all(24);
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}
