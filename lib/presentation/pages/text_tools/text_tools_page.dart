/// Text Tools Page
/// Author: ZF_Clark
/// Description: UI page for text processing tools. Uses TextUtil for text manipulation logic. Provides case conversion, whitespace removal, character statistics, and Base64 encoding/decoding.
/// Last Modified: 2026/02/08
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/text_util.dart';

/// 文本工具页面
/// 提供文本处理功能的UI界面
class TextToolsPage extends StatefulWidget {
  const TextToolsPage({super.key});

  @override
  State<TextToolsPage> createState() => _TextToolsPageState();
}

class _TextToolsPageState extends State<TextToolsPage> {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  int _currentTab = 0;

  /// 标签页选项
  final List<String> _tabs = ['大小写转换', '空格处理', '字符统计', 'Base64', '批量操作'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('文本工具')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 标签栏
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

            // 输入区域
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

            // 输出区域
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
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
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

            // 字符统计
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
                    Text('单词数：${TextUtil.countWords(_inputController.text)}'),
                    Text('行数：${TextUtil.countLines(_inputController.text)}'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 根据当前标签构建操作按钮
  Widget _buildActionButton() {
    switch (_currentTab) {
      case 0: // 大小写转换
        return Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _convertCase(TextCaseType.uppercase),
                child: const Text('转大写'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _convertCase(TextCaseType.lowercase),
                child: const Text('转小写'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _convertCase(TextCaseType.capitalize),
                child: const Text('首字母大写'),
              ),
            ),
          ],
        );
      case 1: // 空格处理
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
      case 2: // 字符统计
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

  /// 转换大小写
  void _convertCase(TextCaseType type) {
    setState(() {
      _output = TextUtil.convertCase(_inputController.text, type);
    });
  }

  /// 移除空格
  void _removeSpaces() {
    setState(() {
      _output = TextUtil.removeSpaces(_inputController.text);
    });
  }

  /// 移除换行符
  void _removeNewlines() {
    setState(() {
      _output = TextUtil.removeNewlines(_inputController.text);
    });
  }

  /// 移除所有空白字符
  void _removeAllWhitespace() {
    setState(() {
      _output = TextUtil.removeAllWhitespace(_inputController.text);
    });
  }

  /// 显示详细统计
  void _showDetailedCount() {
    final stats = TextUtil.getDetailedStats(_inputController.text);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('详细统计'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('总字符数：${stats['characters']}'),
              Text('单词数：${stats['words']}'),
              Text('行数：${stats['lines']}'),
              Text('空格数：${stats['spaces']}'),
              Text('标点符号数：${stats['punctuation']}'),
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

  /// Base64编码
  void _encodeBase64() {
    final result = TextUtil.encodeBase64(_inputController.text);
    if (result == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('编码失败，请检查输入')));
    } else {
      setState(() {
        _output = result;
      });
    }
  }

  /// Base64解码
  void _decodeBase64() {
    final result = TextUtil.decodeBase64(_inputController.text);
    if (result == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('解码失败，请检查输入')));
    } else {
      setState(() {
        _output = result;
      });
    }
  }

  /// 复制结果到剪贴板
  void _copyResult() {
    if (_output.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('结果已复制到剪贴板')));
  }

  /// 清空输入
  void _clearInput() {
    setState(() {
      _inputController.clear();
      _output = '';
    });
  }

  /// 显示批量操作对话框
  void _showBatchOperationDialog() {
    final List<String> operations = [
      '转大写',
      '转小写',
      '首字母大写',
      '去除空格',
      '去除换行',
      '去除所有空白',
    ];
    final List<bool> selectedOperations = List<bool>.filled(
      operations.length,
      false,
    );

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

  /// 执行批量操作
  void _executeBatchOperations(List<bool> selectedOperations) {
    if (_inputController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先输入文本')));
      return;
    }

    var result = _inputController.text;

    // 按顺序执行选中的操作
    if (selectedOperations[0]) {
      // 转大写
      result = TextUtil.convertCase(result, TextCaseType.uppercase);
    }
    if (selectedOperations[1]) {
      // 转小写
      result = TextUtil.convertCase(result, TextCaseType.lowercase);
    }
    if (selectedOperations[2]) {
      // 首字母大写
      result = TextUtil.convertCase(result, TextCaseType.capitalize);
    }
    if (selectedOperations[3]) {
      // 去除空格
      result = TextUtil.removeSpaces(result);
    }
    if (selectedOperations[4]) {
      // 去除换行
      result = TextUtil.removeNewlines(result);
    }
    if (selectedOperations[5]) {
      // 去除所有空白
      result = TextUtil.removeAllWhitespace(result);
    }

    setState(() {
      _output = result;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('批量操作已执行完成')));
  }
}
