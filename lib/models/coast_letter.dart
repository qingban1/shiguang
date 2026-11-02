/// 海岸信封：实景照片 + 温暖短句（匿名，无私信）
class CoastLetter {
  CoastLetter({
    required this.id,
    required this.photoUrl,
    required this.sentence,
    required this.stampLabel,
    required this.city,
    required this.createdAt,
    required this.authorAlias,
    this.authorId = '',
    this.thankCount = 0,
    this.isMine = false,
  });

  final String id;
  final String photoUrl;
  final String sentence;
  final String stampLabel;
  final String city;
  final DateTime createdAt;
  final String authorAlias;
  final String authorId;
  final bool isMine;
  int thankCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'photoUrl': photoUrl,
        'sentence': sentence,
        'stampLabel': stampLabel,
        'city': city,
        'createdAt': createdAt.toIso8601String(),
        'authorAlias': authorAlias,
        'authorId': authorId,
        'thankCount': thankCount,
        'isMine': isMine,
      };

  factory CoastLetter.fromJson(Map<String, dynamic> json) {
    return CoastLetter(
      id: json['id'] as String,
      photoUrl: json['photoUrl'] as String,
      sentence: json['sentence'] as String,
      stampLabel: json['stampLabel'] as String? ?? '',
      city: json['city'] as String? ?? '拾岸',
      createdAt: DateTime.parse(json['createdAt'] as String),
      authorAlias: json['authorAlias'] as String? ?? '远方旅人',
      authorId: json['authorId'] as String? ?? '',
      thankCount: json['thankCount'] as int? ?? 0,
      isMine: json['isMine'] as bool? ?? false,
    );
  }

  CoastLetter copyWith({
    String? id,
    String? photoUrl,
    String? sentence,
    String? stampLabel,
    String? city,
    DateTime? createdAt,
    String? authorAlias,
    String? authorId,
    int? thankCount,
    bool? isMine,
  }) {
    return CoastLetter(
      id: id ?? this.id,
      photoUrl: photoUrl ?? this.photoUrl,
      sentence: sentence ?? this.sentence,
      stampLabel: stampLabel ?? this.stampLabel,
      city: city ?? this.city,
      createdAt: createdAt ?? this.createdAt,
      authorAlias: authorAlias ?? this.authorAlias,
      authorId: authorId ?? this.authorId,
      thankCount: thankCount ?? this.thankCount,
      isMine: isMine ?? this.isMine,
    );
  }
}

/// 当日一投一拆状态
class MailboxDayState {
  MailboxDayState({
    required this.dateKey,
    this.hasSent = false,
    this.hasOpened = false,
    this.sentLetterId,
    this.openedLetterId,
    this.hasThanked = false,
  });

  final String dateKey;
  bool hasSent;
  bool hasOpened;
  String? sentLetterId;
  String? openedLetterId;
  bool hasThanked;

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'hasSent': hasSent,
        'hasOpened': hasOpened,
        'sentLetterId': sentLetterId,
        'openedLetterId': openedLetterId,
        'hasThanked': hasThanked,
      };

  factory MailboxDayState.fromJson(Map<String, dynamic> json) {
    return MailboxDayState(
      dateKey: json['dateKey'] as String,
      hasSent: json['hasSent'] as bool? ?? false,
      hasOpened: json['hasOpened'] as bool? ?? false,
      sentLetterId: json['sentLetterId'] as String?,
      openedLetterId: json['openedLetterId'] as String?,
      hasThanked: json['hasThanked'] as bool? ?? false,
    );
  }

  static String todayKey([DateTime? now]) {
    final n = now ?? DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$d';
  }
}
