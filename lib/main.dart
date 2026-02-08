/// Main Application Entry
/// Author: ZF_Clark
/// Description: Initializes storage service and sets up the application with proper theming and routing.
/// Last Modified: 2026/02/08
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

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  /// 加载主题模式
  void _loadThemeMode() {
    setState(() {
      _themeMode = _getThemeModeFromStorage();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: HomePage(
        onThemeChanged: () {
          // 主题变更时重新加载
          _loadThemeMode();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
