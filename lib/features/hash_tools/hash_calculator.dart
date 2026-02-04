/// Hash Calculator Tool
/// Author: ZF_Clark
/// Description: Unified hash calculation tool supporting multiple algorithms including SHA1, SHA256, SHA512, and MD5. Provides text input, hash calculation, result copying, and history recording functionality
/// Last Modified: 2026/02/04
/// Version: V0.1
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import '../../data/services/storage_service.dart';
import '../../data/models/hash_history.dart';

class HashCalculator extends StatefulWidget {
  const HashCalculator({super.key});

  @override
  State<HashCalculator> createState() => _HashCalculatorState();
}

class _HashCalculatorState extends State<HashCalculator> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  List<HashHistory> _history = [];
  String _selectedAlgorithm = 'SHA256';

  /// Available hash algorithms
  final List<String> _algorithms = ['SHA1', 'SHA256', 'SHA512', 'MD5'];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  /// Load calculation history from storage
  void _loadHistory() {
    setState(() {
      _history = StorageService.getHashHistory();
    });
  }

  /// Calculate hash based on selected algorithm
  void _calculateHash() {
    if (_inputController.text.isEmpty) return;

    final input = _inputController.text;
    final bytes = utf8.encode(input);
    String hashString;

    switch (_selectedAlgorithm) {
      case 'SHA1':
        final hash = sha1.convert(bytes);
        hashString = hash.toString();
        break;
      case 'SHA256':
        final hash = sha256.convert(bytes);
        hashString = hash.toString();
        break;
      case 'SHA512':
        final hash = sha512.convert(bytes);
        hashString = hash.toString();
        break;
      case 'MD5':
        final hash = md5.convert(bytes);
        hashString = hash.toString();
        break;
      default:
        final hash = sha256.convert(bytes);
        hashString = hash.toString();
    }

    setState(() {
      _result = hashString;
    });

    // Save to history
    _saveToHistory(input, hashString);
  }

  /// Save calculation to history
  void _saveToHistory(String input, String hash) {
    final historyItem = HashHistory(
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

  /// Copy result to clipboard
  void _copyResult() {
    if (_result.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _result));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('结果已复制到剪贴板')));
  }

  /// Clear input field
  void _clearInput() {
    setState(() {
      _inputController.clear();
      _result = '';
    });
  }

  /// Clear history
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
            // Algorithm selection
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

            // Result section
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

            // History section
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
