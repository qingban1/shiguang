import 'dart:convert';

class AuthAccount {
  AuthAccount({
    required this.id,
    required this.account,
    required this.passwordHash,
    required this.displayName,
    this.city = '杭州',
    this.bio = '记录微小的生活，感知同频的呼吸。',
    this.avatarUrl = '',
    this.agreedTermsAt,
    this.verifiedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String account;
  String passwordHash;
  String displayName;
  String city;
  String bio;
  String avatarUrl;
  DateTime? agreedTermsAt;
  DateTime? verifiedAt;
  final DateTime createdAt;

  static String hashPassword(String raw) {
    return base64Encode(utf8.encode('拾岸微光::$raw'));
  }

  bool matchesPassword(String raw) => passwordHash == hashPassword(raw);

  String get maskedAccount {
    final a = account.trim();
    if (a.contains('@') && a.length > 4) {
      final at = a.indexOf('@');
      final name = a.substring(0, at);
      final domain = a.substring(at);
      if (name.length <= 2) return '${name[0]}***$domain';
      return '${name.substring(0, 2)}***$domain';
    }
    if (a.length >= 7) {
      return '${a.substring(0, 3)}****${a.substring(a.length - 4)}';
    }
    return a;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'account': account,
        'passwordHash': passwordHash,
        'displayName': displayName,
        'city': city,
        'bio': bio,
        'avatarUrl': avatarUrl,
        'agreedTermsAt': agreedTermsAt?.toIso8601String(),
        'verifiedAt': verifiedAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory AuthAccount.fromJson(Map<String, dynamic> json) {
    return AuthAccount(
      id: json['id'] as String,
      account: json['account'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '拾岸旅人',
      city: json['city'] as String? ?? '杭州',
      bio: json['bio'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? '',
      agreedTermsAt: DateTime.tryParse(json['agreedTermsAt'] as String? ?? ''),
      verifiedAt: DateTime.tryParse(json['verifiedAt'] as String? ?? ''),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

class AuthSession {
  AuthSession({
    required this.accountId,
    required this.issuedAt,
    required this.expiresAt,
  });

  final String accountId;
  final DateTime issuedAt;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'issuedAt': issuedAt.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      accountId: json['accountId'] as String,
      issuedAt: DateTime.tryParse(json['issuedAt'] as String? ?? '') ??
          DateTime.now(),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}

enum VerifyPurpose { register, reset }

class PendingVerifyCode {
  PendingVerifyCode({
    required this.account,
    required this.code,
    required this.purpose,
    required this.expiresAt,
  });

  final String account;
  final String code;
  final VerifyPurpose purpose;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'account': account,
        'code': code,
        'purpose': purpose.name,
        'expiresAt': expiresAt.toIso8601String(),
      };

  factory PendingVerifyCode.fromJson(Map<String, dynamic> json) {
    return PendingVerifyCode(
      account: json['account'] as String? ?? '',
      code: json['code'] as String? ?? '',
      purpose: VerifyPurpose.values.firstWhere(
        (e) => e.name == json['purpose'],
        orElse: () => VerifyPurpose.register,
      ),
      expiresAt: DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }
}
