/// Timestamp Tools Page
/// Author: ZF_Clark
/// Description: UI page for timestamp conversion and formatting. Uses TimestampUtil for all operations.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/timestamp_util.dart';

/// 时间戳转换页面
class TimestampToolsPage extends StatefulWidget {
  const TimestampToolsPage({super.key});

  @override
  State<TimestampToolsPage> createState() => _TimestampToolsPageState();
}

class _TimestampToolsPageState extends State<TimestampToolsPage> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  String? _error;
  int _selectedTab = 0; // 0=秒, 1=毫秒

  @override
  void initState() {
    super.initState();
    _inputController.text = TimestampUtil.nowSeconds.toString();
    _convert();
  }

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

    final timestamp = int.tryParse(input);
    if (timestamp == null) {
      setState(() => _error = '请输入有效的数字');
      return;
    }

    // 判断是秒还是毫秒
    final isMs = timestamp > 9999999999;
    final dateTime = isMs ? TimestampUtil.fromMs(timestamp) : TimestampUtil.fromSeconds(timestamp);

    setState(() {
      _result = '📅 日期时间: ${dateTime.toString().substring(0, 19).replaceAll('T', ' ')}\n'
          '⏱️ 秒时间戳: ${isMs ? TimestampUtil.toSeconds(dateTime) : timestamp}\n'
          '⏱️ 毫秒时间戳: ${isMs ? timestamp : TimestampUtil.toMs(dateTime)}\n'
          '🌍 UTC: ${dateTime.toUtc().toString().substring(0, 19).replaceAll('T', ' ')}\n'
          '⏰ 时区偏移: UTC${dateTime.timeZoneOffset.isNegative ? "-" : "+"}${dateTime.timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:00';
    });
  }

  void _setNow() {
    final now = _selectedTab == 0 ? TimestampUtil.nowSeconds : TimestampUtil.nowMs;
    _inputController.text = now.toString();
    _convert();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('时间戳转换')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 类型选择
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(value: 0, label: Text('秒')),
                          ButtonSegment(value: 1, label: Text('毫秒')),
                        ],
                        selected: {_selectedTab},
                        onSelectionChanged: (selected) {
                          setState(() { _selectedTab = selected.first; });
                          _setNow();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 输入
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
                        Text('输入时间戳（${_selectedTab == 0 ? "秒" : "毫秒"}）：', style: const TextStyle(fontWeight: FontWeight.bold)),
                        TextButton.icon(onPressed: _setNow, icon: const Icon(Icons.access_time, size: 16), label: const Text('当前')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: _selectedTab == 0 ? '例如: 1704067200' : '例如: 1704067200000',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => _convert(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _convert,
                        icon: const Icon(Icons.refresh),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('转换结果', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(_result, style: const TextStyle(fontFamily: 'Monospace')),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _result));
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制')));
                            },
                            icon: const Icon(Icons.copy),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 常用时间戳
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⏰ 常用时间戳', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickChip('今天开始', TimestampUtil.todayStartSeconds),
                        _buildQuickChip('本周开始', TimestampUtil.weekStartSeconds),
                        _buildQuickChip('本月开始', TimestampUtil.monthStartSeconds),
                        _buildQuickChip('2024-01-01', 1704038400),
                        _buildQuickChip('2025-01-01', 1735689600),
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

  Widget _buildQuickChip(String label, int timestamp) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        _inputController.text = timestamp.toString();
        _convert();
      },
    );
  }
}