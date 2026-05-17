/// Random Tools Page
/// Author: ZF_Clark
/// Description: UI page for random number and string generation, and animated spinning wheel picker.
library;

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/random_util.dart';

/// 随机生成器页面
/// 提供随机数、随机字符串、随机选择及可视化转盘功能
class RandomToolsPage extends StatefulWidget {
  const RandomToolsPage({super.key});

  @override
  State<RandomToolsPage> createState() => _RandomToolsPageState();
}

class _RandomToolsPageState extends State<RandomToolsPage> with SingleTickerProviderStateMixin {
  int _selectedTab = 0;

  // 随机数
  List<int> _intResults = [0];
  int _minInt = 1;
  int _maxInt = 100;
  int _count = 1;
  bool _allowDuplicate = true;

  // 随机字符串
  String _stringResult = '';
  int _stringLength = 16;

  // 随机列表 / 转盘
  final List<String> _randomList = ['选项1', '选项2', '选项3', '选项4', '选项5'];
  final TextEditingController _listInputController = TextEditingController(
    text: '选项1\n选项2\n选项3\n选项4\n选项5',
  );
  String? _selectedItem;
  List<String> _selectedItems = [];

  // 转盘动画
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  double _currentSpinAngle = 0;
  bool _isSpinning = false;
  String? _spinResult;

  @override
  void initState() {
    super.initState();
    _generateInt();
    _generateString();
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _spinAnimation = CurvedAnimation(parent: _spinController, curve: Curves.decelerate);
  }

  @override
  void dispose() {
    _listInputController.dispose();
    _spinController.dispose();
    super.dispose();
  }

  void _generateInt() {
    if (_count <= 1) {
      final result = RandomUtil.nextInt(_minInt, _maxInt);
      setState(() => _intResults = [result]);
    } else {
      final results = RandomUtil.generateIntList(_count, _minInt, _maxInt, unique: !_allowDuplicate);
      setState(() => _intResults = results);
    }
  }

  void _generateString() {
    setState(() {
      _stringResult = RandomUtil.generateAlphanumeric(_stringLength);
    });
  }

  void _parseList() {
    final lines = _listInputController.text.split('\n').where((s) => s.trim().isNotEmpty).toList();
    if (lines.isNotEmpty) {
      _randomList.clear();
      _randomList.addAll(lines);
    }
  }

  void _pickOne() {
    _parseList();
    final result = RandomUtil.pickOne(_randomList);
    setState(() {
      _selectedItem = result;
      _selectedItems = [];
    });
  }

  void _pickMultiple() {
    _parseList();
    final count = (_randomList.length / 2).ceil().clamp(1, _randomList.length);
    final results = RandomUtil.pickMany(_randomList, count);
    setState(() {
      _selectedItems = results;
      _selectedItem = null;
    });
  }

  // ==================== 转盘动画 ====================

  void _spinWheel() {
    _parseList();
    if (_randomList.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('至少需要2个选项才能旋转')),
      );
      return;
    }

    if (_isSpinning) return;

    // 随机选择目标
    final targetIndex = RandomUtil.nextInt(0, _randomList.length - 1);
    final segmentAngle = 360.0 / _randomList.length;
    // 旋转到目标扇区中心，加上额外多圈
    final targetAngle = 5 * 360 + (_randomList.length - targetIndex) * segmentAngle - segmentAngle / 2;
    final startAngle = _currentSpinAngle;

    _spinAnimation = Tween<double>(begin: startAngle, end: startAngle + targetAngle).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.decelerate),
    );

    _spinController.reset();
    _spinController.addListener(() {
      setState(() {
        _currentSpinAngle = _spinAnimation.value;
      });
    });
    _spinController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isSpinning = false;
          _spinResult = _randomList[targetIndex];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('选中: $_spinResult'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });

    setState(() => _isSpinning = true);
    _spinController.forward();
  }

  // ==================== 复制 ====================

  void _copyResult(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已复制: $text')),
    );
  }

  void _copyAllResults() {
    final text = _intResults.join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制所有结果')),
    );
  }

  // ==================== 构建UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('随机生成')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Wrap(
                  children: [
                    _buildTabChip(0, '随机数', Icons.numbers),
                    _buildTabChip(1, '随机字符串', Icons.text_fields),
                    _buildTabChip(2, '随机选择', Icons.shuffle),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

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

  // ==================== 随机数 ====================

  Widget _buildRandomIntCard() {
    final theme = Theme.of(context);
    return Column(
      children: [
        // 结果显示
        Card(
          elevation: 0,
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _intResults.length == 1
                ? Column(
                    children: [
                      Text(
                        '${_intResults[0]}',
                        style: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('范围: $_minInt ~ $_maxInt', style: TextStyle(color: Colors.grey[600])),
                    ],
                  )
                : Column(
                    children: [
                      Text(
                        '已生成 ${_intResults.length} 个数字',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _intResults.map((n) => Chip(
                          label: Text('$n', style: const TextStyle(fontFamily: 'Monospace')),
                        )).toList(),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // 设置卡片
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
                        decoration: const InputDecoration(labelText: '最小值', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: '$_minInt'),
                        onChanged: (v) => _minInt = int.tryParse(v) ?? 1,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(labelText: '最大值', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: '$_maxInt'),
                        onChanged: (v) => _maxInt = int.tryParse(v) ?? 100,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: '生成数量',
                          border: OutlineInputBorder(),
                          suffixText: '个',
                        ),
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(text: '$_count'),
                        onChanged: (v) => _count = (int.tryParse(v) ?? 1).clamp(1, 1000),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('允许重复', style: TextStyle(fontSize: 12)),
                        Switch(
                          value: _allowDuplicate,
                          onChanged: (v) => setState(() => _allowDuplicate = v),
                        ),
                      ],
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
                        label: const Text('生成'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _intResults.length == 1
                          ? () => _copyResult('${_intResults[0]}')
                          : _copyAllResults,
                      icon: Icon(Icons.copy, color: theme.colorScheme.primary),
                      tooltip: _intResults.length == 1 ? '复制' : '全部复制',
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
                    _buildQuickChip('0-9', () { _minInt = 0; _maxInt = 9; _generateInt(); }),
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

  // ==================== 随机字符串 ====================

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
                        min: 4, max: 64, divisions: 60,
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

  // ==================== 随机选择 & 转盘 ====================

  Widget _buildRandomPickCard() {
    return Column(
      children: [
        // 选项输入
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
                  maxLines: 5,
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

        // 可视化转盘
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('随机转盘', style: TextStyle(fontWeight: FontWeight.bold)),
                    if (_spinResult != null)
                      Chip(
                        avatar: const Icon(Icons.check, size: 16),
                        label: Text('结果: $_spinResult'),
                        backgroundColor: Colors.green.withValues(alpha: 0.1),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // 转盘绘制
                SizedBox(
                  height: 240,
                  child: _randomList.length >= 2
                      ? GestureDetector(
                          onTap: _isSpinning ? null : _spinWheel,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.rotate(
                                angle: _currentSpinAngle * math.pi / 180,
                                child: CustomPaint(
                                  size: const Size(240, 240),
                                  painter: _WheelPainter(options: _randomList),
                                ),
                              ),
                              // 中心圆
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
                                ),
                                child: Icon(
                                  Icons.casino,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              // 指针
                              Positioned(
                                top: 0,
                                child: Icon(Icons.play_arrow, color: Colors.red, size: 32),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Text('请至少输入2个选项', style: TextStyle(color: Colors.grey[500])),
                        ),
                ),
                const SizedBox(height: 12),
                if (_randomList.length >= 2)
                  ElevatedButton.icon(
                    onPressed: _isSpinning ? null : _spinWheel,
                    icon: _isSpinning
                        ? const SizedBox(
                            width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.rotate_right),
                    label: Text(_isSpinning ? '旋转中...' : '开始旋转'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // 文本选择结果
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
                  Text(_selectedItem!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                    spacing: 8, runSpacing: 8,
                    children: _selectedItems.map((item) => Chip(label: Text(item))).toList(),
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),

        // 文本选择按钮
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

/// 转盘绘制器
class _WheelPainter extends CustomPainter {
  final List<String> options;

  _WheelPainter({required this.options});

  static const _colors = [
    Color(0xFF4CAF50), Color(0xFF2196F3), Color(0xFFFF9800),
    Color(0xFF9C27B0), Color(0xFFF44336), Color(0xFF00BCD4),
    Color(0xFFFF5722), Color(0xFF3F51B5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (options.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final segmentAngle = 2 * math.pi / options.length;

    // 绘制各扇区
    for (int i = 0; i < options.length; i++) {
      final startAngle = i * segmentAngle - math.pi / 2;
      final color = _colors[i % _colors.length];

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(Rect.fromCircle(center: center, radius: radius), startAngle, segmentAngle, true)
        ..close();

      canvas.drawPath(path, paint);

      // 扇区文字
      final midAngle = startAngle + segmentAngle / 2;
      final textRadius = radius * 0.55;
      final textX = center.dx + textRadius * math.cos(midAngle);
      final textY = center.dy + textRadius * math.sin(midAngle);

      final tp = TextPainter(
        text: TextSpan(
          text: options[i],
          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: radius * 0.7);

      canvas.save();
      canvas.translate(textX, textY);
      canvas.rotate(midAngle + math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    // 外边框
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) {
    return oldDelegate.options != options;
  }
}
