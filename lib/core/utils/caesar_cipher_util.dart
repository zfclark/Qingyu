/// Caesar Cipher Utility
/// Author: ZF_Clark
/// Description: Provides Caesar cipher encryption, decryption, and brute-force decoding. Supports both English letters and configurable shift values.
/// Last Modified: 2026/05/24
library;

/// 凯撒密码工具类
/// 提供凯撒密码的加密、解密和暴力破解功能
class CaesarCipherUtil {
  /// 加密明文
  ///
  /// [plaintext] 明文字符串
  /// [shift] 移位量（0-25）
  /// 返回加密后的密文
  static String encrypt(String plaintext, int shift) {
    return _transform(plaintext, shift);
  }

  /// 解密密文
  ///
  /// [ciphertext] 密文字符串
  /// [shift] 移位量（0-25）
  /// 返回解密后的明文
  static String decrypt(String ciphertext, int shift) {
    return _transform(ciphertext, 26 - (shift % 26));
  }

  /// 暴力破解密文
  ///
  /// [ciphertext] 密文字符串
  /// 返回所有 26 种可能的解密结果
  static List<Map<String, dynamic>> bruteForce(String ciphertext) {
    final results = <Map<String, dynamic>>[];
    for (int i = 0; i < 26; i++) {
      results.add({
        'shift': i,
        'text': decrypt(ciphertext, i),
      });
    }
    return results;
  }

  /// 检测移位量
  ///
  /// [knownPlaintext] 已知明文
  /// [ciphertext] 对应密文
  /// 返回检测到的移位量，无法确定时返回 null
  static int? detectShift(String knownPlaintext, String ciphertext) {
    if (knownPlaintext.length != ciphertext.length) return null;
    if (knownPlaintext.isEmpty) return null;

    final firstAlphaIndex = knownPlaintext.split('').indexWhere(
          (c) => c.contains(RegExp(r'[a-zA-Z]')),
        );
    if (firstAlphaIndex == -1) return null;

    final p = knownPlaintext[firstAlphaIndex].toLowerCase().codeUnitAt(0);
    final c = ciphertext[firstAlphaIndex].toLowerCase().codeUnitAt(0);
    if (p < 97 || p > 122 || c < 97 || c > 122) return null;

    return (c - p + 26) % 26;
  }

  /// 内部转换方法
  static String _transform(String text, int shift) {
    final effectiveShift = shift % 26;
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final code = char.codeUnitAt(0);
      if (code >= 65 && code <= 90) {
        // 大写字母
        buffer.writeCharCode((code - 65 + effectiveShift) % 26 + 65);
      } else if (code >= 97 && code <= 122) {
        // 小写字母
        buffer.writeCharCode((code - 97 + effectiveShift) % 26 + 97);
      } else {
        // 非字母字符保持不变
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}
