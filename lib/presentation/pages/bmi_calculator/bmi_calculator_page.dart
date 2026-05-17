/// BMI Calculator Page
/// Author: ZF_Clark
/// Description: UI page for BMI calculation and health assessment. Uses BmiUtil for all calculations.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/bmi_util.dart';

/// BMI 计算器页面
/// 提供身高体重输入、BMI计算及健康评估功能
class BmiCalculatorPage extends StatefulWidget {
  const BmiCalculatorPage({super.key});

  @override
  State<BmiCalculatorPage> createState() => _BmiCalculatorPageState();
}

class _BmiCalculatorPageState extends State<BmiCalculatorPage> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  double _bmi = 0;
  bool _hasResult = false;
  bool _useImperial = false;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _calculate() {
    final heightText = _heightController.text;
    final weightText = _weightController.text;
    if (heightText.isEmpty || weightText.isEmpty) return;

    double height = double.tryParse(heightText) ?? 0;
    double weight = double.tryParse(weightText) ?? 0;
    if (height <= 0 || weight <= 0) return;

    // 英制转公制
    if (_useImperial) {
      height = height * 2.54; // 英寸 -> 厘米
      weight = weight * 0.4536; // 磅 -> 公斤
    }

    final bmi = BmiUtil.calculate(weight, height);
    setState(() {
      _bmi = bmi;
      _hasResult = true;
    });
  }

  void _clear() {
    _heightController.clear();
    _weightController.clear();
    setState(() {
      _bmi = 0;
      _hasResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('BMI 计算器')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputCard(theme),
            const SizedBox(height: 16),
            if (_hasResult) ...[
              _buildResultCard(theme),
              const SizedBox(height: 16),
              _buildHealthAdviceCard(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('输入数据', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('公制'),
                    Switch(
                      value: _useImperial,
                      onChanged: (v) => setState(() => _useImperial = v),
                    ),
                    const Text('英制'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightController,
                    decoration: InputDecoration(
                      labelText: _useImperial ? '身高（英寸）' : '身高（cm）',
                      hintText: _useImperial ? '例如: 70' : '例如: 170',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.height),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: _useImperial ? '体重（磅）' : '体重（kg）',
                      hintText: _useImperial ? '例如: 154' : '例如: 70',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      prefixIcon: const Icon(Icons.monitor_weight),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d.]'))],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _calculate,
                    icon: const Icon(Icons.calculate),
                    label: const Text('计算 BMI'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _clear,
                  icon: const Icon(Icons.clear),
                  label: const Text('清空'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(ThemeData theme) {
    final category = BmiUtil.getCategory(_bmi);
    final riskLevel = BmiUtil.getRiskLevel(_bmi);
    final categoryColor = Color(BmiUtil.getCategoryColorInt(_bmi));
    final range = BmiUtil.getHealthyWeightRange(
      _useImperial
          ? (double.tryParse(_heightController.text) ?? 170) * 2.54
          : double.tryParse(_heightController.text) ?? 170,
    );

    return Card(
      elevation: 0,
      color: categoryColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              _bmi.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: categoryColor,
              ),
            ),
            const Text('BMI', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Chip(
              avatar: Icon(
                riskLevel == 0 ? Icons.check_circle : Icons.warning,
                size: 18,
                color: categoryColor,
              ),
              label: Text(
                category,
                style: TextStyle(
                  color: categoryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: categoryColor.withValues(alpha: 0.15),
            ),
            const SizedBox(height: 12),
            Text(
              '健康体重范围: ${range['min']?.toStringAsFixed(1) ?? '-'} - ${range['max']?.toStringAsFixed(1) ?? '-'} ${_useImperial ? "磅" : "kg"}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthAdviceCard(ThemeData theme) {
    final advice = BmiUtil.getHealthAdvice(_bmi);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('健康建议', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(advice, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
