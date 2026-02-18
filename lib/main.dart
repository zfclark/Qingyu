/// Main Application Entry
/// Author: ZF_Clark
/// Description: Initializes storage service and sets up the application with proper theming and routing.
/// Last Modified: 2026/02/19
library;

import 'package:flutter/material.dart';
import 'app/config/app_theme.dart';
import 'app/config/app_config.dart';
import 'core/services/storage_service.dart';
import 'presentation/pages/home/home_page.dart';

/// 应用程序入口
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化存储服务
  await StorageService.initialize();

  runApp(const MainApp());
}

/// 主应用组件
class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.system;
  String _fontSize = 'medium';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  /// 加载设置
  void _loadSettings() {
    setState(() {
      _themeMode = _getThemeModeFromStorage();
      _fontSize = StorageService.getFontSize();
    });
  }

  /// 从存储获取主题模式
  ThemeMode _getThemeModeFromStorage() {
    final themeModeString = StorageService.getThemeMode();
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// 获取字体大小配置
  FontSizeConfig _getFontSizeConfig() {
    return FontSizeConfig.fromString(_fontSize);
  }

  @override
  Widget build(BuildContext context) {
    final fontSizeConfig = _getFontSizeConfig();

    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.getLightTheme(fontSizeConfig),
      darkTheme: AppTheme.getDarkTheme(fontSizeConfig),
      themeMode: _themeMode,
      home: HomePage(
        onThemeChanged: () {
          // 设置变更时重新加载
          _loadSettings();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
