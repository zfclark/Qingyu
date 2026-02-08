/// Hash Calculator Page
/// Author: ZF_Clark
/// Description: UI page for hash calculation. Uses HashUtil for calculation logic and StorageService for data persistence. Provides text input, algorithm selection, result display, and history management.
/// Last Modified: 2026/02/08
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/core/utils/hash_util.dart';
import '/core/services/storage_service.dart';
import '/data/models/hash_history_model.dart';

/// 哈希计算器页面
/// 提供哈希计算功能的UI界面
class HashCalculatorPage extends StatefulWidget {
  const HashCalculatorPage({super.key});

  @override
  State<HashCalculatorPage> createState() => _HashCalculatorPageState();
}

class _HashCalculatorPageState extends State<HashCalculatorPage> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  List<HashHistoryModel> _history = [];
  String _selectedAlgorithm = 'SHA256';

  /// 可用的哈希算法列表
  final List<String> _algorithms = HashUtil.supportedAlgorithms;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// 从存储加载历史记录
  void _loadHistory() {
    setState(() {
      _history = StorageService.getHashHistory();
    });
  }

  /// 执行哈希计算
  void _calculateHash() {
    if (_inputController.text.isEmpty) return;

    // 使用工具类执行计算
    final hashString = HashUtil.calculateHash(
      _inputController.text,
      _selectedAlgorithm,
    );

    setState(() {
      _result = hashString;
    });

    // 保存到历史记录
    _saveToHistory(_inputController.text, hashString);
  }

  /// 保存计算到历史记录
  void _saveToHistory(String input, String hash) {
    final historyItem = HashHistoryModel(
      input: input,
      hash: hash,
      algorithm: _selectedAlgorithm,
      timestamp: DateTime.now(),
    );

    setState(() {
      _history.insert(0, historyItem);
      if (_history.length > 50) {
        _history = _history.sublist(0, 50);
      }
    });

    StorageService.saveHashHistory(_history);
  }

  /// 复制结果到剪贴板
  void _copyResult() {
    if (_result.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _result));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('结果已复制到剪贴板')));
  }

  /// 清空输入
  void _clearInput() {
    setState(() {
      _inputController.clear();
      _result = '';
    });
  }

  /// 清空历史记录
  void _clearHistory() {
    setState(() {
      _history.clear();
    });
    StorageService.saveHashHistory([]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('哈希计算器')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 算法选择区域
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
                    const Text('选择算法：'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _algorithms.map((algorithm) {
                        return ChoiceChip(
                          label: Text(algorithm),
                          selected: _selectedAlgorithm == algorithm,
                          onSelected: (selected) {
                            setState(() {
                              _selectedAlgorithm = algorithm;
                              _result = '';
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
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
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _calculateHash,
                            child: Text('计算 $_selectedAlgorithm'),
                          ),
                        ),
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

            // 结果区域
            if (_result.isNotEmpty)
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
                      Text('计算结果 ($_selectedAlgorithm)：'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _result,
                          style: const TextStyle(fontFamily: 'Monospace'),
                        ),
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

            // 历史记录区域
            Expanded(
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('历史记录：'),
                          if (_history.isNotEmpty)
                            TextButton(
                              onPressed: _clearHistory,
                              child: const Text('清空历史'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: _history.isEmpty
                            ? const Center(child: Text('暂无历史记录'))
                            : ListView.builder(
                                itemCount: _history.length,
                                itemBuilder: (context, index) {
                                  final item = _history[index];
                                  return ListTile(
                                    title: Text(
                                      item.input.length > 30
                                          ? '${item.input.substring(0, 30)}...'
                                          : item.input,
                                    ),
                                    subtitle: Text(
                                      '${item.algorithm} · ${item.timestamp.toString().substring(0, 19)}',
                                    ),
                                    trailing: Text(
                                      '${item.hash.substring(0, 10)}...',
                                      style: const TextStyle(
                                        fontFamily: 'Monospace',
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _inputController.text = item.input;
                                        _selectedAlgorithm = item.algorithm;
                                        _result = item.hash;
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
