/// Word Count Utility
/// Author: ZF_Clark
/// Description: Provides text statistics and counting utilities including characters, words, lines, and reading time estimation. Pure utility class without UI dependencies.
/// Last Modified: 2026/04/04
library;

/// 字数统计工具类
/// 提供文本统计功能
class WordCountUtil {
  // ==================== 基础统计 ====================

  /// 统计字符数（不含空格）
  ///
  /// [text] 输入文本
  /// 返回字符数
  static int countCharacters(String text) {
    return text.replaceAll(RegExp(r'\s'), '').length;
  }

  /// 统计字符数（含空格）
  ///
  /// [text] 输入文本
  /// 返回字符数
  static int countAllCharacters(String text) {
    return text.length;
  }

  /// 统计单词数
  ///
  /// [text] 输入文本
  /// 返回单词数
  static int countWords(String text) {
    if (text.isEmpty) return 0;
    final words = text.trim().split(RegExp(r'[\s\u3000]+'));
    return words.where((w) => w.isNotEmpty).length;
  }

  /// 统计行数
  ///
  /// [text] 输入文本
  /// 返回行数
  static int countLines(String text) {
    if (text.isEmpty) return 0;
    return text.split('\n').length;
  }

  /// 统计段落数
  ///
  /// [text] 输入文本
  /// 返回段落数（以空行分隔）
  static int countParagraphs(String text) {
    if (text.isEmpty) return 0;
    final paragraphs = text.split(RegExp(r'\n\s*\n'));
    return paragraphs.where((p) => p.trim().isNotEmpty).length;
  }

  /// 统计句子数
  ///
  /// [text] 输入文本
  /// 返回句子数
  static int countSentences(String text) {
    if (text.isEmpty) return 0;
    final sentences = text.split(RegExp(r'[.!?。！？]+'));
    return sentences.where((s) => s.trim().isNotEmpty).length;
  }

  // ==================== 详细统计 ====================

  /// 完整统计
  ///
  /// [text] 输入文本
  /// 返回完整统计结果Map
  static Map<String, int> getFullStats(String text) {
    if (text.isEmpty) {
      return {
        'characters': 0,
        'charactersNoSpaces': 0,
        'words': 0,
        'lines': 0,
        'paragraphs': 0,
        'sentences': 0,
        'chineseChars': 0,
        'englishWords': 0,
        'numbers': 0,
        'punctuations': 0,
      };
    }

    return {
      'characters': countAllCharacters(text),
      'charactersNoSpaces': countCharacters(text),
      'words': countWords(text),
      'lines': countLines(text),
      'paragraphs': countParagraphs(text),
      'sentences': countSentences(text),
      'chineseChars': _countChineseChars(text),
      'englishWords': _countEnglishWords(text),
      'numbers': _countNumbers(text),
      'punctuations': _countPuncts(text),
    };
  }

  /// 统计中文字符
  static int _countChineseChars(String text) {
    final chinese = RegExp(r'[\u4e00-\u9fa5]');
    return chinese.allMatches(text).length;
  }

  /// 统计英文单词
  static int _countEnglishWords(String text) {
    final english = RegExp(r'[a-zA-Z]+');
    return english.allMatches(text).length;
  }

  /// 统计数字
  static int _countNumbers(String text) {
    final numbers = RegExp(r'\d+');
    return numbers.allMatches(text).length;
  }

  /// 统计标点符号
  static int _countPuncts(String text) {
    final puncts = RegExp(
      r'[!@#$%^&*()_+\-=\[\]{}|;:,\x27.<>?/`~\\]+|[.!?\u3001\uff01\uff1f]+',
    );
    return puncts.allMatches(text).length;
  }

  // ==================== 估算功能 ====================

  /// 估算阅读时间（中文）
  ///
  /// [text] 输入文本
  /// [speed] 阅读速度（字/分钟）
  /// 返回阅读时间（分钟）
  static int estimateReadingTime(String text, {int speed = 200}) {
    final chineseChars = _countChineseChars(text);
    final englishWords = _countEnglishWords(text);
    final totalChars = chineseChars + englishWords;
    return (totalChars / speed).ceil();
  }

  /// 估算阅读时间（英文）
  ///
  /// [text] 输入文本
  /// [wpm] 每分钟单词数
  /// 返回阅读时间（分钟）
  static int estimateReadingTimeEn(String text, {int wpm = 200}) {
    final words = countWords(text);
    return (words / wpm).ceil();
  }

  /// 估算语音朗读时间（字数/分钟）
  ///
  /// [text] 输入文本
  /// [speed] 朗读速度（字/分钟），默认150
  /// 返回朗读时间（秒）
  static int estimateSpeakingTime(String text, {int speed = 150}) {
    final chars = countCharacters(text);
    return ((chars / speed) * 60).ceil();
  }

  // ==================== 格式化输出 ====================

  /// 获取格式化统计报告
  ///
  /// [text] 输入文本
  /// 返回统计报告字符串
  static String getReport(String text) {
    final stats = getFullStats(text);
    final readTime = estimateReadingTime(text);
    final speakTime = estimateSpeakingTime(text);

    return '''
📊 文本统计报告
━━━━━━━━━━━━━━
字符数（含空格）：${stats['characters']}
字符数（不含空格）：${stats['charactersNoSpaces']}
中文字符：${stats['chineseChars']}
英文字符：${stats['englishWords']}
━━━━━━━━━━━━━━
单词数：${stats['words']}
数字个数：${stats['numbers']}
━━━━━━━━━━━━━━
行数：${stats['lines']}
段落数：${stats['paragraphs']}
句子数：${stats['sentences']}
━━━━━━━━━━━━━━
估算阅读时间：约 $readTime 分钟
估算朗读时间：约 ${(speakTime / 60).ceil()} 分钟
''';
  }
}
