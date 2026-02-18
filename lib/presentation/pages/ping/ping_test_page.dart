/// Ping Test Page
/// Author: ZF_Clark
/// Description: Network connectivity testing tool with latency and packet loss measurement. Supports domain and IP address testing.
/// Last Modified: 2026/02/09
library;

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/utils/network_util.dart';
import '../../../core/utils/logger_util.dart';

/// Ping测试结果模型（兼容NetworkTestResult）
class PingResult {
  final String target;
  final bool success;
  final int? latency;
  final String? error;
  final DateTime timestamp;
  final NetworkErrorType? errorType;

  PingResult({
    required this.target,
    required this.success,
    this.latency,
    this.error,
    required this.timestamp,
    this.errorType,
  });

  /// 从NetworkTestResult创建PingResult
  factory PingResult.fromNetworkTestResult(NetworkTestResult result) {
    return PingResult(
      target: result.target,
      success: result.success,
      latency: result.latency,
      error: result.error,
      timestamp: result.timestamp,
      errorType: result.errorType,
    );
  }
}

/// Ping测试页面
class PingTestPage extends StatefulWidget {
  const PingTestPage({super.key});

  @override
  State<PingTestPage> createState() => _PingTestPageState();
}

class _PingTestPageState extends State<PingTestPage> {
  final TextEditingController _targetController = TextEditingController();
  final List<PingResult> _results = [];
  bool _isTesting = false;
  int _testCount = 4;
  int _currentTest = 0;
  int _packetSize = 64; // 默认数据包大小
  int _timeout = 5; // 默认超时时间（秒）
  int _retries = 2; // 默认重试次数

  /// 常用测试目标
  final List<String> _commonTargets = [
    'baidu.com',
    'google.com',
    '114.114.114.114',
    '8.8.8.8',
  ];

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  /// 执行Ping测试
  Future<void> _startPingTest() async {
    final target = _targetController.text.trim();
    if (target.isEmpty) {
      _showError('请输入目标地址');
      return;
    }

    logger.info(
      'PingTestPage',
      'Starting ping test to $target with $_testCount attempts',
    );
    logger.debug(
      'PingTestPage',
      'Test parameters: timeout=$_timeout seconds, packetSize=$_packetSize bytes, retries=$_retries',
    );

    setState(() {
      _isTesting = true;
      _results.clear();
      _currentTest = 0;
    });

    // 使用NetworkUtil执行Ping测试
    await NetworkUtil.ping(
      target,
      attempts: _testCount,
      timeout: Duration(seconds: _timeout),
      interval: const Duration(seconds: 1),
      packetSize: _packetSize,
      retries: _retries,
      retryInterval: const Duration(seconds: 2),
      onProgress: (attempt, result) {
        logger.debug(
          'PingTestPage',
          'Ping attempt $attempt completed with ${result.success ? 'success' : 'failure'}',
        );
        setState(() {
          _currentTest = attempt;
          _results.add(PingResult.fromNetworkTestResult(result));
        });
      },
    );

    setState(() {
      _isTesting = false;
    });

    logger.info(
      'PingTestPage',
      'Ping test completed. Total results: ${_results.length}',
    );
  }

  /// 显示错误提示
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// 清空结果
  void _clearResults() {
    setState(() {
      _results.clear();
    });
  }

  /// 获取统计信息
  Map<String, dynamic> _getStatistics() {
    if (_results.isEmpty) return {};

    // 转换为NetworkTestResult列表
    final networkResults = _results
        .map(
          (result) => NetworkTestResult(
            target: result.target,
            success: result.success,
            latency: result.latency,
            error: result.error,
            timestamp: result.timestamp,
            errorType: result.errorType,
          ),
        )
        .toList();

    // 使用NetworkUtil分析结果
    final stats = NetworkUtil.analyzePingResults(networkResults);
    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final stats = _getStatistics();
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Ping测试')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 输入区域
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('目标地址：'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _targetController,
                        decoration: InputDecoration(
                          hintText: '输入域名或IP地址',
                          prefixIcon: const Icon(Icons.network_ping),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: _targetController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _targetController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 12),
                      // 常用目标
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _commonTargets.map((target) {
                          return ActionChip(
                            label: Text(target),
                            onPressed: () {
                              _targetController.text = target;
                              setState(() {});
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                      // 测试次数选择
                      Row(
                        children: [
                          const Text('测试次数：'),
                          const SizedBox(width: 12),
                          SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(value: 4, label: Text('4次')),
                              ButtonSegment(value: 10, label: Text('10次')),
                              ButtonSegment(value: 20, label: Text('20次')),
                            ],
                            selected: {_testCount},
                            onSelectionChanged: (selected) {
                              setState(() {
                                _testCount = selected.first;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 数据包大小选择
                      Row(
                        children: [
                          const Text('数据包大小：'),
                          const SizedBox(width: 12),
                          SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(value: 64, label: Text('64B')),
                              ButtonSegment(value: 128, label: Text('128B')),
                              ButtonSegment(value: 256, label: Text('256B')),
                            ],
                            selected: {_packetSize},
                            onSelectionChanged: (selected) {
                              setState(() {
                                _packetSize = selected.first;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 超时时间选择
                      Row(
                        children: [
                          const Text('超时时间：'),
                          const SizedBox(width: 12),
                          SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(value: 3, label: Text('3s')),
                              ButtonSegment(value: 5, label: Text('5s')),
                              ButtonSegment(value: 10, label: Text('10s')),
                            ],
                            selected: {_timeout},
                            onSelectionChanged: (selected) {
                              setState(() {
                                _timeout = selected.first;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 重试次数选择
                      Row(
                        children: [
                          const Text('重试次数：'),
                          const SizedBox(width: 12),
                          SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(value: 0, label: Text('0次')),
                              ButtonSegment(value: 2, label: Text('2次')),
                              ButtonSegment(value: 3, label: Text('3次')),
                            ],
                            selected: {_retries},
                            onSelectionChanged: (selected) {
                              setState(() {
                                _retries = selected.first;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // 操作按钮
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isTesting ? null : _startPingTest,
                              icon: _isTesting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.play_arrow),
                              label: Text(
                                _isTesting
                                    ? '测试中 ($_currentTest/$_testCount)'
                                    : '开始测试',
                              ),
                            ),
                          ),
                          if (_results.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _clearResults,
                              icon: const Icon(Icons.clear_all),
                              label: const Text('清空'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.errorContainer,
                                foregroundColor: colorScheme.onErrorContainer,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 统计信息
              if (stats.isNotEmpty) ...[
                Card(
                  elevation: 0,
                  color: colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '测试结果统计',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              '发送',
                              '${stats['total']}',
                              Icons.send,
                              colorScheme,
                            ),
                            _buildStatItem(
                              '成功',
                              '${stats['success']}',
                              Icons.check_circle,
                              colorScheme,
                              color: Colors.green,
                            ),
                            _buildStatItem(
                              '丢包率',
                              '${stats['lossRate']}%',
                              Icons.error,
                              colorScheme,
                              color: stats['failed'] > 0
                                  ? Colors.red
                                  : Colors.green,
                            ),
                          ],
                        ),
                        if (stats['avgLatency'] != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                '最小延迟',
                                '${stats['minLatency']}ms',
                                Icons.speed,
                                colorScheme,
                              ),
                              _buildStatItem(
                                '平均延迟',
                                '${stats['avgLatency']}ms',
                                Icons.trending_flat,
                                colorScheme,
                              ),
                              _buildStatItem(
                                '最大延迟',
                                '${stats['maxLatency']}ms',
                                Icons.speed,
                                colorScheme,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 详细结果列表
              if (_results.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '详细结果：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('${_results.length} 条记录'),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 300,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        return ListTile(
                          leading: Icon(
                            result.success ? Icons.check_circle : Icons.error,
                            color: result.success ? Colors.green : Colors.red,
                          ),
                          title: Text('测试 #${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                result.success
                                    ? '延迟: ${result.latency}ms'
                                    : '失败: ${result.error}',
                              ),
                              if (!result.success && result.errorType != null)
                                Text(
                                  '错误类型: ${_getErrorTypeString(result.errorType!)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                          trailing: Text(
                            '${result.timestamp.hour.toString().padLeft(2, '0')}:${result.timestamp.minute.toString().padLeft(2, '0')}:${result.timestamp.second.toString().padLeft(2, '0')}',
                            style: const TextStyle(
                              fontFamily: 'Monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 将NetworkErrorType转换为可读字符串
  ///
  /// [errorType] 网络错误类型枚举值
  /// 返回用户友好的错误描述字符串
  String _getErrorTypeString(NetworkErrorType errorType) {
    switch (errorType) {
      case NetworkErrorType.timeout:
        return '连接超时，请检查网络连接或目标地址是否可达';
      case NetworkErrorType.hostNotFound:
        return '主机未找到，请检查域名是否正确或DNS配置是否正常';
      case NetworkErrorType.networkUnreachable:
        return '网络不可达，请检查本地网络连接是否正常';
      case NetworkErrorType.permissionDenied:
        return '权限被拒绝，请检查应用是否有网络访问权限';
      case NetworkErrorType.other:
        return '未知网络错误，请稍后重试';
    }
  }

  /// 构建统计项
  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ColorScheme colorScheme, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color ?? colorScheme.primary, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color ?? colorScheme.onPrimaryContainer,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onPrimaryContainer.withAlpha(
              178,
            ), // 255 * 0.7 = 178
          ),
        ),
      ],
    );
  }
}
