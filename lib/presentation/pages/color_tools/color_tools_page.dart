/// Color Tools Page
/// Author: ZF_Clark
/// Description: UI page for color format conversion between HEX, RGB, HSL, HSV, and CSS formats. Uses ColorUtil for all color operations.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/color_util.dart';

/// 颜色工具页面
/// 提供颜色格式转换的UI界面
class ColorToolsPage extends StatefulWidget {
  const ColorToolsPage({super.key});

  @override
  State<ColorToolsPage> createState() => _ColorToolsPageState();
}

class _ColorToolsPageState extends State<ColorToolsPage> {
  final TextEditingController _inputController = TextEditingController();
  Color? _previewColor;
  Map<String, String>? _colorFormats;
  String? _errorMessage;

  /// 预设颜色列表
  final List<Map<String, dynamic>> _presetColors = [
    {'name': '红色', 'hex': '#FF0000'},
    {'name': '绿色', 'hex': '#00FF00'},
    {'name': '蓝色', 'hex': '#0000FF'},
    {'name': '黄色', 'hex': '#FFFF00'},
    {'name': '青色', 'hex': '#00FFFF'},
    {'name': '品红', 'hex': '#FF00FF'},
    {'name': '白色', 'hex': '#FFFFFF'},
    {'name': '黑色', 'hex': '#000000'},
    {'name': '橙色', 'hex': '#FFA500'},
    {'name': '紫色', 'hex': '#800080'},
    {'name': '粉色', 'hex': '#FFC0CB'},
    {'name': '灰色', 'hex': '#808080'},
  ];

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  /// 转换颜色
  void _convertColor() {
    final input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() {
        _previewColor = null;
        _colorFormats = null;
        _errorMessage = null;
      });
      return;
    }

    // 尝试解析颜色
    Color? color;

    // 先尝试直接作为HEX
    color = ColorUtil.colorFromHex(input);

    // 如果失败，尝试CSS解析
    if (color == null) {
      final rgba = ColorUtil.parseCssColor(input);
      if (rgba != null) {
        color = Color.fromARGB(rgba[3], rgba[0], rgba[1], rgba[2]);
      }
    }

    if (color != null) {
      final formats = ColorUtil.getAllFormats(input);
      setState(() {
        _previewColor = color;
        _colorFormats = formats;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _previewColor = null;
        _colorFormats = null;
        _errorMessage = '无法解析颜色格式';
      });
    }
  }

  /// 应用预设颜色
  void _applyPreset(String hex) {
    _inputController.text = hex;
    _convertColor();
  }

  /// 复制颜色值
  void _copyValue(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已复制: $value')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('颜色转换')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 输入区域
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '输入颜色值：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      decoration: InputDecoration(
                        hintText: '输入 HEX、RGB、HSL 等格式',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.colorize),
                          onPressed: _convertColor,
                        ),
                      ),
                      onSubmitted: (_) => _convertColor(),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _convertColor,
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('转换'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _inputController.clear();
                              setState(() {
                                _previewColor = null;
                                _colorFormats = null;
                                _errorMessage = null;
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('清空'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 错误信息
            if (_errorMessage != null)
              Card(
                elevation: 0,
                color: Colors.red.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),

            // 颜色预览
            if (_previewColor != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '颜色预览：',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // 颜色块
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: _previewColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _previewColor!.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // 颜色信息
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildColorInfoRow('RGB', 'rgb(${(_previewColor!.r * 255).round()}, ${(_previewColor!.g * 255).round()}, ${(_previewColor!.b * 255).round()})'),
                                _buildColorInfoRow('HEX', ColorUtil.colorToHex(_previewColor!)),
                                _buildColorInfoRow(
                                  '对比色',
                                  ColorUtil.getContrastColor(ColorUtil.colorToHex(_previewColor!)) ?? 'N/A',
                                ),
                                _buildColorInfoRow(
                                  '深色?',
                                  ColorUtil.isDarkColor(ColorUtil.colorToHex(_previewColor!)) == true ? '是' : '否',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 所有格式
              if (_colorFormats != null)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '所有格式：',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        ..._colorFormats!.entries.map((entry) {
                          return _buildFormatRow(entry.key, entry.value);
                        }),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // 调色板生成
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '色相调色板：',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextButton(
                            onPressed: () {
                              final base = _colorFormats?['HEX'] ?? '#FF0000';
                              final palette = ColorUtil.generatePalette(base);
                              if (palette != null) {
                                _showPaletteDialog(palette);
                              }
                            },
                            child: const Text('查看全部'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildPaletteRow(_colorFormats?['HEX'] ?? '#FF0000'),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 预设颜色
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '预设颜色：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _presetColors.map((preset) {
                        final hex = preset['hex'] as String;
                        return GestureDetector(
                          onTap: () => _applyPreset(hex),
                          child: Tooltip(
                            message: '${preset['name']}\n$hex',
                            child: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: ColorUtil.colorFromHex(hex),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
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

  Widget _buildColorInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'Monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatRow(String label, String value) {
    return InkWell(
      onTap: () => _copyValue(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(fontFamily: 'Monospace'),
              ),
            ),
            Icon(
              Icons.copy,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaletteRow(String baseHex) {
    final palette = ColorUtil.generatePalette(baseHex, count: 8);
    if (palette == null) return const SizedBox();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: palette.map((hex) {
        return GestureDetector(
          onTap: () {
            _inputController.text = hex;
            _convertColor();
          },
          child: Tooltip(
            message: hex,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ColorUtil.colorFromHex(hex),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showPaletteDialog(List<String> palette) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('色相调色板'),
          content: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: palette.map((hex) {
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _inputController.text = hex;
                  _convertColor();
                },
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: ColorUtil.colorFromHex(hex),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hex,
                      style: const TextStyle(
                        fontFamily: 'Monospace',
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }
}
