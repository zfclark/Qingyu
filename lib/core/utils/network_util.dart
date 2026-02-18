/// Network Utility
/// Author: ZF_Clark
/// Description: Provides network testing utilities including ping functionality and network status checks. Supports cross-platform operations with platform-specific implementations.
/// Last Modified: 2026/02/09
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import './logger_util.dart';

/// 网络错误类型枚举
enum NetworkErrorType {
  /// 超时
  timeout,

  /// 主机未找到
  hostNotFound,

  /// 网络不可达
  networkUnreachable,

  /// 权限被拒绝
  permissionDenied,

  /// 其他错误
  other,
}

/// 网络测试结果模型
class NetworkTestResult {
  /// 测试目标
  final String target;

  /// 是否成功
  final bool success;

  /// 延迟时间（毫秒）
  final int? latency;

  /// 错误信息
  final String? error;

  /// 测试时间戳
  final DateTime timestamp;

  /// 错误类型
  final NetworkErrorType? errorType;

  NetworkTestResult({
    required this.target,
    required this.success,
    this.latency,
    this.error,
    required this.timestamp,
    this.errorType,
  });
}

/// 网络测试诊断模型
/// 包含详细的网络测试失败原因分析信息
class NetworkTestDiagnostic {
  /// 诊断时间戳
  final DateTime timestamp;

  /// 失败类型
  final NetworkErrorType errorType;

  /// 详细错误信息
  final String errorMessage;

  /// 网络权限状态
  final bool hasNetworkPermission;

  /// ICMP协议支持状态
  final bool icmpSupported;

  /// 网络连接类型
  final String? networkType;

  /// 目标服务器状态
  final bool targetReachable;

  /// 建议的解决方案
  final List<String> suggestions;

  NetworkTestDiagnostic({
    required this.timestamp,
    required this.errorType,
    required this.errorMessage,
    required this.hasNetworkPermission,
    required this.icmpSupported,
    this.networkType,
    required this.targetReachable,
    required this.suggestions,
  });

  /// 转换为Map
  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'errorType': errorType.name,
      'errorMessage': errorMessage,
      'hasNetworkPermission': hasNetworkPermission,
      'icmpSupported': icmpSupported,
      'networkType': networkType,
      'targetReachable': targetReachable,
      'suggestions': suggestions,
    };
  }
}

/// 网络工具类
/// 提供网络测试功能，支持跨平台操作
class NetworkUtil {
  /// 执行Ping测试
  ///
  /// [target] 测试目标（域名或IP地址）
  /// [timeout] 超时时间
  /// [attempts] 尝试次数
  /// [interval] 每次尝试的间隔时间
  /// [packetSize] 数据包大小（字节）
  /// [retries] 失败自动重试次数
  /// [retryInterval] 重试间隔时间
  /// [onProgress] 进度回调
  /// 返回测试结果列表
  static Future<List<NetworkTestResult>> ping(
    String target, {
    Duration timeout = const Duration(seconds: 5),
    int attempts = 4,
    Duration interval = const Duration(seconds: 1),
    int packetSize = 64,
    int retries = 2,
    Duration retryInterval = const Duration(seconds: 2),
    void Function(int attempt, NetworkTestResult result)? onProgress,
  }) async {
    logger.info(
      'NetworkUtil',
      'Starting ping test to $target with $attempts attempts',
    );
    final results = <NetworkTestResult>[];

    for (int i = 0; i < attempts; i++) {
      logger.debug('NetworkUtil', 'Performing ping attempt ${i + 1}/$attempts');
      NetworkTestResult result;
      int currentRetry = 0;

      // 主测试尝试
      result = await _performPing(target, timeout, packetSize);

      // 失败后自动重试
      while (!result.success && currentRetry < retries) {
        currentRetry++;
        logger.warning(
          'NetworkUtil',
          'Ping attempt ${i + 1} failed, retrying ($currentRetry/$retries)',
        );
        await Future.delayed(retryInterval);
        final retryResult = await _performPing(target, timeout, packetSize);

        if (retryResult.success) {
          result = retryResult;
          logger.info('NetworkUtil', 'Retry $currentRetry successful');
          break;
        }
      }

      results.add(result);

      if (onProgress != null) {
        onProgress(i + 1, result);
      }

      if (i < attempts - 1) {
        await Future.delayed(interval);
      }
    }

    final stats = analyzePingResults(results);
    logger.info(
      'NetworkUtil',
      'Ping test completed. Success: ${stats['success']}/${stats['total']}, Loss rate: ${stats['lossRate']}%',
    );
    return results;
  }

  /// 执行单次Ping测试
  static Future<NetworkTestResult> _performPing(
    String target,
    Duration timeout,
    int packetSize,
  ) async {
    final stopwatch = Stopwatch()..start();

    try {
      logger.debug(
        'NetworkUtil',
        'Performing single ping test to $target with packet size $packetSize',
      );
      if (kIsWeb) {
        // Web平台：使用HTTP请求作为替代
        logger.debug('NetworkUtil', 'Using web ping method for target $target');
        return await _webPing(target, timeout, stopwatch, packetSize);
      } else {
        // 非Web平台：使用Socket连接测试（作为ICMP的替代）
        logger.debug(
          'NetworkUtil',
          'Using socket ping method for target $target',
        );
        return await _socketPing(target, timeout, stopwatch, packetSize);
      }
    } catch (e) {
      stopwatch.stop();
      logger.error('NetworkUtil', 'Ping test failed with exception', e);
      return NetworkTestResult(
        target: target,
        success: false,
        error: e.toString(),
        timestamp: DateTime.now(),
        errorType: _mapErrorToType(e),
      );
    }
  }

  /// Web平台的Ping测试（使用HTTP请求）
  static Future<NetworkTestResult> _webPing(
    String target,
    Duration timeout,
    Stopwatch stopwatch,
    int packetSize,
  ) async {
    HttpClient? client;
    try {
      // 构建HTTP请求URL
      final url = _ensureHttpUrl(target);
      logger.debug(
        'NetworkUtil',
        'Web ping: Connecting to $url with timeout $timeout',
      );

      // 使用HttpClient进行测试
      client = HttpClient();
      client.connectionTimeout = timeout;

      final request = await client.getUrl(Uri.parse(url));
      // 添加一个自定义头，模拟不同大小的数据包
      final padding = 'x' * (packetSize.clamp(0, 1024) - 100); // 减去基本头大小
      request.headers.add('X-Ping-Size', padding);
      logger.debug(
        'NetworkUtil',
        'Web ping: Added custom header with packet size $packetSize',
      );

      final response = await request.close();
      logger.info(
        'NetworkUtil',
        'Web ping: Received response with status ${response.statusCode}',
      );

      // 无论响应状态如何，只要能连接成功就算测试通过
      await response.drain();
      stopwatch.stop();
      logger.debug(
        'NetworkUtil',
        'Web ping: Request completed in ${stopwatch.elapsedMilliseconds}ms',
      );

      return NetworkTestResult(
        target: target,
        success: true,
        latency: stopwatch.elapsedMilliseconds,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      stopwatch.stop();
      logger.error('NetworkUtil', 'Web ping failed', e);
      return NetworkTestResult(
        target: target,
        success: false,
        error: e.toString(),
        timestamp: DateTime.now(),
        errorType: _mapErrorToType(e),
      );
    } finally {
      // 确保客户端被关闭
      client?.close();
      logger.debug('NetworkUtil', 'Web ping: HttpClient closed');
    }
  }

  /// 非Web平台的Ping测试（使用Socket连接）
  static Future<NetworkTestResult> _socketPing(
    String target,
    Duration timeout,
    Stopwatch stopwatch,
    int packetSize,
  ) async {
    try {
      // 尝试连接多个端口以提高成功率
      final ports = [80, 443, 53]; // HTTP, HTTPS, DNS
      logger.debug(
        'NetworkUtil',
        'Socket ping: Testing target $target on ports $ports',
      );

      for (final port in ports) {
        try {
          logger.debug(
            'NetworkUtil',
            'Socket ping: Attempting to connect to $target:$port',
          );
          final socket = await Socket.connect(target, port, timeout: timeout);

          // 发送测试数据包
          if (packetSize > 0) {
            final testData = List<int>.filled(packetSize, 0x41); // 发送 'A' 字符
            socket.add(testData);
            await socket.flush();
            logger.debug(
              'NetworkUtil',
              'Socket ping: Sent $packetSize bytes to $target:$port',
            );
          }

          await socket.close();
          stopwatch.stop();
          logger.info(
            'NetworkUtil',
            'Socket ping: Connection to $target:$port successful in ${stopwatch.elapsedMilliseconds}ms',
          );

          return NetworkTestResult(
            target: target,
            success: true,
            latency: stopwatch.elapsedMilliseconds,
            timestamp: DateTime.now(),
          );
        } catch (e) {
          logger.warning(
            'NetworkUtil',
            'Socket ping: Failed to connect to $target:$port',
            e,
          );
          // 尝试下一个端口
          continue;
        }
      }

      // 所有端口都失败
      stopwatch.stop();
      logger.error(
        'NetworkUtil',
        'Socket ping: All ports failed for target $target',
      );
      return NetworkTestResult(
        target: target,
        success: false,
        error: '所有端口连接失败',
        timestamp: DateTime.now(),
        errorType: NetworkErrorType.networkUnreachable,
      );
    } catch (e) {
      stopwatch.stop();
      logger.error('NetworkUtil', 'Socket ping: Exception occurred', e);
      return NetworkTestResult(
        target: target,
        success: false,
        error: e.toString(),
        timestamp: DateTime.now(),
        errorType: _mapErrorToType(e),
      );
    }
  }

  /// 确保URL以http://或https://开头
  static String _ensureHttpUrl(String target) {
    if (target.startsWith('http://') || target.startsWith('https://')) {
      return target;
    }
    return 'http://$target';
  }

  /// 将错误映射到错误类型
  static NetworkErrorType _mapErrorToType(dynamic error) {
    if (error is SocketException) {
      switch (error.osError?.errorCode) {
        case 110: // Connection timed out
        case 11001: // getaddrinfo failed
          return NetworkErrorType.timeout;
        case 11004: // getaddrinfo failed
          return NetworkErrorType.hostNotFound;
        case 10065: // No route to host
        case 113: // No route to host
          return NetworkErrorType.networkUnreachable;
        case 13: // Permission denied
          return NetworkErrorType.permissionDenied;
        default:
          return NetworkErrorType.other;
      }
    }

    if (error.toString().contains('timeout')) {
      return NetworkErrorType.timeout;
    }

    if (error.toString().contains('host') ||
        error.toString().contains('DNS') ||
        error.toString().contains('getaddrinfo')) {
      return NetworkErrorType.hostNotFound;
    }

    if (error.toString().contains('permission')) {
      return NetworkErrorType.permissionDenied;
    }

    return NetworkErrorType.other;
  }

  /// 分析Ping测试结果
  ///
  /// [results] 测试结果列表
  /// 返回分析结果
  static Map<String, dynamic> analyzePingResults(
    List<NetworkTestResult> results,
  ) {
    if (results.isEmpty) return {};

    final successful = results.where((r) => r.success).toList();
    final failed = results.where((r) => !r.success).toList();

    int? minLatency;
    int? maxLatency;
    double? avgLatency;

    if (successful.isNotEmpty) {
      final latencies = successful.map((r) => r.latency!).toList();
      minLatency = latencies.reduce((a, b) => a < b ? a : b);
      maxLatency = latencies.reduce((a, b) => a > b ? a : b);
      avgLatency = latencies.reduce((a, b) => a + b) / latencies.length;
    }

    // 分析错误类型分布
    final errorTypes = <NetworkErrorType, int>{};
    for (final result in failed) {
      if (result.errorType != null) {
        errorTypes[result.errorType!] =
            (errorTypes[result.errorType!] ?? 0) + 1;
      }
    }

    return {
      'total': results.length,
      'success': successful.length,
      'failed': failed.length,
      'lossRate': (failed.length / results.length * 100).toStringAsFixed(1),
      'minLatency': minLatency,
      'maxLatency': maxLatency,
      'avgLatency': avgLatency?.toStringAsFixed(1),
      'errorTypes': errorTypes,
    };
  }

  /// 检查网络连接状态
  static Future<bool> isNetworkConnected() async {
    try {
      final result = await _performPing(
        '8.8.8.8',
        const Duration(seconds: 3),
        64,
      );
      return result.success;
    } catch (_) {
      return false;
    }
  }

  /// 诊断网络测试失败原因
  ///
  /// [errorType] 错误类型
  /// [errorMessage] 错误信息
  /// [target] 测试目标
  /// 返回详细的诊断信息
  static Future<NetworkTestDiagnostic> diagnoseFailure(
    NetworkErrorType errorType,
    String errorMessage,
    String target,
  ) async {
    logger.info(
      'NetworkUtil',
      'Diagnosing network failure for target $target with error $errorType',
    );

    final hasNetworkPermission = await _checkNetworkPermission();
    logger.debug(
      'NetworkUtil',
      'Network permission check result: $hasNetworkPermission',
    );

    final icmpSupported = await _checkIcmpSupport();
    logger.debug('NetworkUtil', 'ICMP support check result: $icmpSupported');

    final networkType = await _getNetworkType();
    logger.debug('NetworkUtil', 'Network type: $networkType');

    final targetReachable = await _checkTargetReachable(target);
    logger.debug(
      'NetworkUtil',
      'Target reachability check result: $targetReachable',
    );

    final suggestions = _generateSuggestions(
      errorType,
      errorMessage,
      hasNetworkPermission,
      icmpSupported,
      targetReachable,
    );
    logger.debug(
      'NetworkUtil',
      'Generated ${suggestions.length} suggestions for the error',
    );

    final diagnostic = NetworkTestDiagnostic(
      timestamp: DateTime.now(),
      errorType: errorType,
      errorMessage: errorMessage,
      hasNetworkPermission: hasNetworkPermission,
      icmpSupported: icmpSupported,
      networkType: networkType,
      targetReachable: targetReachable,
      suggestions: suggestions,
    );

    logger.info('NetworkUtil', 'Diagnosis completed for target $target');
    return diagnostic;
  }

  /// 检查网络权限
  static Future<bool> _checkNetworkPermission() async {
    try {
      // 尝试进行网络连接测试，间接检查权限
      final result = await isNetworkConnected();
      return result;
    } catch (e) {
      return false;
    }
  }

  /// 检查ICMP协议支持
  static Future<bool> _checkIcmpSupport() async {
    try {
      // 尝试使用Socket连接测试，作为ICMP支持的替代检查
      final socket = await Socket.connect(
        '8.8.8.8',
        53,
        timeout: const Duration(seconds: 2),
      );
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取网络连接类型
  static Future<String?> _getNetworkType() async {
    try {
      // 这里可以根据实际平台实现更详细的网络类型检测
      // 目前返回一个通用描述
      if (kIsWeb) {
        return 'Web';
      } else {
        return 'Mobile Network';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// 检查目标是否可达
  static Future<bool> _checkTargetReachable(String target) async {
    try {
      // 尝试使用不同端口连接目标
      final ports = [80, 443, 53];
      for (final port in ports) {
        try {
          final socket = await Socket.connect(
            target,
            port,
            timeout: const Duration(seconds: 2),
          );
          await socket.close();
          return true;
        } catch (e) {
          continue;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 生成建议的解决方案
  static List<String> _generateSuggestions(
    NetworkErrorType errorType,
    String errorMessage,
    bool hasNetworkPermission,
    bool icmpSupported,
    bool targetReachable,
  ) {
    final suggestions = <String>[];

    // 通用建议
    suggestions.add('检查设备是否连接到网络');
    suggestions.add('尝试重新启动应用');

    // 根据错误类型添加特定建议
    switch (errorType) {
      case NetworkErrorType.timeout:
        suggestions.add('增加超时时间设置');
        suggestions.add('检查网络连接质量');
        suggestions.add('尝试连接其他网络');
        break;
      case NetworkErrorType.hostNotFound:
        suggestions.add('检查目标地址是否正确');
        suggestions.add('检查DNS配置是否正常');
        suggestions.add('尝试使用IP地址替代域名');
        break;
      case NetworkErrorType.networkUnreachable:
        suggestions.add('检查本地网络连接是否正常');
        suggestions.add('尝试重启路由器或调制解调器');
        suggestions.add('联系网络服务提供商');
        break;
      case NetworkErrorType.permissionDenied:
        suggestions.add('检查应用是否有网络访问权限');
        suggestions.add('在设备设置中启用网络权限');
        break;
      case NetworkErrorType.other:
        suggestions.add('检查错误信息详情');
        suggestions.add('尝试在不同时间再次测试');
        break;
    }

    // 根据检测结果添加特定建议
    if (!hasNetworkPermission) {
      suggestions.add('请确保应用有网络访问权限');
    }

    if (!icmpSupported) {
      suggestions.add('当前网络环境可能不支持ICMP协议');
      suggestions.add('尝试使用其他网络环境');
    }

    if (!targetReachable) {
      suggestions.add('目标服务器可能不可用');
      suggestions.add('检查目标服务器状态');
      suggestions.add('尝试使用其他目标地址');
    }

    return suggestions;
  }
}
