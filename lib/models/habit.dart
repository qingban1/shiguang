/// 7 日连载微习惯
class HabitProgress {
  const HabitProgress({
    required this.title,
    required this.doneDays,
    required this.totalDays,
    required this.dayImageUrls,
  });

  final String title;
  final int doneDays;
  final int totalDays;
  final List<String> dayImageUrls;

  String get badge => '进行中 ($doneDays/$totalDays)';
}

/// 社区微光画卷四宫格
class CollageItem {
  const CollageItem({
    required this.id,
    required this.authorInitial,
    required this.authorLabel,
    required this.caption,
    required this.imageUrls,
  });

  final String id;
  final String authorInitial;
  final String authorLabel;
  final String caption;
  final List<String> imageUrls;
}
