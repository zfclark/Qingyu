/// Text Tools
/// Author: ZF_Clark
/// Description: Provides text processing utilities including case conversion (uppercase, lowercase, capitalize), whitespace removal (spaces, newlines, all whitespace), character count with detailed statistics, and Base64 encoding/decoding functionality
/// Last Modified: 2026/02/04
/// Version: V0.1
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextTools extends StatefulWidget {
  const TextTools({super.key});

  @override
  State<TextTools> createState() => _TextToolsState();
}

class _TextToolsState extends State<TextTools> {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  int _currentTab = 0;

  /// Tab options
  final List<String> _tabs = ['大小写转换', '空格处理', '字符统计', 'Base64', '批量操作'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文本工具')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tab bar
            DefaultTabController(
              length: _tabs.length,
              initialIndex: _currentTab,
              child: TabBar(
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                onTap: (index) {
                  setState(() {
                    _currentTab = index;
                    _output = '';
                  });
                },
                isScrollable: true,
              ),
            ),
            const SizedBox(height: 16),

            // Input section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('输入文本：'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '请输入或粘贴文本',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildActionButton()),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: _clearInput,
                          child: const Text('清空'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Output section
            if (_output.isNotEmpty)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('处理结果：'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(_output),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _copyResult,
                        icon: const Icon(Icons.copy),
                        label: const Text('复制结果'),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Character count
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('字符数：${_inputController.text.length}'),
                    Text('单词数：${_countWords()}'),
                    Text('行数：${_countLines()}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build action button based on current tab
  Widget _buildActionButton() {
    switch (_currentTab) {
      case 0: // Case conversion
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _convertCase('uppercase'),
                child: const Text('转大写'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _convertCase('lowercase'),
                child: const Text('转小写'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _convertCase('capitalize'),
                child: const Text('首字母大写'),
              ),
            ),
          ],
        );
      case 1: // Whitespace processing
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _removeSpaces,
                child: const Text('去除空格'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _removeNewlines,
                child: const Text('去除换行'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _removeAllWhitespace,
                child: const Text('去除所有空白'),
              ),
            ),
          ],
        );
      case 2: // Character count
        return ElevatedButton(
          onPressed: _showDetailedCount,
          child: const Text('详细统计'),
        );
      case 3: // Base64
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _encodeBase64,
                child: const Text('编码'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: _decodeBase64,
                child: const Text('解码'),
              ),
            ),
          ],
        );
      case 4: // 批量操作
        return ElevatedButton(
          onPressed: _showBatchOperationDialog,
          child: const Text('批量处理'),
        );
      default:
        return ElevatedButton(onPressed: () {}, child: const Text('执行'));
    }
  }

  /// Convert case
  void _convertCase(String type) {
    final input = _inputController.text;
    String result;

    switch (type) {
      case 'uppercase':
        result = input.toUpperCase();
        break;
      case 'lowercase':
        result = input.toLowerCase();
        break;
      case 'capitalize':
        if (input.isEmpty) {
          result = '';
        } else {
          result =
              input.substring(0, 1).toUpperCase() +
              input.substring(1).toLowerCase();
        }
        break;
      default:
        result = input;
    }

    setState(() {
      _output = result;
    });
  }

  /// Remove spaces
  void _removeSpaces() {
    setState(() {
      _output = _inputController.text.replaceAll(' ', '');
    });
  }

  /// Remove newlines
  void _removeNewlines() {
    setState(() {
      _output = _inputController.text.replaceAll('\n', '').replaceAll('\r', '');
    });
  }

  /// Remove all whitespace
  void _removeAllWhitespace() {
    setState(() {
      _output = _inputController.text.replaceAll(RegExp(r'\s+'), '');
    });
  }

  /// Show detailed character count
  void _showDetailedCount() {
    final input = _inputController.text;
    final charCount = input.length;
    final wordCount = _countWords();
    final lineCount = _countLines();
    final spaceCount = input.split(' ').length - 1;
    final punctuationCount =
        input.split(RegExp(r'[.,;!?()\[\]{}:"]')).length - 1;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('详细统计'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('总字符数：$charCount'),
              Text('单词数：$wordCount'),
              Text('行数：$lineCount'),
              Text('空格数：$spaceCount'),
              Text('标点符号数：$punctuationCount'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// Encode to Base64
  void _encodeBase64() {
    try {
      final input = _inputController.text;
      final bytes = utf8.encode(input);
      final encoded = base64.encode(bytes);
      setState(() {
        _output = encoded;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('编码失败，请检查输入')));
    }
  }

  /// Decode from Base64
  void _decodeBase64() {
    try {
      final input = _inputController.text;
      final bytes = base64.decode(input);
      final decoded = utf8.decode(bytes);
      setState(() {
        _output = decoded;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('解码失败，请检查输入')));
    }
  }

  /// Copy result to clipboard
  void _copyResult() {
    if (_output.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('结果已复制到剪贴板')));
  }

  /// Clear input field
  void _clearInput() {
    setState(() {
      _inputController.clear();
      _output = '';
    });
  }

  /// Count words
  int _countWords() {
    final input = _inputController.text.trim();
    if (input.isEmpty) return 0;
    return input.split(RegExp(r'\s+')).length;
  }

  /// Count lines
  int _countLines() {
    final input = _inputController.text;
    if (input.isEmpty) return 0;
    return input.split('\n').length;
  }

  /// Show batch operation dialog
  void _showBatchOperationDialog() {
    final List<String> operations = [
      '转大写',
      '转小写',
      '首字母大写',
      '去除空格',
      '去除换行',
      '去除所有空白',
    ];
    final List<bool> selectedOperations = List<bool>.filled(operations.length, false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('批量操作'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(operations.length, (index) {
                  return CheckboxListTile(
                    title: Text(operations[index]),
                    value: selectedOperations[index],
                    onChanged: (value) {
                      setState(() {
                        selectedOperations[index] = value ?? false;
                      });
                    },
                  );
                }),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                _executeBatchOperations(selectedOperations);
                Navigator.pop(context);
              },
              child: const Text('执行'),
            ),
          ],
        );
      },
    );
  }

  /// Execute batch operations
  void _executeBatchOperations(List<bool> selectedOperations) {
    if (_inputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先输入文本')),
      );
      return;
    }

    var result = _inputController.text;

    // 按顺序执行选中的操作
    if (selectedOperations[0]) { // 转大写
      result = result.toUpperCase();
    }
    if (selectedOperations[1]) { // 转小写
      result = result.toLowerCase();
    }
    if (selectedOperations[2]) { // 首字母大写
      if (result.isNotEmpty) {
        result = result.substring(0, 1).toUpperCase() + result.substring(1).toLowerCase();
      }
    }
    if (selectedOperations[3]) { // 去除空格
      result = result.replaceAll(' ', '');
    }
    if (selectedOperations[4]) { // 去除换行
      result = result.replaceAll('\n', '').replaceAll('\r', '');
    }
    if (selectedOperations[5]) { // 去除所有空白
      result = result.replaceAll(RegExp(r'\s+'), '');
    }

    setState(() {
      _output = result;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('批量操作已执行完成')),
    );
  }
}
