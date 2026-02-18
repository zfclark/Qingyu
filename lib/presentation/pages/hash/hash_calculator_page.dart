/// Hash Calculator Page
/// Author: ZF_Clark
/// Description: Comprehensive hash calculation tool supporting both text and file hashing. Uses HashUtil for calculation and StorageService for history persistence.
/// Last Modified: 2026/02/09
library;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/utils/hash_util.dart';
import '../../../core/services/storage_service.dart';
import '../../../data/models/hash_history_model.dart';

/// 哈希计算器页面
/// 提供文本哈希和文件哈希计算功能
class HashCalculatorPage extends StatefulWidget {
  const HashCalculatorPage({super.key});

  @override
  State<HashCalculatorPage> createState() => _HashCalculatorPageState();
}

class _HashCalculatorPageState extends State<HashCalculatorPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 文本哈希相关
  final TextEditingController _inputController = TextEditingController();
  String _textResult = '';
  List<HashHistoryModel> _history = [];
  String _selectedAlgorithm = 'SHA256';

  // 文件哈希相关
  File? _selectedFile;
  Uint8List? _selectedFileBytes;
  String _selectedFileName = '';
  String _fileResult = '';
  bool _isCalculatingFile = false;
  int _fileProgress = 0;

  /// 可用的哈希算法列表
  final List<String> _algorithms = HashUtil.supportedAlgorithms;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _inputController.dispose();
    super.dispose();
  }

  /// 从存储加载历史记录
  void _loadHistory() {
    setState(() {
      _history = StorageService.getHashHistory();
    });
  }

  // ==================== 文本哈希功能 ====================

  /// 执行文本哈希计算
  void _calculateTextHash() {
    if (_inputController.text.isEmpty) return;

    final hashString = HashUtil.calculateHash(
      _inputController.text,
      _selectedAlgorithm,
    );

    setState(() {
      _textResult = hashString;
    });

    _saveToHistory(_inputController.text, hashString);
  }

  /// 保存计算到历史记录
  void _saveToHistory(String input, String hash) {
    final historyItem = HashHistoryModel(
      input: input,
      hash: hash,
      algorithm: _selectedAlgorithm,
      timestamp: DateTime.now(),
    );

    setState(() {
      _history.insert(0, historyItem);
      if (_history.length > 50) {
        _history = _history.sublist(0, 50);
      }
    });

    StorageService.saveHashHistory(_history);
  }

  /// 复制文本结果到剪贴板
  void _copyTextResult() {
    if (_textResult.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _textResult));
    _showSnackBar('结果已复制到剪贴板');
  }

  /// 清空文本输入
  void _clearTextInput() {
    setState(() {
      _inputController.clear();
      _textResult = '';
    });
  }

  // ==================== 文件哈希功能 ====================

  /// 选择文件
  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();

      if (result != null) {
        final file = result.files.single;

        setState(() {
          _fileResult = '';
          _fileProgress = 0;
          _selectedFileName = file.name;
        });

        if (kIsWeb) {
          // Web平台：使用bytes属性
          if (file.bytes != null) {
            setState(() {
              _selectedFileBytes = file.bytes!;
              _selectedFile = null; // Web平台不需要File对象
            });
          } else {
            _showSnackBar('选择文件失败: 无法获取文件数据');
          }
        } else {
          // 非Web平台：使用path属性
          if (file.path != null) {
            setState(() {
              _selectedFile = File(file.path!);
              _selectedFileBytes = null;
            });
          } else {
            _showSnackBar('选择文件失败: 无法获取文件路径');
          }
        }
      }
    } catch (e) {
      _showSnackBar('选择文件失败: $e');
    }
  }

  /// 计算文件哈希
  Future<void> _calculateFileHash() async {
    if (kIsWeb) {
      if (_selectedFileBytes == null) {
        _showSnackBar('请先选择文件');
        return;
      }
    } else {
      if (_selectedFile == null) {
        _showSnackBar('请先选择文件');
        return;
      }
    }

    setState(() {
      _isCalculatingFile = true;
      _fileProgress = 0;
      _fileResult = '';
    });

    try {
      String hashString;

      if (kIsWeb) {
        // Web平台：使用字节数组计算哈希
        hashString = HashUtil.calculateHashFromBytes(
          _selectedFileBytes!,
          _selectedAlgorithm,
          onProgress: (progress) {
            setState(() {
              _fileProgress = progress;
            });
          },
        );
      } else {
        // 非Web平台：使用文件对象计算哈希
        hashString = await HashUtil.calculateFileHashChunked(
          _selectedFile!,
          _selectedAlgorithm,
          onProgress: (progress) {
            setState(() {
              _fileProgress = progress;
            });
          },
        );
      }

      setState(() {
        _fileResult = hashString;
        _isCalculatingFile = false;
      });

      _showSnackBar('文件哈希计算完成');
    } catch (e) {
      setState(() {
        _isCalculatingFile = false;
      });
      _showSnackBar('计算失败: $e');
    }
  }

  /// 复制文件结果到剪贴板
  void _copyFileResult() {
    if (_fileResult.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _fileResult));
    _showSnackBar('结果已复制到剪贴板');
  }

  /// 清空文件选择
  void _clearFileSelection() {
    setState(() {
      _selectedFile = null;
      _selectedFileBytes = null;
      _selectedFileName = '';
      _fileResult = '';
      _fileProgress = 0;
    });
  }

  // ==================== 通用功能 ====================

  /// 显示提示
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  /// 清空历史记录
  void _clearHistory() {
    setState(() {
      _history.clear();
    });
    StorageService.saveHashHistory([]);
  }

  /// 构建算法选择器
  Widget _buildAlgorithmSelector() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('选择算法：'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _algorithms.map((algorithm) {
                return ChoiceChip(
                  label: Text(algorithm),
                  selected: _selectedAlgorithm == algorithm,
                  onSelected: (selected) {
                    setState(() {
                      _selectedAlgorithm = algorithm;
                      _textResult = '';
                      _fileResult = '';
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建文本哈希Tab
  Widget _buildTextHashTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 算法选择
          _buildAlgorithmSelector(),
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
                  const Text('输入文本：'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _inputController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: '请输入或粘贴文本',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _calculateTextHash,
                          icon: const Icon(Icons.calculate),
                          label: Text('计算 $_selectedAlgorithm'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _clearTextInput,
                        icon: const Icon(Icons.clear),
                        label: const Text('清空'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 结果区域
          if (_textResult.isNotEmpty)
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
                    Text('计算结果 ($_selectedAlgorithm)：'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _textResult,
                        style: const TextStyle(fontFamily: 'Monospace'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _copyTextResult,
                      icon: const Icon(Icons.copy),
                      label: const Text('复制结果'),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // 历史记录
          _buildHistorySection(),
        ],
      ),
    );
  }

  /// 构建文件哈希Tab
  Widget _buildFileHashTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 算法选择
          _buildAlgorithmSelector(),
          const SizedBox(height: 16),

          // 文件选择区域
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
                  const Text('选择文件：'),
                  const SizedBox(height: 8),
                  if (_selectedFile == null && _selectedFileBytes == null)
                    InkWell(
                      onTap: _pickFile,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withAlpha(25),
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.upload_file,
                              size: 48,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '点击选择文件',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '支持所有文件类型',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withAlpha(30),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.insert_drive_file,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  kIsWeb
                                      ? _selectedFileName
                                      : _selectedFile!.path.split('/').last,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: _clearFileSelection,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (kIsWeb)
                            Text(
                              '文件大小: ${HashUtil.formatFileSize(_selectedFileBytes!.length)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            )
                          else
                            FutureBuilder<int>(
                              future: _selectedFile!.length(),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(
                                    '文件大小: ${HashUtil.formatFileSize(snapshot.data!)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                                  );
                                }
                                return const SizedBox.shrink();
                              },
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),

                  // 进度条
                  if (_isCalculatingFile) ...[
                    LinearProgressIndicator(
                      value: _fileProgress / 100,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '计算中... $_fileProgress%',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isCalculatingFile
                              ? null
                              : _calculateFileHash,
                          icon: _isCalculatingFile
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.calculate),
                          label: Text(_isCalculatingFile ? '计算中...' : '计算文件哈希'),
                        ),
                      ),
                      if (_selectedFile != null) ...[
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isCalculatingFile ? null : _pickFile,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('重新选择'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 文件结果区域
          if (_fileResult.isNotEmpty)
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
                    Text('文件哈希结果 ($_selectedAlgorithm)：'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        _fileResult,
                        style: const TextStyle(fontFamily: 'Monospace'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _copyFileResult,
                      icon: const Icon(Icons.copy),
                      label: const Text('复制结果'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 构建历史记录区域
  Widget _buildHistorySection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('历史记录：'),
                if (_history.isNotEmpty)
                  TextButton(
                    onPressed: _clearHistory,
                    child: const Text('清空历史'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: _history.isEmpty
                  ? const Center(child: Text('暂无历史记录'))
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return ListTile(
                          title: Text(
                            item.input.length > 30
                                ? '${item.input.substring(0, 30)}...'
                                : item.input,
                          ),
                          subtitle: Text(
                            '${item.algorithm} · ${item.timestamp.toString().substring(0, 19)}',
                          ),
                          trailing: Text(
                            '${item.hash.substring(0, 10)}...',
                            style: const TextStyle(fontFamily: 'Monospace'),
                          ),
                          onTap: () {
                            setState(() {
                              _inputController.text = item.input;
                              _selectedAlgorithm = item.algorithm;
                              _textResult = item.hash;
                            });
                            _tabController.animateTo(0);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('哈希计算器'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.text_fields), text: '文本哈希'),
            Tab(icon: Icon(Icons.insert_drive_file), text: '文件哈希'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildTextHashTab(), _buildFileHashTab()],
      ),
    );
  }
}
