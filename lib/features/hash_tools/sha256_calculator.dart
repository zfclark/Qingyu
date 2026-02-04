/// SHA256 Calculator Tool
/// Author: ZF_Clark
/// Description: Provides functionality to compute SHA256 hash values from text input. Supports text input, result copying to clipboard, and history recording with persistence
/// Last Modified: 2026/02/04
/// Version: V0.1
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import '../../data/services/storage_service.dart';
import '../../data/models/hash_history.dart';

class SHA256Calculator extends StatefulWidget {
  const SHA256Calculator({super.key});

  @override
  State<SHA256Calculator> createState() => _SHA256CalculatorState();
}

class _SHA256CalculatorState extends State<SHA256Calculator> {
  final TextEditingController _inputController = TextEditingController();
  String _result = '';
  List<HashHistory> _history = [];

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

  /// Calculate SHA256 hash
  void _calculateSHA256() {
    if (_inputController.text.isEmpty) return;

    final input = _inputController.text;
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    final hashString = hash.toString();

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
      algorithm: 'SHA256',
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
      appBar: AppBar(title: const Text('SHA256 计算器')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                            onPressed: _calculateSHA256,
                            child: const Text('计算 SHA256'),
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
                      const Text('计算结果：'),
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
