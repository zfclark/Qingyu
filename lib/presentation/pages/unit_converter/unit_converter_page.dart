/// Unit Converter Page
/// Author: ZF_Clark
/// Description: UI page for unit conversion. Uses ConversionUtil for conversion logic. Supports length, weight, temperature, and timestamp conversion.
/// Last Modified: 2026/02/08
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/conversion_util.dart';

/// 单位转换页面
/// 提供各种单位转换功能的UI界面
class UnitConverterPage extends StatefulWidget {
  const UnitConverterPage({super.key});

  @override
  State<UnitConverterPage> createState() => _UnitConverterPageState();
}

class _UnitConverterPageState extends State<UnitConverterPage> {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  int _currentTab = 0;

  /// 标签页选项
  final List<String> _tabs = ['长度', '重量', '温度', '时间戳'];

  /// 转换单位
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
            // 标签栏
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
                    if (_currentTab != 3) // 非时间戳
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _fromUnit,
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
                              value: _toUnit,
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

            // 输出区域
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
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
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

  /// 根据当前标签重置单位
  void _resetUnits() {
    switch (_currentTab) {
      case 0: // 长度
        _fromUnit = '米';
        _toUnit = '千米';
        break;
      case 1: // 重量
        _fromUnit = '千克';
        _toUnit = '克';
        break;
      case 2: // 温度
        _fromUnit = '摄氏度';
        _toUnit = '华氏度';
        break;
      case 3: // 时间戳
        break;
    }
  }

  /// 执行转换
  void _convert() {
    if (_inputController.text.isEmpty) return;

    try {
      switch (_currentTab) {
        case 0: // 长度
          _convertLength();
          break;
        case 1: // 重量
          _convertWeight();
          break;
        case 2: // 温度
          _convertTemperature();
          break;
        case 3: // 时间戳
          _convertTimestamp();
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('转换失败，请检查输入')));
    }
  }

  /// 转换长度
  void _convertLength() {
    final value = double.parse(_inputController.text);
    final result = ConversionUtil.convertLengthByName(
      value,
      _fromUnit,
      _toUnit,
    );
    setState(() {
      _output = '$result $_toUnit';
    });
  }

  /// 转换重量
  void _convertWeight() {
    final value = double.parse(_inputController.text);
    final result = ConversionUtil.convertWeightByName(
      value,
      _fromUnit,
      _toUnit,
    );
    setState(() {
      _output = '$result $_toUnit';
    });
  }

  /// 转换温度
  void _convertTemperature() {
    final value = double.parse(_inputController.text);
    final result = ConversionUtil.convertTemperatureByName(
      value,
      _fromUnit,
      _toUnit,
    );
    setState(() {
      _output = '$result $_toUnit';
    });
  }

  /// 转换时间戳
  void _convertTimestamp() {
    final result = ConversionUtil.convertTimestamp(_inputController.text);
    setState(() {
      _output = result;
    });
  }

  /// 复制结果到剪贴板
  void _copyResult() {
    if (_output.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('结果已复制到剪贴板')));
  }

  /// 清空输入
  void _clearInput() {
    setState(() {
      _inputController.clear();
      _output = '';
    });
  }
}
