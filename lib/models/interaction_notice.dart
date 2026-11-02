import 'reaction_type.dart';

enum NoticeKind { follow, reaction }

/// 互动回响：仅非文字善意通知（无私信）
class InteractionNotice {
  InteractionNotice({
    required this.id,
    required this.kind,
    required this.actorId,
    required this.actorName,
    required this.actorAvatarUrl,
    required this.createdAt,
    this.reaction,
    this.postTitle,
    this.read = false,
  });

  final String id;
  final NoticeKind kind;
  final String actorId;
  final String actorName;
  final String actorAvatarUrl;
  final DateTime createdAt;
  final ReactionType? reaction;
  final String? postTitle;
  bool read;

  String get body {
    switch (kind) {
      case NoticeKind.follow:
        return '@$actorName 关注了你';
      case NoticeKind.reaction:
        final emoji = reaction?.emoji ?? '✨';
        final label = reaction?.label ?? '治愈';
        final title = postTitle ?? '你的微光';
        return '@$actorName 给你的《$title》送上了一份 [$emoji $label]';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'actorId': actorId,
        'actorName': actorName,
        'actorAvatarUrl': actorAvatarUrl,
        'createdAt': createdAt.toIso8601String(),
        'reaction': reaction?.name,
        'postTitle': postTitle,
        'read': read,
      };

  factory InteractionNotice.fromJson(Map<String, dynamic> json) {
    final kindName = json['kind'] as String? ?? 'follow';
    final kind = NoticeKind.values.firstWhere(
      (e) => e.name == kindName,
      orElse: () => NoticeKind.follow,
    );
    ReactionType? reaction;
    final r = json['reaction'] as String?;
    if (r != null) {
      reaction = ReactionTypeX.fromName(r);
    }
    return InteractionNotice(
      id: json['id'] as String,
      kind: kind,
      actorId: json['actorId'] as String,
      actorName: json['actorName'] as String? ?? '拾岸旅人',
      actorAvatarUrl: json['actorAvatarUrl'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      reaction: reaction,
      postTitle: json['postTitle'] as String?,
      read: json['read'] as bool? ?? false,
    );
  }
}
