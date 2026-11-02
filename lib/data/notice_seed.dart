import '../models/interaction_notice.dart';
import '../models/reaction_type.dart';
import '../models/user_profile.dart';
import 'seed_data.dart';

class NoticeSeed {
  NoticeSeed._();

  static UserProfile _u(String id) {
    return SeedData.userById(id) ?? SeedData.communityUsers().first;
  }

  static List<InteractionNotice> initial() {
    final now = DateTime.now();
    final walk = _u('author_walk');
    final cook = _u('author_cook');
    final book = _u('author_book');
    final sunset = _u('author_sunset');
    final coffee = _u('author_coffee');

    return [
      InteractionNotice(
        id: 'notice_follow_1',
        kind: NoticeKind.follow,
        actorId: walk.id,
        actorName: walk.displayName,
        actorAvatarUrl: walk.avatarUrl,
        createdAt: now.subtract(const Duration(minutes: 26)),
      ),
      InteractionNotice(
        id: 'notice_react_1',
        kind: NoticeKind.reaction,
        actorId: sunset.id,
        actorName: sunset.displayName,
        actorAvatarUrl: sunset.avatarUrl,
        createdAt: now.subtract(const Duration(hours: 1)),
        reaction: ReactionType.heal,
        postTitle: '清晨手冲',
      ),
      InteractionNotice(
        id: 'notice_follow_2',
        kind: NoticeKind.follow,
        actorId: cook.id,
        actorName: cook.displayName,
        actorAvatarUrl: cook.avatarUrl,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      InteractionNotice(
        id: 'notice_react_2',
        kind: NoticeKind.reaction,
        actorId: book.id,
        actorName: book.displayName,
        actorAvatarUrl: book.avatarUrl,
        createdAt: now.subtract(const Duration(hours: 5)),
        reaction: ReactionType.cheer,
        postTitle: '巷口暖面',
      ),
      InteractionNotice(
        id: 'notice_react_3',
        kind: NoticeKind.reaction,
        actorId: coffee.id,
        actorName: coffee.displayName,
        actorAvatarUrl: coffee.avatarUrl,
        createdAt: now.subtract(const Duration(hours: 8)),
        reaction: ReactionType.hug,
        postTitle: '窗边慢读',
      ),
      InteractionNotice(
        id: 'notice_react_4',
        kind: NoticeKind.reaction,
        actorId: walk.id,
        actorName: walk.displayName,
        actorAvatarUrl: walk.avatarUrl,
        createdAt: now.subtract(const Duration(days: 1)),
        reaction: ReactionType.luck,
        postTitle: '黄昏海堤',
      ),
    ];
  }
}
