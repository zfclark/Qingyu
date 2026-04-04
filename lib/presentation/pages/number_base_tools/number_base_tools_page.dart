/// Number Base Tools Page
/// Author: ZF_Clark
/// Description: UI page for number base conversion between binary, octal, decimal, and hexadecimal. Uses NumberBaseUtil for all conversion operations.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/number_base_util.dart';

/// 进制转换工具页面
/// 提供二进制、八进制、十进制、十六进制之间转换的UI界面
class NumberBaseToolsPage extends StatefulWidget {
  const NumberBaseToolsPage({super.key});

  @override
  State<NumberBaseToolsPage> createState() => _NumberBaseToolsPageState();
}

class _NumberBaseToolsPageState extends State<NumberBaseToolsPage> {
  final TextEditingController _inputController = TextEditingController();
  int _fromBase = 10;
  int _toBase = 16;
  String _output = '';
  String? _errorMessage;
  bool _isIntegerMode = true;
  bool _uppercase = true;
  int _precision = 10;

  /// 进制选项
  final List<Map<String, dynamic>> _baseOptions = [
    {'base': 2, 'name': '二进制', 'prefix': '0b', 'color': Colors.blue},
    {'base': 8, 'name': '八进制', 'prefix': '0o', 'color': Colors.green},
    {'base': 10, 'name': '十进制', 'prefix': '', 'color': Colors.orange},
    {'base': 16, 'name': '十六进制', 'prefix': '0x', 'color': Colors.purple},
  ];

  /// 快速输入值
  final List<String> _quickValues = ['0', '1', '255', '1024', '65535', '1000000'];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  /// 执行转换
  void _convert() {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _output = '';
        _errorMessage = null;
      });
      return;
    }

    String result;
    try {
      if (_isIntegerMode) {
        result = NumberBaseUtil.convert(input, _fromBase, _toBase, uppercase: _uppercase) ?? '';
      } else {
        result = NumberBaseUtil.convertWithFraction(
          input,
          _fromBase,
          _toBase,
          precision: _precision,
          uppercase: _uppercase,
        ) ?? '';
      }

      if (result.isNotEmpty) {
        final prefix = _baseOptions.firstWhere((o) => o['base'] == _toBase)['prefix'] as String;
        setState(() {
          _output = prefix.isEmpty ? result : '$prefix$result';
          _errorMessage = null;
        });
      } else {
        setState(() {
          _output = '';
          _errorMessage = '转换失败，请检查输入格式';
        });
      }
    } catch (e) {
      setState(() {
        _output = '';
        _errorMessage = '转换失败: $e';
      });
    }
  }

  /// 转换为所有进制
  void _convertToAll() {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _output = '';
        _errorMessage = null;
      });
      return;
    }

    final results = NumberBaseUtil.convertToAll(input, _fromBase, uppercase: _uppercase);
    if (results != null) {
      final buffer = StringBuffer();
      for (final base in NumberBaseUtil.supportedBases) {
        final option = _baseOptions.firstWhere((o) => o['base'] == base);
        final prefix = option['prefix'] as String;
        buffer.writeln('$prefix: ${results[base]}');
      }
      setState(() {
        _output = buffer.toString();
        _errorMessage = null;
      });
    } else {
      setState(() {
        _output = '';
        _errorMessage = '转换失败，请检查输入格式';
      });
    }
  }

  /// 交换源进制和目标进制
  void _swapBases() {
    setState(() {
      final temp = _fromBase;
      _fromBase = _toBase;
      _toBase = temp;
      _inputController.clear();
      _output = '';
      _errorMessage = null;
    });
  }

  /// 复制结果
  void _copyResult() {
    if (_output.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('结果已复制到剪贴板')),
    );
  }

  /// 复制单行结果
  void _copySingleLine(String line) {
    final parts = line.split(':');
    if (parts.length > 1) {
      Clipboard.setData(ClipboardData(text: parts[1].trim()));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已复制')),
      );
    }
  }

  /// 清空
  void _clear() {
    setState(() {
      _inputController.clear();
      _output = '';
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('进制转换')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 输入和设置区域
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
                    // 进制选择
                    Row(
                      children: [
                        Expanded(
                          child: _buildBaseSelector('源进制', _fromBase, (value) {
                            setState(() => _fromBase = value);
                          }),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: IconButton(
                            onPressed: _swapBases,
                            icon: const Icon(Icons.swap_horiz),
                            tooltip: '交换进制',
                          ),
                        ),
                        Expanded(
                          child: _buildBaseSelector('目标进制', _toBase, (value) {
                            setState(() => _toBase = value);
                          }),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 输入框
                    TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        labelText: '输入值',
                        hintText: '输入 ${NumberBaseUtil.baseNames[_fromBase]} 格式的数字',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixText: NumberBaseUtil.baseSymbols[_fromBase],
                      ),
                      style: const TextStyle(fontFamily: 'Monospace'),
                      onChanged: (_) => setState(() {}),
                    ),

                    const SizedBox(height: 12),

                    // 快速输入
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _quickValues.map((value) {
                        return ActionChip(
                          label: Text(value),
                          onPressed: () {
                            _inputController.text = value;
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 16),

                    // 选项
                    Row(
                      children: [
                        Expanded(
                          child: SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(value: true, label: Text('整数')),
                              ButtonSegment(value: false, label: Text('小数')),
                            ],
                            selected: {_isIntegerMode},
                            onSelectionChanged: (selected) {
                              setState(() {
                                _isIntegerMode = selected.first;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: [
                            const Text('大写'),
                            Switch(
                              value: _uppercase,
                              onChanged: (value) {
                                setState(() => _uppercase = value);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (!_isIntegerMode) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('小数精度: '),
                          Expanded(
                            child: Slider(
                              value: _precision.toDouble(),
                              min: 1,
                              max: 20,
                              divisions: 19,
                              label: '$_precision',
                              onChanged: (value) {
                                setState(() => _precision = value.round());
                              },
                            ),
                          ),
                          Text('$_precision'),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // 操作按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _convert,
                            icon: const Icon(Icons.calculate),
                            label: const Text('转换'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _convertToAll,
                            icon: const Icon(Icons.table_chart),
                            label: const Text('转换全部'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _clear,
                          icon: const Icon(Icons.clear),
                          tooltip: '清空',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 结果区域
            if (_errorMessage != null)
              Card(
                elevation: 0,
                color: Colors.red.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),

            if (_output.isNotEmpty && !_output.contains(':')) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${NumberBaseUtil.baseNames[_toBase]}结果：',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: _copyResult,
                            icon: const Icon(Icons.copy),
                            tooltip: '复制',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _output,
                          style: TextStyle(
                            fontFamily: 'Monospace',
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_output.contains(':')) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '所有进制转换结果：',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._output.split('\n').where((s) => s.isNotEmpty).map((line) {
                        return InkWell(
                          onTap: () => _copySingleLine(line),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    line,
                                    style: const TextStyle(fontFamily: 'Monospace'),
                                  ),
                                ),
                                Icon(
                                  Icons.copy,
                                  size: 16,
                                  color: Colors.grey[400],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 进制对照表
            Card(
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '常用进制对照表：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('十进制')),
                          DataColumn(label: Text('二进制')),
                          DataColumn(label: Text('八进制')),
                          DataColumn(label: Text('十六进制')),
                        ],
                        rows: List.generate(16, (index) {
                          return DataRow(cells: [
                            DataCell(Text('$index')),
                            DataCell(Text(index.toRadixString(2).padLeft(4, '0'))),
                            DataCell(Text(index.toRadixString(8))),
                            DataCell(Text(index.toRadixString(16).toUpperCase())),
                          ]);
                        }),
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

  Widget _buildBaseSelector(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<int>(
          initialValue: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          items: _baseOptions.map((option) {
            return DropdownMenuItem<int>(
              value: option['base'] as int,
              child: Text(
                '${option['name']} (${option['prefix'] == '' ? '无前缀' : option['prefix']})',
              ),
            );
          }).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ],
    );
  }
}
