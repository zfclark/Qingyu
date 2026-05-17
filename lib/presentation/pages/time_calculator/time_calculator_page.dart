/// Time Calculator Page
/// Author: ZF_Clark
/// Description: UI page for date and time calculations including date difference, age calculation, timestamp conversion, date arithmetic, and workday calculation.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/time_calculator_util.dart';

/// 时间计算器页面
/// 提供日期计算、年龄计算、时间戳转换、日期加减和工作日计算功能
class TimeCalculatorPage extends StatefulWidget {
  const TimeCalculatorPage({super.key});

  @override
  State<TimeCalculatorPage> createState() => _TimeCalculatorPageState();
}

class _TimeCalculatorPageState extends State<TimeCalculatorPage> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  DateTime? _birthDate;
  int _selectedTab = 0;

  // 日期差结果
  Map<String, dynamic>? _diffResult;
  Map<String, int>? _ageResult;
  String _timestampResult = '';

  // 日期加减
  DateTime _baseDate = DateTime.now();
  final _addYearsController = TextEditingController(text: '0');
  final _addMonthsController = TextEditingController(text: '0');
  final _addDaysController = TextEditingController(text: '0');
  DateTime? _computedDate;

  // 工作日
  DateTime _workStartDate = DateTime.now();
  DateTime _workEndDate = DateTime.now();
  int? _workDaysCount;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateDiff();
    });
  }

  @override
  void dispose() {
    _addYearsController.dispose();
    _addMonthsController.dispose();
    _addDaysController.dispose();
    super.dispose();
  }

  // ==================== 日期差计算 ====================

  void _calculateDiff() {
    final result = TimeCalculatorUtil.diffBetween(_startDate, _endDate);
    if (mounted) setState(() => _diffResult = result);
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _calculateDiff();
    }
  }

  // ==================== 年龄计算 ====================

  void _calculateAge() {
    if (_birthDate == null) return;
    final result = TimeCalculatorUtil.calculateExactAge(_birthDate!);
    if (mounted) setState(() => _ageResult = result);
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
      _calculateAge();
    }
  }

  // ==================== 时间戳 ====================

  void _convertTimestamp() {
    final now = DateTime.now();
    final result =
        'Unix时间戳（秒）: ${TimeCalculatorUtil.toTimestamp(now)}\n'
        'Unix时间戳（毫秒）: ${TimeCalculatorUtil.toTimestampMs(now)}\n'
        'ISO8601: ${now.toIso8601String()}\n'
        '本地时间: ${TimeCalculatorUtil.format(now)}';
    if (mounted) setState(() => _timestampResult = result);
  }

  // ==================== 日期加减 ====================

  Future<void> _pickBaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _baseDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _baseDate = picked);
    }
  }

  void _calculateDateArithmetic() {
    final years = int.tryParse(_addYearsController.text) ?? 0;
    final months = int.tryParse(_addMonthsController.text) ?? 0;
    final days = int.tryParse(_addDaysController.text) ?? 0;

    DateTime result = _baseDate;
    if (years != 0) result = TimeCalculatorUtil.addYears(result, years);
    if (months != 0) result = TimeCalculatorUtil.addMonths(result, months);
    if (days != 0) result = TimeCalculatorUtil.addDays(result, days);

    setState(() => _computedDate = result);
  }

  // ==================== 工作日计算 ====================

  Future<void> _pickWorkDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _workStartDate : _workEndDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _workStartDate = picked;
        } else {
          _workEndDate = picked;
        }
      });
    }
  }

  void _calculateWorkDays() {
    final days = TimeCalculatorUtil.workDaysBetween(_workStartDate, _workEndDate);
    setState(() => _workDaysCount = days);
  }

  // ==================== 构建UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('时间计算器')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标签选择
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  children: [
                    _buildTabChip(0, '日差计算', Icons.date_range),
                    _buildTabChip(1, '年龄计算', Icons.cake),
                    _buildTabChip(2, '时间戳', Icons.access_time),
                    _buildTabChip(3, '日期加减', Icons.add_circle_outline),
                    _buildTabChip(4, '工作日', Icons.work_outline),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (_selectedTab == 0) _buildDateDiffCard(),
            if (_selectedTab == 1) _buildAgeCalcCard(),
            if (_selectedTab == 2) _buildTimestampCard(),
            if (_selectedTab == 3) _buildDateArithmeticCard(),
            if (_selectedTab == 4) _buildWorkDayCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: isSelected ? Theme.of(context).colorScheme.primary : null),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(
                fontSize: 13,
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              )),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== 日差计算 ====================

  Widget _buildDateDiffCard() {
    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('开始日期'),
                  subtitle: Text(TimeCalculatorUtil.format(_startDate, format: 'yyyy-MM-dd')),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _pickDate(true),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.event),
                  title: const Text('结束日期'),
                  subtitle: Text(TimeCalculatorUtil.format(_endDate, format: 'yyyy-MM-dd')),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _pickDate(false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_diffResult != null)
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('时间差：', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(children: [
                    _buildDiffItem('年', _diffResult!['years']!),
                    _buildDiffItem('月', _diffResult!['months']!),
                    _buildDiffItem('天', _diffResult!['days']!),
                  ]),
                  const Divider(),
                  Row(children: [
                    _buildDiffItem('小时', _diffResult!['hours']!),
                    _buildDiffItem('分', _diffResult!['minutes']!),
                    _buildDiffItem('秒', _diffResult!['seconds']!),
                  ]),
                  const Divider(),
                  _buildDiffItem('总天数', _diffResult!['totalDays']!, isLarge: true),
                  const SizedBox(height: 8),
                  Text(
                    (_diffResult!['isFuture'] as bool) ? '结束日期在开始日期之后' : '结束日期在开始日期之前',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildDiffItem(String label, int value, {bool isLarge = false}) {
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: TextStyle(
            fontSize: isLarge ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          )),
          Text(label, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ==================== 年龄计算 ====================

  Widget _buildAgeCalcCard() {
    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.cake),
                  title: Text('出生日期'),
                  subtitle: Text('选择您的出生日期'),
                ),
                ElevatedButton.icon(
                  onPressed: _pickBirthDate,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(_birthDate != null
                      ? TimeCalculatorUtil.format(_birthDate!, format: 'yyyy年MM月dd日')
                      : '选择日期'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_ageResult != null)
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('您的年龄', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildAgeItem(_ageResult!['years']!, '岁'),
                      _buildAgeItem(_ageResult!['months']!, '月'),
                      _buildAgeItem(_ageResult!['days']!, '天'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    avatar: const Icon(Icons.emoji_events, size: 18),
                    label: Text('已存活 ${TimeCalculatorUtil.daysBetween(DateTime.now(), _birthDate ?? DateTime.now())} 天'),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAgeItem(int value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text('$value', style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          )),
          Text(label, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // ==================== 时间戳 ====================

  Widget _buildTimestampCard() {
    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('当前时间戳', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _convertTimestamp,
                  icon: const Icon(Icons.refresh),
                  label: const Text('刷新时间戳'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_timestampResult.isNotEmpty)
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('转换结果', style: TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () async {
                          if (_timestampResult.isNotEmpty) {
                            await Clipboard.setData(ClipboardData(text: _timestampResult));
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('已复制到剪贴板')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(_timestampResult, style: const TextStyle(fontFamily: 'Monospace')),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  // ==================== 日期加减 ====================

  Widget _buildDateArithmeticCard() {
    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('基准日期', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Text(TimeCalculatorUtil.format(_baseDate, format: 'yyyy年MM月dd日')),
                  subtitle: Text('星期${TimeCalculatorUtil.getWeekdayName(_baseDate, short: true)}'),
                  trailing: const Icon(Icons.edit),
                  onTap: _pickBaseDate,
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('偏移量（负数表示减）', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildOffsetField('年', _addYearsController)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildOffsetField('月', _addMonthsController)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildOffsetField('天', _addDaysController)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _calculateDateArithmetic,
                    icon: const Icon(Icons.calculate),
                    label: const Text('计算'),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_computedDate != null) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('计算结果', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    TimeCalculatorUtil.format(_computedDate!, format: 'yyyy年MM月dd日'),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '星期${TimeCalculatorUtil.getWeekdayName(_computedDate!, short: true)}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildOffsetField(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^-?[\d]'))],
    );
  }

  // ==================== 工作日计算 ====================

  Widget _buildWorkDayCard() {
    return Column(
      children: [
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: const Text('开始日期'),
                  subtitle: Text(TimeCalculatorUtil.format(_workStartDate, format: 'yyyy-MM-dd')),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _pickWorkDate(true),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.stop),
                  title: const Text('结束日期'),
                  subtitle: Text(TimeCalculatorUtil.format(_workEndDate, format: 'yyyy-MM-dd')),
                  trailing: const Icon(Icons.edit),
                  onTap: () => _pickWorkDate(false),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _calculateWorkDays,
            icon: const Icon(Icons.work),
            label: const Text('计算工作日'),
          ),
        ),
        if (_workDaysCount != null) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.work, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    '$_workDaysCount',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Text('个工作日', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    '${TimeCalculatorUtil.workDaysBetween(_workStartDate, _workEndDate)} 天',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
