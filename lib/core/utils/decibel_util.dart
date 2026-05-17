/// Decibel Utility
/// Author: ZF_Clark
/// Description: Provides decibel calculation and noise level classification utilities. Pure utility class without UI dependencies.
library;

import 'dart:math' as math;

/// 分贝检测工具类
/// 提供振幅转分贝及噪音等级分类功能
class DecibelUtil {
  /// 将振幅值转换为分贝值
  ///
  /// [amplitude] 振幅值（0.0 - 1.0）
  /// 返回分贝值（约 0 - 120 dB）
  static double amplitudeToDB(double amplitude) {
    if (amplitude <= 0) return 0;
    // 将振幅映射到分贝范围，使用对数尺度
    // 振幅 0.0001 ≈ 0dB, 振幅 1.0 ≈ 120dB
    final normalized = amplitude.clamp(0.0001, 1.0);
    final db = 120.0 + 20.0 * math.log(normalized) / math.ln10;
    return double.parse(db.clamp(0.0, 120.0).toStringAsFixed(1));
  }

  /// 获取分贝等级描述
  ///
  /// [db] 分贝值
  /// 返回中文等级描述
  static String getDBLevel(double db) {
    if (db < 0) return '未知';
    if (db < 30) return '安静';
    if (db < 50) return '正常';
    if (db < 70) return '较吵';
    if (db < 90) return '吵闹';
    return '刺耳';
  }

  /// 获取分贝等级对应的图标名称
  ///
  /// [db] 分贝值
  /// 返回描述性文字
  static String getLevelDescription(double db) {
    if (db < 0) return '无法检测';
    if (db < 30) return '图书馆般安静';
    if (db < 50) return '正常交谈声';
    if (db < 70) return '繁忙街道';
    if (db < 90) return '工厂车间';
    return '摇滚音乐会';
  }

  /// 获取分贝等级建议
  ///
  /// [db] 分贝值
  /// 返回健康建议
  static String getHealthAdvice(double db) {
    if (db < 0) return '';
    if (db < 30) return '非常安静，适合休息。';
    if (db < 50) return '正常环境噪音，无害。';
    if (db < 70) return '略感嘈杂，长时间可能影响注意力。';
    if (db < 90) return '噪音较大，长时间暴露可能影响听力。';
    return '噪音强烈，建议佩戴防护耳塞并减少暴露时间！';
  }

  /// 获取分贝等级对应的颜色值（ARGB）
  ///
  /// [db] 分贝值
  /// 返回 0x 格式的颜色值
  static int getDBColorInt(double db) {
    if (db < 0) return 0xFF9E9E9E;
    if (db < 30) return 0xFF4CAF50;
    if (db < 50) return 0xFF8BC34A;
    if (db < 70) return 0xFFFFEB3B;
    if (db < 90) return 0xFFFF9800;
    return 0xFFF44336;
  }

  /// 获取分贝等级对应的文本颜色值（ARGB）
  ///
  /// [db] 分贝值
  /// 返回 0x 格式的颜色值
  static int getTextColorForDB(double db) {
    if (db < 0) return 0xFFFFFFFF;
    if (db < 70) return 0xFF000000;
    return 0xFFFFFFFF;
  }

  /// 检查是否需要听力保护
  static bool needsHearingProtection(double db) {
    return db >= 85;
  }

  /// 获取安全暴露时间（分钟）
  ///
  /// [db] 分贝值
  /// 返回建议的最大暴露时间（分钟），-1表示安全
  static int getSafeExposureMinutes(double db) {
    if (db < 80) return -1;
    if (db < 85) return 480;
    if (db < 90) return 120;
    if (db < 95) return 60;
    if (db < 100) return 15;
    if (db < 105) return 5;
    return 1;
  }

  /// 计算一段振幅数据的平均分贝
  ///
  /// [amplitudes] 振幅值列表
  /// 返回平均分贝值
  static double averageDB(List<double> amplitudes) {
    if (amplitudes.isEmpty) return 0;
    final sum = amplitudes.fold<double>(0, (prev, amp) => prev + amplitudeToDB(amp));
    return double.parse((sum / amplitudes.length).toStringAsFixed(1));
  }
}
