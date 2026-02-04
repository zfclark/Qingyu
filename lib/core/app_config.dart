/// App configuration constants
/// Author: ZF_Clark
/// Description: Provides global configuration values for the application.
/// Last Modified: 2026/02/04
/// Version: V0.1
library;

class AppConfig {
  /// App name
  static const String appName = '清隅';

  /// App version
  static const String appVersion = '0.1';

  /// Copyright information
  static const String copyright = '© 2026 ZF-Clark';

  /// Cache key for hash history
  static const String hashHistoryKey = 'hash_history';

  /// Cache key for favorite tools
  static const String favoriteToolsKey = 'favorite_tools';

  /// Cache key for theme mode
  static const String themeModeKey = 'theme_mode';

  /// Cache key for font size
  static const String fontSizeKey = 'font_size';

  /// Maximum history records to store
  static const int maxHistoryRecords = 50;
}
