/// Time Screen Page
/// Author: ZF_Clark
/// Description: A full-screen landscape time display with flip animations, multiple themes, font size adjustment, and dark mode support.
/// Last Modified: 2026/03/01
library;

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/time_screen_settings_model.dart';
import 'themes/time_screen_themes.dart';
import 'widgets/flip_digit.dart';

class TimeScreenPage extends StatefulWidget {
  const TimeScreenPage({super.key});

  @override
  State<TimeScreenPage> createState() => _TimeScreenPageState();
}

class _TimeScreenPageState extends State<TimeScreenPage>
    with WidgetsBindingObserver {
  late TimeScreenSettings _settings;
  DateTime _currentTime = DateTime.now();
  Timer? _timer;
  bool _colonVisible = true;
  bool _isFullscreen = false;
  bool _showThemePanel = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
    _setLandscapeMode();
    _startTimer();
  }

  void _loadSettings() {
    _settings = StorageService.getTimeScreenSettings();
    setState(() {});
  }

  void _setLandscapeMode() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _restoreOrientation() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final now = DateTime.now();
      bool needUpdate = false;
      bool needColonUpdate = false;

      if (now.second != _currentTime.second ||
          now.minute != _currentTime.minute ||
          now.hour != _currentTime.hour) {
        _currentTime = now;
        _colonVisible = true;
        needUpdate = true;
      } else if (_colonVisible) {
        _colonVisible = false;
        needColonUpdate = true;
      }

      if (needUpdate || needColonUpdate) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadSettings();
      _setLandscapeMode();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _restoreOrientation();
    super.dispose();
  }

  void _saveSettings(TimeScreenSettings settings) {
    _settings = settings;
    StorageService.saveTimeScreenSettings(settings);
    _cachedFontSize = null;
    _lastFontSizeUpdate = null;
    setState(() {});
  }

  bool _getEffectiveDarkMode() {
    if (_settings.followSystemTheme) {
      return true;
    }
    return _settings.isDarkMode;
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  void _toggleDarkMode() {
    _saveSettings(_settings.copyWith(
      isDarkMode: !_getEffectiveDarkMode(),
      followSystemTheme: false,
    ));
  }

  void _increaseFontSize() {
    final sizes = TimeScreenFontSize.allSizes;
    final currentIndex = 
        sizes.indexWhere((s) => s.size == _settings.fontSize);
    if (currentIndex < sizes.length - 1) {
      _saveSettings(_settings.copyWith(fontSize: sizes[currentIndex + 1].size));
      _cachedFontSize = null;
      _lastFontSizeUpdate = null;
    }
  }

  void _decreaseFontSize() {
    final sizes = TimeScreenFontSize.allSizes;
    final currentIndex = 
        sizes.indexWhere((s) => s.size == _settings.fontSize);
    if (currentIndex > 0) {
      _saveSettings(_settings.copyWith(fontSize: sizes[currentIndex - 1].size));
      _cachedFontSize = null;
      _lastFontSizeUpdate = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _getEffectiveDarkMode();
    final theme = TimeScreenThemes.getTheme(_settings.themeId);

    return Scaffold(
      backgroundColor: theme.getBackgroundColor(isDark),
      body: SafeArea(
        child: Stack(
          children: [
            _buildTimeDisplay(theme, isDark),
            _buildTopToolbar(theme, isDark),
            _buildBottomBar(theme, isDark),
            if (_showThemePanel)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () =>
                      setState(() => _showThemePanel = false),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: _buildThemeSelectorDialog(theme, isDark),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeDisplay(TimeScreenTheme theme, bool isDark) {
    final baseFontSize = _calculateOptimalFontSize();
    final textColor = theme.getTextColor(isDark);
    final cardColor = theme.getBackgroundColor(isDark).withValues(alpha: 0.4);

    return Center(
      child: Semantics(
        label:
            '当前时间: ${_currentTime.hour}时${_currentTime.minute}分${_settings.showSeconds ? '${_currentTime.second}秒' : ''}',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildDigitCard(
              value: _currentTime.hour.toString().padLeft(2, '0'),
              fontSize: baseFontSize,
              textColor: textColor,
              cardColor: cardColor,
              theme: theme,
              isDark: isDark,
            ),
            SizedBox(width: baseFontSize * 0.15),
            TimeSeparator(
              fontSize: baseFontSize * 0.8,
              color: textColor.withValues(alpha: 0.6),
              visible: _colonVisible,
            ),
            SizedBox(width: baseFontSize * 0.15),
            _buildDigitCard(
              value: _currentTime.minute.toString().padLeft(2, '0'),
              fontSize: baseFontSize,
              textColor: textColor,
              cardColor: cardColor,
              theme: theme,
              isDark: isDark,
            ),
            if (_settings.showSeconds) ...[
              SizedBox(width: baseFontSize * 0.15),
              TimeSeparator(
                fontSize: baseFontSize * 0.6,
                color: textColor.withValues(alpha: 0.4),
                visible: _colonVisible,
              ),
              SizedBox(width: baseFontSize * 0.15),
              _buildDigitCard(
                value: _currentTime.second.toString().padLeft(2, '0'),
                fontSize: baseFontSize * 0.75,
                textColor: textColor.withValues(alpha: 0.85),
                cardColor: cardColor,
                theme: theme,
                isDark: isDark,
              ),
            ],
          ],
        ),
      ),
    );
  }

  double? _cachedFontSize;
  DateTime? _lastFontSizeUpdate;

  double _calculateOptimalFontSize() {
    final now = DateTime.now();
    if (_cachedFontSize != null && 
        _lastFontSizeUpdate != null &&
        now.difference(_lastFontSizeUpdate!).inMilliseconds < 1000) {
      return _cachedFontSize!;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final minDimension = screenHeight < screenWidth ? screenHeight : screenWidth;
    final fontSize = minDimension * 0.18 * (_settings.fontSize / 22);
    
    _cachedFontSize = fontSize;
    _lastFontSizeUpdate = now;
    return fontSize;
  }

  Widget _buildDigitCard({
    required String value,
    required double fontSize,
    required Color textColor,
    required Color cardColor,
    required TimeScreenTheme theme,
    required bool isDark,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.25,
        vertical: fontSize * 0.15,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(fontSize * 0.15),
        border: Border.all(
          color: theme.getAccentColor(isDark).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: FlipTimeBlock(
        value: value,
        fontSize: fontSize,
        textColor: textColor,
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Widget _buildTopToolbar(TimeScreenTheme theme, bool isDark) {
    final iconColor = theme.getTextColor(isDark).withValues(alpha: 0.9);
    final bgColor =
        theme.getBackgroundColor(isDark).withValues(alpha: 0.3);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildToolbarButton(
              icon: Icons.arrow_back,
              color: iconColor,
              bgColor: bgColor,
              onTap: () => Navigator.of(context).pop(),
              tooltip: '返回',
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToolbarButton(
                  icon: Icons.add,
                  color: iconColor,
                  bgColor: bgColor,
                  onTap: _increaseFontSize,
                  tooltip: '增大字体',
                ),
                const SizedBox(width: 8),
                _buildToolbarButton(
                  icon: Icons.remove,
                  color: iconColor,
                  bgColor: bgColor,
                  onTap: _decreaseFontSize,
                  tooltip: '缩小字体',
                ),
                const SizedBox(width: 8),
                _buildToolbarButton(
                  icon: _isFullscreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  color: iconColor,
                  bgColor: bgColor,
                  onTap: _toggleFullscreen,
                  tooltip: _isFullscreen ? '退出全屏' : '全屏',
                ),
                const SizedBox(width: 8),
                _buildToolbarButton(
                  icon: _getEffectiveDarkMode()
                      ? Icons.light_mode
                      : Icons.dark_mode,
                  color: iconColor,
                  bgColor: bgColor,
                  onTap: _toggleDarkMode,
                  tooltip: _getEffectiveDarkMode() ? '浅色模式' : '深色模式',
                ),
                const SizedBox(width: 8),
                _buildToolbarButton(
                  icon: Icons.more_horiz,
                  color: iconColor,
                  bgColor: bgColor,
                  onTap: () {},
                  tooltip: '更多',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    VoidCallback? onTap,
    String? tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildBottomBar(TimeScreenTheme theme, bool isDark) {
    return Positioned(
      bottom: 16,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: () => setState(() => _showThemePanel = true),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: theme.getBackgroundColor(isDark).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: theme.getAccentColor(isDark).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ..._buildThemeIndicatorDots(theme),
                const SizedBox(width: 10),
                Text(
                  '更换主题',
                  style: TextStyle(
                    color: theme.getTextColor(isDark),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildThemeIndicatorDots(TimeScreenTheme currentTheme) {
    final themes = TimeScreenThemes.allThemes;
    return themes.map((t) {
      final isSelected = t.name == currentTheme.name;
      return Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: t.primaryColor,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: Colors.white, width: 1.5)
                : null,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildThemeSelectorDialog(TimeScreenTheme theme, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 400,
        constraints: const BoxConstraints(maxHeight: 450),
        margin: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: theme.getBackgroundColor(isDark).withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDialogTitle(theme, isDark),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSectionTitle('选择主题', theme, isDark),
                    const SizedBox(height: 16),
                    _buildThemeGrid(theme, isDark),
                    const SizedBox(height: 24),
                    _buildSectionTitle('显示选项', theme, isDark),
                    const SizedBox(height: 12),
                    _buildShowSecondsToggle(theme, isDark),
                    const SizedBox(height: 8),
                    _buildDarkModeToggle(theme, isDark),
                    const SizedBox(height: 24),
                    _buildSectionTitle('字体大小', theme, isDark),
                    const SizedBox(height: 12),
                    _buildFontSizeSelector(theme, isDark),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogTitle(TimeScreenTheme theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '时钟设置',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.getTextColor(isDark),
            ),
          ),
          IconButton(
            onPressed: () =>
                setState(() => _showThemePanel = false),
            icon: Icon(Icons.close, color: theme.getTextColor(isDark)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, TimeScreenTheme theme, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: theme.getSecondaryTextColor(isDark),
      ),
    );
  }

  Widget _buildThemeGrid(TimeScreenTheme theme, bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: TimeScreenThemes.allThemes.map((t) {
        final isSelected =
            t.name == TimeScreenThemes.getTheme(_settings.themeId).name;
        return GestureDetector(
          onTap: () {
            _saveSettings(
              _settings.copyWith(
                themeId: TimeScreenThemes.getThemeId(
                  TimeScreenThemes.themeIdToString(
                    TimeScreenThemes.allThemes.indexOf(t) == 0
                        ? TimeScreenThemeId.oceanBlue
                        : TimeScreenThemes.allThemes.indexOf(t) == 1
                            ? TimeScreenThemeId.sunsetOrange
                            : TimeScreenThemes.allThemes.indexOf(t) == 2
                                ? TimeScreenThemeId.forestGreen
                                : TimeScreenThemes.allThemes.indexOf(t) == 3
                                    ? TimeScreenThemeId.lavenderPurple
                                    : TimeScreenThemeId.midnightDark,
                  ),
                ),
              ),
            );
          },
          child: Container(
            width: 110,
            height: 80,
            decoration: BoxDecoration(
              color: isSelected
                  ? t.primaryColor.withValues(alpha: 0.3)
                  : theme.getBackgroundColor(isDark).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? t.primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: t.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: t.primaryColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                            )
                          ]
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  t.name,
                  style: TextStyle(
                    color: isSelected
                        ? t.primaryColor
                        : theme.getTextColor(isDark),
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFontSizeSelector(TimeScreenTheme theme, bool isDark) {
    final sizes = TimeScreenFontSize.allSizes;
    final currentIndex =
        sizes.indexWhere((s) => s.size == _settings.fontSize);

    return Row(
      children: sizes.asMap().entries.map((entry) {
        final index = entry.key;
        final size = entry.value;
        final isSelected = index == currentIndex;

        return Expanded(
          child: GestureDetector(
            onTap: () =>
                _saveSettings(_settings.copyWith(fontSize: size.size)),
            child: Container(
              height: 44,
              margin: EdgeInsets.only(
                left: index > 0 ? 6 : 0,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.getAccentColor(isDark)
                    : theme
                        .getBackgroundColor(isDark)
                        .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  size.name,
                  style: TextStyle(
                    color: isSelected
                        ? theme.getBackgroundColor(isDark)
                        : theme.getTextColor(isDark),
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShowSecondsToggle(TimeScreenTheme theme, bool isDark) {
    return _buildToggleItem(
      '显示秒数',
      '在时间显示中包含秒数',
      _settings.showSeconds,
      (value) => _saveSettings(_settings.copyWith(showSeconds: value)),
      theme,
      isDark,
    );
  }

  Widget _buildDarkModeToggle(TimeScreenTheme theme, bool isDark) {
    return _buildToggleItem(
      '深色模式',
      '使用深色背景主题',
      _getEffectiveDarkMode(),
      _settings.followSystemTheme
          ? null
          : (value) => _saveSettings(_settings.copyWith(isDarkMode: value)),
      theme,
      isDark,
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool>? onChanged,
    TimeScreenTheme theme,
    bool isDark,
  ) {
    final isEnabled = onChanged != null;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          title,
          style: TextStyle(
            color: theme.getTextColor(isDark),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: theme.getSecondaryTextColor(isDark),
            fontSize: 12,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: theme.getAccentColor(isDark),
          activeTrackColor:
              theme.getAccentColor(isDark).withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
