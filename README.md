# 清隅

## 项目概述

清隅是一个集合了多种实用工具的开源项目，旨在为开发者及个人提供便捷高效的工具服务。以 Flutter 为框架，支持多平台运行，包括 Android、Web 等。

### 核心特性

- **🔐 哈希计算器**：支持 SHA1、SHA256、SHA512、MD5 等多种哈希算法，可计算文本的哈希值，并提供历史记录功能
- **📝 文本工具**：提供文本处理相关功能，包括大小写转换、空格处理、字符统计、Base64 编解码
- **🔄 单位转换**：支持长度、重量、温度、时间戳等各种单位之间的转换
- **📱 二维码生成**：将文本转换为二维码，方便快速分享信息
- **🧮 计算器**：基础四则运算功能

### 特色功能

- **📱 响应式设计**：适配不同屏幕尺寸，在手机、平板和桌面设备上均有良好表现
- **⭐ 工具收藏**：支持将常用工具添加到收藏夹，方便快速访问
- **🔧 个性化设置**：提供多种主题和字体选择，满足个性化需求
- **🌙 深色模式**：支持系统深色模式，提供舒适的视觉体验

---

## 技术架构

### 技术栈

- **前端框架**：Flutter 3.10+
- **开发语言**：Dart
- **状态管理**：StatefulWidget（原生状态管理）
- **本地存储**：shared_preferences
- **哈希计算**：crypto
- **二维码生成**：qr_flutter

### 项目架构

```text
lib/
├── main.dart                          # 应用入口
├── app/
│   ├── config/
│   │   ├── app_config.dart            # 应用配置
│   │   └── app_theme.dart             # 主题配置
│   └── routes/
│       └── app_routes.dart            # 路由配置（预留）
├── core/
│   ├── services/                      # 核心服务层
│   │   └── storage_service.dart       # 存储服务
│   └── utils/                         # 工具类层（纯逻辑，无UI）
│       ├── hash_util.dart             # 哈希计算工具
│       ├── text_util.dart             # 文本处理工具
│       ├── conversion_util.dart       # 单位转换工具
│       └── calculator_util.dart       # 计算器工具
├── data/
│   └── models/
│       └── hash_history_model.dart    # 数据模型
└── presentation/                      # 表现层（所有UI页面）
    ├── pages/                         # 页面目录
    │   ├── home/
    │   │   ├── home_page.dart         # 首页
    │   │   └── widgets/
    │   │       └── tool_card_widget.dart  # 工具卡片组件
    │   ├── hash/
    │   │   └── hash_calculator_page.dart  # 哈希计算器页面
    │   ├── calculator/
    │   │   └── calculator_page.dart   # 计算器页面
    │   ├── qr_code/
    │   │   └── qr_code_generator_page.dart  # 二维码生成页面
    │   ├── text_tools/
    │   │   └── text_tools_page.dart   # 文本工具页面
    │   ├── unit_converter/
    │   │   └── unit_converter_page.dart   # 单位转换页面
    │   └── settings/
    │       └── settings_page.dart     # 设置页面
    └── widgets/                       # 通用UI组件（预留）
```

---

## 安装指南

### 前提条件

- 安装 [Flutter SDK](https://docs.flutter.dev/get-started/install)（3.10 或更高版本）
- 安装 [Dart SDK](https://dart.dev/get-dart)
- 配置好相应平台的开发环境（Android Studio、Visual Studio 等）

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
    - **Android**：连接设备后运行 `flutter run`
    - **iOS**：在 macOS 上运行 `flutter run`
    - **Web**：运行 `flutter run -d chrome`（或其他浏览器）

---

## 使用说明

### 哈希计算器

1. 在输入框中输入或粘贴要计算哈希值的文本
2. 选择要使用的哈希算法（SHA1、SHA256、SHA512、MD5）
3. 点击「计算」按钮，系统会自动计算并显示哈希值
4. 点击「复制结果」按钮可将计算结果复制到剪贴板
5. 系统会自动保存计算历史，点击历史记录可快速复用之前的输入

### 文本工具

1. **大小写转换**：支持转大写、转小写、首字母大写
2. **空格处理**：去除空格、去除换行、去除所有空白
3. **字符统计**：查看字符数、单词数、行数等详细统计
4. **Base64**：文本与Base64编码之间的相互转换
5. **批量操作**：可组合多种操作一次性处理

### 单位转换

1. 选择转换类型（长度、重量、温度、时间戳）
2. 输入要转换的数值
3. 选择源单位和目标单位
4. 点击「转换」按钮查看结果

### 二维码生成

1. 在输入框中输入要转换为二维码的文本
2. 点击「生成二维码」按钮，系统会自动生成并显示二维码
3. 点击「复制输入文本」按钮可将输入文本复制到剪贴板

### 计算器

1. 在计算器界面输入数字和运算符
2. 点击「=」按钮获取结果
3. 支持基础四则运算（加、减、乘、除）

---

## 开发规范

### 代码风格

- 遵循 Flutter 官方推荐的代码风格
- 使用 `dart format` 格式化代码
- 使用 `flutter analyze` 进行静态分析

### 提交规范

- 提交信息应清晰明了，描述本次提交的主要内容
- 使用中文或英文编写提交信息
- 功能提交前确保代码通过基本测试

## 参与贡献

欢迎大家参与项目贡献！以下是贡献流程：

1. **Fork 本仓库**
2. **新建 Feature_xxx 分支**
3. **提交代码**
4. **新建 Pull Request**

### 贡献指南

- 确保代码符合项目架构设计
- 新功能应包含对应的工具类和页面（如适用）
- 更新相关文档
- 确保代码通过 Flutter 分析器检查

---

## 许可证

本项目采用 MIT 许可证，详情请参阅 [LICENSE](LICENSE) 文件。

---

## 联系方式

- 项目地址：<https://github.com/zfclark/qingyu>
- 问题反馈：<https://github.com/zfclark/qingyu/issues>

---

感谢您使用清隅工具箱！如果您有任何建议或问题，欢迎随时反馈。
