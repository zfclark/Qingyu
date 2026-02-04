/// Settings Page
/// Author: ZF_Clark
/// Description: App settings page providing about dialog, usage guide, cache clearing functionality, and theme switching options
/// Last Modified: 2026/02/04
/// Version: V0.1
library;

import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../core/app_config.dart';
import '../../data/services/storage_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: ListView(
        children: [
          // App info section
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.build,
                      size: 40,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConfig.appName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '版本 ${AppConfig.appVersion}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConfig.copyright,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          // Settings options
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('关于'),
                  subtitle: const Text('应用信息和声明'),
                  onTap: () {
                    _showAboutDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.description),
                  title: const Text('使用说明'),
                  subtitle: const Text('工具使用指南'),
                  onTap: () {
                    _showUsageGuide(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_sweep),
                  title: const Text('清除缓存'),
                  subtitle: const Text('清除计算历史记录'),
                  onTap: () {
                    _clearCache(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('给我们评分'),
                  subtitle: const Text('如果喜欢，请给我们好评'),
                  onTap: () {
                    // 跳转到应用商店评分页面
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('感谢您的支持！')));
                  },
                ),
              ],
            ),
          ),

          // Theme settings
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('主题设置'),
                  subtitle: const Text('选择应用主题'),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 设置浅色主题
                            StorageService.saveThemeMode('light');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('主题已设置为浅色模式')),
                            );
                          },
                          child: const Text('浅色'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 设置深色主题
                            StorageService.saveThemeMode('dark');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('主题已设置为深色模式')),
                            );
                          },
                          child: const Text('深色'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // 设置跟随系统
                            StorageService.saveThemeMode('system');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('主题已设置为跟随系统')),
                            );
                          },
                          child: const Text('系统'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Personalization settings
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('个性化设置'),
                  subtitle: const Text('调整应用外观和行为'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.font_download),
                  title: const Text('字体大小'),
                  subtitle: const Text('调整应用字体大小'),
                  onTap: () {
                    _showFontSizeDialog(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.color_lens),
                  title: const Text('主题颜色'),
                  subtitle: const Text('自定义主题颜色'),
                  onTap: () {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('此功能即将推出')));
                  },
                ),
              ],
            ),
          ),

          // Data management
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.data_object),
                  title: const Text('数据管理'),
                  subtitle: const Text('导出/导入应用数据'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('导出数据'),
                  subtitle: const Text('将数据导出为JSON文件'),
                  onTap: () {
                    _exportData(context);
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.upload),
                  title: const Text('导入数据'),
                  subtitle: const Text('从JSON文件导入数据'),
                  onTap: () {
                    _importData(context);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// Show about dialog
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('关于清隅工具箱'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppConfig.appName} v${AppConfig.appVersion}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('清隅工具箱是一款轻量级、无广告的实用工具合集应用，提供多种常用工具，方便用户日常使用。'),
                const SizedBox(height: 16),
                const Text(' ${AppConfig.copyright} 保留所有权利'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// Show usage guide
  void _showUsageGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('使用说明'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('SHA256计算器使用方法：'),
                const SizedBox(height: 8),
                const Text('1. 在输入框中输入或粘贴文本'),
                const Text('2. 点击"计算SHA256"按钮'),
                const Text('3. 计算结果将显示在下方'),
                const Text('4. 点击"复制结果"按钮复制到剪贴板'),
                const SizedBox(height: 16),
                const Text('工具收藏方法：'),
                const SizedBox(height: 8),
                const Text('1. 在首页找到想要收藏的工具'),
                const Text('2. 点击工具卡片上的星标图标'),
                const Text('3. 收藏的工具会显示在"常用工具"区域'),
                const SizedBox(height: 16),
                const Text('搜索工具：'),
                const SizedBox(height: 8),
                const Text('1. 在首页顶部的搜索框中输入关键词'),
                const Text('2. 系统会自动过滤匹配的工具'),
                const SizedBox(height: 16),
                const Text('Web端快捷键：'),
                const SizedBox(height: 8),
                const Text('• Tab键：在工具间导航'),
                const Text('• Enter键：选择当前工具'),
                const Text('• Ctrl+F：快速搜索'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// Clear cache
  void _clearCache(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清除缓存'),
          content: const Text('确定要清除所有计算历史记录吗？此操作不可恢复。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                StorageService.clearCache();
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('缓存已清除')));
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  /// Show font size dialog
  void _showFontSizeDialog(BuildContext context) {
    final currentFontSize = StorageService.getFontSize();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('字体大小'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                title: const Text('小'),
                value: 'small',
                groupValue: currentFontSize,
                onChanged: (value) {
                  // 保存字体大小设置
                  StorageService.saveFontSize('small');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('字体大小已设置为小')));
                },
              ),
              RadioListTile(
                title: const Text('中'),
                value: 'medium',
                groupValue: currentFontSize,
                onChanged: (value) {
                  // 保存字体大小设置
                  StorageService.saveFontSize('medium');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('字体大小已设置为中')));
                },
              ),
              RadioListTile(
                title: const Text('大'),
                value: 'large',
                groupValue: currentFontSize,
                onChanged: (value) {
                  // 保存字体大小设置
                  StorageService.saveFontSize('large');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('字体大小已设置为大')));
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  /// Export data
  void _exportData(BuildContext context) {
    try {
      final data = StorageService.exportData();
      final jsonString = jsonEncode(data);

      // 创建一个临时文件并下载
      if (kIsWeb) {
        // Web端实现
        try {
          final blob = html.Blob([jsonString], 'application/json');
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.document.createElement('a') as html.AnchorElement
            ..href = url
            ..style.display = 'none'
            ..download =
                'qingyu_data_${DateTime.now().toString().substring(0, 10)}.json';
          html.document.body?.append(anchor);
          anchor.click();
          // 使用Future.delayed确保元素被正确移除
          Future.delayed(const Duration(milliseconds: 100), () {
            anchor.remove();
            html.Url.revokeObjectUrl(url);
          });
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('数据导出失败，请重试')));
          return;
        }
      } else {
        // 移动端实现（预留）
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('数据导出功能即将推出')));
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('数据已成功导出')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('数据导出失败，请重试')));
    }
  }

  /// Import data
  void _importData(BuildContext context) {
    try {
      if (kIsWeb) {
        // Web端实现
        try {
          final input =
              html.document.createElement('input') as html.InputElement
                ..type = 'file'
                ..accept = '.json';

          input.onChange.listen((event) async {
            if (input.files?.isNotEmpty ?? false) {
              final file = input.files![0];
              final reader = html.FileReader();

              reader.onLoad.listen((event) async {
                try {
                  final jsonString = reader.result as String;
                  final data = jsonDecode(jsonString);
                  await StorageService.importData(data);

                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('数据已成功导入')));
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('数据格式错误，请检查文件')));
                }
              });

              reader.readAsText(file);
            }
          });

          input.click();
        } catch (e) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('数据导入失败，请重试')));
        }
      } else {
        // 移动端实现（预留）
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('数据导入功能即将推出')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('数据导入失败，请重试')));
    }
  }
}
