import 'package:flutter_test/flutter_test.dart';
import 'package:qingyu/core/utils/pinyin_util.dart';

void main() {
  group('PinyinUtil.convert', () {
    test('空字符串返回空', () {
      expect(PinyinUtil.convert(''), equals(''));
    });

    test('单字转换', () {
      expect(PinyinUtil.convert('中'), equals('zhong1'));
    });

    test('多字转换', () {
      final result = PinyinUtil.convert('中国');
      expect(result, equals('zhong1 guo2'));
    });

    test('无分隔符', () {
      final result = PinyinUtil.convert('中国', separator: '');
      expect(result, equals('zhong1guo2'));
    });

    test('首字母大写', () {
      final result = PinyinUtil.convert('中国', capitalize: true);
      expect(result, equals('Zhong1 Guo2'));
    });

    test('移除音调数字', () {
      final result = PinyinUtil.convert('中国', keepToneNumbers: false);
      expect(result, equals('zhong guo'));
    });

    test('仅首字母', () {
      final result = PinyinUtil.convert('中国', initialOnly: true);
      expect(result, equals('Z G'));
    });

    test('混合中英文', () {
      final result = PinyinUtil.convert('Hello世界');
      // 非汉字逐字符添加，汉字转为拼音
      expect(result, contains('shi4'));
      expect(result, contains('jie4'));
    });

    test('非汉字字符保持原样', () {
      final result = PinyinUtil.convert('2024年');
      // 每个字符单独用空格连接: "2 0 2 4 nian2"
      expect(result, contains('nian2'));
    });
  });

  group('PinyinUtil.getInitials', () {
    test('获取首字母缩写', () {
      expect(PinyinUtil.getInitials('中国'), equals('ZG'));
    });

    test('空字符串', () {
      expect(PinyinUtil.getInitials(''), equals(''));
    });

    test('首字母大写缩写', () {
      final result = PinyinUtil.getInitials('世界');
      // 世→shi4→S, 界→jie4→J
      expect(result, equals('SJ'));
    });
  });

  group('PinyinUtil.isChinese', () {
    test('汉字返回true', () {
      expect(PinyinUtil.isChinese('中'), isTrue);
      expect(PinyinUtil.isChinese('国'), isTrue);
    });

    test('非汉字返回false', () {
      expect(PinyinUtil.isChinese('a'), isFalse);
      expect(PinyinUtil.isChinese('1'), isFalse);
      expect(PinyinUtil.isChinese('!'), isFalse);
    });

    test('空字符返回false', () {
      expect(PinyinUtil.isChinese(''), isFalse);
    });
  });

  group('PinyinUtil.countChineseChars', () {
    test('纯文本', () {
      expect(PinyinUtil.countChineseChars('中国'), equals(2));
    });

    test('混合文本', () {
      expect(PinyinUtil.countChineseChars('Hello世界'), equals(2));
    });

    test('无汉字', () {
      expect(PinyinUtil.countChineseChars('Hello123'), equals(0));
    });

    test('空字符串', () {
      expect(PinyinUtil.countChineseChars(''), equals(0));
    });
  });

  group('PinyinUtil.hasChinese', () {
    test('包含汉字', () {
      expect(PinyinUtil.hasChinese('中文'), isTrue);
    });

    test('不包含汉字', () {
      expect(PinyinUtil.hasChinese('English'), isFalse);
    });

    test('空字符串', () {
      expect(PinyinUtil.hasChinese(''), isFalse);
    });
  });
}
