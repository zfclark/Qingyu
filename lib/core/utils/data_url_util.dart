/// Data URL Utility
/// Author: ZF_Clark
/// Description: Provides Data URL encoding and decoding utilities for images and files. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

/// Data URL工具类
/// 提供Data URL编码解码功能
class DataUrlUtil {
  /// 编码文件为Data URL
  ///
  /// [mimeType] MIME类型
  /// [base64Data] Base64数据
  /// 返回Data URL字符串
  static String encode(String mimeType, String base64Data) {
    return 'data:$mimeType;base64,$base64Data';
  }

  /// 解码Data URL
  ///
  /// [dataUrl] Data URL字符串
  /// 返回解码后的Map {mimeType, base64Data, data}
  static Map<String, String?>? decode(String dataUrl) {
    if (!dataUrl.startsWith('data:')) return null;
    
    final match = RegExp(r'^data:([^;]+);base64,(.+)$').firstMatch(dataUrl);
    if (match == null) return null;
    
    return {
      'mimeType': match.group(1),
      'base64Data': match.group(2),
      'dataUrl': dataUrl,
    };
  }

  /// 验证是否为有效的Data URL
  ///
  /// [dataUrl] Data URL字符串
  /// 返回是否为有效Data URL
  static bool isValid(String dataUrl) {
    if (!dataUrl.startsWith('data:')) return false;
    return RegExp(r'^data:[^;]+;base64,.+$').hasMatch(dataUrl);
  }

  /// 从Data URL提取MIME类型
  ///
  /// [dataUrl] Data URL字符串
  /// 返回MIME类型
  static String? getMimeType(String dataUrl) {
    final decoded = decode(dataUrl);
    return decoded?['mimeType'];
  }

  /// 从Data URL提取Base64数据
  ///
  /// [dataUrl] Data URL字符串
  /// 返回Base64数据
  static String? getBase64Data(String dataUrl) {
    final decoded = decode(dataUrl);
    return decoded?['base64Data'];
  }

  /// 检查是否为图片
  ///
  /// [dataUrl] Data URL字符串
  /// 返回是否为图片类型
  static bool isImage(String dataUrl) {
    final mimeType = getMimeType(dataUrl);
    if (mimeType == null) return false;
    return mimeType.startsWith('image/');
  }

  /// 获取图片扩展名
  ///
  /// [dataUrl] Data URL字符串
  /// 返回文件扩展名
  static String? getImageExtension(String dataUrl) {
    final mimeType = getMimeType(dataUrl);
    if (mimeType == null) return null;
    
    const mimeToExt = {
      'image/jpeg': 'jpg',
      'image/png': 'png',
      'image/gif': 'gif',
      'image/webp': 'webp',
      'image/svg+xml': 'svg',
      'image/bmp': 'bmp',
      'image/x-icon': 'ico',
    };
    
    return mimeToExt[mimeType];
  }
}