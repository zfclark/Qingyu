/// Calculator
/// Basic arithmetic calculator
/// Created: 2026-02-04
library;

import 'package:flutter/material.dart';

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String _display = '0';
  double _firstOperand = 0;
  double _secondOperand = 0;
  String _operator = '';
  bool _isNewOperation = true;

  /// Button types
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
          // Display
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

          // Buttons
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

  /// Handle button press
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

  /// Clear calculator
  void _clear() {
    _display = '0';
    _firstOperand = 0;
    _secondOperand = 0;
    _operator = '';
    _isNewOperation = true;
  }

  /// Toggle sign
  void _toggleSign() {
    if (_display == '0') return;
    if (_display.startsWith('-')) {
      _display = _display.substring(1);
    } else {
      _display = '-$_display';
    }
  }

  /// Calculate percentage
  void _calculatePercentage() {
    double value = double.parse(_display);
    value /= 100;
    _display = value.toString();
  }

  /// Set operator
  void _setOperator(String operator) {
    _firstOperand = double.parse(_display);
    _operator = operator;
    _isNewOperation = true;
  }

  /// Calculate result
  void _calculateResult() {
    if (_operator.isEmpty) return;

    _secondOperand = double.parse(_display);
    double result = 0;

    switch (_operator) {
      case '÷':
        if (_secondOperand == 0) {
          _display = '错误';
          return;
        }
        result = _firstOperand / _secondOperand;
        break;
      case '×':
        result = _firstOperand * _secondOperand;
        break;
      case '-':
        result = _firstOperand - _secondOperand;
        break;
      case '+':
        result = _firstOperand + _secondOperand;
        break;
    }

    // Format result
    if (result == result.toInt()) {
      _display = result.toInt().toString();
    } else {
      _display = result.toString();
    }

    _operator = '';
    _isNewOperation = true;
  }

  /// Add decimal
  void _addDecimal() {
    if (_display.contains('.')) return;
    _display += '.';
  }

  /// Add digit
  void _addDigit(String digit) {
    if (_isNewOperation) {
      _display = digit;
      _isNewOperation = false;
    } else {
      if (_display == '0') {
        _display = digit;
      } else {
        _display += digit;
      }
    }
  }
}
