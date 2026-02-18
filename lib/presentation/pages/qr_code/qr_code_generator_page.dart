/// QR Code Generator Page
/// Author: ZF_Clark
/// Description: UI page for generating QR codes from text input. Uses qr_flutter package for QR code generation. Provides text input and QR code display functionality.
/// Last Modified: 2026/02/08
library;

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qingyu/core/utils/qr_code_saver.dart';
import '../../../core/utils/platform_util.dart';

/// 二维码生成页面
/// 提供将文本转换为二维码的UI界面
class QrCodeGeneratorPage extends StatefulWidget {
  const QrCodeGeneratorPage({super.key});

  @override
  State<QrCodeGeneratorPage> createState() => _QrCodeGeneratorPageState();
}

class _QrCodeGeneratorPageState extends State<QrCodeGeneratorPage> {
  final TextEditingController _inputController = TextEditingController();
  double _qrCodeSize = 200.0;
  final GlobalKey _globalKey = GlobalKey();
  bool _isSaving = false;
  bool _showQrCode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('二维码生成')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                    const Text('输入文本或链接：'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _inputController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        hintText: '请输入要转换为二维码的文本或链接',
                        suffixText: '${_inputController.text.length} 字符',
                        suffixStyle: TextStyle(color: Colors.grey),
                      ),
                      onChanged: (text) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _generateQrCode,
                            child: const Text('生成二维码'),
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

            // 二维码显示区域
            if (_showQrCode)
              Expanded(
                child: Card(
                  elevation: 4,
                  shadowColor: Colors.black.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '二维码：',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    spreadRadius: 2,
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: RepaintBoundary(
                                key: _globalKey,
                                child: QrImageView(
                                  data: _inputController.text,
                                  version: QrVersions.auto,
                                  size: _qrCodeSize,
                                  gapless: false,
                                  errorStateBuilder: (cxt, err) {
                                    return const Center(child: Text('生成二维码失败'));
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            // 二维码大小调整
                            Row(
                              children: [
                                const Text('二维码大小：'),
                                Expanded(
                                  child: Slider(
                                    value: _qrCodeSize,
                                    min: 100,
                                    max: 300,
                                    divisions: 4,
                                    label: '${_qrCodeSize.round()}',
                                    activeColor: Theme.of(context).primaryColor,
                                    onChanged: (value) {
                                      setState(() {
                                        _qrCodeSize = value;
                                      });
                                    },
                                  ),
                                ),
                                Text('${_qrCodeSize.round()}px'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _copyInput,
                                    icon: const Icon(Icons.copy),
                                    label: const Text('复制输入文本'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isSaving ? null : _saveQrCode,
                                    icon: _isSaving
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.save_alt),
                                    label: Text(_isSaving ? '保存中...' : '保存二维码'),
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 生成二维码
  void _generateQrCode() {
    if (_inputController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入文本')));
      return;
    }

    // 显示二维码
    setState(() {
      _showQrCode = true;
    });
  }

  /// 清空输入
  void _clearInput() {
    setState(() {
      _inputController.clear();
      _showQrCode = false;
    });
  }

  /// 复制输入文本到剪贴板
  void _copyInput() {
    if (_inputController.text.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _inputController.text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('文本已复制到剪贴板')));
  }

  /// 保存二维码为图片
  Future<void> _saveQrCode() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // 检查输入是否为空
      if (_inputController.text.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('请先生成二维码')));
        return;
      }

      // 获取RepaintBoundary的渲染对象
      RenderRepaintBoundary boundary =
          _globalKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      // 捕获图像
      Uint8List imageBytes = await boundary
          .toImage(pixelRatio: 3.0)
          .then((image) => image.toByteData(format: ImageByteFormat.png))
          .then((byteData) => byteData!.buffer.asUint8List());

      // 检测平台并执行相应的保存逻辑
      if (kIsWeb) {
        // Web平台：使用download API
        try {
          final fileName =
              'qr_code_${DateTime.now().millisecondsSinceEpoch}.png';
          final success = await QrCodeSaverWeb.saveQrCode(imageBytes, fileName);
          if (success) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('二维码已开始下载')));
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Web平台保存失败')));
          }
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Web平台保存失败: $e')));
        }
      } else if (PlatformUtil.isAndroid()) {
        // Android平台：保存到公共图片目录
        Directory? directory;
        try {
          // 尝试获取公共图片目录
          directory = Directory('/storage/emulated/0/Pictures/Qingyu');
          // 如果目录不存在，创建它
          if (!directory.existsSync()) {
            directory.createSync(recursive: true);
          }
        } catch (e) {
          // 如果无法访问公共目录，回退到应用文档目录
          directory = await getApplicationDocumentsDirectory();
        }

        String path = directory.path;
        // 创建保存文件
        File file = File(
          '$path/qr_code_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        // 写入文件
        await file.writeAsBytes(imageBytes);

        // 显示保存成功消息
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('二维码已保存到: ${file.path}')));
      } else if (PlatformUtil.isIOS()) {
        // iOS平台：保存到应用文档目录
        Directory directory = await getApplicationDocumentsDirectory();
        String path = directory.path;
        // 创建保存文件
        File file = File(
          '$path/qr_code_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        // 写入文件
        await file.writeAsBytes(imageBytes);

        // 显示保存成功消息
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('二维码已保存到: ${file.path}')));
      } else {
        // 其他平台：保存到应用文档目录
        Directory directory = await getApplicationDocumentsDirectory();
        String path = directory.path;
        // 创建保存文件
        File file = File(
          '$path/qr_code_${DateTime.now().millisecondsSinceEpoch}.png',
        );
        // 写入文件
        await file.writeAsBytes(imageBytes);

        // 显示保存成功消息
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('二维码已保存到: ${file.path}')));
      }
    } catch (e) {
      // 显示保存失败消息
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }
}
