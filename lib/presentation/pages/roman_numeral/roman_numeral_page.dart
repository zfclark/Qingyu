/// Roman Numeral Page
/// Author: ZF_Clark
/// Description: UI page for Roman numeral conversion. Uses NumberBaseUtil.toRoman() and NumberBaseUtil.fromRoman() for conversion.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/number_base_util.dart';

/// 转换模式
enum _RomanMode { toRoman, fromRoman, reference }

/// 罗马数字转换页面
/// 提供整数与罗马数字的互转功能
class RomanNumeralPage extends StatefulWidget {
  const RomanNumeralPage({super.key});

  @override
  State<RomanNumeralPage> createState() => _RomanNumeralPageState();
}

class _RomanNumeralPageState extends State<RomanNumeralPage> {
  final _controller = TextEditingController();
  _RomanMode _mode = _RomanMode.toRoman;
  String _result = '';
  String? _error;

  final List<int> _intPresets = [1, 4, 9, 42, 99, 499, 999, 1999, 3999];
  final List<String> _romanPresets = ['I', 'IV', 'IX', 'XLII', 'XCIX', 'MCMXCIX'];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _convert() {
    final input = _controller.text.trim();
    if (input.isEmpty) {
      setState(() {
        _result = '';
        _error = '请输入内容';
      });
      return;
    }

    setState(() {
      _error = null;
      switch (_mode) {
        case _RomanMode.toRoman:
          final num = int.tryParse(input);
          if (num == null) {
            _error = '请输入有效的整数';
            _result = '';
          } else {
            final roman = NumberBaseUtil.toRoman(num);
            if (roman == null) {
              _error = '请输入 1-3999 范围内的整数';
              _result = '';
            } else {
              _result = roman;
            }
          }
          break;
        case _RomanMode.fromRoman:
          final num = NumberBaseUtil.fromRoman(input.toUpperCase());
          if (num == null) {
            _error = '请输入有效的罗马数字';
            _result = '';
          } else {
            _result = '$num';
          }
          break;
        case _RomanMode.reference:
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
        title: const Text('罗马数字转换'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 模式选择
            SegmentedButton<_RomanMode>(
              segments: const [
                ButtonSegment(
                  value: _RomanMode.toRoman,
                  label: Text('数字转罗马'),
                  icon: Icon(Icons.arrow_forward),
                ),
                ButtonSegment(
                  value: _RomanMode.fromRoman,
                  label: Text('罗马转数字'),
                  icon: Icon(Icons.arrow_back),
                ),
                ButtonSegment(
                  value: _RomanMode.reference,
                  label: Text('对照表'),
                  icon: Icon(Icons.table_chart),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (selected) {
                setState(() {
                  _mode = selected.first;
                  _result = '';
                  _error = null;
                  _controller.clear();
                });
              },
            ),
            const SizedBox(height: 16),

            // 输入区域（对照表模式不显示）
            if (_mode != _RomanMode.reference)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _mode == _RomanMode.toRoman
                            ? '输入整数（1-3999）'
                            : '输入罗马数字',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              keyboardType: _mode == _RomanMode.toRoman
                                  ? TextInputType.number
                                  : TextInputType.text,
                              decoration: InputDecoration(
                                hintText: _mode == _RomanMode.toRoman
                                    ? '例如: 1999'
                                    : '例如: MCMXCIX',
                                border: const OutlineInputBorder(),
                              ),
                              textCapitalization: _mode == _RomanMode.fromRoman
                                  ? TextCapitalization.characters
                                  : TextCapitalization.none,
                              onSubmitted: (_) => _convert(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _convert,
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('转换'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (_mode == _RomanMode.toRoman
                                ? _intPresets.map((n) => ActionChip(
                                      label: Text('$n'),
                                      onPressed: () {
                                        _controller.text = '$n';
                                        _convert();
                                      },
                                    ))
                                : _romanPresets.map((r) => ActionChip(
                                      label: Text(r),
                                      onPressed: () {
                                        _controller.text = r;
                                        _convert();
                                      },
                                    )))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // 错误提示
            if (_error != null)
              Card(
                color: colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: TextStyle(color: colorScheme.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 转换结果
            if (_result.isNotEmpty && _mode != _RomanMode.reference)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: colorScheme.primary),
                          const SizedBox(width: 8),
                          Text(
                            '转换结果',
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
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                          letterSpacing: _mode == _RomanMode.toRoman ? 4 : 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 对照表
            if (_mode == _RomanMode.reference)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '罗马数字对照表',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Divider(),
                      DataTable(
                        columns: const [
                          DataColumn(label: Text('整数')),
                          DataColumn(label: Text('罗马数字')),
                          DataColumn(label: Text('说明')),
                        ],
                        rows: const [
                          DataRow(cells: [
                            DataCell(Text('1')),
                            DataCell(Text('I')),
                            DataCell(Text('基本符号')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('4')),
                            DataCell(Text('IV')),
                            DataCell(Text('减法原则')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('5')),
                            DataCell(Text('V')),
                            DataCell(Text('基本符号')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('9')),
                            DataCell(Text('IX')),
                            DataCell(Text('减法原则')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('10')),
                            DataCell(Text('X')),
                            DataCell(Text('基本符号')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('40')),
                            DataCell(Text('XL')),
                            DataCell(Text('减法原则')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('50')),
                            DataCell(Text('L')),
                            DataCell(Text('基本符号')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('90')),
                            DataCell(Text('XC')),
                            DataCell(Text('减法原则')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('100')),
                            DataCell(Text('C')),
                            DataCell(Text('基本符号')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('400')),
                            DataCell(Text('CD')),
                            DataCell(Text('减法原则')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('500')),
                            DataCell(Text('D')),
                            DataCell(Text('基本符号')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('900')),
                            DataCell(Text('CM')),
                            DataCell(Text('减法原则')),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('1000')),
                            DataCell(Text('M')),
                            DataCell(Text('基本符号')),
                          ]),
                        ],
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
