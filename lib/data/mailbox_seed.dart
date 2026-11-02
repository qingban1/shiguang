import '../models/coast_letter.dart';
import 'seed_data.dart';

class MailboxSeed {
  MailboxSeed._();

  static List<CoastLetter> publicPool() {
    final now = DateTime.now();
    return [
      CoastLetter(
        id: 'letter_pool_1',
        photoUrl: PhotoPresets.daily[2],
        sentence: '窗台的光刚好落在杯沿，今天也值得被轻轻记得。',
        stampLabel: '晨曦 · 18℃ · 远方海岸',
        city: '杭州',
        createdAt: now.subtract(const Duration(hours: 5)),
        authorAlias: '匿名旅人·桂',
        thankCount: 126,
      ),
      CoastLetter(
        id: 'letter_pool_2',
        photoUrl: PhotoPresets.food[1],
        sentence: '巷口那碗热汤，把一天的冷意都捂化了。',
        stampLabel: '午后 · 探店 · 烟火微光',
        city: '成都',
        createdAt: now.subtract(const Duration(hours: 9)),
        authorAlias: '匿名旅人·汤',
        thankCount: 88,
      ),
      CoastLetter(
        id: 'letter_pool_3',
        photoUrl: PhotoPresets.scenery[0],
        sentence: '海风把头发吹乱的瞬间，心里突然空旷又平静。',
        stampLabel: '黄昏 · 霞光 · 海岸印记',
        city: '厦门',
        createdAt: now.subtract(const Duration(hours: 14)),
        authorAlias: '匿名旅人·潮',
        thankCount: 203,
      ),
      CoastLetter(
        id: 'letter_pool_4',
        photoUrl: PhotoPresets.pet[0],
        sentence: '它把下巴搁在我手背，世界忽然变得很轻。',
        stampLabel: '傍晚 · 毛孩 · 柔软时分',
        city: '昆明',
        createdAt: now.subtract(const Duration(days: 1)),
        authorAlias: '匿名旅人·爪',
        thankCount: 157,
      ),
      CoastLetter(
        id: 'letter_pool_5',
        photoUrl: PhotoPresets.selfie[1],
        sentence: '不是为了被看见，只是想认真和今天的自己道声好。',
        stampLabel: '今日 · 自然光 · 自画像',
        city: '上海',
        createdAt: now.subtract(const Duration(days: 1, hours: 3)),
        authorAlias: '匿名旅人·光',
        thankCount: 94,
      ),
      CoastLetter(
        id: 'letter_pool_6',
        photoUrl: PhotoPresets.scenery[2],
        sentence: '林间的碎光像一封未拆的信，提醒我慢一点。',
        stampLabel: '午后 · 林荫 · 慢行',
        city: '杭州',
        createdAt: now.subtract(const Duration(days: 2)),
        authorAlias: '匿名旅人·叶',
        thankCount: 71,
      ),
    ];
  }
}
