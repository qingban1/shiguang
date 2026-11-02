/// 足迹页个人中心本地设置
class AppSettings {
  AppSettings({
    this.notifyResonance = true,
    this.notifyFollow = true,
    this.notifyMailbox = true,
    this.showCityOnPosts = true,
    this.allowFollow = true,
    this.reduceMotion = false,
  });

  bool notifyResonance;
  bool notifyFollow;
  bool notifyMailbox;
  bool showCityOnPosts;
  bool allowFollow;
  bool reduceMotion;

  Map<String, dynamic> toJson() => {
        'notifyResonance': notifyResonance,
        'notifyFollow': notifyFollow,
        'notifyMailbox': notifyMailbox,
        'showCityOnPosts': showCityOnPosts,
        'allowFollow': allowFollow,
        'reduceMotion': reduceMotion,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      notifyResonance: json['notifyResonance'] as bool? ?? true,
      notifyFollow: json['notifyFollow'] as bool? ?? true,
      notifyMailbox: json['notifyMailbox'] as bool? ?? true,
      showCityOnPosts: json['showCityOnPosts'] as bool? ?? true,
      allowFollow: json['allowFollow'] as bool? ?? true,
      reduceMotion: json['reduceMotion'] as bool? ?? false,
    );
  }
}
