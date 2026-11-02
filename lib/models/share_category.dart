/// 分享内容品类：日常之外还可美食探店、自拍等
class ShareCategory {
  const ShareCategory({
    required this.id,
    required this.emoji,
    required this.label,
    required this.hint,
  });

  final String id;
  final String emoji;
  final String label;
  final String hint;

  String get display => '$emoji $label';

  Map<String, dynamic> toJson() => {
        'id': id,
        'emoji': emoji,
        'label': label,
        'hint': hint,
      };

  factory ShareCategory.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String? ?? 'daily';
    return ShareCategory.byId(id);
  }

  static const ShareCategory daily = ShareCategory(
    id: 'daily',
    emoji: '🌿',
    label: '日常碎片',
    hint: '写下一句给生活的心绪…',
  );

  static const ShareCategory food = ShareCategory(
    id: 'food',
    emoji: '🍜',
    label: '美食探店',
    hint: '记下这份味道、店名或探店心情…',
  );

  static const ShareCategory selfie = ShareCategory(
    id: 'selfie',
    emoji: '📷',
    label: '今日自拍',
    hint: '留下此刻的自己，无需滤镜以外的审视…',
  );

  static const ShareCategory scenery = ShareCategory(
    id: 'scenery',
    emoji: '🏞',
    label: '风景打卡',
    hint: '把眼前的光与风写进海岸…',
  );

  static const ShareCategory pet = ShareCategory(
    id: 'pet',
    emoji: '🐾',
    label: '毛孩瞬间',
    hint: '分享毛孩的一个可爱瞬间…',
  );

  static const List<ShareCategory> presets = [
    daily,
    food,
    selfie,
    scenery,
    pet,
  ];

  static ShareCategory byId(String id) {
    return presets.firstWhere(
      (c) => c.id == id,
      orElse: () => daily,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ShareCategory && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
