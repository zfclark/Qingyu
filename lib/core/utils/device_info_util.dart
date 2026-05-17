/// Device Info Utility
/// Author: ZF_Clark
/// Description: Provides device hardware and software information collection utilities. Pure utility class without UI dependencies.
library;

import 'dart:io' show Platform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 设备信息数据模型
class DeviceInfoData {
  final String deviceModel;
  final String brand;
  final String manufacturer;
  final String osName;
  final String osVersion;
  final String cpuArchitecture;
  final double screenDiagonal;
  final double screenWidth;
  final double screenHeight;
  final double pixelDensity;
  final String appVersion;
  final String packageName;
  final String language;
  final String timezone;
  final String totalMemory;

  const DeviceInfoData({
    required this.deviceModel,
    required this.brand,
    required this.manufacturer,
    required this.osName,
    required this.osVersion,
    required this.cpuArchitecture,
    required this.screenDiagonal,
    required this.screenWidth,
    required this.screenHeight,
    required this.pixelDensity,
    required this.appVersion,
    required this.packageName,
    required this.language,
    required this.timezone,
    required this.totalMemory,
  });

  /// 获取所有信息为键值对列表（用于UI展示）
  List<Map<String, String>> toInfoList() {
    return [
      {'label': '设备型号', 'value': deviceModel, 'icon': 'smartphone'},
      {'label': '品牌', 'value': brand, 'icon': 'brand'},
      {'label': '制造商', 'value': manufacturer, 'icon': 'business'},
      {'label': '操作系统', 'value': '$osName $osVersion', 'icon': 'os'},
      {'label': 'CPU架构', 'value': cpuArchitecture, 'icon': 'cpu'},
      {'label': '屏幕尺寸', 'value': '${screenDiagonal.toStringAsFixed(1)} 英寸', 'icon': 'screen'},
      {'label': '屏幕分辨率', 'value': '${screenWidth.toInt()} × ${screenHeight.toInt()}', 'icon': 'resolution'},
      {'label': '像素密度', 'value': '${pixelDensity.toStringAsFixed(1)} dpi', 'icon': 'density'},
      {'label': '总内存', 'value': totalMemory, 'icon': 'memory'},
      {'label': '应用版本', 'value': appVersion, 'icon': 'info'},
      {'label': '包名', 'value': packageName, 'icon': 'package'},
      {'label': '系统语言', 'value': language, 'icon': 'language'},
      {'label': '时区', 'value': timezone, 'icon': 'timezone'},
    ];
  }
}

/// 设备信息工具类
/// 提供设备硬件和软件信息获取功能
class DeviceInfoUtil {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// 收集设备信息
  ///
  /// [context] 用于获取 MediaQuery 信息
  /// [appVersion] 应用版本号
  /// 返回 DeviceInfoData
  static Future<DeviceInfoData> getDeviceInfo(BuildContext context, {String appVersion = '1.2.0'}) async {
    String deviceModel = '未知';
    String brand = '未知';
    String manufacturer = '未知';
    String osName = '未知';
    String osVersion = '未知';
    String cpuArchitecture = '未知';
    String totalMemory = '未知';

    // 在异步前捕获屏幕信息
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;
    final pixelDensity = mediaQuery.devicePixelRatio;
    final diagonal = _calculateDiagonal(size.width, size.height, pixelDensity);

    try {
      if (!kIsWeb) {
        if (Platform.isAndroid) {
          final info = await _deviceInfo.androidInfo;
          deviceModel = info.model;
          brand = info.brand;
          manufacturer = info.manufacturer;
          osName = 'Android';
          osVersion = info.version.release;
          cpuArchitecture = info.supportedAbis.isNotEmpty ? info.supportedAbis.join(', ') : '未知';
        } else if (Platform.isIOS) {
          final info = await _deviceInfo.iosInfo;
          deviceModel = info.utsname.machine;
          brand = 'Apple';
          manufacturer = 'Apple';
          osName = 'iOS';
          osVersion = info.systemVersion;
          cpuArchitecture = info.utsname.machine;
        } else if (Platform.isWindows) {
          final info = await _deviceInfo.windowsInfo;
          deviceModel = info.computerName;
          brand = 'Windows PC';
          manufacturer = info.computerName;
          osName = 'Windows';
          osVersion = info.buildNumber.toString();
          cpuArchitecture = info.computerName;
        } else if (Platform.isMacOS) {
          final info = await _deviceInfo.macOsInfo;
          deviceModel = info.model;
          brand = 'Apple';
          manufacturer = 'Apple';
          osName = 'macOS';
          osVersion = info.osRelease;
        } else if (Platform.isLinux) {
          final info = await _deviceInfo.linuxInfo;
          deviceModel = info.name;
          brand = 'Linux';
          manufacturer = '';
          osName = 'Linux';
          osVersion = info.version ?? '';
        }
      } else {
        final info = await _deviceInfo.webBrowserInfo;
        deviceModel = info.vendor ?? 'Web Browser';
        brand = info.vendor ?? '';
        manufacturer = '';
        osName = info.platform ?? 'Web';
        osVersion = info.userAgent?.isNotEmpty == true ? info.userAgent!.split(';').length > 1 ? info.userAgent!.split(';')[1].trim() : '' : '';
        cpuArchitecture = info.userAgent ?? '';
      }
    } catch (e) {
      deviceModel = '获取失败';
    }

    return DeviceInfoData(
      deviceModel: deviceModel,
      brand: brand,
      manufacturer: manufacturer,
      osName: osName,
      osVersion: osVersion,
      cpuArchitecture: cpuArchitecture,
      screenDiagonal: diagonal,
      screenWidth: size.width * pixelDensity,
      screenHeight: size.height * pixelDensity,
      pixelDensity: pixelDensity,
      appVersion: appVersion,
      packageName: 'com.zfclark.qingyu',
      language: WidgetsBinding.instance.platformDispatcher.locales.firstOrNull?.toString() ?? '未知',
      timezone: DateTime.now().timeZoneName,
      totalMemory: totalMemory,
    );
  }

  /// 计算屏幕对角线尺寸（英寸）
  static double _calculateDiagonal(double widthPx, double heightPx, double pixelDensity) {
    const dpi = 160.0;
    final widthInches = widthPx / dpi;
    final heightInches = heightPx / dpi;
    return (widthInches * widthInches + heightInches * heightInches);
  }
}
