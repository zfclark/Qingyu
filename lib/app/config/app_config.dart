/// App configuration constants
/// Author: ZF_Clark
/// Description: Provides global configuration values for the application.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import '../../core/services/platform_service.dart';
import '../../presentation/pages/hash/hash_calculator_page.dart';
import '../../presentation/pages/text_tools/text_tools_page.dart';
import '../../presentation/pages/unit_converter/unit_converter_page.dart';
import '../../presentation/pages/qr_code/qr_code_generator_page.dart';
import '../../presentation/pages/calculator/calculator_page.dart';
import '../../presentation/pages/ping/ping_test_page.dart';
import '../../presentation/pages/time_screen/time_screen_page.dart';
import '../../presentation/pages/json_tools/json_tools_page.dart';
import '../../presentation/pages/color_tools/color_tools_page.dart';
import '../../presentation/pages/number_base_tools/number_base_tools_page.dart';
import '../../presentation/pages/uuid_tools/uuid_tools_page.dart';
import '../../presentation/pages/password_tools/password_tools_page.dart';
import '../../presentation/pages/encoding_tools/encoding_tools_page.dart';
import '../../presentation/pages/regex_tools/regex_tools_page.dart';
import '../../presentation/pages/time_calculator/time_calculator_page.dart';
import '../../presentation/pages/random_tools/random_tools_page.dart';
import '../../presentation/pages/word_count/word_count_page.dart';
import '../../presentation/pages/diff_tools/diff_tools_page.dart';
import '../../presentation/pages/file_size_tools/file_size_tools_page.dart';
import '../../presentation/pages/timestamp_tools/timestamp_tools_page.dart';
import '../../presentation/pages/bmi_calculator/bmi_calculator_page.dart';
import '../../presentation/pages/pinyin/pinyin_page.dart';
import '../../presentation/pages/decibel/decibel_page.dart';
import '../../presentation/pages/device_info/device_info_page.dart';

class AppConfig {
  /// App name
  static const String appName = '清隅';

  /// App version
  static const String appVersion = '1.2.0';

  /// Copyright information
  static const String copyright = '© 2026 ZF-Clark';

  /// Cache key for hash history
  static const String hashHistoryKey = 'hash_history';

  /// Cache key for favorite tools
  static const String favoriteToolsKey = 'favorite_tools';

  /// Cache key for theme mode
  static const String themeModeKey = 'theme_mode';

  /// Cache key for font size
  static const String fontSizeKey = 'font_size';

  /// Maximum history records to store
  static const int maxHistoryRecords = 50;

  /// Tool categories and items - 使用静态常量避免重复创建
  static final Map<String, List<Map<String, dynamic>>> toolCategories =
      _buildToolCategories();

  /// 构建工具分类
  static Map<String, List<Map<String, dynamic>>> _buildToolCategories() {
    final categories = <String, List<Map<String, dynamic>>>{
      // ===== 生活便捷 =====
      '生活便捷': [
        {
          'id': 'text_tools',
          'name': '文本工具',
          'icon': Icons.text_fields,
          'description': '文本处理工具集',
          'widget': TextToolsPage,
          'color': null,
        },
        {
          'id': 'word_count',
          'name': '字数统计',
          'icon': Icons.abc,
          'description': '统计字符与阅读时间',
          'widget': WordCountPage,
          'color': null,
        },
        {
          'id': 'diff_tools',
          'name': '文本对比',
          'icon': Icons.difference,
          'description': '对比两个文本差异',
          'widget': DiffToolsPage,
          'color': null,
        },
        {
          'id': 'time_calculator',
          'name': '时间计算',
          'icon': Icons.schedule,
          'description': '日期计算与年龄测算',
          'widget': TimeCalculatorPage,
          'color': null,
        },
        {
          'id': 'timestamp_tools',
          'name': '时间戳转换',
          'icon': Icons.timer,
          'description': 'Unix 时间戳互转',
          'widget': TimestampToolsPage,
          'color': null,
        },
        {
          'id': 'random_tools',
          'name': '随机生成',
          'icon': Icons.casino,
          'description': '随机数与随机选择',
          'widget': RandomToolsPage,
          'color': null,
        },
      ],

      // ===== 数据处理 =====
      '数据处理': [
        {
          'id': 'json_tools',
          'name': 'JSON 工具',
          'icon': Icons.data_object,
          'description': 'JSON 格式化与验证',
          'widget': JsonToolsPage,
          'color': null,
        },
        {
          'id': 'encoding_tools',
          'name': '编码解码',
          'icon': Icons.translate,
          'description': 'Base64/URL/HTML 编码',
          'widget': EncodingToolsPage,
          'color': null,
        },
        {
          'id': 'number_base_tools',
          'name': '进制转换',
          'icon': Icons.swap_horiz,
          'description': '二进制/十进制/十六进制',
          'widget': NumberBaseToolsPage,
          'color': null,
        },
        {
          'id': 'hash_calculator',
          'name': '哈希计算',
          'icon': Icons.tag,
          'description': 'SHA/MD5 哈希算法',
          'widget': HashCalculatorPage,
          'color': null,
        },
        {
          'id': 'file_size_tools',
          'name': '文件大小',
          'icon': Icons.sd_storage,
          'description': '字节与容量单位转换',
          'widget': FileSizeToolsPage,
          'color': null,
        },
      ],

      // ===== 开发工具 =====
      '开发工具': [
        {
          'id': 'regex_tools',
          'name': '正则匹配',
          'icon': Icons.code,
          'description': '正则表达式匹配',
          'widget': RegexToolsPage,
          'color': null,
        },
        {
          'id': 'calculator',
          'name': '计算器',
          'icon': Icons.calculate,
          'description': '基础与科学计算',
          'widget': CalculatorPage,
          'color': null,
        },
        {
          'id': 'uuid_tools',
          'name': 'UUID 生成',
          'icon': Icons.fingerprint,
          'description': '生成唯一标识符',
          'widget': UuidToolsPage,
          'color': null,
        },
        {
          'id': 'password_tools',
          'name': '密码生成',
          'icon': Icons.password,
          'description': '随机密码与强度检测',
          'widget': PasswordToolsPage,
          'color': null,
        },
        {
          'id': 'color_tools',
          'name': '颜色转换',
          'icon': Icons.palette,
          'description': 'HEX/RGB/HSL 互转',
          'widget': ColorToolsPage,
          'color': null,
        },
      ],

      // ===== 实用工具 =====
      '实用工具': [
        {
          'id': 'qr_code',
          'name': '二维码',
          'icon': Icons.qr_code,
          'description': '生成二维码图片',
          'widget': QrCodeGeneratorPage,
          'color': null,
        },
        {
          'id': 'time_screen',
          'name': '时钟屏',
          'icon': Icons.access_time,
          'description': '全屏时间显示',
          'widget': TimeScreenPage,
          'color': null,
        },
        {
          'id': 'unit_converter',
          'name': '单位转换',
          'icon': Icons.compare_arrows,
          'description': '长度/重量/温度转换',
          'widget': UnitConverterPage,
          'color': null,
        },
        {
          'id': 'bmi_calculator',
          'name': 'BMI 计算',
          'icon': Icons.monitor_heart,
          'description': '身体质量指数评估',
          'widget': BmiCalculatorPage,
          'color': null,
        },
        {
          'id': 'pinyin',
          'name': '中文转拼音',
          'icon': Icons.text_fields,
          'description': '中文文本转拼音',
          'widget': PinyinPage,
          'color': null,
        },
        {
          'id': 'decibel',
          'name': '分贝检测',
          'icon': Icons.hearing,
          'description': '环境噪音检测',
          'widget': DecibelPage,
          'color': null,
        },
        {
          'id': 'device_info',
          'name': '设备信息',
          'icon': Icons.phone_android,
          'description': '查看设备硬件与系统信息',
          'widget': DeviceInfoPage,
          'color': null,
        },
      ],
    };

    // 仅在移动平台上添加 Ping 测试工具
    if (PlatformService.supportsNativeFeatures) {
      (categories['实用工具'] ?? []).add({
        'id': 'ping_test',
        'name': 'Ping 测试',
        'icon': Icons.network_ping,
        'description': '网络连通性测试',
        'widget': PingTestPage,
        'color': null,
      });
    }

    return categories;
  }

  /// Online tool categories and items
  static const Map<String, List<Map<String, dynamic>>> onlineTools = {
    '在线服务': [
      {
        'id': 'weather',
        'name': '天气查询',
        'icon': Icons.wb_sunny,
        'description': '实时天气信息',
        'widgetBuilder': null,
        'url': 'https://weather.com/',
      },
      {
        'id': 'translate',
        'name': '在线翻译',
        'icon': Icons.translate,
        'description': '多语言翻译服务',
        'widgetBuilder': null,
        'url': 'https://translate.google.com/',
      },
      {
        'id': 'map',
        'name': '地图导航',
        'icon': Icons.map,
        'description': '在线地图服务',
        'widgetBuilder': null,
        'url': 'https://maps.google.com/',
      },
    ],
  };

  /// Get all tools as a flat list
  static List<Map<String, dynamic>> getAllTools() {
    final tools = <Map<String, dynamic>>[];
    for (final category in toolCategories.values) {
      tools.addAll(category);
    }
    return tools;
  }
}
