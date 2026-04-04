/// Time Screen Settings Model
/// Author: ZF_Clark
/// Description: Data model for time screen settings including theme, font size, seconds display, and dark mode preferences.
/// Last Modified: 2026/03/01
library;

import '../../presentation/pages/time_screen/themes/time_screen_themes.dart';

class TimeScreenSettings {
  final TimeScreenThemeId themeId;
  final double fontSize;
  final bool showSeconds;
  final bool isDarkMode;
  final bool followSystemTheme;

  const TimeScreenSettings({
    this.themeId = TimeScreenThemeId.oceanBlue,
    this.fontSize = 28,
    this.showSeconds = true,
    this.isDarkMode = true,
    this.followSystemTheme = false,
  });

  TimeScreenSettings copyWith({
    TimeScreenThemeId? themeId,
    double? fontSize,
    bool? showSeconds,
    bool? isDarkMode,
    bool? followSystemTheme,
  }) {
    return TimeScreenSettings(
      themeId: themeId ?? this.themeId,
      fontSize: fontSize ?? this.fontSize,
      showSeconds: showSeconds ?? this.showSeconds,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      followSystemTheme: followSystemTheme ?? this.followSystemTheme,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeId': TimeScreenThemes.themeIdToString(themeId),
      'fontSize': fontSize,
      'showSeconds': showSeconds,
      'isDarkMode': isDarkMode,
      'followSystemTheme': followSystemTheme,
    };
  }

  factory TimeScreenSettings.fromJson(Map<String, dynamic> json) {
    return TimeScreenSettings(
      themeId: TimeScreenThemes.getThemeId(
        json['themeId'] as String? ?? 'oceanBlue',
      ),
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 22,
      showSeconds: json['showSeconds'] as bool? ?? true,
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      followSystemTheme: json['followSystemTheme'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TimeScreenSettings &&
        other.themeId == themeId &&
        other.fontSize == fontSize &&
        other.showSeconds == showSeconds &&
        other.isDarkMode == isDarkMode &&
        other.followSystemTheme == followSystemTheme;
  }

  @override
  int get hashCode {
    return Object.hash(
      themeId,
      fontSize,
      showSeconds,
      isDarkMode,
      followSystemTheme,
    );
  }
}
