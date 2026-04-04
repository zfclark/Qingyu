/// Random Tools Page
/// Author: ZF_Clark
/// Description: UI page for random number and string generation. Uses RandomUtil for all randomization operations.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/random_util.dart';

/// 随机数生成器页面
/// 提供随机数、随机字符串、随机选择等功能的UI界面
class RandomToolsPage extends StatefulWidget {
  const RandomToolsPage({super.key});

  @override
  State<RandomToolsPage> createState() => _RandomToolsPageState();
}

class _RandomToolsPageState extends State<RandomToolsPage> {
  int _selectedTab = 0;
  
  // 随机数
  int _intResult = 0;
  int _minInt = 1;
  int _maxInt = 100;
  
  // 随机字符串
  String _stringResult = '';
  int _stringLength = 16;
  
  // 随机列表
  final List<String> _randomList = ['选项1', '选项2', '选项3', '选项4', '选项5'];
  final TextEditingController _listInputController = TextEditingController(text: '选项1\n选项2\n选项3\n选项4\n选项5');
  String? _selectedItem;
  List<String> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _generateInt();
    _generateString();
  }

  @override
  void dispose() {
    _listInputController.dispose();
    super.dispose();
  }

  void _generateInt() {
    setState(() {
      _intResult = RandomUtil.nextInt(_minInt, _maxInt);
    });
  }

  void _generateString() {
    setState(() {
      _stringResult = RandomUtil.generateAlphanumeric(_stringLength);
    });
  }

  void _pickOne() {
    _parseList();
    final result = RandomUtil.pickOne(_randomList);
    setState(() {
      _selectedItem = result;
    });
  }

  void _pickMultiple() {
    _parseList();
    final count = (_randomList.length / 2).ceil().clamp(1, _randomList.length);
    final results = RandomUtil.pickMany(_randomList, count);
    setState(() {
      _selectedItems = results;
    });
  }

  void _parseList() {
    final lines = _listInputController.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) {
      _randomList.clear();
      _randomList.addAll(lines);
    }
  }

  void _copyResult(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已复制: $text')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('随机生成')),
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
                child: Row(
                  children: [
                    _buildTabChip(0, '随机数', Icons.numbers),
                    _buildTabChip(1, '随机字符串', Icons.text_fields),
                    _buildTabChip(2, '随机选择', Icons.shuffle),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 随机数
            if (_selectedTab == 0) _buildRandomIntCard(),
            if (_selectedTab == 1) _buildRandomStringCard(),
            if (_selectedTab == 2) _buildRandomPickCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Theme.of(context).colorScheme.primary : null),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(
                color: isSelected ? Theme.of(context).colorScheme.primary : null,
                fontWeight: isSelected ? FontWeight.bold : null,
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRandomIntCard() {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  '$_intResult',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text('范围: $_minInt ~ $_maxInt', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: '最小值'),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: '$_minInt'),
                        onChanged: (v) => _minInt = int.tryParse(v) ?? 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: '最大值'),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: '$_maxInt'),
                        onChanged: (v) => _maxInt = int.tryParse(v) ?? 100,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _generateInt,
                        icon: const Icon(Icons.refresh),
                        label: const Text('生成整数'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _copyResult('$_intResult'),
                      icon: const Icon(Icons.copy),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 快捷范围
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('快捷范围：', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickChip('1-10', () { _minInt = 1; _maxInt = 10; _generateInt(); }),
                    _buildQuickChip('1-100', () { _minInt = 1; _maxInt = 100; _generateInt(); }),
                    _buildQuickChip('1-1000', () { _minInt = 1; _maxInt = 1000; _generateInt(); }),
                    _buildQuickChip('0-9 (随机数字)', () { _minInt = 0; _maxInt = 9; _generateInt(); }),
                    _buildQuickChip('奇数', () { _minInt = 1; _maxInt = 99; _generateInt(); setState(() => _intResult = _intResult ~/ 2 * 2 + 1); }),
                    _buildQuickChip('偶数', () { _minInt = 0; _maxInt = 100; _generateInt(); setState(() => _intResult = _intResult ~/ 2 * 2); }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickChip(String label, VoidCallback onTap) {
    return ActionChip(label: Text(label), onPressed: onTap);
  }

  Widget _buildRandomStringCard() {
    return Column(
      children: [
        Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                SelectableText(
                  _stringResult,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Monospace',
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text('长度: $_stringLength 字符', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Text('长度: '),
                    Expanded(
                      child: Slider(
                        value: _stringLength.toDouble(),
                        min: 4,
                        max: 64,
                        divisions: 60,
                        label: '$_stringLength',
                        onChanged: (v) => setState(() => _stringLength = v.round()),
                      ),
                    ),
                    Text('$_stringLength', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [8, 12, 16, 24, 32].map((l) {
                    return ActionChip(
                      label: Text('$l'),
                      onPressed: () => setState(() => _stringLength = l),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _generateString,
                        icon: const Icon(Icons.refresh),
                        label: const Text('生成'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _copyResult(_stringResult),
                      icon: const Icon(Icons.copy),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRandomPickCard() {
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
                const Text('选项列表（每行一个）：', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _listInputController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: '每行输入一个选项...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        if (_selectedItem != null)
          Card(
            elevation: 0,
            color: Colors.green.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    _selectedItem!,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

        if (_selectedItems.isNotEmpty)
          Card(
            elevation: 0,
            color: Colors.blue.withValues(alpha: 0.1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('抽中的选项：', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedItems.map((item) {
                      return Chip(label: Text(item));
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickOne,
                icon: const Icon(Icons.touch_app),
                label: const Text('随机抽取一个'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickMultiple,
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('随机抽取多个'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
