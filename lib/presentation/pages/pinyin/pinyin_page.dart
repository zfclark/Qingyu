/// Pinyin Page
/// Author: ZF_Clark
/// Description: UI page for Chinese to pinyin conversion. Uses PinyinUtil for all conversions.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/pinyin_util.dart';

/// 中文转拼音页面
/// 提供中文文本到拼音、首字母提取等功能
class PinyinPage extends StatefulWidget {
  const PinyinPage({super.key});

  @override
  State<PinyinPage> createState() => _PinyinPageState();
}

class _PinyinPageState extends State<PinyinPage> {
  final _inputController = TextEditingController();
  String _result = '';
  bool _showInitials = false;
  bool _capitalize = true;
  bool _keepTone = true;
  String _separator = ' ';

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _convert() {
    final text = _inputController.text;
    if (text.isEmpty) return;

    final result = PinyinUtil.convert(
      text,
      separator: _showInitials ? '' : _separator,
      capitalize: _capitalize && !_showInitials,
      keepToneNumbers: _keepTone,
      initialOnly: _showInitials,
    );
    setState(() => _result = result);
  }

  void _clear() {
    _inputController.clear();
    setState(() => _result = '');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('中文转拼音')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputCard(theme),
            const SizedBox(height: 16),
            _buildOptionsCard(theme),
            const SizedBox(height: 16),
            _buildActionButtons(theme),
            if (_result.isNotEmpty) ...[
              const SizedBox(height: 16),
              _buildResultCard(theme),
              const SizedBox(height: 16),
              _buildStatsCard(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('输入中文文本', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: _inputController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '请输入中文文本...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('转换选项', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('仅首字母'),
              subtitle: const Text('如 "中国" → "ZG"'),
              value: _showInitials,
              onChanged: (v) => setState(() => _showInitials = v),
              contentPadding: EdgeInsets.zero,
            ),
            if (!_showInitials) ...[
              SwitchListTile(
                title: const Text('首字母大写'),
                value: _capitalize,
                onChanged: (v) => setState(() => _capitalize = v),
                contentPadding: EdgeInsets.zero,
              ),
              SwitchListTile(
                title: const Text('显示音调'),
                subtitle: const Text('如 "hao3" 或 "hao"'),
                value: _keepTone,
                onChanged: (v) => setState(() => _keepTone = v),
                contentPadding: EdgeInsets.zero,
              ),
              ListTile(
                title: const Text('分隔符'),
                contentPadding: EdgeInsets.zero,
                subtitle: Row(
                  children: [
                    _buildSepChip('空格', ' '),
                    const SizedBox(width: 8),
                    _buildSepChip('无', ''),
                    const SizedBox(width: 8),
                    _buildSepChip('横线', '-'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSepChip(String label, String sep) {
    final isSelected = _separator == sep;
    return ActionChip(
      label: Text(label, style: TextStyle(fontSize: 12)),
      onPressed: () => setState(() => _separator = sep),
      backgroundColor: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _convert,
            icon: const Icon(Icons.translate),
            label: const Text('转换'),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: _clear,
          icon: const Icon(Icons.clear),
          label: const Text('清空'),
        ),
      ],
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('转换结果', style: TextStyle(fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _result));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('已复制到剪贴板')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _result,
                style: const TextStyle(fontSize: 18, fontFamily: 'Monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(ThemeData theme) {
    final text = _inputController.text;
    final chineseCount = PinyinUtil.countChineseChars(text);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _buildStatItem('汉字', '$chineseCount'),
            _buildStatItem('总字符', '${text.length}'),
            _buildStatItem('拼音词', '${_result.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          )),
          Text(label, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }
}
