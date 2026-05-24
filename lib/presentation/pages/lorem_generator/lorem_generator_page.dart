/// Lorem Generator Page
/// Author: ZF_Clark
/// Description: UI page for generating placeholder text in English and Chinese. Uses LoremUtil for text generation.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/lorem_util.dart';

/// 文本模式
enum _LoremMode { words, sentences, paragraphs }

/// 语言
enum _LoremLanguage { english, chinese }

/// Lorem 占位文本生成器页面
/// 提供英文和中文占位文本的生成功能
class LoremGeneratorPage extends StatefulWidget {
  const LoremGeneratorPage({super.key});

  @override
  State<LoremGeneratorPage> createState() => _LoremGeneratorPageState();
}

class _LoremGeneratorPageState extends State<LoremGeneratorPage> {
  _LoremMode _mode = _LoremMode.words;
  _LoremLanguage _language = _LoremLanguage.english;
  final _countController = TextEditingController(text: '5');
  String _result = '';

  @override
  void dispose() {
    _countController.dispose();
    super.dispose();
  }

  void _generate() {
    final count = int.tryParse(_countController.text) ?? 0;
    if (count <= 0) return;

    setState(() {
      switch (_mode) {
        case _LoremMode.words:
          _result = _language == _LoremLanguage.english
              ? LoremUtil.generateWords(count)
              : LoremUtil.generateChineseWords(count);
          break;
        case _LoremMode.sentences:
          _result = _language == _LoremLanguage.english
              ? LoremUtil.generateSentences(count)
              : LoremUtil.generateChineseSentences(count);
          break;
        case _LoremMode.paragraphs:
          _result = _language == _LoremLanguage.english
              ? LoremUtil.generateParagraphs(count)
              : LoremUtil.generateChineseParagraphs(count);
          break;
      }
    });
  }

  int _getWordCount() {
    if (_result.isEmpty) return 0;
    if (_language == _LoremLanguage.chinese) return _result.length;
    return _result.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lorem 生成器'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 语言选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '语言',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<_LoremLanguage>(
                      segments: const [
                        ButtonSegment(
                          value: _LoremLanguage.english,
                          label: Text('English'),
                        ),
                        ButtonSegment(
                          value: _LoremLanguage.chinese,
                          label: Text('中文'),
                        ),
                      ],
                      selected: {_language},
                      onSelectionChanged: (selected) {
                        setState(() {
                          _language = selected.first;
                          _result = '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 模式选择
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '生成模式',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<_LoremMode>(
                      segments: const [
                        ButtonSegment(
                          value: _LoremMode.words,
                          label: Text('单词'),
                          icon: Icon(Icons.short_text),
                        ),
                        ButtonSegment(
                          value: _LoremMode.sentences,
                          label: Text('句子'),
                          icon: Icon(Icons.subject),
                        ),
                        ButtonSegment(
                          value: _LoremMode.paragraphs,
                          label: Text('段落'),
                          icon: Icon(Icons.article),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (selected) {
                        setState(() {
                          _mode = selected.first;
                          _result = '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 数量输入
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '数量',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _countController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '输入数量',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton.icon(
                          onPressed: _generate,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('生成'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [5, 10, 20, 50].map((n) {
                        return ActionChip(
                          label: Text('$n'),
                          onPressed: () {
                            _countController.text = '$n';
                            _generate();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 生成结果
            if (_result.isNotEmpty)
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
                            '生成结果',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_result.length} 字符 / ${_getWordCount()} 词',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _result));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已复制')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.refresh),
                            onPressed: _generate,
                            tooltip: '重新生成',
                          ),
                        ],
                      ),
                      const Divider(),
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxHeight: 300),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _result,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.6,
                            ),
                          ),
                        ),
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
}
