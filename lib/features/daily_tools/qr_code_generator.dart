/// QR Code Generator
/// Author: ZF_Clark
/// Description: Widget that allows users to input text and generate a corresponding QR code. Utilizes the qr_flutter package for QR code generation
/// Last Modified: 2026/02/04
/// Version: V0.1
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeGenerator extends StatefulWidget {
  const QrCodeGenerator({super.key});

  @override
  State<QrCodeGenerator> createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  final TextEditingController _inputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('二维码生成')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input section
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
                        hintText: '请输入要转换为二维码的文本',
                      ),
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

            // QR Code display
            if (_inputController.text.isNotEmpty)
              Expanded(
                child: Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('二维码：'),
                          const SizedBox(height: 16),
                          QrImageView(
                            data: _inputController.text,
                            version: QrVersions.auto,
                            size: 200,
                            gapless: false,
                            errorStateBuilder: (cxt, err) {
                              return const Center(child: Text('生成二维码失败'));
                            },
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _copyInput,
                            icon: const Icon(Icons.copy),
                            label: const Text('复制输入文本'),
                          ),
                        ],
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

  /// Generate QR code
  void _generateQrCode() {
    if (_inputController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入文本')));
      return;
    }

    // QR code generation is handled by QrImageView
    // No need for async operation here
    // The QR code will be displayed automatically when input text is not empty
  }

  /// Clear input field
  void _clearInput() {
    setState(() {
      _inputController.clear();
    });
  }

  /// Copy input text to clipboard
  void _copyInput() {
    if (_inputController.text.isEmpty) return;

    Clipboard.setData(ClipboardData(text: _inputController.text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('文本已复制到剪贴板')));
  }
}
