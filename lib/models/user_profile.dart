/// 社区用户资料（无私信通道）
class UserProfile {
  UserProfile({
    required this.id,
    required this.displayName,
    required this.bio,
    required this.city,
    required this.avatarUrl,
    this.initial = '',
  });

  static const String meId = 'me_local';

  final String id;
  String displayName;
  String bio;
  String city;
  String avatarUrl;
  String initial;

  bool get isMe => id == meId;

  String get avatarLetter {
    if (initial.isNotEmpty) return initial;
    if (displayName.isEmpty) return '拾';
    return String.fromCharCodes(displayName.runes.take(1));
  }

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? bio,
    String? city,
    String? avatarUrl,
    String? initial,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      initial: initial ?? this.initial,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'bio': bio,
        'city': city,
        'avatarUrl': avatarUrl,
        'initial': initial,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      displayName: json['displayName'] as String? ?? '拾岸旅人',
      bio: json['bio'] as String? ?? '',
      city: json['city'] as String? ?? '拾岸',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      initial: json['initial'] as String? ?? '',
    );
  }
}
