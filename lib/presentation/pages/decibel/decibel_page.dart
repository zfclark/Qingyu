/// Decibel Detector Page
/// Author: ZF_Clark
/// Description: UI page for ambient noise decibel detection using device microphone.
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';
import '../../../core/utils/decibel_util.dart';
import '../../../core/services/platform_service.dart';

/// 环境分贝检测页面
/// 使用设备麦克风实时检测环境噪音分贝值
class DecibelPage extends StatefulWidget {
  const DecibelPage({super.key});

  @override
  State<DecibelPage> createState() => _DecibelPageState();
}

class _DecibelPageState extends State<DecibelPage> with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _hasPermission = false;
  double _currentDB = 0;
  double _maxDB = 0;
  double _dbAngle = 0;
  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Timer? _simulateTimer;

  // 仅用于 Web 平台的模拟模式
  bool _isSimulatedMode = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _amplitudeSubscription?.cancel();
    _simulateTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    if (!PlatformService.supportsNativeFeatures) {
      // Web 平台 - 使用模拟模式
      setState(() => _isSimulatedMode = true);
      return;
    }

    final status = await Permission.microphone.request();
    if (!mounted) return;
    setState(() => _hasPermission = status.isGranted);
  }

  Future<void> _startRecording() async {
    if (!_hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('需要麦克风权限才能检测分贝')),
      );
      return;
    }

    if (_isSimulatedMode) {
      _startSimulation();
      return;
    }

    try {
      await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        numChannels: 1,
        sampleRate: 44100,
      ));

      _amplitudeSubscription = _recorder.onAmplitudeChanged(const Duration(milliseconds: 100)).listen(
        (amplitude) {
          final db = DecibelUtil.amplitudeToDB(amplitude.current);
          _updateDB(db);
        },
      );

      setState(() => _isRecording = true);
    } catch (e) {
      // 降级到模拟模式
      _startSimulation();
    }
  }

  void _startSimulation() {
    setState(() {
      _isSimulatedMode = true;
      _isRecording = true;
    });

    _simulateTimer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
      // 模拟 20-80 dB 之间的随机变化
      final simulated = 20 + math.Random().nextDouble() * 60;
      _updateDB(simulated);
    });
  }

  void _updateDB(double db) {
    setState(() {
      _currentDB = db;
      if (db > _maxDB) _maxDB = db;
      // 映射 0-120dB 到 0-270 度（270度仪表盘）
      _dbAngle = (db / 120.0) * 270.0;
    });
  }

  Future<void> _stopRecording() async {
    _amplitudeSubscription?.cancel();
    _amplitudeSubscription = null;
    _simulateTimer?.cancel();
    _simulateTimer = null;

    if (!_isSimulatedMode) {
      try {
        await _recorder.stop();
      } catch (_) {}
    }

    setState(() => _isRecording = false);
  }

  void _resetMax() {
    setState(() => _maxDB = 0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('分贝检测')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (!_hasPermission && !_isSimulatedMode && PlatformService.supportsNativeFeatures)
              _buildPermissionCard(theme)
            else ...[
              _buildGaugeCard(theme),
              const SizedBox(height: 16),
              _buildInfoCard(theme),
              const SizedBox(height: 16),
              _buildControls(theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.mic_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text('需要麦克风权限', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('分贝检测需要访问您的麦克风', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await _checkPermission();
                if (mounted && _hasPermission) {
                  _startRecording();
                }
              },
              icon: const Icon(Icons.mic),
              label: const Text('授予权限并开始'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugeCard(ThemeData theme) {
    final dbColor = Color(DecibelUtil.getDBColorInt(_currentDB));
    final dbLevel = DecibelUtil.getDBLevel(_currentDB);
    final dbDesc = DecibelUtil.getLevelDescription(_currentDB);

    return Card(
      elevation: 0,
      color: _isRecording ? dbColor.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // 仪表盘
            SizedBox(
              height: 180,
              child: CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _GaugePainter(
                  angle: _dbAngle,
                  color: dbColor,
                  isActive: _isRecording,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _currentDB.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 56,
                fontWeight: FontWeight.bold,
                color: _isRecording ? dbColor : Colors.grey[400],
              ),
            ),
            Text(
              '分贝 (dB)',
              style: TextStyle(color: _isRecording ? dbColor : Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 8),
            if (_isRecording)
              Chip(
                avatar: Icon(
                  _currentDB > 70 ? Icons.warning : Icons.check_circle,
                  size: 18,
                  color: dbColor,
                ),
                label: Text('$dbLevel — $dbDesc'),
                backgroundColor: dbColor.withValues(alpha: 0.15),
              )
            else
              const Chip(
                avatar: Icon(Icons.mic_off, size: 18),
                label: Text('未开始检测'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    if (!_isRecording) return const SizedBox.shrink();

    final advice = DecibelUtil.getHealthAdvice(_currentDB);
    final maxLevelColor = Color(DecibelUtil.getDBColorInt(_maxDB));

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('峰值', '${_maxDB.toStringAsFixed(1)} dB', maxLevelColor),
                _buildInfoItem('当前', '${_currentDB.toStringAsFixed(1)} dB', Color(DecibelUtil.getDBColorInt(_currentDB))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 16, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(advice, style: TextStyle(color: Colors.grey[600], fontSize: 13))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      ],
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isRecording)
              ElevatedButton.icon(
                onPressed: _startRecording,
                icon: const Icon(Icons.mic),
                label: const Text('开始检测'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              )
            else
              ElevatedButton.icon(
                onPressed: _stopRecording,
                icon: const Icon(Icons.stop),
                label: const Text('停止检测'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            if (_isRecording) ...[
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _resetMax,
                icon: const Icon(Icons.refresh),
                label: const Text('重置峰值'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 半圆仪表盘绘制器
class _GaugePainter extends CustomPainter {
  final double angle;
  final Color color;
  final bool isActive;

  _GaugePainter({required this.angle, required this.color, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = math.min(size.width / 2 - 16, size.height - 16);
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 背景弧
    final bgPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, math.pi, math.pi, false, bgPaint);

    // 值弧
    if (isActive && angle > 0) {
      final valuePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round;

      final sweepAngle = (angle / 270.0) * math.pi;
      canvas.drawArc(rect, math.pi, sweepAngle.clamp(0.01, math.pi), false, valuePaint);
    }

    // 刻度标签
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const labels = ['0', '30', '60', '90', '120'];
    const labelAngles = [0.0, 0.25, 0.5, 0.75, 1.0];

    for (int i = 0; i < labels.length; i++) {
      final a = math.pi + labelAngles[i] * math.pi;
      final labelRadius = radius - 32;
      final x = center.dx + labelRadius * math.cos(a);
      final y = center.dy + labelRadius * math.sin(a);

      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(color: Colors.grey[500], fontSize: 11),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.color != color || oldDelegate.isActive != isActive;
}
