/// App theme configuration
/// Author: ZF_Clark
/// Description: Provides Material 3 theme settings for light and dark modes, including color schemes, text styles, and button themes
/// Last Modified: 2026/02/19
library;

import 'package:flutter/material.dart';

/// 字体大小配置
class FontSizeConfig {
  /// 字体大小缩放因子
  final double scale;

  const FontSizeConfig({required this.scale});

  /// 小字体
  static const FontSizeConfig small = FontSizeConfig(scale: 0.85);

  /// 中等字体（默认）
  static const FontSizeConfig medium = FontSizeConfig(scale: 1.0);

  /// 大字体
  static const FontSizeConfig large = FontSizeConfig(scale: 1.15);

  /// 根据字符串获取字体配置
  static FontSizeConfig fromString(String size) {
    switch (size) {
      case 'small':
        return small;
      case 'large':
        return large;
      case 'medium':
      default:
        return medium;
    }
  }
}

class AppTheme {
  /// 获取浅色主题
  ///
  /// [fontSizeConfig] 字体大小配置，可选
  static ThemeData getLightTheme([FontSizeConfig? fontSizeConfig]) {
    final config = fontSizeConfig ?? FontSizeConfig.medium;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8EAEBD),
        brightness: Brightness.light,
      ),
      primaryColor: const Color(0xFF8EAEBD),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      cardColor: Colors.white,
      textTheme: _buildTextTheme(
        baseColor: Colors.black87,
        secondaryColor: Colors.black54,
        config: config,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  /// 获取深色主题
  ///
  /// [fontSizeConfig] 字体大小配置，可选
  static ThemeData getDarkTheme([FontSizeConfig? fontSizeConfig]) {
    final config = fontSizeConfig ?? FontSizeConfig.medium;
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6B8E9E),
        brightness: Brightness.dark,
      ),
      primaryColor: const Color(0xFF8EB4C4),
      scaffoldBackgroundColor: const Color(0xFF121212),
      cardColor: const Color(0xFF1E1E1E),
      textTheme: _buildTextTheme(
        baseColor: const Color(0xFFE0E0E0),
        secondaryColor: const Color(0xFFB0B0B0),
        config: config,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E1E1E),
        foregroundColor: Color(0xFFE0E0E0),
      ),
      dividerColor: const Color(0xFF424242),
      iconTheme: const IconThemeData(
        color: Color(0xFFB0B0B0),
      ),
    );
  }

  /// 构建文本主题
  static TextTheme _buildTextTheme({
    required Color baseColor,
    required Color secondaryColor,
    required FontSizeConfig config,
  }) {
    return TextTheme(
      bodyLarge: TextStyle(
        fontSize: 16 * config.scale,
        color: baseColor,
      ),
      bodyMedium: TextStyle(
        fontSize: 14 * config.scale,
        color: secondaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12 * config.scale,
        color: secondaryColor,
      ),
      titleLarge: TextStyle(
        fontSize: 20 * config.scale,
        fontWeight: FontWeight.bold,
        color: baseColor,
      ),
      titleMedium: TextStyle(
        fontSize: 18 * config.scale,
        fontWeight: FontWeight.w600,
        color: baseColor,
      ),
      titleSmall: TextStyle(
        fontSize: 16 * config.scale,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelLarge: TextStyle(
        fontSize: 14 * config.scale,
        fontWeight: FontWeight.w500,
        color: baseColor,
      ),
      labelMedium: TextStyle(
        fontSize: 12 * config.scale,
        fontWeight: FontWeight.w500,
        color: secondaryColor,
      ),
    );
  }

  /// Light theme configuration (deprecated, use getLightTheme instead)
  static ThemeData lightTheme = getLightTheme();

  /// Dark theme configuration (deprecated, use getDarkTheme instead)
  static ThemeData darkTheme = getDarkTheme();
}
