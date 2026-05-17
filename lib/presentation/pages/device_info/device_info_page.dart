/// Device Info Page
/// Author: ZF_Clark
/// Description: UI page for displaying device hardware and software information.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/utils/device_info_util.dart';
import '../../../app/config/app_config.dart';

/// 设备信息查看页面
/// 展示设备型号、系统版本、屏幕分辨率等硬件和软件信息
class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  DeviceInfoData? _deviceInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    try {
      final info = await DeviceInfoUtil.getDeviceInfo(context, appVersion: AppConfig.appVersion);
      if (mounted) {
        setState(() {
          _deviceInfo = info;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设备信息'),
        actions: [
          if (_deviceInfo != null)
            IconButton(
              icon: const Icon(Icons.copy_all),
              tooltip: '全部复制',
              onPressed: _copyAll,
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadDeviceInfo();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _deviceInfo == null
              ? const Center(child: Text('无法获取设备信息'))
              : _buildContent(),
    );
  }

  void _copyAll() {
    if (_deviceInfo == null) return;
    final infoList = _deviceInfo!.toInfoList();
    final text = infoList.map((item) => '${item['label']}: ${item['value']}').join('\n');
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已复制所有信息到剪贴板')),
    );
  }

  Widget _buildContent() {
    final theme = Theme.of(context);
    final infoList = _deviceInfo!.toInfoList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: infoList.length + 2, // + header + footer
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeader(theme);
        }
        if (index == infoList.length + 1) {
          return _buildFooter(theme);
        }
        return _buildInfoItem(infoList[index - 1], theme);
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.phone_android, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text('设备信息', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('应用版本 ${AppConfig.appVersion}', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(Map<String, String> item, ThemeData theme) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(item['label'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(item['value'] ?? '', style: TextStyle(color: Colors.grey[600])),
        trailing: IconButton(
          icon: Icon(Icons.copy, size: 18, color: Colors.grey[400]),
          onPressed: () {
            final text = '${item['label']}: ${item['value']}';
            Clipboard.setData(ClipboardData(text: text));
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('已复制: ${item['value']}')),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text('数据仅供参考', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
      ),
    );
  }
}
