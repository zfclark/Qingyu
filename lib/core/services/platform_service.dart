/// Platform Service
/// Author: ZF_Clark
/// Description: Provides platform-specific services and features. Handles Web and Android platform differences.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/foundation.dart';

/// 平台服务
/// 提供平台特定的功能和服务
class PlatformService {
  /// 是否为Web平台
  static bool get isWeb => kIsWeb;

  /// 是否为移动端（Android/iOS）
  static bool get isMobile => !kIsWeb && _isMobilePlatform();

  /// 是否为Android平台
  static bool get isAndroid {
    if (kIsWeb) return false;
    return _detectPlatform() == 'android';
  }

  /// 是否为iOS平台
  static bool get isIOS {
    if (kIsWeb) return false;
    return _detectPlatform() == 'ios';
  }

  /// 是否支持原生功能（如文件访问、相机等）
  static bool get supportsNativeFeatures => !kIsWeb && isMobile;

  /// 获取平台名称
  static String get platformName {
    if (kIsWeb) return 'Web';
    return _capitalize(_detectPlatform());
  }

  /// 获取平台特性描述
  static String get platformDescription {
    if (isWeb) {
      return 'Web端 - 部分功能受限';
    } else if (isAndroid) {
      return 'Android端 - 完整功能支持';
    } else if (isIOS) {
      return 'iOS端 - 完整功能支持';
    } else {
      return '桌面端';
    }
  }

  /// 检测平台
  static String _detectPlatform() {
    // Flutter Web平台检测
    if (kIsWeb) return 'web';
    
    // 平台特定逻辑
    try {
      // 尝试使用Platform检测
      // 由于这是简化实现，使用静态检测
      return 'android'; // 默认Android
    } catch (e) {
      return 'unknown';
    }
  }

  /// 检测是否为移动平台
  static bool _isMobilePlatform() {
    final platform = _detectPlatform();
    return platform == 'android' || platform == 'ios';
  }

  /// 首字母大写
  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  /// 获取平台特定的工具列表（过滤不适合当前平台的工具）
  static List<Map<String, dynamic>> filterToolsForPlatform(List<Map<String, dynamic>> tools) {
    return tools.where((tool) {
      final id = tool['id'] as String?;
      
      // Web平台不支持的工具
      if (isWeb) {
        // Web平台不支持的工具ID列表
        const webUnsupported = ['ping_test'];
        if (webUnsupported.contains(id)) {
          return false;
        }
      }
      
      return true;
    }).toList();
  }

  /// 获取平台特定的功能配置
  static Map<String, dynamic> getPlatformConfig() {
    return {
      'platform': platformName,
      'isWeb': isWeb,
      'isMobile': isMobile,
      'supportsNativeFeatures': supportsNativeFeatures,
      'description': platformDescription,
    };
  }
}
