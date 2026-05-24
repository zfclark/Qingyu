/// Lorem Ipsum Utility
/// Author: ZF_Clark
/// Description: Provides placeholder text generation (Lorem Ipsum and Chinese Lorem). Supports word, sentence, and paragraph generation with configurable counts.
/// Last Modified: 2026/05/24
library;

import 'dart:math';

/// Lorem 占位文本生成工具类
/// 提供英文和中文占位文本的生成功能
class LoremUtil {
  static final Random _random = Random();

  /// 经典 Lorem Ipsum 词库
  static const List<String> _loremWords = [
    'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur',
    'adipiscing', 'elit', 'sed', 'do', 'eiusmod', 'tempor',
    'incididunt', 'ut', 'labore', 'et', 'dolore', 'magna',
    'aliqua', 'enim', 'ad', 'minim', 'veniam', 'quis',
    'nostrud', 'exercitation', 'ullamco', 'laboris', 'nisi',
    'aliquip', 'ex', 'ea', 'commodo', 'consequat', 'duis',
    'aute', 'irure', 'in', 'reprehenderit', 'voluptate',
    'velit', 'esse', 'cillum', 'fugiat', 'nulla', 'pariatur',
    'excepteur', 'sint', 'occaecat', 'cupidatat', 'non',
    'proident', 'sunt', 'culpa', 'qui', 'officia', 'deserunt',
    'mollit', 'anim', 'id', 'est', 'laborum',
  ];

  /// 中文常用字词库
  static const List<String> _chineseWords = [
    '的', '一', '是', '在', '不', '了', '有', '和', '人', '这',
    '中', '大', '为', '上', '个', '国', '我', '以', '要', '他',
    '时', '来', '用', '们', '生', '到', '作', '地', '于', '出',
    '就', '分', '对', '成', '会', '可', '主', '发', '年', '动',
    '同', '工', '也', '能', '下', '过', '子', '说', '产', '种',
    '面', '而', '方', '后', '多', '定', '行', '学', '法', '所',
    '民', '得', '经', '十', '三', '之', '进', '着', '等', '部',
    '度', '家', '电', '力', '里', '如', '水', '化', '高', '自',
  ];

  /// 生成英文单词
  ///
  /// [count] 单词数量
  /// 返回由随机 Lorem 单词组成的字符串
  static String generateWords(int count) {
    if (count <= 0) return '';
    final words = List.generate(
      count,
      (_) => _loremWords[_random.nextInt(_loremWords.length)],
    );
    // 首字母大写
    if (words.isNotEmpty) {
      words[0] = _capitalize(words[0]);
    }
    return words.join(' ');
  }

  /// 生成英文句子
  ///
  /// [count] 句子数量
  /// 返回由随机句子组成的字符串
  static String generateSentences(int count) {
    if (count <= 0) return '';
    final sentences = List.generate(count, (_) {
      final wordCount = 5 + _random.nextInt(11); // 5-15 个单词
      final words = List.generate(
        wordCount,
        (_) => _loremWords[_random.nextInt(_loremWords.length)],
      );
      words[0] = _capitalize(words[0]);
      return '${words.join(' ')}.';
    });
    return sentences.join(' ');
  }

  /// 生成英文段落
  ///
  /// [count] 段落数量
  /// 返回由随机段落组成的字符串
  static String generateParagraphs(int count) {
    if (count <= 0) return '';
    final paragraphs = List.generate(count, (_) {
      final sentenceCount = 3 + _random.nextInt(5); // 3-7 个句子
      return generateSentences(sentenceCount);
    });
    return paragraphs.join('\n\n');
  }

  /// 生成中文单词
  ///
  /// [count] 单词数量
  /// 返回由随机中文字符组成的字符串
  static String generateChineseWords(int count) {
    if (count <= 0) return '';
    final words = List.generate(
      count,
      (_) => _chineseWords[_random.nextInt(_chineseWords.length)],
    );
    return words.join('');
  }

  /// 生成中文句子
  ///
  /// [count] 句子数量
  /// 返回由随机中文句子组成的字符串
  static String generateChineseSentences(int count) {
    if (count <= 0) return '';
    final punctuation = ['，', '。', '；', '、', '！', '？'];
    final sentences = List.generate(count, (_) {
      final charCount = 5 + _random.nextInt(11); // 5-15 个字
      final buffer = StringBuffer();
      for (int i = 0; i < charCount; i++) {
        buffer.write(_chineseWords[_random.nextInt(_chineseWords.length)]);
        if (i > 0 && i < charCount - 1 && _random.nextInt(5) == 0) {
          buffer.write(punctuation[_random.nextInt(2)]); // 只用逗号或顿号
        }
      }
      buffer.write(punctuation[1 + _random.nextInt(5)]); // 句末标点
      return buffer.toString();
    });
    return sentences.join('');
  }

  /// 生成中文段落
  ///
  /// [count] 段落数量
  /// 返回由随机中文段落组成的字符串
  static String generateChineseParagraphs(int count) {
    if (count <= 0) return '';
    final paragraphs = List.generate(count, (_) {
      final sentenceCount = 3 + _random.nextInt(5); // 3-7 个句子
      return generateChineseSentences(sentenceCount);
    });
    return paragraphs.join('\n\n');
  }

  /// 首字母大写
  static String _capitalize(String word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1);
  }
}
