import '../models/habit.dart';
import '../models/mood_tag.dart';
import '../models/post.dart';
import '../models/share_category.dart';
import '../models/user_profile.dart';

/// 预设相纸（网络图，按分享品类分组）
class PhotoPresets {
  PhotoPresets._();

  static const List<String> daily = [
    'https://images.unsplash.com/photo-1518495973542-4542c06a5843?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=800&q=80',
  ];

  static const List<String> food = [
    'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1414235077428-338989a2e8c0?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80',
  ];

  static const List<String> selfie = [
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=800&q=80',
  ];

  static const List<String> scenery = [
    'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1426604966848-d7adac402bff?auto=format&fit=crop&w=800&q=80',
  ];

  static const List<String> pet = [
    'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1587300003388-59208cc962cb?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1543466835-00a7907e9de1?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1574158622682-e40e69881006?auto=format&fit=crop&w=800&q=80',
  ];

  /// 兼容旧引用
  static List<String> get posts => daily;

  static const List<String> habitDays = [
    'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=150&q=80',
    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=150&q=80',
  ];

  static const List<String> collage = [
    'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1518495973542-4542c06a5843?auto=format&fit=crop&w=400&q=80',
    'https://images.unsplash.com/photo-1426604966848-d7adac402bff?auto=format&fit=crop&w=400&q=80',
  ];

  static List<String> forCategory(ShareCategory category) {
    switch (category.id) {
      case 'food':
        return food;
      case 'selfie':
        return selfie;
      case 'scenery':
        return scenery;
      case 'pet':
        return pet;
      case 'daily':
      default:
        return daily;
    }
  }

  static List<String> watermarksFor(ShareCategory category) {
    switch (category.id) {
      case 'food':
        return const [
          '午后 · 探店时分 · 暖味上桌',
          '夜晚 · 街头小馆 · 烟火气',
          '周末 · brunch · 慢食记录',
          '深夜 · 一碗热汤 · 归家味',
        ];
      case 'selfie':
        return const [
          '今日 · 自然光 · 自拍一帧',
          '午后 · 窗边 · 松弛感',
          '黄昏 · 柔光 · 看见自己',
          '周末 · 街角 · 随心拍',
        ];
      case 'scenery':
        return const [
          '黄昏 · 22℃ 霞光 · 风景打卡',
          '清晨 · 薄雾 · 山野微风',
          '午后 · 晴空 · 林间光斑',
          '海边 · 微风 · 拾岸时分',
        ];
      case 'pet':
        return const [
          '毛孩 · 晒太阳 · 软乎乎',
          '散步 · 小爪印 · 同频呼吸',
          '午后 · 猫猫成精 · 偷懒中',
          '夜晚 · 等你回家 · 摇尾巴',
        ];
      default:
        return const [
          '黄昏 · 20℃ 微风 · 拾岸时分',
          '晨曦 · 18℃ 薄雾 · 咖啡时分',
          '午后 · 24℃ 晴朗 · 林间光斑',
          '傍晚 · 22℃ 霞光 · 海岸微风',
        ];
    }
  }
}

class SeedData {
  SeedData._();

  static List<Post> initialPosts() {
    final now = DateTime.now();
    return [
      Post(
        id: 'seed_1024',
        authorId: 'author_coffee',
        authorName: '晨光手冲咖啡',
        body:
            '清晨 7 点推开窗，空气里泛着微凉的桂花香。手冲萃取的第一股香气漫开时，突然觉得今天所有的赶路都有了温暖的锚点。',
        memoBack: '把疲惫留在昨夜的浪潮里，今日的阳光自会替你晒干所有情绪。',
        imageUrl: PhotoPresets.daily[2],
        mood: MoodTag.byId('coffee'),
        category: ShareCategory.daily,
        stampLabel: '晨曦 · 19℃ 微晴 · 日常碎片',
        city: '杭州',
        createdAt: now.subtract(const Duration(minutes: 18)),
        memoNo: 1024,
        healCount: 38,
        cheerCount: 52,
        luckCount: 19,
        hugCount: 26,
      ),
      Post(
        id: 'seed_food_1',
        authorId: 'author_cook',
        authorName: '慢炖厨房',
        body:
            '巷口新开的小面馆，招牌红油抄手又麻又香。老板说汤底熬了四小时，第一口下去，整条街的烟火气都活了。',
        memoBack: '探店不必打卡炫耀，把味道记进身体就好。',
        imageUrl: PhotoPresets.food[0],
        mood: MoodTag.byId('cook'),
        category: ShareCategory.food,
        stampLabel: '午后 · 探店时分 · 美食探店',
        city: '上海',
        createdAt: now.subtract(const Duration(minutes: 42)),
        memoNo: 1030,
        healCount: 56,
        cheerCount: 71,
        luckCount: 28,
        hugCount: 33,
      ),
      Post(
        id: 'seed_1025',
        authorId: 'author_sunset',
        authorName: '落日余晖海岸',
        body: '下班路过海堤，天空被橘粉色的晚霞染透。戴着耳机安静站了十分钟，风把所有杂念都吹平整了。',
        memoBack: '世界很大，但日落是每个人平等的退烧药。',
        imageUrl: PhotoPresets.scenery[0],
        mood: MoodTag.byId('sky'),
        category: ShareCategory.scenery,
        stampLabel: '黄昏 · 22℃ 霞光 · 风景打卡',
        city: '厦门',
        createdAt: now.subtract(const Duration(hours: 1)),
        memoNo: 1025,
        healCount: 89,
        cheerCount: 44,
        luckCount: 63,
        hugCount: 51,
      ),
      Post(
        id: 'seed_selfie_1',
        authorId: 'author_walk',
        authorName: '林中散步客',
        body: '周末把自己带到公园角落，阳光刚好落在发梢。不是为了好看，只是想认真和今天的自己打个照面。',
        memoBack: '自拍也可以很轻：看见自己，就已经很够。',
        imageUrl: PhotoPresets.selfie[0],
        mood: MoodTag.byId('walk'),
        category: ShareCategory.selfie,
        stampLabel: '今日 · 自然光 · 今日自拍',
        city: '昆明',
        createdAt: now.subtract(const Duration(hours: 2)),
        memoNo: 1031,
        healCount: 64,
        cheerCount: 39,
        luckCount: 45,
        hugCount: 58,
      ),
      Post(
        id: 'seed_1026',
        authorId: 'author_book',
        authorName: '窗边翻书人',
        body: '午后阳光斜斜切过书页，只读了两章，却觉得心里的褶皱被轻轻熨平了。',
        memoBack: '不必追赶章节，慢读本身就是一种抵达。',
        imageUrl: PhotoPresets.daily[0],
        mood: MoodTag.byId('book'),
        category: ShareCategory.daily,
        stampLabel: '午后 · 24℃ 薄云 · 日常碎片',
        city: '成都',
        createdAt: now.subtract(const Duration(hours: 3)),
        memoNo: 1026,
        healCount: 41,
        cheerCount: 27,
        luckCount: 33,
        hugCount: 18,
      ),
      Post(
        id: 'seed_pet_1',
        authorId: 'author_coffee',
        authorName: '晨光手冲咖啡',
        body: '它趴在窗台偷懒晒太阳，耳朵随着风轻轻抖。原来陪伴也可以是一种无声的微光。',
        memoBack: '毛孩不懂点赞，却最懂同频。',
        imageUrl: PhotoPresets.pet[0],
        mood: MoodTag.byId('sky'),
        category: ShareCategory.pet,
        stampLabel: '毛孩 · 晒太阳 · 毛孩瞬间',
        city: '杭州',
        createdAt: now.subtract(const Duration(hours: 5)),
        memoNo: 1032,
        healCount: 92,
        cheerCount: 48,
        luckCount: 37,
        hugCount: 81,
      ),
      Post(
        id: 'seed_food_2',
        authorId: 'author_sunset',
        authorName: '落日余晖海岸',
        body: '海边的夜市烧烤，鱿鱼烤到微焦，柠檬一挤整个人都醒了。和朋友分着吃，比任何评价都真实。',
        memoBack: '最好的探店笔记，是一起举杯的笑声。',
        imageUrl: PhotoPresets.food[3],
        mood: MoodTag.byId('walk'),
        category: ShareCategory.food,
        stampLabel: '夜晚 · 街头小馆 · 美食探店',
        city: '厦门',
        createdAt: now.subtract(const Duration(hours: 6)),
        memoNo: 1033,
        healCount: 47,
        cheerCount: 66,
        luckCount: 29,
        hugCount: 22,
      ),
      Post(
        id: 'seed_book_2',
        authorId: 'author_book',
        authorName: '窗边翻书人',
        body: '雨天把旧书摊开，墨香混着潮湿空气。读到一句刚好写进今天的心情，便觉得被轻轻接住了。',
        memoBack: '好句子会自己找到需要它的人。',
        imageUrl: PhotoPresets.daily[1],
        mood: MoodTag.byId('book'),
        category: ShareCategory.daily,
        stampLabel: '雨天 · 窗边 · 日常碎片',
        city: '成都',
        createdAt: now.subtract(const Duration(hours: 8)),
        memoNo: 1034,
        healCount: 53,
        cheerCount: 31,
        luckCount: 22,
        hugCount: 40,
      ),
      Post(
        id: 'seed_walk_2',
        authorId: 'author_walk',
        authorName: '林中散步客',
        body: '傍晚沿着湖岸走了三公里，落叶踩起来很脆。耳机都没戴，只听见风穿过树冠的声音。',
        memoBack: '有些平静，要靠脚步一点点走出来。',
        imageUrl: PhotoPresets.scenery[1],
        mood: MoodTag.byId('walk'),
        category: ShareCategory.scenery,
        stampLabel: '傍晚 · 湖岸 · 风景打卡',
        city: '昆明',
        createdAt: now.subtract(const Duration(hours: 10)),
        memoNo: 1035,
        healCount: 71,
        cheerCount: 36,
        luckCount: 28,
        hugCount: 49,
      ),
      Post(
        id: 'seed_cook_2',
        authorId: 'author_cook',
        authorName: '慢炖厨房',
        body: '周末给自己炖了一锅番茄牛腩，厨房里飘着酸甜的香。盛出第一勺时，觉得这一周的疲惫都被焐热了。',
        memoBack: '好好吃饭，是把温柔留给自己。',
        imageUrl: PhotoPresets.food[1],
        mood: MoodTag.byId('cook'),
        category: ShareCategory.food,
        stampLabel: '周末 · 家常灶火 · 美食探店',
        city: '上海',
        createdAt: now.subtract(const Duration(hours: 12)),
        memoNo: 1036,
        healCount: 68,
        cheerCount: 55,
        luckCount: 34,
        hugCount: 47,
      ),
      Post(
        id: 'seed_coffee_3',
        authorId: 'author_coffee',
        authorName: '晨光手冲咖啡',
        body: '今日换了浅烘豆，果酸轻盈像早晨的第一缕风。写下冲煮笔记时，窗外刚好有人推着单车路过。',
        memoBack: '慢冲的不只是咖啡，还有对今天的期待。',
        imageUrl: PhotoPresets.daily[3],
        mood: MoodTag.byId('coffee'),
        category: ShareCategory.daily,
        stampLabel: '晨曦 · 浅烘时分 · 日常碎片',
        city: '杭州',
        createdAt: now.subtract(const Duration(hours: 14)),
        memoNo: 1037,
        healCount: 44,
        cheerCount: 61,
        luckCount: 25,
        hugCount: 30,
      ),
    ];
  }

  static HabitProgress habit() {
    return const HabitProgress(
      title: '晨间手冲咖啡 · 连续 5 天',
      doneDays: 5,
      totalDays: 7,
      dayImageUrls: PhotoPresets.habitDays,
    );
  }

  static List<CollageItem> collages() {
    return const [
      CollageItem(
        id: 'collage_lin',
        authorInitial: '林',
        authorLabel: '@林中散步客 · 7日晨光辑',
        caption: '“连续七天早起，在晨雾散去前收集了7次破晓”',
        imageUrls: PhotoPresets.collage,
      ),
    ];
  }

  static int radarCountFor(MoodTag tag) {
    switch (tag.id) {
      case 'coffee':
        return 427;
      case 'sky':
        return 318;
      case 'book':
        return 256;
      case 'walk':
        return 189;
      case 'cook':
        return 142;
      default:
        return 200;
    }
  }

  static UserProfile defaultMe() {
    return UserProfile(
      id: UserProfile.meId,
      displayName: '拾岸旅人',
      bio: '记录微小的生活，感知同频的呼吸。',
      city: '杭州',
      avatarUrl:
          'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=200&q=80',
      initial: '拾',
    );
  }

  static List<UserProfile> communityUsers() {
    return [
      UserProfile(
        id: 'author_coffee',
        displayName: '晨光手冲咖啡',
        bio: '用一杯手冲慢下早晨的节奏。',
        city: '杭州',
        avatarUrl:
            'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=200&q=80',
        initial: '晨',
      ),
      UserProfile(
        id: 'author_sunset',
        displayName: '落日余晖海岸',
        bio: '每天留十分钟给晚霞。',
        city: '厦门',
        avatarUrl:
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=200&q=80',
        initial: '落',
      ),
      UserProfile(
        id: 'author_book',
        displayName: '窗边翻书人',
        bio: '两页书，一段安静。',
        city: '成都',
        avatarUrl:
            'https://images.unsplash.com/photo-1518495973542-4542c06a5843?auto=format&fit=crop&w=200&q=80',
        initial: '窗',
      ),
      UserProfile(
        id: 'author_walk',
        displayName: '林中散步客',
        bio: '把脚步放慢，把呼吸还给森林。',
        city: '昆明',
        avatarUrl:
            'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&w=200&q=80',
        initial: '林',
      ),
      UserProfile(
        id: 'author_cook',
        displayName: '慢炖厨房',
        bio: '认真做饭，是对自己温柔。也爱街头探店。',
        city: '上海',
        avatarUrl:
            'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=200&q=80',
        initial: '慢',
      ),
    ];
  }

  static List<String> defaultFollowerIds() {
    return const ['author_walk', 'author_cook', 'author_book'];
  }

  static UserProfile? userById(String id) {
    if (id == UserProfile.meId) return defaultMe();
    for (final u in communityUsers()) {
      if (u.id == id) return u;
    }
    return null;
  }
}
