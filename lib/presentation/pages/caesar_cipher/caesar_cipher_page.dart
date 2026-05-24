/// Caesar Cipher Page
/// Author: ZF_Clark
/// Description: UI page for Caesar cipher encryption, decryption, and brute-force decoding. Uses CaesarCipherUtil for all operations.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/caesar_cipher_util.dart';

/// 操作模式
enum _CipherMode { encrypt, decrypt, bruteForce }

/// 凯撒密码页面
/// 提供凯撒密码的加密、解密和暴力破解功能
class CaesarCipherPage extends StatefulWidget {
  const CaesarCipherPage({super.key});

  @override
  State<CaesarCipherPage> createState() => _CaesarCipherPageState();
}

class _CaesarCipherPageState extends State<CaesarCipherPage> {
  final _inputController = TextEditingController();
  _CipherMode _mode = _CipherMode.encrypt;
  int _shift = 3;
  String _result = '';
  List<Map<String, dynamic>> _bruteResults = [];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _execute() {
    final input = _inputController.text;
    if (input.isEmpty) return;

    setState(() {
      switch (_mode) {
        case _CipherMode.encrypt:
          _result = CaesarCipherUtil.encrypt(input, _shift);
          _bruteResults = [];
          break;
        case _CipherMode.decrypt:
          _result = CaesarCipherUtil.decrypt(input, _shift);
          _bruteResults = [];
          break;
        case _CipherMode.bruteForce:
          _result = '';
          _bruteResults = CaesarCipherUtil.bruteForce(input);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('凯撒密码'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 模式选择
            SegmentedButton<_CipherMode>(
              segments: const [
                ButtonSegment(
                  value: _CipherMode.encrypt,
                  label: Text('加密'),
                  icon: Icon(Icons.lock),
                ),
                ButtonSegment(
                  value: _CipherMode.decrypt,
                  label: Text('解密'),
                  icon: Icon(Icons.lock_open),
                ),
                ButtonSegment(
                  value: _CipherMode.bruteForce,
                  label: Text('暴力破解'),
                  icon: Icon(Icons.key),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selected) {
                setState(() {
                  _mode = selected.first;
                  _result = '';
                  _bruteResults = [];
                });
              },
            ),
            const SizedBox(height: 16),

            // 输入区域
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _mode == _CipherMode.encrypt ? '输入明文' : '输入密文',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _inputController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: _mode == _CipherMode.encrypt
                            ? '请输入要加密的文本...'
                            : '请输入要解密的文本...',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 移位量选择（暴力破解模式不显示）
                    if (_mode != _CipherMode.bruteForce) ...[
                      Row(
                        children: [
                          Text(
                            '移位量: $_shift',
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Slider(
                              value: _shift.toDouble(),
                              min: 0,
                              max: 25,
                              divisions: 25,
                              label: '$_shift',
                              onChanged: (value) {
                                setState(() {
                                  _shift = value.round();
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [3, 5, 13, 25].map((s) {
                          return ActionChip(
                            label: Text('$s'),
                            onPressed: () {
                              setState(() {
                                _shift = s;
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 执行按钮
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _execute,
                        icon: Icon(
                          _mode == _CipherMode.encrypt
                              ? Icons.lock
                              : _mode == _CipherMode.decrypt
                                  ? Icons.lock_open
                                  : Icons.key,
                        ),
                        label: Text(
                          _mode == _CipherMode.encrypt
                              ? '加密'
                              : _mode == _CipherMode.decrypt
                                  ? '解密'
                                  : '暴力破解',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 加密/解密结果
            if (_result.isNotEmpty && _mode != _CipherMode.bruteForce)
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
                            _mode == _CipherMode.encrypt ? '加密结果' : '解密结果',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _result));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已复制')),
                              );
                            },
                          ),
                        ],
                      ),
                      const Divider(),
                      SelectableText(
                        _result,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 暴力破解结果
            if (_bruteResults.isNotEmpty) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.key, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            '暴力破解结果（共 26 种）',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const Divider(),
                      ...List.generate(_bruteResults.length, (index) {
                        final r = _bruteResults[index];
                        return ListTile(
                          dense: true,
                          leading: CircleAvatar(
                            radius: 16,
                            child: Text('${r['shift']}'),
                          ),
                          title: Text(
                            r['text'] as String,
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy, size: 18),
                            onPressed: () {
                              Clipboard.setData(
                                ClipboardData(text: r['text'] as String),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已复制')),
                              );
                            },
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
}
