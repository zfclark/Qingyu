/// Logger Utility
/// Author: ZF_Clark
/// Description: Provides a hierarchical logging system with DEBUG, INFO, WARNING, ERROR levels. Supports log rotation, security filtering, and runtime log level adjustment.
/// Last Modified: 2026/02/09
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// 日志级别枚举
enum LogLevel {
  /// 调试级别
  debug,

  /// 信息级别
  info,

  /// 警告级别
  warning,

  /// 错误级别
  error,
}

/// 日志工具类
/// 提供分级日志系统，支持日志轮转和安全过滤
class LoggerUtil {
  /// 单例实例
  static final LoggerUtil _instance = LoggerUtil._internal();

  /// 获取单例实例
  factory LoggerUtil() => _instance;

  /// 内部构造函数
  LoggerUtil._internal() {
    _initialize();
  }

  /// 当前日志级别
  LogLevel _currentLevel = LogLevel.info;

  /// 日志文件路径
  String? _logFilePath;

  /// 日志文件流
  File? _logFile;

  /// 日志文件大小限制（5MB）
  static const int _maxLogSize = 5 * 1024 * 1024;

  /// 最大历史日志文件数
  static const int _maxHistoryFiles = 5;

  /// 初始化日志系统
  Future<void> _initialize() async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // 在移动平台上初始化日志文件
        final directory = await _getLogDirectory();
        if (directory != null) {
          _logFilePath = '${directory.path}/app.log';
          _logFile = File(_logFilePath!);
          await _checkLogSize();
        }
      }
    } catch (e) {
      // 初始化失败时静默处理，确保应用正常运行
      debugPrint('Logger initialization failed: $e');
    }
  }

  /// 获取日志目录
  Future<Directory?> _getLogDirectory() async {
    try {
      final appDir = Directory.current;
      final logDir = Directory('${appDir.path}/logs');

      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      return logDir;
    } catch (e) {
      return null;
    }
  }

  /// 检查并轮转日志文件
  Future<void> _checkLogSize() async {
    if (_logFile == null) return;

    try {
      final fileSize = await _logFile!.length();
      if (fileSize >= _maxLogSize) {
        await _rotateLogs();
      }
    } catch (e) {
      // 检查失败时静默处理
    }
  }

  /// 轮转日志文件
  Future<void> _rotateLogs() async {
    if (_logFilePath == null) return;

    try {
      // 重命名当前日志文件
      for (int i = _maxHistoryFiles - 1; i > 0; i--) {
        final oldLogPath = '${_logFilePath!}.$i';
        final newLogPath = '${_logFilePath!}.${i + 1}';

        final oldLogFile = File(oldLogPath);
        if (await oldLogFile.exists()) {
          final newLogFile = File(newLogPath);
          if (await newLogFile.exists()) {
            await newLogFile.delete();
          }
          await oldLogFile.rename(newLogPath);
        }
      }

      // 重命名当前日志文件为 app.log.1
      final currentLogFile = File(_logFilePath!);
      if (await currentLogFile.exists()) {
        final rotatedLogFile = File('${_logFilePath!}.1');
        if (await rotatedLogFile.exists()) {
          await rotatedLogFile.delete();
        }
        await currentLogFile.rename('${_logFilePath!}.1');
      }

      // 创建新的日志文件
      _logFile = File(_logFilePath!);
    } catch (e) {
      // 轮转失败时静默处理
    }
  }

  /// 设置日志级别
  void setLogLevel(LogLevel level) {
    _currentLevel = level;
    _log(LogLevel.info, 'Logger', 'Log level set to $level');
  }

  /// 获取当前日志级别
  LogLevel getLogLevel() {
    return _currentLevel;
  }

  /// 调试级别日志
  void debug(String module, String message) {
    if (_currentLevel.index <= LogLevel.debug.index) {
      _log(LogLevel.debug, module, message);
    }
  }

  /// 信息级别日志
  void info(String module, String message) {
    if (_currentLevel.index <= LogLevel.info.index) {
      _log(LogLevel.info, module, message);
    }
  }

  /// 警告级别日志
  void warning(String module, String message, [Object? e]) {
    if (_currentLevel.index <= LogLevel.warning.index) {
      final warningMessage = e != null ? '$message\nWarning: $e' : message;
      _log(LogLevel.warning, module, warningMessage);
    }
  }

  /// 错误级别日志
  void error(String module, String message, [dynamic error]) {
    if (_currentLevel.index <= LogLevel.error.index) {
      final errorMessage = error != null ? '$message\nError: $error' : message;
      _log(LogLevel.error, module, errorMessage);
    }
  }

  /// 执行日志记录
  Future<void> _log(LogLevel level, String module, String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage =
        '$timestamp [${_levelToString(level)}] [$module] $message';

    // 在移动平台上，只输出到应用内部日志文件
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await _writeToFile(logMessage);
    } else if (kDebugMode) {
      // 在调试模式下，输出到控制台
      _printToConsole(level, logMessage);
    }
  }

  /// 写入日志到文件
  Future<void> _writeToFile(String message) async {
    if (_logFile == null) return;

    try {
      // 过滤敏感信息
      final filteredMessage = _filterSensitiveInfo(message);

      await _checkLogSize();
      await _logFile!.writeAsString(
        '$filteredMessage\n',
        mode: FileMode.append,
      );
    } catch (e) {
      // 写入失败时静默处理
    }
  }

  /// 输出日志到控制台
  void _printToConsole(LogLevel level, String message) {
    switch (level) {
      case LogLevel.debug:
        debugPrint('🔧 $message');
        break;
      case LogLevel.info:
        debugPrint('ℹ️ $message');
        break;
      case LogLevel.warning:
        debugPrint('⚠️ $message');
        break;
      case LogLevel.error:
        debugPrint('❌ $message');
        break;
    }
  }

  /// 过滤敏感信息
  String _filterSensitiveInfo(String message) {
    // 过滤IP地址
    message = message.replaceAll(
      RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b'),
      '[IP_ADDRESS]',
    );

    // 过滤设备ID
    message = message.replaceAll(RegExp(r'[0-9A-Fa-f]{16,}'), '[DEVICE_ID]');

    // 过滤用户数据
    message = message.replaceAll(
      RegExp(r'user|username|email|phone|password|token', caseSensitive: false),
      '[USER_DATA]',
    );

    return message;
  }

  /// 将日志级别转换为字符串
  String _levelToString(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARNING';
      case LogLevel.error:
        return 'ERROR';
    }
  }

  /// 导出日志
  Future<File?> exportLogs() async {
    if (_logFilePath == null) return null;

    try {
      final exportDir = await _getLogDirectory();
      if (exportDir == null) return null;

      final exportFile = File(
        '${exportDir.path}/logs_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      final exportContent = StringBuffer();

      // 读取当前日志文件
      if (await File(_logFilePath!).exists()) {
        final currentLog = await File(_logFilePath!).readAsString();
        exportContent.writeln('=== Current Log ===');
        exportContent.writeln(currentLog);
      }

      // 读取历史日志文件
      for (int i = 1; i <= _maxHistoryFiles; i++) {
        final historyLogPath = '${_logFilePath!}.$i';
        if (await File(historyLogPath).exists()) {
          final historyLog = await File(historyLogPath).readAsString();
          exportContent.writeln('\n=== History Log $i ===');
          exportContent.writeln(historyLog);
        }
      }

      await exportFile.writeAsString(exportContent.toString());
      return exportFile;
    } catch (e) {
      return null;
    }
  }

  /// 清除所有日志
  Future<void> clearLogs() async {
    if (_logFilePath == null) return;

    try {
      // 删除当前日志文件
      if (await File(_logFilePath!).exists()) {
        await File(_logFilePath!).delete();
        _logFile = File(_logFilePath!);
      }

      // 删除历史日志文件
      for (int i = 1; i <= _maxHistoryFiles; i++) {
        final historyLogPath = '${_logFilePath!}.$i';
        if (await File(historyLogPath).exists()) {
          await File(historyLogPath).delete();
        }
      }
    } catch (e) {
      // 清除失败时静默处理
    }
  }
}

/// 全局日志实例
final logger = LoggerUtil();
