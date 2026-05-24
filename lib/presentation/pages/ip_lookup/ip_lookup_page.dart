/// IP Lookup Page
/// Author: ZF_Clark
/// Description: UI page for IP address parsing, validation, and classification. Uses IpUtil for all calculations.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/ip_util.dart';

/// IP 地址查询页面
/// 提供 IP 地址验证、解析和分类功能
class IpLookupPage extends StatefulWidget {
  const IpLookupPage({super.key});

  @override
  State<IpLookupPage> createState() => _IpLookupPageState();
}

class _IpLookupPageState extends State<IpLookupPage> {
  final _controller = TextEditingController();
  Map<String, dynamic>? _result;
  String? _error;

  final List<String> _presets = [
    '192.168.1.1',
    '10.0.0.1',
    '127.0.0.1',
    '8.8.8.8',
    '::1',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _lookup() {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() {
        _result = null;
        _error = '请输入 IP 地址';
      });
      return;
    }

    final result = IpUtil.parse(input);
    setState(() {
      if (result != null) {
        _result = result;
        _error = null;
      } else {
        _result = null;
        _error = '无效的 IP 地址格式';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IP 地址查询'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 输入区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '输入 IP 地址',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            decoration: const InputDecoration(
                              hintText: '例如: 192.168.1.1 或 ::1',
                              border: OutlineInputBorder(),
                            ),
                            onSubmitted: (_) => _lookup(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: _lookup,
                          icon: const Icon(Icons.search),
                          label: const Text('查询'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presets.map((ip) {
                        return ActionChip(
                          label: Text(ip),
                          onPressed: () {
                            _controller.text = ip;
                            _lookup();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 错误提示
            if (_error != null)
              Card(
                color: colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 查询结果
            if (_result != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            '查询结果',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      _buildResultRow('IP 地址', _result!['address'] as String),
                      _buildResultRow('类型', _result!['type'] as String),
                      _buildResultRow(
                        '地址范围',
                        IpUtil.getScopeDescription(_result!['address'] as String),
                      ),
                      if (_result!['type'] == 'IPv4') ...[
                        _buildResultRow('地址类别', '${_result!['classType']} 类'),
                        _buildResultRow(
                          '是否私有',
                          _result!['isPrivate'] == true ? '是' : '否',
                        ),
                      ],
                      if (_result!['type'] == 'IPv6') ...[
                        _buildResultRow(
                          '完整形式',
                          _result!['fullForm'] as String,
                        ),
                        _buildResultRow(
                          '是否私有',
                          _result!['isPrivate'] == true ? '是' : '否',
                        ),
                      ],
                      _buildResultRow(
                        '回环地址',
                        _result!['isLoopback'] == true ? '是' : '否',
                      ),
                      _buildResultRow(
                        '链路本地',
                        _result!['isLinkLocal'] == true ? '是' : '否',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('已复制')),
                );
              },
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
