/// Password Tools Page
/// Author: ZF_Clark
/// Description: UI page for random password generation with customizable options and strength evaluation. Uses PasswordUtil for all password operations.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/password_util.dart';

/// 密码生成工具页面
/// 提供随机密码生成、强度评估等功能的UI界面
class PasswordToolsPage extends StatefulWidget {
  const PasswordToolsPage({super.key});

  @override
  State<PasswordToolsPage> createState() => _PasswordToolsPageState();
}

class _PasswordToolsPageState extends State<PasswordToolsPage> {
  String _generatedPassword = '';
  int _passwordLength = 16;
  bool _includeLowercase = true;
  bool _includeUppercase = true;
  bool _includeDigits = true;
  bool _includeSpecial = true;
  bool _excludeAmbiguous = false;
  int _strength = 0;

  @override
  void initState() {
    super.initState();
    _generatePassword();
  }

  /// 生成密码
  void _generatePassword() {
    final password = PasswordUtil.generate(
      length: _passwordLength,
      includeLowercase: _includeLowercase,
      includeUppercase: _includeUppercase,
      includeDigits: _includeDigits,
      includeSpecial: _includeSpecial,
      excludeAmbiguous: _excludeAmbiguous,
    );

    setState(() {
      _generatedPassword = password;
      _strength = PasswordUtil.evaluateStrength(password);
    });
  }

  /// 生成简单密码
  void _generateSimple() {
    final password = PasswordUtil.generateSimple(length: _passwordLength);
    setState(() {
      _generatedPassword = password;
      _strength = PasswordUtil.evaluateStrength(password);
    });
  }

  /// 生成纯数字密码
  void _generateNumeric() {
    final password = PasswordUtil.generateNumeric(length: _passwordLength);
    setState(() {
      _generatedPassword = password;
      _strength = PasswordUtil.evaluateStrength(password);
    });
  }

  /// 生成Passphrase
  void _generatePassphrase() {
    final password = PasswordUtil.generatePassphrase(wordCount: 4);
    setState(() {
      _generatedPassword = password;
      _strength = PasswordUtil.evaluateStrength(password);
    });
  }

  /// 复制密码
  void _copyPassword() {
    if (_generatedPassword.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('密码已复制到剪贴板')),
    );
  }

  /// 获取强度标签
  Color _getStrengthColor() {
    switch (_strength) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.yellow.shade700;
      case 3:
        return Colors.lightGreen;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStrengthLabel() {
    switch (_strength) {
      case 0:
        return '极弱';
      case 1:
        return '弱';
      case 2:
        return '中等';
      case 3:
        return '强';
      case 4:
        return '极强';
      default:
        return '未知';
    }
  }

  IconData _getStrengthIcon() {
    switch (_strength) {
      case 0:
        return Icons.sentiment_very_dissatisfied;
      case 1:
        return Icons.sentiment_dissatisfied;
      case 2:
        return Icons.sentiment_neutral;
      case 3:
        return Icons.sentiment_satisfied;
      case 4:
        return Icons.sentiment_very_satisfied;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('密码生成器')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 生成的密码显示
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getStrengthIcon(),
                          color: _getStrengthColor(),
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '强度: ${_getStrengthLabel()}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _getStrengthColor(),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStrengthColor().withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${(_strength / 4 * 100).round()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getStrengthColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // 强度条
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _strength / 4,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation(_getStrengthColor()),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 密码显示
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                        ),
                      ),
                      child: SelectableText(
                        _generatedPassword,
                        style: const TextStyle(
                          fontFamily: 'Monospace',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 操作按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _generatePassword,
                            icon: const Icon(Icons.refresh),
                            label: const Text('重新生成'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _copyPassword,
                            icon: const Icon(Icons.copy),
                            label: const Text('复制'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 快速生成
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
                      '快速生成',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickButton(
                          '随机密码',
                          Icons.password,
                          _generatePassword,
                        ),
                        _buildQuickButton(
                          '简单密码',
                          Icons.text_fields,
                          _generateSimple,
                        ),
                        _buildQuickButton(
                          '纯数字',
                          Icons.pin,
                          _generateNumeric,
                        ),
                        _buildQuickButton(
                          '助记词',
                          Icons.auto_awesome,
                          _generatePassphrase,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 设置区域
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
                      '密码设置',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // 长度滑块
                    Row(
                      children: [
                        const Text('密码长度: '),
                        Text(
                          '$_passwordLength',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _passwordLength.toDouble(),
                      min: 4,
                      max: 64,
                      divisions: 60,
                      label: '$_passwordLength',
                      onChanged: (value) {
                        setState(() {
                          _passwordLength = value.round();
                        });
                        _generatePassword();
                      },
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        ActionChip(
                          label: const Text('8'),
                          onPressed: () {
                            setState(() => _passwordLength = 8);
                            _generatePassword();
                          },
                        ),
                        ActionChip(
                          label: const Text('12'),
                          onPressed: () {
                            setState(() => _passwordLength = 12);
                            _generatePassword();
                          },
                        ),
                        ActionChip(
                          label: const Text('16'),
                          onPressed: () {
                            setState(() => _passwordLength = 16);
                            _generatePassword();
                          },
                        ),
                        ActionChip(
                          label: const Text('20'),
                          onPressed: () {
                            setState(() => _passwordLength = 20);
                            _generatePassword();
                          },
                        ),
                        ActionChip(
                          label: const Text('32'),
                          onPressed: () {
                            setState(() => _passwordLength = 32);
                            _generatePassword();
                          },
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    // 字符类型选择
                    const Text(
                      '包含字符',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    _buildOptionSwitch(
                      '小写字母 (a-z)',
                      'abcdefghijklmnopqrstuvwxyz',
                      _includeLowercase,
                      (value) {
                        setState(() => _includeLowercase = value);
                        _generatePassword();
                      },
                    ),
                    _buildOptionSwitch(
                      '大写字母 (A-Z)',
                      'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
                      _includeUppercase,
                      (value) {
                        setState(() => _includeUppercase = value);
                        _generatePassword();
                      },
                    ),
                    _buildOptionSwitch(
                      '数字 (0-9)',
                      '0123456789',
                      _includeDigits,
                      (value) {
                        setState(() => _includeDigits = value);
                        _generatePassword();
                      },
                    ),
                    _buildOptionSwitch(
                      '特殊字符',
                      '!@#\$%^&*+-=_?',
                      _includeSpecial,
                      (value) {
                        setState(() => _includeSpecial = value);
                        _generatePassword();
                      },
                    ),

                    const Divider(height: 24),

                    // 其他选项
                    _buildOptionSwitch(
                      '排除易混淆字符 (l, 1, I, O, 0)',
                      '更易阅读',
                      _excludeAmbiguous,
                      (value) {
                        setState(() => _excludeAmbiguous = value);
                        _generatePassword();
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 改进建议
            if (_generatedPassword.isNotEmpty) ...[
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
                        children: [
                          const Icon(Icons.lightbulb_outline),
                          const SizedBox(width: 8),
                          const Text(
                            '密码安全建议',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...PasswordUtil.getSuggestions(_generatedPassword).map((suggestion) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(child: Text(suggestion)),
                            ],
                          ),
                        );
                      }),
                      if (PasswordUtil.getSuggestions(_generatedPassword).isEmpty)
                        const Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: Colors.green),
                            SizedBox(width: 8),
                            Text('密码安全性良好'),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 批量生成
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
                      '批量生成',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _showBatchDialog(),
                      icon: const Icon(Icons.playlist_add),
                      label: const Text('生成多个密码'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildOptionSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  void _showBatchDialog() {
    int count = 10;
    int length = 16;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('批量生成密码'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('生成数量: $count'),
                  Slider(
                    value: count.toDouble(),
                    min: 5,
                    max: 50,
                    divisions: 9,
                    label: '$count',
                    onChanged: (value) {
                      setDialogState(() => count = value.round());
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('密码长度: $length'),
                  Slider(
                    value: length.toDouble(),
                    min: 8,
                    max: 32,
                    divisions: 24,
                    label: '$length',
                    onChanged: (value) {
                      setDialogState(() => length = value.round());
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _generateBatch(count, length);
                  },
                  child: const Text('生成并复制'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _generateBatch(int count, int length) {
    final passwords = PasswordUtil.generateBatch(
      count: count,
      length: length,
      includeLowercase: _includeLowercase,
      includeUppercase: _includeUppercase,
      includeDigits: _includeDigits,
      includeSpecial: _includeSpecial,
      excludeAmbiguous: _excludeAmbiguous,
    );

    final text = passwords.join('\n');
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已生成$count个密码并复制到剪贴板')),
    );
  }
}
