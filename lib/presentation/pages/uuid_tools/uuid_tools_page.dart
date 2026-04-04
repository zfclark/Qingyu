/// UUID Tools Page
/// Author: ZF_Clark
/// Description: UI page for UUID generation and management. Supports UUID v1 (timestamp-based) and v4 (random). Uses UuidUtil for all UUID operations.
/// Last Modified: 2026/04/04
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/uuid_util.dart';

/// UUID工具页面
/// 提供UUID生成、验证和管理功能的UI界面
class UuidToolsPage extends StatefulWidget {
  const UuidToolsPage({super.key});

  @override
  State<UuidToolsPage> createState() => _UuidToolsPageState();
}

class _UuidToolsPageState extends State<UuidToolsPage> {
  String? _generatedUuid;
  String _uuidVersion = 'v4';
  final List<String> _history = [];
  bool _lowercase = true;
  String _inputUuid = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('UUID生成器')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 生成区域
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
                      '生成UUID',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 16),

                    // 版本选择
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'v4',
                          label: Text('UUID v4'),
                          icon: Icon(Icons.shuffle),
                        ),
                        ButtonSegment(
                          value: 'v1',
                          label: Text('UUID v1'),
                          icon: Icon(Icons.schedule),
                        ),
                      ],
                      selected: {_uuidVersion},
                      onSelectionChanged: (selected) {
                        setState(() {
                          _uuidVersion = selected.first;
                          _generatedUuid = null;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // 选项
                    Row(
                      children: [
                        const Text('小写字母'),
                        Switch(
                          value: _lowercase,
                          onChanged: (value) {
                            setState(() => _lowercase = value);
                          },
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            _generateUuid();
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('生成'),
                        ),
                      ],
                    ),

                    // 批量生成
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showBatchDialog(),
                            icon: const Icon(Icons.playlist_add),
                            label: const Text('批量生成'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 生成结果
            if (_generatedUuid != null)
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.tag),
                              const SizedBox(width: 8),
                              Text(
                                '生成的 ${_uuidVersion.toUpperCase()}：',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          _buildVersionBadge(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _lowercase ? _generatedUuid!.toLowerCase() : _generatedUuid!.toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'Monospace',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _copyUuid(_generatedUuid!),
                              icon: const Icon(Icons.copy),
                              label: const Text('复制'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _addToHistory(_generatedUuid!),
                              icon: const Icon(Icons.bookmark_add),
                              label: const Text('保存'),
                            ),
                          ),
                        ],
                      ),

                      // UUID信息
                      if (_uuidVersion == 'v1')
                        _buildUuidInfo(_generatedUuid!),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 验证UUID
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
                      '验证UUID',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: '输入UUID进行验证',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.search),
                      ),
                      style: const TextStyle(fontFamily: 'Monospace'),
                      onChanged: (value) {
                        setState(() => _inputUuid = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    if (_inputUuid.isNotEmpty)
                      _buildValidationResult(_inputUuid),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 历史记录
            if (_history.isNotEmpty) ...[
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
                          Row(
                            children: [
                              const Icon(Icons.history),
                              const SizedBox(width: 8),
                              const Text(
                                '历史记录',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() => _history.clear());
                            },
                            child: const Text('清空'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._history.asMap().entries.map((entry) {
                        final index = entry.key;
                        final uuid = entry.value;
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            UuidUtil.isValidV1(uuid) ? Icons.schedule : Icons.shuffle,
                            size: 20,
                          ),
                          title: Text(
                            uuid,
                            style: const TextStyle(fontFamily: 'Monospace', fontSize: 13),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                onPressed: () => _copyUuid(uuid),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                onPressed: () {
                                  setState(() => _history.removeAt(index));
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVersionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _uuidVersion == 'v4' 
            ? Colors.blue.withValues(alpha: 0.2) 
            : Colors.green.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _uuidVersion.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: _uuidVersion == 'v4' ? Colors.blue : Colors.green,
        ),
      ),
    );
  }

  Widget _buildUuidInfo(String uuid) {
    final version = UuidUtil.getVersion(uuid);
    DateTime? timestamp;
    if (UuidUtil.isValidV1(uuid)) {
      timestamp = UuidUtil.getTimestampFromV1(uuid);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildInfoChip('版本', version?.toString() ?? 'N/A'),
            const SizedBox(width: 8),
            if (timestamp != null)
              _buildInfoChip('时间', _formatDateTime(timestamp)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationResult(String uuid) {
    final isValid = UuidUtil.isValid(uuid);
    final isV1 = UuidUtil.isValidV1(uuid);
    final isV4 = UuidUtil.isValidV4(uuid);
    final version = UuidUtil.getVersion(uuid);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid 
            ? Colors.green.withValues(alpha: 0.1) 
            : Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isValid ? Icons.check_circle : Icons.error,
                color: isValid ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              Text(
                isValid ? '有效的UUID' : '无效的UUID格式',
                style: TextStyle(
                  color: isValid ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isValid) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (isV1) Chip(label: const Text('UUID v1'), backgroundColor: Colors.green.shade100),
                if (isV4) Chip(label: const Text('UUID v4'), backgroundColor: Colors.blue.shade100),
                Chip(label: Text('版本 $version')),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _generateUuid() {
    String uuid;
    if (_uuidVersion == 'v4') {
      uuid = UuidUtil.generateV4();
    } else {
      uuid = UuidUtil.generateV1();
    }

    setState(() {
      _generatedUuid = uuid;
    });
  }

  void _copyUuid(String uuid) {
    final text = _lowercase ? uuid.toLowerCase() : uuid.toUpperCase();
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('UUID已复制到剪贴板')),
    );
  }

  void _addToHistory(String uuid) {
    if (!_history.contains(uuid)) {
      setState(() {
        _history.insert(0, uuid);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('已添加到历史记录')),
      );
    }
  }

  void _showBatchDialog() {
    int count = 5;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('批量生成UUID'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('生成数量: $count'),
                  Slider(
                    value: count.toDouble(),
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '$count',
                    onChanged: (value) {
                      setDialogState(() => count = value.round());
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
                    _generateBatch(count);
                  },
                  child: const Text('生成'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _generateBatch(int count) {
    final uuids = _uuidVersion == 'v4'
        ? UuidUtil.generateV4Batch(count, lowercase: _lowercase)
        : List.generate(count, (_) {
            final uuid = UuidUtil.generateV1();
            return _lowercase ? uuid.toLowerCase() : uuid.toUpperCase();
          });

    final text = uuids.join('\n');
    Clipboard.setData(ClipboardData(text: text));
    
    setState(() {
      _generatedUuid = '${uuids.length}个UUID已生成并复制到剪贴板';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已生成$count个${_uuidVersion.toUpperCase()}并复制到剪贴板')),
    );
  }
}
