/// App configuration constants
/// Author: ZF_Clark
/// Description: Provides global configuration values for the application.
/// Last Modified: 2026/02/09
library;

import 'package:flutter/material.dart';
import '../../core/utils/platform_util.dart';
import '../../presentation/pages/hash/hash_calculator_page.dart';
import '../../presentation/pages/text_tools/text_tools_page.dart';
import '../../presentation/pages/unit_converter/unit_converter_page.dart';
import '../../presentation/pages/qr_code/qr_code_generator_page.dart';
import '../../presentation/pages/calculator/calculator_page.dart';
import '../../presentation/pages/ping/ping_test_page.dart';

class AppConfig {
  /// App name
  static const String appName = '清隅';

  /// App version
  static const String appVersion = '0.1.0';

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

  /// Tool categories and items
  static Map<String, List<Map<String, dynamic>>> get toolCategories {
    final categories = <String, List<Map<String, dynamic>>>{
      '常用工具': [
        {
          'id': 'text_tools',
          'name': '文本工具',
          'icon': Icons.text_fields,
          'description': '文本处理工具集',
          'widget': TextToolsPage(),
          'color': null,
        },
        {
          'id': 'unit_converter',
          'name': '单位转换',
          'icon': Icons.compare_arrows,
          'description': '各种单位之间的转换',
          'widget': UnitConverterPage(),
          'color': null,
        },
      ],
      '计算工具': [
        {
          'id': 'calculator',
          'name': '计算器',
          'icon': Icons.calculate_outlined,
          'description': '基础四则运算',
          'widget': CalculatorPage(),
          'color': null,
        },
        {
          'id': 'hash_calculator',
          'name': '哈希计算器',
          'icon': Icons.calculate,
          'description': '支持SHA1、SHA256、SHA512、MD5算法',
          'widget': HashCalculatorPage(),
          'color': null,
        },
      ],
      '日常工具': [
        {
          'id': 'qr_code',
          'name': '二维码生成',
          'icon': Icons.qr_code,
          'description': '将文本转换为二维码',
          'widget': QrCodeGeneratorPage(),
          'color': null,
        },
      ],
    };

    // 仅在移动平台上添加Ping测试工具
    if (PlatformUtil.isPingTestSupported()) {
      categories['网络工具'] = [
        {
          'id': 'ping_test',
          'name': 'Ping测试',
          'icon': Icons.network_ping,
          'description': '网络连通性测试',
          'widget': PingTestPage(),
          'color': null,
        },
      ];
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
        'widget': null,
        'color': null,
      },
      {
        'id': 'news',
        'name': '新闻资讯',
        'icon': Icons.article,
        'description': '最新新闻头条',
        'widget': null,
        'color': null,
      },
      {
        'id': 'ip_lookup',
        'name': 'IP查询',
        'icon': Icons.location_on,
        'description': '查询IP地址信息',
        'widget': null,
        'color': null,
      },
    ],
    'API工具': [
      {
        'id': 'api_tester',
        'name': 'API测试',
        'icon': Icons.api,
        'description': 'HTTP接口测试工具',
        'widget': null,
        'color': null,
      },
    ],
  };
}
