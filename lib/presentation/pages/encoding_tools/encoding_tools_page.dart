/// Encoding Tools Page
/// Author: ZF_Clark
/// Description: UI page for Base64 and URL encoding/decoding operations. Uses EncodingUtil for all encoding operations.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/encoding_util.dart';

/// 编码工具页面
/// 提供Base64和URL编解码功能的UI界面
class EncodingToolsPage extends StatefulWidget {
  const EncodingToolsPage({super.key});

  @override
  State<EncodingToolsPage> createState() => _EncodingToolsPageState();
}

class _EncodingToolsPageState extends State<EncodingToolsPage> {
  final TextEditingController _inputController = TextEditingController();
  String _base64Output = '';
  String _urlOutput = '';
  String _htmlOutput = '';
  int _selectedTab = 0;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final input = _inputController.text;
    if (input.isEmpty) {
      setState(() {
        _base64Output = '';
        _urlOutput = '';
        _htmlOutput = '';
      });
      return;
    }

    setState(() {
      _base64Output = EncodingUtil.encodeBase64(input) ?? '';
      _urlOutput = EncodingUtil.encodeUrl(input);
      _htmlOutput = EncodingUtil.encodeHtml(input);
    });
  }

  void _decode(String encoded, String type) {
    String? result;
    switch (type) {
      case 'base64':
        result = EncodingUtil.decodeBase64(encoded);
        break;
      case 'url':
        result = EncodingUtil.decodeUrl(encoded);
        break;
      case 'html':
        result = EncodingUtil.decodeHtml(encoded);
        break;
    }

    if (result != null) {
      setState(() {
        _inputController.text = result!;
        _convert();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('解码失败')),
      );
    }
  }

  void _copyResult(String text) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制到剪贴板')),
    );
  }

  void _paste() async {
    final data = await Clipboard.getData('text/plain');
    if (data?.text != null) {
      _inputController.text = data!.text!;
      _convert();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('编码解码')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标签选择
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    _buildTabChip(0, 'Base64', Icons.code),
                    const SizedBox(width: 8),
                    _buildTabChip(1, 'URL', Icons.link),
                    const SizedBox(width: 8),
                    _buildTabChip(2, 'HTML', Icons.html),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 输入区域
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('输入：', style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            TextButton.icon(onPressed: _paste, icon: const Icon(Icons.content_paste, size: 18), label: const Text('粘贴')),
                            TextButton.icon(onPressed: () => _inputController.clear(), icon: const Icon(Icons.clear, size: 18), label: const Text('清空')),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: '输入要编码的文本...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (_) => _convert(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 输出区域
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _selectedTab == 0 ? 'Base64 编码：' : _selectedTab == 1 ? 'URL 编码：' : 'HTML 编码：',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => _copyResult(_getCurrentOutput()),
                          icon: const Icon(Icons.copy),
                          tooltip: '复制',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _getCurrentOutput().isEmpty ? '结果将在此显示...' : _getCurrentOutput(),
                        style: TextStyle(
                          fontFamily: 'Monospace',
                          color: _getCurrentOutput().isEmpty ? Colors.grey : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 快捷操作
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('快捷操作：', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildActionChip('Base64编码', () => _copyResult(_base64Output)),
                        _buildActionChip('URL编码', () => _copyResult(_urlOutput)),
                        _buildActionChip('HTML编码', () => _copyResult(_htmlOutput)),
                        _buildActionChip('Base64解码', () => _decode(_inputController.text, 'base64')),
                        _buildActionChip('URL解码', () => _decode(_inputController.text, 'url')),
                        _buildActionChip('HTML解码', () => _decode(_inputController.text, 'html')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) setState(() => _selectedTab = index);
      },
    );
  }

  Widget _buildActionChip(String label, VoidCallback onPressed) {
    return ActionChip(
      label: Text(label),
      onPressed: onPressed,
    );
  }

  String _getCurrentOutput() {
    switch (_selectedTab) {
      case 0:
        return _base64Output;
      case 1:
        return _urlOutput;
      case 2:
        return _htmlOutput;
      default:
        return '';
    }
  }
}
