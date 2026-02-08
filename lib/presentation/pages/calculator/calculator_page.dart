/// Calculator Page
/// Author: ZF_Clark
/// Description: UI page for basic arithmetic calculator. Uses CalculatorUtil for calculation logic. Provides number input, operator selection, and result display.
/// Last Modified: 2026/02/08
library;

import 'package:flutter/material.dart';
import '../../../core/utils/calculator_util.dart';

/// 计算器页面
/// 提供基础四则运算功能的UI界面
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

  /// 按钮配置
  final List<List<Map<String, dynamic>>> _buttons = [
    [
      {'text': 'C', 'color': Colors.grey[300], 'textcolor': Colors.black},
      {'text': '+/-', 'color': Colors.grey[300], 'textcolor': Colors.black},
      {'text': '%', 'color': Colors.grey[300], 'textcolor': Colors.black},
      {'text': '÷', 'color': Colors.orange, 'textcolor': Colors.white},
    ],
    [
      {'text': '7', 'color': Colors.grey[100], 'textcolor': Colors.black},
      {'text': '8', 'color': Colors.grey[100], 'textcolor': Colors.black},
      {'text': '9', 'color': Colors.grey[100], 'textcolor': Colors.black},
      {'text': '×', 'color': Colors.orange, 'textcolor': Colors.white},
    ],
    [
      {'text': '4', 'color': Colors.grey[100], 'textcolor': Colors.black},
      {'text': '5', 'color': Colors.grey[100], 'textcolor': Colors.black},
      {'text': '6', 'color': Colors.grey[100], 'textcolor': Colors.black},
      {'text': '-', 'color': Colors.orange, 'textcolor': Colors.white},
    ],
    [
      {'text': '1', 'color': Colors.grey[100], 'textcolor': Colors.black},
      {'text': '2', 'color': Colors.grey[100], 'textcolor': Colors.black},
      {'text': '3', 'color': Colors.grey[100], 'textcolor': Colors.black},
      {'text': '+', 'color': Colors.orange, 'textcolor': Colors.white},
    ],
    [
      {
        'text': '0',
        'color': Colors.grey[100],
        'textcolor': Colors.black,
        'flex': 2,
      },
      {'text': '.', 'color': Colors.grey[100], 'textcolor': Colors.black},
      {'text': '=', 'color': Colors.orange, 'textcolor': Colors.white},
    ],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('计算器')),
      body: Column(
        children: [
          // 显示屏
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomRight,
              child: Text(
                _display,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),

          // 按钮区域
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _buttons.map((row) {
                return Row(
                  children: row.map((button) {
                    return Expanded(
                      flex: button['flex'] ?? 1,
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        child: ElevatedButton(
                          onPressed: () => _onButtonPressed(button['text']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: button['color'],
                            foregroundColor: button['textcolor'],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 24),
                          ),
                          child: Text(
                            button['text'],
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理按钮点击
  void _onButtonPressed(String buttonText) {
    setState(() {
      switch (buttonText) {
        case 'C':
          _clear();
          break;
        case '+/-':
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
}
