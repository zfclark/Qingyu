/// Color Utility
/// Author: ZF_Clark
/// Description: Provides color conversion utilities between HEX, RGB, HSL, and HSV formats. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

import 'dart:ui';

/// 颜色工具类
/// 提供HEX、RGB、HSL、HSV格式之间的转换功能
class ColorUtil {
  // ==================== HEX格式转换 ====================

  /// HEX转RGB
  ///
  /// [hex] HEX颜色值，支持 #RGB、#RRGGBB、#RRGGBBAA 格式
  /// 返回RGB数组 [r, g, b]，失败返回null
  static List<int>? hexToRgb(String hex) {
    hex = hex.replaceAll('#', '').toUpperCase();

    // 处理简写格式 #RGB -> #RRGGBB
    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }

    if (hex.length == 6) {
      hex = '${hex}FF'; // 添加完全不透明 alpha
    }

    if (hex.length != 8) return null;

    try {
      return [
        int.parse(hex.substring(0, 2), radix: 16),
        int.parse(hex.substring(2, 4), radix: 16),
        int.parse(hex.substring(4, 6), radix: 16),
      ];
    } catch (e) {
      return null;
    }
  }

  /// HEX转RGBA
  ///
  /// [hex] HEX颜色值，支持 #RGB、#RRGGBB、#RRGGBBAA 格式
  /// 返回RGBA数组 [r, g, b, a]，失败返回null
  static List<int>? hexToRgba(String hex) {
    hex = hex.replaceAll('#', '').toUpperCase();

    if (hex.length == 3) {
      hex = hex.split('').map((c) => '$c$c').join();
    }

    if (hex.length == 6) {
      hex = '${hex}FF';
    }

    if (hex.length != 8) return null;

    try {
      return [
        int.parse(hex.substring(0, 2), radix: 16),
        int.parse(hex.substring(2, 4), radix: 16),
        int.parse(hex.substring(4, 6), radix: 16),
        int.parse(hex.substring(6, 8), radix: 16),
      ];
    } catch (e) {
      return null;
    }
  }

  /// RGB转HEX
  ///
  /// [r] 红色值 0-255
  /// [g] 绿色值 0-255
  /// [b] 蓝色值 0-255
  /// [includeHash] 是否包含#号前缀
  /// 返回HEX字符串，失败返回null
  static String? rgbToHex(int r, int g, int b, {bool includeHash = true}) {
    if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255) {
      return null;
    }

    final prefix = includeHash ? '#' : '';
    return '$prefix${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  /// RGBA转HEX
  ///
  /// [r] 红色值 0-255
  /// [g] 绿色值 0-255
  /// [b] 蓝色值 0-255
  /// [a] Alpha值 0-255
  /// [includeHash] 是否包含#号前缀
  /// 返回带Alpha的HEX字符串，失败返回null
  static String? rgbaToHex(int r, int g, int b, int a, {bool includeHash = true}) {
    if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255 || a < 0 || a > 255) {
      return null;
    }

    final prefix = includeHash ? '#' : '';
    return '$prefix${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${a.toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  // ==================== RGB格式转换 ====================

  /// RGB转HSL
  ///
  /// [r] 红色值 0-255
  /// [g] 绿色值 0-255
  /// [b] 蓝色值 0-255
  /// 返回HSL数组 [h, s, l]，h为0-360，s和l为0-100，失败返回null
  static List<double>? rgbToHsl(int r, int g, int b) {
    if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255) {
      return null;
    }

    final rf = r / 255.0;
    final gf = g / 255.0;
    final bf = b / 255.0;

    final max = [rf, gf, bf].reduce((a, b) => a > b ? a : b);
    final min = [rf, gf, bf].reduce((a, b) => a < b ? a : b);
    final l = (max + min) / 2;

    if (max == min) {
      // 灰度颜色
      return [0.0, 0.0, (l * 100).roundToDouble()];
    }

    final d = max - min;
    final s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

    double h;
    if (max == rf) {
      h = (gf - bf) / d + (gf < bf ? 6 : 0);
    } else if (max == gf) {
      h = (bf - rf) / d + 2;
    } else {
      h = (rf - gf) / d + 4;
    }
    h /= 6;

    return [
      (h * 360).roundToDouble(),
      (s * 100).roundToDouble(),
      (l * 100).roundToDouble(),
    ];
  }

  /// RGB转HSV
  ///
  /// [r] 红色值 0-255
  /// [g] 绿色值 0-255
  /// [b] 蓝色值 0-255
  /// 返回HSV数组 [h, s, v]，h为0-360，s和v为0-100，失败返回null
  static List<double>? rgbToHsv(int r, int g, int b) {
    if (r < 0 || r > 255 || g < 0 || g > 255 || b < 0 || b > 255) {
      return null;
    }

    final rf = r / 255.0;
    final gf = g / 255.0;
    final bf = b / 255.0;

    final max = [rf, gf, bf].reduce((a, b) => a > b ? a : b);
    final min = [rf, gf, bf].reduce((a, b) => a < b ? a : b);
    final v = max;
    final d = max - min;

    final s = max == 0 ? 0.0 : d / max;

    if (max == min) {
      return [0.0, (s * 100).roundToDouble(), (v * 100).roundToDouble()];
    }

    double h;
    if (max == rf) {
      h = (gf - bf) / d + (gf < bf ? 6 : 0);
    } else if (max == gf) {
      h = (bf - rf) / d + 2;
    } else {
      h = (rf - gf) / d + 4;
    }
    h /= 6;

    return [
      (h * 360).roundToDouble(),
      (s * 100).roundToDouble(),
      (v * 100).roundToDouble(),
    ];
  }

  // ==================== HSL格式转换 ====================

  /// HSL转RGB
  ///
  /// [h] 色相 0-360
  /// [s] 饱和度 0-100
  /// [l] 亮度 0-100
  /// 返回RGB数组 [r, g, b]，失败返回null
  static List<int>? hslToRgb(double h, double s, double l) {
    if (h < 0 || h > 360 || s < 0 || s > 100 || l < 0 || l > 100) {
      return null;
    }

    final hf = h / 360;
    final sf = s / 100;
    final lf = l / 100;

    if (sf == 0) {
      final gray = (lf * 255).round();
      return [gray, gray, gray];
    }

    final q = lf < 0.5 ? lf * (1 + sf) : lf + sf - lf * sf;
    final p = 2 * lf - q;

    return [
      (_hueToRgb(p, q, hf + 1 / 3) * 255).round(),
      (_hueToRgb(p, q, hf) * 255).round(),
      (_hueToRgb(p, q, hf - 1 / 3) * 255).round(),
    ];
  }

  static double _hueToRgb(double p, double q, double t) {
    var tVar = t;
    if (tVar < 0) tVar += 1;
    if (tVar > 1) tVar -= 1;
    if (tVar < 1 / 6) return p + (q - p) * 6 * tVar;
    if (tVar < 1 / 2) return q;
    if (tVar < 2 / 3) return p + (q - p) * (2 / 3 - tVar) * 6;
    return p;
  }

  /// HSL转HEX
  ///
  /// [h] 色相 0-360
  /// [s] 饱和度 0-100
  /// [l] 亮度 0-100
  /// [includeHash] 是否包含#号前缀
  /// 返回HEX字符串，失败返回null
  static String? hslToHex(double h, double s, double l, {bool includeHash = true}) {
    final rgb = hslToRgb(h, s, l);
    if (rgb == null) return null;
    return rgbToHex(rgb[0], rgb[1], rgb[2], includeHash: includeHash);
  }

  // ==================== HSV格式转换 ====================

  /// HSV转RGB
  ///
  /// [h] 色相 0-360
  /// [s] 饱和度 0-100
  /// [v] 明度 0-100
  /// 返回RGB数组 [r, g, b]，失败返回null
  static List<int>? hsvToRgb(double h, double s, double v) {
    if (h < 0 || h > 360 || s < 0 || s > 100 || v < 0 || v > 100) {
      return null;
    }

    final hf = h / 360;
    final sf = s / 100;
    final vf = v / 100;

    final i = (hf * 6).floor();
    final f = hf * 6 - i;
    final p = vf * (1 - sf);
    final q = vf * (1 - f * sf);
    final t = vf * (1 - (1 - f) * sf);

    int r, g, b;
    switch (i % 6) {
      case 0:
        r = (vf * 255).round();
        g = (t * 255).round();
        b = (p * 255).round();
        break;
      case 1:
        r = (q * 255).round();
        g = (vf * 255).round();
        b = (p * 255).round();
        break;
      case 2:
        r = (p * 255).round();
        g = (vf * 255).round();
        b = (t * 255).round();
        break;
      case 3:
        r = (p * 255).round();
        g = (q * 255).round();
        b = (vf * 255).round();
        break;
      case 4:
        r = (t * 255).round();
        g = (p * 255).round();
        b = (vf * 255).round();
        break;
      default:
        r = (vf * 255).round();
        g = (p * 255).round();
        b = (q * 255).round();
    }

    return [r, g, b];
  }

  /// HSV转HEX
  ///
  /// [h] 色相 0-360
  /// [s] 饱和度 0-100
  /// [v] 明度 0-100
  /// [includeHash] 是否包含#号前缀
  /// 返回HEX字符串，失败返回null
  static String? hsvToHex(double h, double s, double v, {bool includeHash = true}) {
    final rgb = hsvToRgb(h, s, v);
    if (rgb == null) return null;
    return rgbToHex(rgb[0], rgb[1], rgb[2], includeHash: includeHash);
  }

  // ==================== Flutter Color 转换 ====================

  /// 从HEX字符串创建Flutter Color
  ///
  /// [hex] HEX颜色值
  /// 返回Color对象，失败返回null
  static Color? colorFromHex(String hex) {
    final rgba = hexToRgba(hex);
    if (rgba == null) return null;
    return Color.fromARGB(rgba[3], rgba[0], rgba[1], rgba[2]);
  }

  /// Color转HEX字符串
  ///
  /// [color] Flutter Color对象
  /// [includeHash] 是否包含#号前缀
  /// [includeAlpha] 是否包含Alpha通道
  /// 返回HEX字符串
  static String colorToHex(Color color, {bool includeHash = true, bool includeAlpha = false}) {
    final prefix = includeHash ? '#' : '';
    if (includeAlpha) {
      return '$prefix${(color.r * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${(color.g * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${(color.b * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${(color.a * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase()}';
    }
    return '$prefix${(color.r * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${(color.g * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${(color.b * 255).round().clamp(0, 255).toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  // ==================== 辅助功能 ====================

  /// 获取颜色的对比色（黑或白）
  ///
  /// [hex] HEX颜色值
  /// 返回对比色HEX字符串，失败返回null
  static String? getContrastColor(String hex) {
    final rgb = hexToRgb(hex);
    if (rgb == null) return null;

    // 使用相对亮度公式
    final luminance = (0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]) / 255;
    return luminance > 0.5 ? '#000000' : '#FFFFFF';
  }

  /// 判断颜色是否为深色
  ///
  /// [hex] HEX颜色值
  /// 返回是否为深色，失败返回null
  static bool? isDarkColor(String hex) {
    final rgb = hexToRgb(hex);
    if (rgb == null) return null;

    final luminance = (0.299 * rgb[0] + 0.587 * rgb[1] + 0.114 * rgb[2]) / 255;
    return luminance < 0.5;
  }

  /// 调整颜色亮度
  ///
  /// [hex] HEX颜色值
  /// [amount] 调整量，-100到100，正值变亮，负值变暗
  /// 返回调整后的HEX字符串，失败返回null
  static String? adjustBrightness(String hex, double amount) {
    final hsl = rgbToHsl(
      hexToRgb(hex)?[0] ?? 0,
      hexToRgb(hex)?[1] ?? 0,
      hexToRgb(hex)?[2] ?? 0,
    );
    if (hsl == null) return null;

    var newL = hsl[2] + amount;
    newL = newL.clamp(0.0, 100.0);

    return hslToHex(hsl[0], hsl[1], newL);
  }

  /// 生成颜色调色板（基于色相变化）
  ///
  /// [hex] 基础HEX颜色值
  /// [count] 调色板颜色数量
  /// 返回HEX颜色数组，失败返回null
  static List<String>? generatePalette(String hex, {int count = 5}) {
    final rgb = hexToRgb(hex);
    if (rgb == null) return null;

    final hsl = rgbToHsl(rgb[0], rgb[1], rgb[2]);
    if (hsl == null) return null;

    final palette = <String>[];
    final step = 360.0 / count;

    for (int i = 0; i < count; i++) {
      final newHue = (hsl[0] + step * i) % 360;
      final hexColor = hslToHex(newHue, hsl[1], hsl[2]);
      if (hexColor != null) {
        palette.add(hexColor);
      }
    }

    return palette;
  }

  /// 解析CSS颜色字符串
  ///
  /// [colorString] CSS颜色字符串，支持 rgb(), rgba(), hsl(), hsla(), #hex
  /// 返回RGBA数组 [r, g, b, a]，失败返回null
  static List<int>? parseCssColor(String colorString) {
    colorString = colorString.trim().toLowerCase();

    // 处理 HEX
    if (colorString.startsWith('#')) {
      final rgba = hexToRgba(colorString);
      if (rgba != null) {
        return [rgba[0], rgba[1], rgba[2], 255];
      }
    }

    // 处理 rgb/rgba
    final rgbMatch = RegExp(r'rgba?\s*\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*(?:,\s*([\d.]+))?\s*\)')
        .firstMatch(colorString);
    if (rgbMatch != null) {
      final r = int.parse(rgbMatch.group(1)!);
      final g = int.parse(rgbMatch.group(2)!);
      final b = int.parse(rgbMatch.group(3)!);
      final a = rgbMatch.group(4) != null 
          ? (double.parse(rgbMatch.group(4)!) * 255).round() 
          : 255;
      return [r, g, b, a.clamp(0, 255)];
    }

    // 处理 hsl/hsla
    final hslMatch = RegExp(r'hsla?\s*\(\s*([\d.]+)\s*,\s*([\d.]+)%?\s*,\s*([\d.]+)%?\s*(?:,\s*([\d.]+))?\s*\)')
        .firstMatch(colorString);
    if (hslMatch != null) {
      final h = double.parse(hslMatch.group(1)!);
      final s = double.parse(hslMatch.group(2)!);
      final l = double.parse(hslMatch.group(3)!);
      final a = hslMatch.group(4) != null 
          ? (double.parse(hslMatch.group(4)!) * 255).round() 
          : 255;
      final rgb = hslToRgb(h, s, l);
      if (rgb != null) {
        return [rgb[0], rgb[1], rgb[2], a.clamp(0, 255)];
      }
    }

    // 处理颜色名称（基础颜色）
    final colorNames = {
      'red': [255, 0, 0, 255],
      'green': [0, 128, 0, 255],
      'blue': [0, 0, 255, 255],
      'white': [255, 255, 255, 255],
      'black': [0, 0, 0, 255],
      'gray': [128, 128, 128, 255],
      'grey': [128, 128, 128, 255],
      'orange': [255, 165, 0, 255],
      'purple': [128, 0, 128, 255],
      'yellow': [255, 255, 0, 255],
      'cyan': [0, 255, 255, 255],
      'magenta': [255, 0, 255, 255],
      'transparent': [0, 0, 0, 0],
    };

    return colorNames[colorString];
  }

  /// 获取所有格式的颜色表示
  ///
  /// [hex] HEX颜色值
  /// 返回包含所有格式的Map，失败返回null
  static Map<String, String>? getAllFormats(String hex) {
    final rgba = hexToRgba(hex);
    if (rgba == null) return null;

    final rgb = [rgba[0], rgba[1], rgba[2]];
    final hsl = rgbToHsl(rgb[0], rgb[1], rgb[2]);
    final hsv = rgbToHsv(rgb[0], rgb[1], rgb[2]);

    if (hsl == null || hsv == null) return null;

    final alphaValue = (rgba[3] / 255).toStringAsFixed(2);

    return {
      'HEX': rgbToHex(rgba[0], rgba[1], rgba[2]) ?? '',
      'HEX8': rgbaToHex(rgba[0], rgba[1], rgba[2], rgba[3]) ?? '',
      'RGB': 'rgb(${rgb.join(', ')})',
      'RGBA': 'rgba(${rgb.join(', ')}, $alphaValue)',
      'HSL': 'hsl(${hsl[0].round()}, ${hsl[1].round()}%, ${hsl[2].round()}%)',
      'HSV': 'hsv(${hsv[0].round()}, ${hsv[1].round()}%, ${hsv[2].round()}%)',
      'Flutter': 'Color(0x${rgba[3].toRadixString(16).padLeft(2, '0').toUpperCase()}${rgba[0].toRadixString(16).padLeft(2, '0').toUpperCase()}${rgba[1].toRadixString(16).padLeft(2, '0').toUpperCase()}${rgba[2].toRadixString(16).padLeft(2, '0').toUpperCase()})',
    };
  }
}
