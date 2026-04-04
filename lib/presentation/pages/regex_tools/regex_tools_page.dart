/// Regex Tools Page
/// Author: ZF_Clark
/// Description: UI page for regular expression testing and validation. Uses RegexUtil for all regex operations.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/regex_util.dart';

/// 正则表达式工具页面
/// 提供正则匹配、常用模式功能的UI界面
class RegexToolsPage extends StatefulWidget {
  const RegexToolsPage({super.key});

  @override
  State<RegexToolsPage> createState() => _RegexToolsPageState();
}

class _RegexToolsPageState extends State<RegexToolsPage> {
  final TextEditingController _patternController = TextEditingController();
  final TextEditingController _inputController = TextEditingController();
  RegexTestResult? _result;
  String? _errorMessage;
  bool _caseSensitive = true;

  @override
  void dispose() {
    _patternController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _test() {
    final pattern = _patternController.text;
    final input = _inputController.text;

    if (pattern.isEmpty) {
      setState(() {
        _result = null;
        _errorMessage = '请输入正则表达式';
      });
      return;
    }

    final result = RegexUtil.test(
      input,
      pattern,
      caseSensitive: _caseSensitive,
    );
    setState(() {
      _result = result;
      _errorMessage = result.error;
    });
  }

  void _applyPattern(String pattern) {
    _patternController.text = pattern;
    _test();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('正则匹配')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 正则输入
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '正则表达式：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _patternController,
                      decoration: InputDecoration(
                        hintText: '输入正则表达式...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixText: '/',
                        suffixText: _caseSensitive ? '/i' : '/',
                        prefixStyle: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'Monospace'),
                      onChanged: (_) => _test(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          value: _caseSensitive,
                          onChanged: (v) {
                            setState(() => _caseSensitive = v ?? true);
                            _test();
                          },
                        ),
                        const Text('区分大小写'),
                        const Spacer(),
                        if (_errorMessage != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 常用模式
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '常用模式：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: RegexUtil.commonPatterns.keys.take(10).map((
                        name,
                      ) {
                        return ActionChip(
                          label: Text(
                            name,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onPressed: () =>
                              _applyPattern(RegexUtil.commonPatterns[name]!),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 文本匹配
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '匹配文本：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            TextButton.icon(
                              onPressed: () async {
                                final data = await Clipboard.getData(
                                  'text/plain',
                                );
                                if (data?.text != null) {
                                  _inputController.text = data!.text!;
                                  _test();
                                }
                              },
                              icon: const Icon(Icons.content_paste, size: 16),
                              label: const Text('粘贴'),
                            ),
                            TextButton.icon(
                              onPressed: () => _inputController.clear(),
                              icon: const Icon(Icons.clear, size: 16),
                              label: const Text('清空'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: '输入要匹配的文本...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: const TextStyle(fontFamily: 'Monospace'),
                      onChanged: (_) => _test(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 匹配结果
            if (_result != null)
              Card(
                elevation: 0,
                color: _result!.isMatch
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _result!.isMatch ? Icons.check_circle : Icons.info,
                            color: _result!.isMatch
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _result!.isMatch ? '匹配成功' : '未匹配',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _result!.isMatch
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                          const Spacer(),
                          Text('${_result!.matches.length} 个匹配'),
                        ],
                      ),
                      if (_result!.matches.isNotEmpty) ...[
                        const Divider(),
                        const Text(
                          '匹配项：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ...List.generate(_result!.matches.length.clamp(0, 20), (
                          i,
                        ) {
                          final match = _result!.matchDetails[i];
                          return ListTile(
                            dense: true,
                            leading: CircleAvatar(
                              radius: 12,
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ),
                            title: Text(
                              match.match,
                              style: const TextStyle(fontFamily: 'Monospace'),
                            ),
                            subtitle: Text(
                              '位置: ${match.start}-${match.end}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy, size: 16),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: match.match),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('已复制')),
                                );
                              },
                            ),
                          );
                        }),
                      ],
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
