/// App entry
/// Author: ZF_Clark
/// Description: Initializes storage service and sets up the application
/// Last Modified: 2026/02/04
/// Version: V0.1
library;

import 'package:flutter/material.dart';
import 'core/app_theme.dart';
import 'core/app_config.dart';
import 'data/services/storage_service.dart';
import 'features/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize storage service
  await StorageService.initialize();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme mode from storage
    final themeMode = _getThemeModeFromStorage();

    return MaterialApp(
      title: AppConfig.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }

  /// Get theme mode from storage
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
}
