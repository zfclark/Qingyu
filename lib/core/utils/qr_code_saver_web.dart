/// QR Code Saver Web Implementation
/// Author: ZF_Clark
/// Description: Web platform implementation for saving QR codes. Uses browser download API to save images.
/// Last Modified: 2026/02/19
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web平台二维码保存器
/// 使用浏览器下载API保存二维码图片
class QrCodeSaverWeb {
  /// 保存二维码图片到本地（Web平台）
  ///
  /// [imageBytes] - 图片字节数据
  /// [fileName] - 文件名
  /// 返回值：保存成功返回true，失败返回false
  static Future<bool> saveQrCode(Uint8List imageBytes, String fileName) async {
    try {
      final blob = web.Blob(
        [imageBytes] as JSArray<web.BlobPart>,
        'image/png' as web.BlobPropertyBag,
      );
      final url = web.URL.createObjectURL(blob);
      final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
      anchor.href = url;
      anchor.download = fileName;
      web.document.body?.appendChild(anchor);
      anchor.click();
      web.document.body?.removeChild(anchor);
      web.URL.revokeObjectURL(url);
      return true;
    } catch (e) {
      return false;
    }
  }
}
