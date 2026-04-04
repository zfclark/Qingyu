/// Word Count Page
/// Author: ZF_Clark
/// Description: UI page for text statistics and word counting. Uses WordCountUtil for all calculations.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/word_count_util.dart';

/// 字数统计页面
class WordCountPage extends StatefulWidget {
  const WordCountPage({super.key});

  @override
  State<WordCountPage> createState() => _WordCountPageState();
}

class _WordCountPageState extends State<WordCountPage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, int> _stats = {};
  int _readingTime = 0;
  int _speakingTime = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateStats() {
    final text = _controller.text;
    setState(() {
      _stats = WordCountUtil.getFullStats(text);
      _readingTime = WordCountUtil.estimateReadingTime(text);
      _speakingTime = WordCountUtil.estimateSpeakingTime(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('字数统计')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        const Text('输入文本：', style: TextStyle(fontWeight: FontWeight.bold)),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                final data = await Clipboard.getData('text/plain');
                                if (data?.text != null) {
                                  _controller.text = data!.text!;
                                  _updateStats();
                                }
                              },
                              icon: const Icon(Icons.content_paste, size: 16),
                              label: const Text('粘贴'),
                            ),
                            TextButton.icon(
                              onPressed: () { _controller.clear(); _updateStats(); },
                              icon: const Icon(Icons.clear, size: 16),
                              label: const Text('清空'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _controller,
                      maxLines: 8,
                      decoration: InputDecoration(
                        hintText: '输入或粘贴文本...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onChanged: (_) => _updateStats(),
                    ),
                  ],
                ),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📊 统计结果', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildStatCard('字符', '${_stats['characters']}', Icons.text_fields),
                          _buildStatCard('字符(无空格)', '${_stats['charactersNoSpaces']}', Icons.short_text),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatCard('中文', '${_stats['chineseChars']}', Icons.language),
                          _buildStatCard('英文词', '${_stats['englishWords']}', Icons.abc),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatCard('行数', '${_stats['lines']}', Icons.format_line_spacing),
                          _buildStatCard('段落', '${_stats['paragraphs']}', Icons.notes),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatCard('句子', '${_stats['sentences']}', Icons.format_quote),
                          _buildStatCard('数字', '${_stats['numbers']}', Icons.pin),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 估算时间
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('⏱️ 时间估算', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.menu_book),
                        title: const Text('阅读时间'),
                        subtitle: const Text('中文阅读速度 200字/分钟'),
                        trailing: Text('约 $_readingTime 分钟', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.record_voice_over),
                        title: const Text('朗读时间'),
                        subtitle: const Text('朗读速度 150字/分钟'),
                        trailing: Text('约 ${(_speakingTime / 60).ceil()} 分钟', style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}