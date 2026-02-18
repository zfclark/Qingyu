/// Platform Utility
/// Author: ZF_Clark
/// Description: Provides platform detection utilities to identify the current operating system and device type. Supports caching for improved performance and forward compatibility with future system versions.
/// Last Modified: 2026/02/10
library;

import 'dart:io';

/// 平台工具类
/// 提供平台检测功能，支持移动平台识别和缓存机制
class PlatformUtil {
  /// 缓存平台检测结果，提高性能
  static bool? _isAndroid;
  static bool? _isIOS;
  static bool? _isMobilePlatform;
  static bool? _isWeb;
  static bool? _isWindows;
  static bool? _isMacOS;
  static bool? _isLinux;

  /// 检测当前平台是否为Android
  ///
  /// 返回值：如果当前平台是Android，返回true；否则返回false
  static bool isAndroid() {
    if (_isAndroid == null) {
      try {
        _isAndroid = Platform.isAndroid;
      } catch (e) {
        _isAndroid = false;
      }
    }
    return _isAndroid!;
  }

  /// 检测当前平台是否为iOS
  ///
  /// 返回值：如果当前平台是iOS，返回true；否则返回false
  static bool isIOS() {
    if (_isIOS == null) {
      try {
        _isIOS = Platform.isIOS;
      } catch (e) {
        _isIOS = false;
      }
    }
    return _isIOS!;
  }

  /// 检测当前平台是否为移动平台（Android或iOS）
  ///
  /// 返回值：如果当前平台是Android或iOS，返回true；否则返回false
  static bool isMobilePlatform() {
    _isMobilePlatform ??= isAndroid() || isIOS();
    return _isMobilePlatform!;
  }

  /// 检测当前平台是否为Web
  ///
  /// 返回值：如果当前平台是Web，返回true；否则返回false
  static bool isWeb() {
    if (_isWeb == null) {
      try {
        // Web平台不支持Platform类，会抛出异常
        Platform.isAndroid;
        _isWeb = false;
      } catch (e) {
        _isWeb = true;
      }
    }
    return _isWeb!;
  }

  /// 检测当前平台是否为Windows
  ///
  /// 返回值：如果当前平台是Windows，返回true；否则返回false
  static bool isWindows() {
    if (_isWindows == null) {
      try {
        _isWindows = Platform.isWindows;
      } catch (e) {
        _isWindows = false;
      }
    }
    return _isWindows!;
  }

  /// 检测当前平台是否为macOS
  ///
  /// 返回值：如果当前平台是macOS，返回true；否则返回false
  static bool isMacOS() {
    if (_isMacOS == null) {
      try {
        _isMacOS = Platform.isMacOS;
      } catch (e) {
        _isMacOS = false;
      }
    }
    return _isMacOS!;
  }

  /// 检测当前平台是否为Linux
  ///
  /// 返回值：如果当前平台是Linux，返回true；否则返回false
  static bool isLinux() {
    if (_isLinux == null) {
      try {
        _isLinux = Platform.isLinux;
      } catch (e) {
        _isLinux = false;
      }
    }
    return _isLinux!;
  }

  /// 检测当前平台是否为桌面平台（Windows、macOS、Linux）
  ///
  /// 返回值：如果当前平台是桌面平台，返回true；否则返回false
  static bool isDesktopPlatform() {
    return isWindows() || isMacOS() || isLinux();
  }

  /// 获取当前平台的名称
  ///
  /// 返回值：当前平台的名称字符串
  static String getPlatformName() {
    if (isAndroid()) return 'Android';
    if (isIOS()) return 'iOS';
    if (isWindows()) return 'Windows';
    if (isMacOS()) return 'macOS';
    if (isLinux()) return 'Linux';
    if (isWeb()) return 'Web';
    return 'Unknown';
  }

  /// 检测当前平台是否支持ping测试
  ///
  /// 根据需求，仅在Android和iOS平台上支持ping测试
  /// 返回值：如果当前平台支持ping测试，返回true；否则返回false
  static bool isPingTestSupported() {
    return isMobilePlatform();
  }

  /// 清除平台检测缓存，强制重新检测
  ///
  /// 当需要重新检测平台时调用此方法
  static void clearCache() {
    _isAndroid = null;
    _isIOS = null;
    _isMobilePlatform = null;
    _isWeb = null;
    _isWindows = null;
    _isMacOS = null;
    _isLinux = null;
  }
}
