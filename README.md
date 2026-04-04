# 清隅

## 项目概述

清隅是一个功能丰富、界面美观的工具集合，旨在为开发者和个人用户提供便捷高效的日常工具服务。基于 Flutter 框架开发，支持多平台运行，包括 Android、Web 等平台，为用户提供便利的使用体验。

### 核心特性

**📝 文本处理**

- **文本工具**：大小写转换、空格处理、字符统计、文本替换
- **字数统计**：字符/单词/行数统计，阅读/朗读时间估算，支持多语言文本
- **文本对比**：行级差异对比，清晰显示新增/删除/修改内容，支持导出对比结果

**🔢 数据处理**

- **JSON工具**：格式化、验证、压缩、路径查询，支持复杂JSON结构
- **编码解码**：Base64、URL、HTML 编码解码，支持批量处理
- **进制转换**：二进制/八进制/十进制/十六进制互转，支持大数字处理
- **哈希计算**：SHA1、SHA256、SHA512、MD5 算法，支持文件和文本哈希
- **文件大小**：B/KB/MB/GB/TB 单位转换，支持自定义精度

**🧮 计算工具**

- **计算器**：基础四则运算 + 科学计算模式，支持复杂表达式
- **时间计算**：日期差计算、年龄测算、时间戳转换，支持多种日期格式
- **随机生成**：随机数/字符串生成、随机选择，支持自定义范围和规则

**💻 开发工具**

- **正则测试**：常用正则模式库、实时匹配验证，支持语法高亮
- **UUID生成**：UUID v1(时间戳)/v4(随机)，支持批量生成和格式定制
- **密码生成**：随机密码生成、强度评估，支持多种字符集组合
- **颜色转换**：HEX/RGB/HSL/HSV 格式互转，支持颜色预览和复制

**📱 实用工具**

- **二维码生成**：文本转二维码图片，支持自定义尺寸和颜色
- **时钟屏**：全屏时间显示，现代化翻页动画，支持多种主题
- **单位转换**：长度/重量/温度/时间等单位转换，覆盖日常生活常用单位

**🌐 网络工具**

- **Ping测试**：网络连通性测试（仅移动端），支持自定义参数
- **在线工具**：天气查询、新闻资讯、IP查询等（需网络连接）

### 特色功能

- **📱 响应式设计**：智能适配手机、平板、桌面设备，提供最佳显示效果
- **⭐ 工具收藏**：常用工具快速访问，支持自定义收藏列表
- **🔧 个性化设置**：多种主题和字体选择，支持自定义界面布局
- **🌙 深色模式**：支持系统深色模式，自动切换，保护眼睛
- **💾 数据持久化**：工具使用历史和配置自动保存，下次打开恢复状态
- **🔍 快速搜索**：支持工具名称和功能搜索，快速找到所需工具
- **📤 数据导出**：支持工具结果导出为文件，方便分享和保存

---

## 技术架构

### 技术栈

- **前端框架**：Flutter 3.10+
- **开发语言**：Dart
- **状态管理**：StatefulWidget（原生状态管理）
- **本地存储**：shared_preferences
- **哈希计算**：crypto
- **二维码生成**：qr_flutter
- **文件操作**：path_provider（移动端）
- **网络请求**：http（在线工具）

### 项目架构

```text
lib/
├── main.dart                          # 应用入口
├── app/
│   ├── config/
│   │   ├── app_config.dart            # 应用配置（工具分类）
│   │   └── app_theme.dart             # 主题配置
├── core/
│   ├── services/                      # 核心服务
│   │   ├── storage_service.dart       # 存储服务
│   │   ├── platform_service.dart      # 平台服务
│   │   └── search_service.dart        # 搜索服务
│   └── utils/                         # 工具类层
│       ├── hash_util.dart             # 哈希计算
│       ├── text_util.dart             # 文本处理
│       ├── conversion_util.dart       # 单位转换
│       ├── calculator_util.dart       # 计算器
│       ├── json_util.dart             # JSON工具
│       ├── color_util.dart             # 颜色转换
│       ├── number_base_util.dart      # 进制转换
│       ├── uuid_util.dart             # UUID生成
│       ├── password_util.dart         # 密码生成
│       ├── encoding_util.dart         # 编码解码
│       ├── regex_util.dart            # 正则测试
│       ├── time_calculator_util.dart  # 时间计算
│       ├── random_util.dart           # 随机生成
│       ├── word_count_util.dart       # 字数统计
│       ├── diff_util.dart             # 文本对比
│       ├── file_size_util.dart        # 文件大小
│       ├── timestamp_util.dart        # 时间戳
│       ├── responsive_util.dart       # 响应式布局
│       ├── data_export_util.dart      # 数据导出
│       ├── logger_util.dart           # 日志工具
│       └── network_util.dart          # 网络工具
├── data/
│   └── models/                        # 数据模型
└── presentation/                      # 表现层
    └── pages/
        ├── home/                      # 首页
        ├── hash/                      # 哈希计算
        ├── calculator/                # 计算器
        ├── qr_code/                   # 二维码
        ├── text_tools/                # 文本工具
        ├── unit_converter/            # 单位转换
        ├── json_tools/                # JSON工具
        ├── color_tools/               # 颜色转换
        ├── number_base_tools/         # 进制转换
        ├── uuid_tools/                # UUID生成
        ├── password_tools/            # 密码生成
        ├── encoding_tools/            # 编码解码
        ├── regex_tools/               # 正则测试
        ├── time_calculator/           # 时间计算
        ├── random_tools/              # 随机生成
        ├── word_count/                # 字数统计
        ├── diff_tools/                # 文本对比
        ├── file_size_tools/           # 文件大小
        ├── timestamp_tools/           # 时间戳转换
        ├── time_screen/               # 时钟屏
        ├── ping/                      # Ping测试
        ├── settings/                  # 设置
        ├── online/                    # 在线工具
        └── search/                    # 搜索
```

---

## 工具总览

| 分类         | 工具       | 说明                             |
| ------------ | ---------- | -------------------------------- |
| **生活便捷** | 文本工具   | 文本处理工具集，支持多种文本操作 |
|              | 字数统计   | 字符/词/行统计，阅读时间估算     |
|              | 文本对比   | 行级差异比较，清晰显示变更内容   |
|              | 时间计算   | 日期差计算、年龄测算             |
|              | 时间戳转换 | Unix时间戳与日期互转             |
|              | 随机生成   | 随机数/字符串/随机选择           |
| **数据处理** | JSON工具   | 格式化、验证、压缩、路径查询     |
|              | 编码解码   | Base64/URL/HTML 编码解码         |
|              | 进制转换   | 二/八/十/十六进制互转            |
|              | 哈希计算   | SHA1/SHA256/SHA512/MD5 算法      |
|              | 文件大小   | B/KB/MB/GB/TB 单位转换           |
| **开发工具** | 正则测试   | 正则表达式验证，常用模式库       |
|              | 计算器     | 基础四则运算 + 科学计算模式      |
|              | UUID生成   | UUID v1(时间戳)/v4(随机)         |
|              | 密码生成   | 随机密码生成、强度评估           |
|              | 颜色转换   | HEX/RGB/HSL/HSV 格式互转         |
| **实用工具** | 二维码     | 文本转二维码图片，支持自定义     |
|              | 时钟屏     | 全屏时间显示，现代化翻页动画     |
|              | 单位转换   | 长度/重量/温度/时间等单位转换    |
| **网络工具** | Ping测试   | 网络连通性测试（仅移动端）       |
|              | 在线工具   | 天气查询、新闻资讯、IP查询等     |

---

## 安装指南

### 前提条件

- 安装 [Flutter SDK](https://docs.flutter.dev/get-started/install)（3.10 或更高版本）
- 安装 [Dart SDK](https://dart.dev/get-dart)
- 配置好相应平台的开发环境（Android Studio、VS Code 等）

### 安装步骤

1. **克隆仓库**

    ```bash
    git clone https://github.com/zfclark/qingyu.git
    cd qingyu
    ```

2. **安装依赖**

    ```bash
    flutter pub get
    ```

3. **运行项目**
    - **Web**：`flutter run -d chrome`
    - **Android**：`flutter run`

4. **构建项目**
    - **Web**：`flutter build web`
    - **Android**：`flutter build apk`

---

## 开发规范

### 代码风格

- 遵循 Flutter 官方推荐的代码风格
- 使用 `dart format` 格式化代码
- 使用 `flutter analyze` 进行静态分析
- 保持代码简洁、清晰，添加必要的注释

### 命名规范

- **类名**：使用大驼峰命名法（PascalCase）
- **方法名**：使用小驼峰命名法（camelCase）
- **变量名**：使用小驼峰命名法（camelCase）
- **常量名**：使用全大写字母，下划线分隔（SNAKE_CASE）
- **文件名**：使用小写字母，下划线分隔（snake_case）

---

## 参与贡献

欢迎大家参与项目贡献！无论是功能开发、Bug 修复还是文档改进，都非常感谢您的支持。

### 贡献流程

1. **Fork 本仓库**
2. **新建分支**：`git checkout -b feature/your-feature-name`
3. **提交代码**：确保代码符合开发规范，添加必要的测试
4. **推送分支**：`git push origin feature/your-feature-name`
5. **新建 Pull Request**：描述清楚您的改动内容和目的

### 贡献指南

- 请确保您的代码符合项目的编码规范
- 提交 Pull Request 前，请运行 `flutter analyze` 确保没有错误
- 对于新功能，请添加相应的文档说明
- 对于 Bug 修复，请提供详细的问题描述和修复方案

---

## 许可证

本项目采用 MIT 许可证，详情请参阅 [LICENSE](LICENSE) 文件。

---

## 联系方式

- **项目地址**：<https://github.com/zfclark/qingyu>
- **问题反馈**：<https://github.com/zfclark/qingyu/issues>

---

感谢您使用清隅工具箱！如果您有任何建议或问题，欢迎随时反馈。
