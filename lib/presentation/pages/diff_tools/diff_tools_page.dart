/// Diff Tools Page
/// Author: ZF_Clark
/// Description: UI page for text comparison and diff visualization. Uses DiffUtil for comparison operations.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import '../../../core/utils/diff_util.dart';

/// 文本对比页面
class DiffToolsPage extends StatefulWidget {
  const DiffToolsPage({super.key});

  @override
  State<DiffToolsPage> createState() => _DiffToolsPageState();
}

class _DiffToolsPageState extends State<DiffToolsPage> {
  final TextEditingController _controller1 = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  List<DiffResult> _results = [];
  Map<String, int> _stats = {};

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  void _compare() {
    final text1 = _controller1.text;
    final text2 = _controller2.text;
    
    setState(() {
      _results = DiffUtil.compare(text1, text2);
      _stats = DiffUtil.getStats(_results);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文本对比')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 输入区域
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('原始文本', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controller1,
                            maxLines: 8,
                            decoration: InputDecoration(
                              hintText: '输入原始文本...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('新文本', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _controller2,
                            maxLines: 8,
                            decoration: InputDecoration(
                              hintText: '输入新文本...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 对比按钮
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _compare,
                icon: const Icon(Icons.compare_arrows),
                label: const Text('开始对比'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              ),
            ),

            const SizedBox(height: 16),

            // 统计结果
            if (_stats.isNotEmpty) ...[
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('新增', _stats['added'] ?? 0, Colors.green),
                      _buildStatItem('删除', _stats['removed'] ?? 0, Colors.red),
                      _buildStatItem('修改', _stats['modified'] ?? 0, Colors.orange),
                      _buildStatItem('未变', _stats['unchanged'] ?? 0, Colors.grey),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 差异列表
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📋 差异详情', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ...List.generate(_results.length.clamp(0, 50), (i) {
                        final result = _results[i];
                        Color? bgColor;
                        IconData? icon;
                        
                        switch (result.type) {
                          case DiffType.added:
                            bgColor = Colors.green.withValues(alpha: 0.1);
                            icon = Icons.add;
                            break;
                          case DiffType.removed:
                            bgColor = Colors.red.withValues(alpha: 0.1);
                            icon = Icons.remove;
                            break;
                          case DiffType.modified:
                            bgColor = Colors.orange.withValues(alpha: 0.1);
                            icon = Icons.edit;
                            break;
                          default:
                            return const SizedBox.shrink();
                        }
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(icon, size: 18, color: icon == Icons.add ? Colors.green : icon == Icons.remove ? Colors.red : Colors.orange),
                              const SizedBox(width: 8),
                              Text('第${result.lineNumber}行', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  result.type == DiffType.removed 
                                      ? result.oldContent ?? ''
                                      : result.newContent ?? '',
                                  style: const TextStyle(fontFamily: 'Monospace', fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Text('$value', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}