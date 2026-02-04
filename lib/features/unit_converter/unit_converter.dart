/// Unit Converter
/// Author: ZF_Clark
/// Description: Provides unit conversion utilities for length (millimeter, centimeter, meter, kilometer, inch, foot, yard, mile), weight (gram, kilogram, ton, milligram, pound, ounce), temperature (Celsius, Fahrenheit, Kelvin), and Unix timestamp conversion
/// Last Modified: 2026/02/04
/// Version: V0.1
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UnitConverter extends StatefulWidget {
  const UnitConverter({super.key});

  @override
  State<UnitConverter> createState() => _UnitConverterState();
}

class _UnitConverterState extends State<UnitConverter> {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  int _currentTab = 0;

  /// Tab options
  final List<String> _tabs = ['长度', '重量', '温度', '时间戳'];

  /// Conversion units
  final Map<String, List<String>> _units = {
    '长度': ['毫米', '厘米', '米', '千米', '英寸', '英尺', '码', '英里'],
    '重量': ['克', '千克', '吨', '毫克', '磅', '盎司'],
    '温度': ['摄氏度', '华氏度', '开尔文'],
    '时间戳': ['Unix时间戳', '日期时间'],
  };

  String _fromUnit = '米';
  String _toUnit = '千米';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('单位转换')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Tab bar
            DefaultTabController(
              length: _tabs.length,
              initialIndex: _currentTab,
              child: TabBar(
                tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                onTap: (index) {
                  setState(() {
                    _currentTab = index;
                    _output = '';
                    _resetUnits();
                  });
                },
                isScrollable: true,
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
                    const Text('输入值：'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      keyboardType: _currentTab == 3
                          ? TextInputType.text
                          : TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: _currentTab == 3 ? '请输入时间戳或日期' : '请输入数值',
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_currentTab != 3) // Not timestamp
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _fromUnit,
                              items: _units[_tabs[_currentTab]]?.map((unit) {
                                return DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _fromUnit = value!;
                                  _output = '';
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: '从',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              initialValue: _toUnit,
                              items: _units[_tabs[_currentTab]]?.map((unit) {
                                return DropdownMenuItem<String>(
                                  value: unit,
                                  child: Text(unit),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _toUnit = value!;
                                  _output = '';
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: '到',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _convert,
                            child: const Text('转换'),
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

            // Output section
            if (_output.isNotEmpty)
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
                      const Text('转换结果：'),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(_output),
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
          ],
        ),
      ),
    );
  }

  /// Reset units based on current tab
  void _resetUnits() {
    switch (_currentTab) {
      case 0: // Length
        _fromUnit = '米';
        _toUnit = '千米';
        break;
      case 1: // Weight
        _fromUnit = '千克';
        _toUnit = '克';
        break;
      case 2: // Temperature
        _fromUnit = '摄氏度';
        _toUnit = '华氏度';
        break;
      case 3: // Timestamp
        break;
    }
  }

  /// Convert units
  void _convert() {
    if (_inputController.text.isEmpty) return;

    try {
      switch (_currentTab) {
        case 0: // Length
          _convertLength();
          break;
        case 1: // Weight
          _convertWeight();
          break;
        case 2: // Temperature
          _convertTemperature();
          break;
        case 3: // Timestamp
          _convertTimestamp();
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('转换失败，请检查输入')));
    }
  }

  /// Convert length
  void _convertLength() {
    final value = double.parse(_inputController.text);
    double result;

    // Convert to meters first
    double meters;
    switch (_fromUnit) {
      case '毫米':
        meters = value / 1000;
        break;
      case '厘米':
        meters = value / 100;
        break;
      case '米':
        meters = value;
        break;
      case '千米':
        meters = value * 1000;
        break;
      case '英寸':
        meters = value * 0.0254;
        break;
      case '英尺':
        meters = value * 0.3048;
        break;
      case '码':
        meters = value * 0.9144;
        break;
      case '英里':
        meters = value * 1609.34;
        break;
      default:
        meters = value;
    }

    // Convert from meters to target unit
    switch (_toUnit) {
      case '毫米':
        result = meters * 1000;
        break;
      case '厘米':
        result = meters * 100;
        break;
      case '米':
        result = meters;
        break;
      case '千米':
        result = meters / 1000;
        break;
      case '英寸':
        result = meters / 0.0254;
        break;
      case '英尺':
        result = meters / 0.3048;
        break;
      case '码':
        result = meters / 0.9144;
        break;
      case '英里':
        result = meters / 1609.34;
        break;
      default:
        result = meters;
    }

    setState(() {
      _output = '$result $_toUnit';
    });
  }

  /// Convert weight
  void _convertWeight() {
    final value = double.parse(_inputController.text);
    double result;

    // Convert to grams first
    double grams;
    switch (_fromUnit) {
      case '克':
        grams = value;
        break;
      case '千克':
        grams = value * 1000;
        break;
      case '吨':
        grams = value * 1000000;
        break;
      case '毫克':
        grams = value / 1000;
        break;
      case '磅':
        grams = value * 453.592;
        break;
      case '盎司':
        grams = value * 28.3495;
        break;
      default:
        grams = value;
    }

    // Convert from grams to target unit
    switch (_toUnit) {
      case '克':
        result = grams;
        break;
      case '千克':
        result = grams / 1000;
        break;
      case '吨':
        result = grams / 1000000;
        break;
      case '毫克':
        result = grams * 1000;
        break;
      case '磅':
        result = grams / 453.592;
        break;
      case '盎司':
        result = grams / 28.3495;
        break;
      default:
        result = grams;
    }

    setState(() {
      _output = '$result $_toUnit';
    });
  }

  /// Convert temperature
  void _convertTemperature() {
    final value = double.parse(_inputController.text);
    double result;

    switch (_fromUnit) {
      case '摄氏度':
        if (_toUnit == '华氏度') {
          result = (value * 9 / 5) + 32;
        } else if (_toUnit == '开尔文') {
          result = value + 273.15;
        } else {
          result = value;
        }
        break;
      case '华氏度':
        if (_toUnit == '摄氏度') {
          result = (value - 32) * 5 / 9;
        } else if (_toUnit == '开尔文') {
          result = (value - 32) * 5 / 9 + 273.15;
        } else {
          result = value;
        }
        break;
      case '开尔文':
        if (_toUnit == '摄氏度') {
          result = value - 273.15;
        } else if (_toUnit == '华氏度') {
          result = (value - 273.15) * 9 / 5 + 32;
        } else {
          result = value;
        }
        break;
      default:
        result = value;
    }

    setState(() {
      _output = '$result $_toUnit';
    });
  }

  /// Convert timestamp
  void _convertTimestamp() {
    final input = _inputController.text.trim();
    String result;

    // Try to parse as timestamp
    if (input.isNotEmpty && input.contains(RegExp(r'^\d+$'))) {
      try {
        final timestamp = int.parse(input);
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        result = date.toString();
      } catch (e) {
        // Try parsing as milliseconds
        try {
          final timestamp = int.parse(input);
          final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
          result = date.toString();
        } catch (e) {
          result = '无效的时间戳';
        }
      }
    } else {
      // Try to parse as date
      try {
        final date = DateTime.parse(input);
        result =
            '${date.millisecondsSinceEpoch ~/ 1000} (秒)\n${date.millisecondsSinceEpoch} (毫秒)';
      } catch (e) {
        result = '无效的日期格式';
      }
    }

    setState(() {
      _output = result;
    });
  }

  /// Copy result to clipboard
  void _copyResult() {
    if (_output.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('结果已复制到剪贴板')));
  }

  /// Clear input field
  void _clearInput() {
    setState(() {
      _inputController.clear();
      _output = '';
    });
  }
}
