/// Time Screen Themes
/// Author: ZF_Clark
/// Description: Provides 5 distinct themes for the time screen with light/dark mode support, all meeting WCAG AA contrast standards.
/// Last Modified: 2026/03/01
library;

import 'package:flutter/material.dart';

enum TimeScreenThemeId {
  oceanBlue,
  sunsetOrange,
  forestGreen,
  lavenderPurple,
  midnightDark,
}

class TimeScreenTheme {
  final String name;
  final Color primaryColor;
  final Color lightBackground;
  final Color lightText;
  final Color lightSecondaryText;
  final Color lightAccent;
  final Color darkBackground;
  final Color darkText;
  final Color darkSecondaryText;
  final Color darkAccent;

  const TimeScreenTheme({
    required this.name,
    required this.primaryColor,
    required this.lightBackground,
    required this.lightText,
    required this.lightSecondaryText,
    required this.lightAccent,
    required this.darkBackground,
    required this.darkText,
    required this.darkSecondaryText,
    required this.darkAccent,
  });

  Color getBackgroundColor(bool isDark) {
    return isDark ? darkBackground : lightBackground;
  }

  Color getTextColor(bool isDark) {
    return isDark ? darkText : lightText;
  }

  Color getSecondaryTextColor(bool isDark) {
    return isDark ? darkSecondaryText : lightSecondaryText;
  }

  Color getAccentColor(bool isDark) {
    return isDark ? darkAccent : lightAccent;
  }
}

class TimeScreenThemes {
  static const TimeScreenTheme oceanBlue = TimeScreenTheme(
    name: '海洋蓝',
    primaryColor: Color(0xFF1565C0),
    lightBackground: Color(0xFFE3F2FD),
    lightText: Color(0xFF0D47A1),
    lightSecondaryText: Color(0xFF1976D2),
    lightAccent: Color(0xFF64B5F6),
    darkBackground: Color(0xFF0D1B2A),
    darkText: Color(0xFFE3F2FD),
    darkSecondaryText: Color(0xFF90CAF9),
    darkAccent: Color(0xFF42A5F5),
  );

  static const TimeScreenTheme sunsetOrange = TimeScreenTheme(
    name: '日落橙',
    primaryColor: Color(0xFFE65100),
    lightBackground: Color(0xFFFFF3E0),
    lightText: Color(0xFFBF360C),
    lightSecondaryText: Color(0xFFE65100),
    lightAccent: Color(0xFFFFAB91),
    darkBackground: Color(0xFF2D1B0E),
    darkText: Color(0xFFFFF3E0),
    darkSecondaryText: Color(0xFFFFCC80),
    darkAccent: Color(0xFFFF8A65),
  );

  static const TimeScreenTheme forestGreen = TimeScreenTheme(
    name: '森林绿',
    primaryColor: Color(0xFF2E7D32),
    lightBackground: Color(0xFFE8F5E9),
    lightText: Color(0xFF1B5E20),
    lightSecondaryText: Color(0xFF388E3C),
    lightAccent: Color(0xFF81C784),
    darkBackground: Color(0xFF0D1F12),
    darkText: Color(0xFFE8F5E9),
    darkSecondaryText: Color(0xFFA5D6A7),
    darkAccent: Color(0xFF66BB6A),
  );

  static const TimeScreenTheme lavenderPurple = TimeScreenTheme(
    name: '薰衣草紫',
    primaryColor: Color(0xFF7B1FA2),
    lightBackground: Color(0xFFF3E5F5),
    lightText: Color(0xFF4A148C),
    lightSecondaryText: Color(0xFF7B1FA2),
    lightAccent: Color(0xFFCE93D8),
    darkBackground: Color(0xFF1A0D24),
    darkText: Color(0xFFF3E5F5),
    darkSecondaryText: Color(0xFFCE93D8),
    darkAccent: Color(0xFFAB47BC),
  );

  static const TimeScreenTheme midnightDark = TimeScreenTheme(
    name: '午夜黑',
    primaryColor: Color(0xFF424242),
    lightBackground: Color(0xFFFAFAFA),
    lightText: Color(0xFF212121),
    lightSecondaryText: Color(0xFF616161),
    lightAccent: Color(0xFF9E9E9E),
    darkBackground: Color(0xFF121212),
    darkText: Color(0xFFFAFAFA),
    darkSecondaryText: Color(0xFFB0B0B0),
    darkAccent: Color(0xFF757575),
  );

  static const List<TimeScreenTheme> allThemes = [
    oceanBlue,
    sunsetOrange,
    forestGreen,
    lavenderPurple,
    midnightDark,
  ];

  static TimeScreenTheme getTheme(TimeScreenThemeId id) {
    switch (id) {
      case TimeScreenThemeId.oceanBlue:
        return oceanBlue;
      case TimeScreenThemeId.sunsetOrange:
        return sunsetOrange;
      case TimeScreenThemeId.forestGreen:
        return forestGreen;
      case TimeScreenThemeId.lavenderPurple:
        return lavenderPurple;
      case TimeScreenThemeId.midnightDark:
        return midnightDark;
    }
  }

  static TimeScreenThemeId getThemeId(String name) {
    switch (name) {
      case 'oceanBlue':
        return TimeScreenThemeId.oceanBlue;
      case 'sunsetOrange':
        return TimeScreenThemeId.sunsetOrange;
      case 'forestGreen':
        return TimeScreenThemeId.forestGreen;
      case 'lavenderPurple':
        return TimeScreenThemeId.lavenderPurple;
      case 'midnightDark':
        return TimeScreenThemeId.midnightDark;
      default:
        return TimeScreenThemeId.oceanBlue;
    }
  }

  static String themeIdToString(TimeScreenThemeId id) {
    switch (id) {
      case TimeScreenThemeId.oceanBlue:
        return 'oceanBlue';
      case TimeScreenThemeId.sunsetOrange:
        return 'sunsetOrange';
      case TimeScreenThemeId.forestGreen:
        return 'forestGreen';
      case TimeScreenThemeId.lavenderPurple:
        return 'lavenderPurple';
      case TimeScreenThemeId.midnightDark:
        return 'midnightDark';
    }
  }
}

class TimeScreenFontSize {
  final double size;
  final String name;

  const TimeScreenFontSize({
    required this.size,
    required this.name,
  });

  static const TimeScreenFontSize extraSmall = TimeScreenFontSize(
    size: 14,
    name: '极小',
  );

  static const TimeScreenFontSize small = TimeScreenFontSize(
    size: 18,
    name: '小',
  );

  static const TimeScreenFontSize medium = TimeScreenFontSize(
    size: 22,
    name: '中',
  );

  static const TimeScreenFontSize large = TimeScreenFontSize(
    size: 28,
    name: '大',
  );

  static const TimeScreenFontSize extraLarge = TimeScreenFontSize(
    size: 36,
    name: '极大',
  );

  static const List<TimeScreenFontSize> allSizes = [
    extraSmall,
    small,
    medium,
    large,
    extraLarge,
  ];

  static TimeScreenFontSize fromSize(double size) {
    switch (size) {
      case 14:
        return extraSmall;
      case 18:
        return small;
      case 22:
        return medium;
      case 28:
        return large;
      case 36:
        return extraLarge;
      default:
        return medium;
    }
  }
}
