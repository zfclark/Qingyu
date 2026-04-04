/// JSON Tools Page
/// Author: ZF_Clark
/// Description: UI page for JSON formatting, validation, compression, and path query operations. Uses JsonUtil for all JSON operations.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/json_util.dart';

/// JSON工具页面
/// 提供JSON格式化、验证、压缩、路径查询等功能的UI界面
class JsonToolsPage extends StatefulWidget {
  const JsonToolsPage({super.key});

  @override
  State<JsonToolsPage> createState() => _JsonToolsPageState();
}

class _JsonToolsPageState extends State<JsonToolsPage> {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  String? _errorMessage;
  Map<String, int>? _stats;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  /// 执行格式化
  void _format() {
    final input = _inputController.text;
    if (input.isEmpty) {
      setState(() {
        _output = '';
        _errorMessage = null;
      });
      return;
    }

    final result = JsonUtil.format(input);
    setState(() {
      if (result != null) {
        _output = result;
        _errorMessage = null;
      } else {
        _output = '';
        _errorMessage = JsonUtil.getError(input);
      }
    });
  }

  /// 执行压缩
  void _compress() {
    final input = _inputController.text;
    if (input.isEmpty) {
      setState(() {
        _output = '';
        _errorMessage = null;
      });
      return;
    }

    final result = JsonUtil.compress(input);
    setState(() {
      if (result != null) {
        _output = result;
        _errorMessage = null;
      } else {
        _output = '';
        _errorMessage = JsonUtil.getError(input);
      }
    });
  }

  /// 执行验证
  void _validate() {
    final input = _inputController.text;
    setState(() {
      if (JsonUtil.isValid(input)) {
        _output = '✓ 有效的JSON格式';
        _errorMessage = null;
      } else {
        _output = '';
        _errorMessage = JsonUtil.getError(input);
      }
    });
  }

  /// 显示路径查询对话框
  void _showPathQueryDialog() {
    final input = _inputController.text;
    if (!JsonUtil.isValid(input)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入有效的JSON')),
      );
      return;
    }

    final pathController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('路径查询'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pathController,
                decoration: const InputDecoration(
                  labelText: 'JSON路径',
                  hintText: '例如: data.user.name 或 users.0.name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '使用点分隔的路径，数组用数字索引',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                final result = JsonUtil.queryPath(input, pathController.text);
                Navigator.pop(context);
                setState(() {
                  _output = result?.toString() ?? '路径不存在或格式错误';
                  _errorMessage = null;
                });
              },
              child: const Text('查询'),
            ),
          ],
        );
      },
    );
  }

  /// 显示统计信息
  void _showStats() {
    final input = _inputController.text;
    if (input.isEmpty) {
      setState(() {
        _stats = null;
      });
      return;
    }

    final stats = JsonUtil.getStats(input);
    setState(() {
      _stats = stats;
    });
  }

  /// 复制结果
  void _copyResult() {
    if (_output.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('结果已复制到剪贴板')),
    );
  }

  /// 清空
  void _clear() {
    setState(() {
      _inputController.clear();
      _output = '';
      _errorMessage = null;
      _stats = null;
    });
  }

  /// 粘贴
  void _paste() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _inputController.text = data!.text!;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('JSON工具')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 操作按钮
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildActionButton('格式化', _format, Icons.auto_fix_high),
                    _buildActionButton('压缩', _compress, Icons.compress),
                    _buildActionButton('验证', _validate, Icons.check_circle),
                    _buildActionButton('路径查询', _showPathQueryDialog, Icons.search),
                    _buildActionButton('统计', _showStats, Icons.analytics),
                    _buildActionButton('粘贴', _paste, Icons.content_paste),
                    _buildActionButton('清空', _clear, Icons.clear),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 输入区域
            Expanded(
              flex: 1,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '输入JSON：',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${_inputController.text.length} 字符',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            fontFamily: 'Monospace',
                            fontSize: 13,
                          ),
                          decoration: InputDecoration(
                            hintText: '输入或粘贴JSON...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 输出区域
            Expanded(
              flex: 1,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '输出结果：',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (_output.isNotEmpty)
                            TextButton.icon(
                              onPressed: _copyResult,
                              icon: const Icon(Icons.copy, size: 16),
                              label: const Text('复制'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _errorMessage != null
                                ? Colors.red.withValues(alpha: 0.1)
                                : Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: _errorMessage != null
                                ? Border.all(color: Colors.red.withValues(alpha: 0.3))
                                : null,
                          ),
                          child: SingleChildScrollView(
                            child: _errorMessage != null
                                ? Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontFamily: 'Monospace',
                                    ),
                                  )
                                : _stats != null
                                    ? _buildStatsView()
                                    : SelectableText(
                                        _output.isEmpty ? '结果将在此显示...' : _output,
                                        style: TextStyle(
                                          fontFamily: 'Monospace',
                                          fontSize: 13,
                                          color: _output.isEmpty ? Colors.grey : null,
                                        ),
                                      ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, IconData icon) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildStatsView() {
    if (_stats == null) {
      return const Text('统计信息');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatRow('对象键数量', '${_stats!['keys']}'),
        _buildStatRow('数组数量', '${_stats!['arrays']}'),
        _buildStatRow('字符串数量', '${_stats!['strings']}'),
        _buildStatRow('数字数量', '${_stats!['numbers']}'),
        _buildStatRow('布尔值数量', '${_stats!['booleans']}'),
        _buildStatRow('空值数量', '${_stats!['nulls']}'),
        const Divider(),
        _buildStatRow('总元素数', '${_stats!['totalKeys']}', isBold: true),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? Theme.of(context).colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
