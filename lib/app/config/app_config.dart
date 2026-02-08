/// App configuration constants
/// Author: ZF_Clark
/// Description: Provides global configuration values for the application.
/// Last Modified: 2026/02/08
library;

import 'package:flutter/material.dart';
import '../../presentation/pages/hash/hash_calculator_page.dart';
import '../../presentation/pages/text_tools/text_tools_page.dart';
import '../../presentation/pages/unit_converter/unit_converter_page.dart';
import '../../presentation/pages/qr_code/qr_code_generator_page.dart';
import '../../presentation/pages/calculator/calculator_page.dart';

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
  static const Map<String, List<Map<String, dynamic>>> toolCategories = {
    '常用工具': [
      {
        'id': 'hash_calculator',
        'name': '哈希计算器',
        'icon': Icons.calculate,
        'description': '支持SHA1、SHA256、SHA512、MD5算法',
        'widget': const HashCalculatorPage(),
      },
      {
        'id': 'text_tools',
        'name': '文本工具',
        'icon': Icons.text_fields,
        'description': '文本处理工具集',
        'widget': const TextToolsPage(),
      },
      {
        'id': 'unit_converter',
        'name': '单位转换',
        'icon': Icons.compare_arrows,
        'description': '各种单位之间的转换',
        'widget': const UnitConverterPage(),
      },
      {
        'id': 'qr_code',
        'name': '二维码生成',
        'icon': Icons.qr_code,
        'description': '将文本转换为二维码',
        'widget': const QrCodeGeneratorPage(),
      },
    ],
    '加密工具': [
      {
        'id': 'hash_calculator',
        'name': '哈希计算器',
        'icon': Icons.calculate,
        'description': '支持SHA1、SHA256、SHA512、MD5算法',
        'widget': const HashCalculatorPage(),
      },
      {
        'id': 'base64',
        'name': 'Base64 编解码',
        'icon': Icons.code,
        'description': 'Base64编码与解码',
        'widget': const Placeholder(),
      },
    ],
    '日常工具': [
      {
        'id': 'calculator',
        'name': '计算器',
        'icon': Icons.calculate_outlined,
        'description': '基础四则运算',
        'widget': const CalculatorPage(),
      },
      {
        'id': 'qr_code',
        'name': '二维码生成',
        'icon': Icons.qr_code,
        'description': '将文本转换为二维码',
        'widget': const QrCodeGeneratorPage(),
      },
    ],
  };
}
