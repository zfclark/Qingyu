/// Calculator Page
/// Author: ZF_Clark
/// Description: Enhanced calculator with history, scientific functions, and percentage calculations. Uses CalculatorUtil for calculation logic.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/calculator_util.dart';

/// 计算器页面
/// 提供基础四则运算和科学计算功能的UI界面
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _display = '0';
  double _firstOperand = 0;
  double _secondOperand = 0;
  String _operator = '';
  bool _isNewOperation = true;
  bool _isScientific = false;
  final List<String> _history = [];

  /// 基础按钮配置
  final List<List<Map<String, dynamic>>> _basicButtons = [
    [
      {'text': 'C', 'color': Colors.grey[300], 'textColor': Colors.black},
      {'text': '±', 'color': Colors.grey[300], 'textColor': Colors.black},
      {'text': '%', 'color': Colors.grey[300], 'textColor': Colors.black},
      {'text': '÷', 'color': Colors.orange, 'textColor': Colors.white},
    ],
    [
      {'text': '7', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '8', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '9', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '×', 'color': Colors.orange, 'textColor': Colors.white},
    ],
    [
      {'text': '4', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '5', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '6', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '-', 'color': Colors.orange, 'textColor': Colors.white},
    ],
    [
      {'text': '1', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '2', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '3', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '+', 'color': Colors.orange, 'textColor': Colors.white},
    ],
    [
      {
        'text': '0',
        'color': Colors.grey[100],
        'textColor': Colors.black,
        'flex': 2,
      },
      {'text': '.', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '=', 'color': Colors.orange, 'textColor': Colors.white},
    ],
  ];

  /// 科学计算按钮配置
  final List<List<Map<String, dynamic>>> _scientificButtons = [
    [
      {'text': 'sin', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': 'cos', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': 'tan', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': '√', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': 'x²', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': 'xʸ', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
    ],
    [
      {'text': 'ln', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': 'log', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': 'π', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': 'e', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': '(', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': ')', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
    ],
    [
      {'text': '1/x', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': 'n!', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': '|x|', 'color': Colors.blueGrey[100], 'textColor': Colors.blueGrey[700]},
      {'text': 'C', 'color': Colors.grey[300], 'textColor': Colors.black},
      {'text': '⌫', 'color': Colors.grey[300], 'textColor': Colors.black},
      {'text': '÷', 'color': Colors.orange, 'textColor': Colors.white},
    ],
    [
      {'text': '7', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '8', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '9', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '×', 'color': Colors.orange, 'textColor': Colors.white},
    ],
    [
      {'text': '4', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '5', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '6', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '-', 'color': Colors.orange, 'textColor': Colors.white},
    ],
    [
      {'text': '1', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '2', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '3', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '+', 'color': Colors.orange, 'textColor': Colors.white},
    ],
    [
      {
        'text': '0',
        'color': Colors.grey[100],
        'textColor': Colors.black,
        'flex': 2,
      },
      {'text': '.', 'color': Colors.grey[100], 'textColor': Colors.black},
      {'text': '=', 'color': Colors.orange, 'textColor': Colors.white},
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('计算器'),
        actions: [
          // 科学计算切换
          IconButton(
            onPressed: () {
              setState(() {
                _isScientific = !_isScientific;
              });
            },
            icon: Icon(_isScientific ? Icons.calculate : Icons.science),
            tooltip: _isScientific ? '普通计算器' : '科学计算器',
          ),
          // 历史记录
          IconButton(
            onPressed: _showHistory,
            icon: const Icon(Icons.history),
            tooltip: '历史记录',
          ),
        ],
      ),
      body: Column(
        children: [
          // 表达式显示
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            alignment: Alignment.centerRight,
            child: Text(
              _operator.isNotEmpty ? '$_firstOperand $_operator ...' : '',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),

          // 显示屏
          Expanded(
            flex: _isScientific ? 1 : 2,
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_history.isNotEmpty && _history.length <= 3)
                    ...List.generate(_history.length, (i) {
                      return Text(
                        _history[_history.length - 1 - i],
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                        ),
                      );
                    }),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      _display,
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w300,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 按钮区域
          Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: _isScientific
                  ? _scientificButtons.map((row) => _buildButtonRow(row)).toList()
                  : _basicButtons.map((row) => _buildButtonRow(row)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建按钮行
  Widget _buildButtonRow(List<Map<String, dynamic>> row) {
    return Row(
      children: List.generate(row.length, (index) {
        final button = row[index];
        return Expanded(
          flex: button['flex'] ?? 1,
          child: Container(
            margin: const EdgeInsets.all(2),
            child: ElevatedButton(
              onPressed: () => _onButtonPressed(button['text']),
              style: ElevatedButton.styleFrom(
                backgroundColor: button['color'],
                foregroundColor: button['textColor'],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                button['text'],
                style: TextStyle(
                  fontSize: button['text'].length > 1 ? 16 : 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  /// 处理按钮点击
  void _onButtonPressed(String buttonText) {
    setState(() {
      switch (buttonText) {
        case 'C':
          _clear();
          break;
        case '⌫':
          _backspace();
          break;
        case '±':
          _toggleSign();
          break;
        case '%':
          _calculatePercentage();
          break;
        case '÷':
        case '×':
        case '-':
        case '+':
          _setOperator(buttonText);
          break;
        case '=':
          _calculateResult();
          break;
        case '.':
          _addDecimal();
          break;
        case '√':
          _applyUnaryFunction('sqrt');
          break;
        case 'x²':
          _applyUnaryFunction('square');
          break;
        case 'sin':
          _applyUnaryFunction('sin');
          break;
        case 'cos':
          _applyUnaryFunction('cos');
          break;
        case 'tan':
          _applyUnaryFunction('tan');
          break;
        case 'ln':
          _applyUnaryFunction('ln');
          break;
        case 'log':
          _applyUnaryFunction('log');
          break;
        case '1/x':
          _applyUnaryFunction('reciprocal');
          break;
        case 'n!':
          _applyUnaryFunction('factorial');
          break;
        case '|x|':
          _applyUnaryFunction('abs');
          break;
        case 'xʸ':
          _setOperator('^');
          break;
        case 'π':
          _inputConstant(3.14159265359);
          break;
        case 'e':
          _inputConstant(2.71828182846);
          break;
        default:
          _addDigit(buttonText);
      }
    });
  }

  /// 清空计算器
  void _clear() {
    _display = '0';
    _firstOperand = 0;
    _secondOperand = 0;
    _operator = '';
    _isNewOperation = true;
  }

  /// 退格
  void _backspace() {
    if (_display.length > 1) {
      _display = _display.substring(0, _display.length - 1);
    } else {
      _display = '0';
    }
  }

  /// 切换正负号
  void _toggleSign() {
    if (_display == '0') return;
    final value = CalculatorUtil.parseNumber(_display);
    final result = CalculatorUtil.toggleSign(value);
    _display = CalculatorUtil.formatResult(result);
  }

  /// 计算百分比
  void _calculatePercentage() {
    final value = CalculatorUtil.parseNumber(_display);
    final result = CalculatorUtil.calculatePercentage(value);
    _display = CalculatorUtil.formatResult(result);
  }

  /// 设置运算符
  void _setOperator(String operator) {
    _firstOperand = CalculatorUtil.parseNumber(_display);
    _operator = operator;
    _isNewOperation = true;
  }

  /// 计算结果
  void _calculateResult() {
    if (_operator.isEmpty) return;

    _secondOperand = CalculatorUtil.parseNumber(_display);
    final result = CalculatorUtil.calculate(_firstOperand, _secondOperand, _operator);

    if (result == null) {
      _display = '错误';
    } else {
      final expression = '$_firstOperand $_operator $_secondOperand = $_display';
      if (_history.length >= 10) _history.removeAt(0);
      _history.add(expression);
      _display = CalculatorUtil.formatResult(result);
    }

    _operator = '';
    _isNewOperation = true;
  }

  /// 添加小数点
  void _addDecimal() {
    _display = CalculatorUtil.addDecimal(_display);
  }

  /// 添加数字
  void _addDigit(String digit) {
    _display = CalculatorUtil.appendDigit(_display, digit, _isNewOperation);
    _isNewOperation = false;
  }

  /// 输入常数
  void _inputConstant(double value) {
    _display = CalculatorUtil.formatResult(value);
    _isNewOperation = true;
  }

  /// 应用单目函数
  void _applyUnaryFunction(String function) {
    final value = CalculatorUtil.parseNumber(_display);
    double? result;

    switch (function) {
      case 'sqrt':
        result = CalculatorUtil.sqrt(value);
        break;
      case 'square':
        result = CalculatorUtil.square(value);
        break;
      case 'sin':
        result = CalculatorUtil.sin(value);
        break;
      case 'cos':
        result = CalculatorUtil.cos(value);
        break;
      case 'tan':
        result = CalculatorUtil.tan(value);
        break;
      case 'ln':
        result = CalculatorUtil.ln(value);
        break;
      case 'log':
        result = CalculatorUtil.log(value);
        break;
      case 'reciprocal':
        result = CalculatorUtil.reciprocal(value);
        break;
      case 'factorial':
        result = CalculatorUtil.factorial(value.toInt());
        break;
      case 'abs':
        result = CalculatorUtil.abs(value);
        break;
    }

    if (result != null && !result.isNaN && !result.isInfinite) {
      _display = CalculatorUtil.formatResult(result);
      _isNewOperation = true;
    } else {
      _display = '错误';
    }
  }

  /// 显示历史记录
  void _showHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '计算历史',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_history.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      setState(() => _history.clear());
                      Navigator.pop(context);
                    },
                    child: const Text('清空'),
                  ),
              ],
            ),
            const Divider(),
            if (_history.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: Text('暂无历史记录')),
              )
            else
              SizedBox(
                height: 200,
                child: ListView.builder(
                  itemCount: _history.length,
                  itemBuilder: (context, index) {
                    final item = _history[_history.length - 1 - index];
                    return ListTile(
                      dense: true,
                      title: Text(
                        item,
                        style: const TextStyle(fontFamily: 'Monospace'),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy, size: 18),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: item));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('已复制')),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
