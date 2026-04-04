/// File Size Tools Page
/// Author: ZF_Clark
/// Description: UI page for file size conversion and formatting. Uses FileSizeUtil for all operations.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/file_size_util.dart';

/// 文件大小转换页面
class FileSizeToolsPage extends StatefulWidget {
  const FileSizeToolsPage({super.key});

  @override
  State<FileSizeToolsPage> createState() => _FileSizeToolsPageState();
}

class _FileSizeToolsPageState extends State<FileSizeToolsPage> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  String? _error;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final input = _inputController.text.trim();
    setState(() => _error = null);

    if (input.isEmpty) {
      setState(() => _result = '');
      return;
    }

    // 尝试解析为数字（字节）
    final bytes = int.tryParse(input);
    if (bytes != null) {
      setState(() => _result = FileSizeUtil.format(bytes));
      return;
    }

    // 尝试解析为带单位的字符串
    final parsed = FileSizeUtil.parse(input);
    if (parsed != null) {
      setState(() => _result = FileSizeUtil.format(parsed));
      return;
    }

    setState(() => _error = '无法解析，请输入数字或如 "1.5 MB" 格式');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文件大小转换')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 输入
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('输入值：', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: '输入字节数或如 "1.5 MB"',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () { _inputController.clear(); _convert(); },
                        ),
                      ),
                      onSubmitted: (_) => _convert(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _convert,
                        icon: const Icon(Icons.swap_horiz),
                        label: const Text('转换'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Colors.red.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ),
            ],

            if (_result.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text('转换结果', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Text(
                        _result,
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(height: 16),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _result));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制')));
                        },
                        icon: const Icon(Icons.copy),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 常用单位参考
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('📐 单位参考', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildUnitRow('1 KB', '1024 字节'),
                    _buildUnitRow('1 MB', '1024 KB ≈ 1,048,576 字节'),
                    _buildUnitRow('1 GB', '1024 MB ≈ 1,073,741,824 字节'),
                    _buildUnitRow('1 TB', '1024 GB ≈ 1,099,511,627,776 字节'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitRow(String unit, String desc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(unit, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 12))),
        ],
      ),
    );
  }
}