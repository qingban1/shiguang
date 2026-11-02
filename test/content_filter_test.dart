import 'package:flutter_test/flutter_test.dart';
import 'package:glimmer_coast/data/content_filter.dart';

void main() {
  group('ContentFilter.validatePostText', () {
    test('rejects empty', () {
      final r = ContentFilter.validatePostText('   ');
      expect(r.ok, isFalse);
    });

    test('rejects short text', () {
      final r = ContentFilter.validatePostText('一');
      expect(r.ok, isFalse);
    });

    test('rejects blocked words', () {
      final r = ContentFilter.validatePostText('今天去赌博真开心');
      expect(r.ok, isFalse);
    });

    test('accepts normal post', () {
      final r = ContentFilter.validatePostText('清晨手冲一杯咖啡，慢下来。');
      expect(r.ok, isTrue);
    });

    test('rejects oversized text', () {
      final r = ContentFilter.validatePostText('啊' * 501);
      expect(r.ok, isFalse);
    });
  });

  group('ContentFilter.validateLetterText', () {
    test('rejects letter over 120 chars', () {
      final r = ContentFilter.validateLetterText('光' * 121);
      expect(r.ok, isFalse);
    });

    test('accepts short letter', () {
      final r = ContentFilter.validateLetterText('愿你被晚风温柔接住。');
      expect(r.ok, isTrue);
    });
  });
}
