import 'mood_tag.dart';
import 'reaction_type.dart';
import 'share_category.dart';

/// 微光动态（拍立得双面卡片）
class Post {
  Post({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.body,
    required this.memoBack,
    required this.imageUrl,
    required this.mood,
    required this.stampLabel,
    required this.city,
    required this.createdAt,
    required this.healCount,
    required this.cheerCount,
    required this.luckCount,
    required this.hugCount,
    this.category = ShareCategory.daily,
    this.memoNo = 0,
    this.isMine = false,
    Set<String>? myReactions,
  }) : myReactions = myReactions ?? <String>{};

  final String id;
  final String authorId;
  final String authorName;
  final String body;
  final String memoBack;
  final String imageUrl;
  final MoodTag mood;
  final ShareCategory category;
  final String stampLabel;
  final String city;
  final DateTime createdAt;
  final int memoNo;
  final bool isMine;

  int healCount;
  int cheerCount;
  int luckCount;
  int hugCount;
  Set<String> myReactions;

  int countOf(ReactionType type) {
    switch (type) {
      case ReactionType.heal:
        return healCount;
      case ReactionType.cheer:
        return cheerCount;
      case ReactionType.luck:
        return luckCount;
      case ReactionType.hug:
        return hugCount;
    }
  }

  void setCount(ReactionType type, int value) {
    switch (type) {
      case ReactionType.heal:
        healCount = value;
      case ReactionType.cheer:
        cheerCount = value;
      case ReactionType.luck:
        luckCount = value;
      case ReactionType.hug:
        hugCount = value;
    }
  }

  int get totalResonance => healCount + cheerCount + luckCount + hugCount;

  bool hasReacted(ReactionType type) => myReactions.contains(type.name);

  void toggleReaction(ReactionType type) {
    if (hasReacted(type)) {
      myReactions.remove(type.name);
      setCount(type, (countOf(type) - 1).clamp(0, 999999));
    } else {
      myReactions.add(type.name);
      setCount(type, countOf(type) + 1);
    }
  }

  String relativeTimeLabel([DateTime? now]) {
    final n = now ?? DateTime.now();
    final diff = n.difference(createdAt);
    if (diff.inMinutes < 1) return '刚刚';
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    if (diff.inDays < 7) return '${diff.inDays}天前';
    return '${createdAt.month}.${createdAt.day.toString().padLeft(2, '0')}';
  }

  String drawerDateLabel() {
    final m = createdAt.month.toString().padLeft(2, '0');
    final d = createdAt.day.toString().padLeft(2, '0');
    return '$m.$d';
  }

  Post copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? body,
    String? memoBack,
    String? imageUrl,
    MoodTag? mood,
    ShareCategory? category,
    String? stampLabel,
    String? city,
    DateTime? createdAt,
    int? memoNo,
    bool? isMine,
    int? healCount,
    int? cheerCount,
    int? luckCount,
    int? hugCount,
    Set<String>? myReactions,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      body: body ?? this.body,
      memoBack: memoBack ?? this.memoBack,
      imageUrl: imageUrl ?? this.imageUrl,
      mood: mood ?? this.mood,
      category: category ?? this.category,
      stampLabel: stampLabel ?? this.stampLabel,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
      memoNo: memoNo ?? this.memoNo,
      isMine: isMine ?? this.isMine,
      healCount: healCount ?? this.healCount,
      cheerCount: cheerCount ?? this.cheerCount,
      luckCount: luckCount ?? this.luckCount,
      hugCount: hugCount ?? this.hugCount,
      myReactions: myReactions ?? Set<String>.from(this.myReactions),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorId': authorId,
        'authorName': authorName,
        'body': body,
        'memoBack': memoBack,
        'imageUrl': imageUrl,
        'mood': mood.toJson(),
        'category': category.toJson(),
        'stampLabel': stampLabel,
        'city': city,
        'createdAt': createdAt.toIso8601String(),
        'memoNo': memoNo,
        'isMine': isMine,
        'healCount': healCount,
        'cheerCount': cheerCount,
        'luckCount': luckCount,
        'hugCount': hugCount,
        'myReactions': myReactions.toList(),
      };

  factory Post.fromJson(Map<String, dynamic> json) {
    ShareCategory category = ShareCategory.daily;
    if (json['category'] is Map) {
      category = ShareCategory.fromJson(
        Map<String, dynamic>.from(json['category'] as Map),
      );
    } else if (json['category'] is String) {
      category = ShareCategory.byId(json['category'] as String);
    }

    return Post(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String? ?? '拾岸旅人',
      body: json['body'] as String,
      memoBack: json['memoBack'] as String? ?? json['body'] as String,
      imageUrl: json['imageUrl'] as String,
      mood: MoodTag.fromJson(Map<String, dynamic>.from(json['mood'] as Map)),
      category: category,
      stampLabel: json['stampLabel'] as String? ?? '',
      city: json['city'] as String? ?? '拾岸',
      createdAt: DateTime.parse(json['createdAt'] as String),
      memoNo: json['memoNo'] as int? ?? 0,
      isMine: json['isMine'] as bool? ?? false,
      healCount: json['healCount'] as int? ?? 0,
      cheerCount: json['cheerCount'] as int? ?? 0,
      luckCount: json['luckCount'] as int? ?? 0,
      hugCount: json['hugCount'] as int? ?? 0,
      myReactions: ((json['myReactions'] as List?) ?? const [])
          .map((e) => e.toString())
          .toSet(),
    );
  }
}
