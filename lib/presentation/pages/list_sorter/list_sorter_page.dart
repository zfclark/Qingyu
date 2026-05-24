/// List Sorter Page
/// Author: ZF_Clark
/// Description: UI page for text line sorting, deduplication, and shuffling. Uses ListSortUtil for all operations.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/list_sort_util.dart';

/// 列表排序器页面
/// 提供文本行的排序、去重和随机打乱功能
class ListSorterPage extends StatefulWidget {
  const ListSorterPage({super.key});

  @override
  State<ListSorterPage> createState() => _ListSorterPageState();
}

class _ListSorterPageState extends State<ListSorterPage> {
  final _inputController = TextEditingController();
  final _outputController = TextEditingController();
  int _removedCount = 0;

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }

  List<String> _getInputLines() {
    return _inputController.text.split('\n');
  }

  void _applyResult(List<String> result) {
    final originalCount = _getInputLines().length;
    setState(() {
      _removedCount = originalCount - result.length;
      _outputController.text = result.join('\n');
    });
  }

  void _useResultAsInput() {
    setState(() {
      _inputController.text = _outputController.text;
      _outputController.text = '';
      _removedCount = 0;
    });
  }

  void _clear() {
    setState(() {
      _inputController.clear();
      _outputController.clear();
      _removedCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final inputLines = _getInputLines();
    final lineCount = _inputController.text.isEmpty
        ? 0
        : inputLines.where((l) => l.trim().isNotEmpty).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('列表排序器'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 输入区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '输入',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$lineCount 行',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _inputController,
                      maxLines: 10,
                      decoration: const InputDecoration(
                        hintText: '每行输入一个条目...',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 操作按钮
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '操作',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ActionChip(
                          avatar: const Icon(Icons.sort_by_alpha, size: 18),
                          label: const Text('A-Z 排序'),
                          onPressed: () => _applyResult(
                            ListSortUtil.sortAlphabetical(_getInputLines()),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.sort_by_alpha, size: 18),
                          label: const Text('Z-A 排序'),
                          onPressed: () => _applyResult(
                            ListSortUtil.sortAlphabetical(
                              _getInputLines(),
                              ascending: false,
                            ),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.numbers, size: 18),
                          label: const Text('数字排序↑'),
                          onPressed: () => _applyResult(
                            ListSortUtil.sortNumerical(_getInputLines()),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.numbers, size: 18),
                          label: const Text('数字排序↓'),
                          onPressed: () => _applyResult(
                            ListSortUtil.sortNumerical(
                              _getInputLines(),
                              ascending: false,
                            ),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.format_line_spacing, size: 18),
                          label: const Text('按长度排序'),
                          onPressed: () => _applyResult(
                            ListSortUtil.sortByLength(_getInputLines()),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.swap_vert, size: 18),
                          label: const Text('反转顺序'),
                          onPressed: () => _applyResult(
                            ListSortUtil.reverse(_getInputLines()),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.shuffle, size: 18),
                          label: const Text('随机打乱'),
                          onPressed: () => _applyResult(
                            ListSortUtil.shuffle(_getInputLines()),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.content_copy, size: 18),
                          label: const Text('去重'),
                          onPressed: () => _applyResult(
                            ListSortUtil.removeDuplicates(_getInputLines()),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.format_clear, size: 18),
                          label: const Text('去除空行'),
                          onPressed: () => _applyResult(
                            ListSortUtil.removeEmptyLines(_getInputLines()),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.format_list_numbered, size: 18),
                          label: const Text('添加序号'),
                          onPressed: () => _applyResult(
                            ListSortUtil.numberedLines(
                              ListSortUtil.removeEmptyLines(_getInputLines()),
                            ),
                          ),
                        ),
                        ActionChip(
                          avatar: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('清空'),
                          onPressed: _clear,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 结果区域
            if (_outputController.text.isNotEmpty)
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
                            '结果',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          if (_removedCount > 0)
                            Text(
                              '移除了 $_removedCount 项',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.error,
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: _outputController.text),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已复制')),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.input),
                            onPressed: _useResultAsInput,
                            tooltip: '使用结果作为输入',
                          ),
                        ],
                      ),
                      const Divider(),
                      TextField(
                        controller: _outputController,
                        maxLines: 10,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        style: const TextStyle(fontFamily: 'monospace'),
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
