/// 同频微状态标签（单选）
class MoodTag {
  const MoodTag({
    required this.id,
    required this.emoji,
    required this.label,
  });

  final String id;
  final String emoji;
  final String label;

  String get display => '$emoji $label';

  Map<String, dynamic> toJson() => {
        'id': id,
        'emoji': emoji,
        'label': label,
      };

  factory MoodTag.fromJson(Map<String, dynamic> json) {
    return MoodTag(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      label: json['label'] as String,
    );
  }

  static const List<MoodTag> presets = [
    MoodTag(id: 'coffee', emoji: '☕️', label: '喝杯咖啡'),
    MoodTag(id: 'sky', emoji: '☁️', label: '放空看天'),
    MoodTag(id: 'book', emoji: '📖', label: '翻两页书'),
    MoodTag(id: 'walk', emoji: '🚶', label: '慢行漫步'),
    MoodTag(id: 'cook', emoji: '🍳', label: '认真做饭'),
  ];

  static MoodTag byId(String id) {
    return presets.firstWhere(
      (t) => t.id == id,
      orElse: () => presets.first,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MoodTag && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
