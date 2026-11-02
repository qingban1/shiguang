import '../models/content_report.dart';

/// 发布前格式检查与不当内容过滤
class ContentFilter {
  ContentFilter._();

  static const int minLength = 2;
  static const int maxLength = 500;

  static const _blockedWords = <String>[
    '色情',
    '裸体',
    '约炮',
    '援交',
    '赌博',
    '毒品',
    '冰毒',
    '杀人',
    '自杀教程',
    '傻逼',
    '去死',
    '脑残',
    '滚蛋',
    '去死吧',
    '强奸',
    '卖淫',
    '代孕买卖',
    '枪支',
    '炸药',
    '发票代开',
    '刷单',
    '加微信领红包',
  ];

  static ContentCheckResult validatePostText(String raw) {
    return _validate(raw, emptyMsg: '请写下想分享的内容', max: maxLength);
  }

  /// 信箱短句同样走格式与敏感词检查
  static ContentCheckResult validateLetterText(String raw) {
    return _validate(
      raw,
      emptyMsg: '请写下想投递的句子',
      max: 120,
      min: 2,
    );
  }

  static ContentCheckResult _validate(
    String raw, {
    required String emptyMsg,
    required int max,
    int min = minLength,
  }) {
    final text = raw.trim();
    if (text.isEmpty) {
      return ContentCheckResult.reject(emptyMsg);
    }
    if (text.runes.length < min) {
      return const ContentCheckResult.reject('内容过短，请再写一句真实感受');
    }
    if (text.runes.length > max) {
      return ContentCheckResult.reject('内容请控制在 $max 字以内');
    }
    if (RegExp(r'(.)\1{8,}').hasMatch(text)) {
      return const ContentCheckResult.reject('检测到异常重复字符，请修改后再发布');
    }
    if (RegExp(r'(https?:\/\/|www\.)', caseSensitive: false).hasMatch(text) &&
        RegExp(r'(加微|领红包|刷单|代开)', caseSensitive: false).hasMatch(text)) {
      return const ContentCheckResult.reject('疑似垃圾引流内容，无法发布');
    }
    final hit = findBlockedWord(text);
    if (hit != null) {
      return const ContentCheckResult.reject('内容包含不当表述，请修改后重试');
    }
    return const ContentCheckResult.ok();
  }

  static String? findBlockedWord(String text) {
    final lower = text.toLowerCase();
    for (final w in _blockedWords) {
      if (lower.contains(w.toLowerCase())) return w;
    }
    return null;
  }

  /// 备注字段较宽松，但仍过滤极端词
  static ContentCheckResult validateReportNote(String raw) {
    final text = raw.trim();
    if (text.runes.length > 200) {
      return const ContentCheckResult.reject('补充说明请控制在 200 字以内');
    }
    final hit = findBlockedWord(text);
    if (hit != null) {
      return const ContentCheckResult.reject('补充说明含不当表述，请修改');
    }
    return const ContentCheckResult.ok();
  }
}
