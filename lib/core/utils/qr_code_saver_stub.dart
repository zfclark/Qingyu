/// QR Code Saver Stub Implementation
/// Author: ZF_Clark
/// Description: Stub implementation for non-web platforms. This file is used when compiling for Android, iOS, or desktop platforms.
/// Last Modified: 2026/02/19
library;

import 'dart:typed_data';

/// 非Web平台二维码保存器存根
/// 此类在非Web平台上不执行任何操作
class QrCodeSaverWeb {
  /// 存根方法，在非Web平台上不应被调用
  ///
  /// [imageBytes] - 图片字节数据
  /// [fileName] - 文件名
  /// 返回值：始终返回false，表示不支持
  static Future<bool> saveQrCode(Uint8List imageBytes, String fileName) async {
    throw UnsupportedError('Web save is not supported on this platform');
  }
}
