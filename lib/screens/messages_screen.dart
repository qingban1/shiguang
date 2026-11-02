import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/interaction_notice.dart';
import '../models/post.dart';
import '../models/reaction_type.dart';
import '../models/user_profile.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/feed_card.dart';
import '../widgets/user_avatar.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({
    super.key,
    required this.followingProfiles,
    required this.followingPosts,
    required this.updatedAuthorIds,
    required this.notices,
    required this.onToggleReaction,
    required this.onOpenAuthor,
    required this.onToggleFollow,
    required this.followingIds,
    required this.onMarkNoticesRead,
    required this.onPostSafety,
  });

  final List<UserProfile> followingProfiles;
  final List<Post> followingPosts;
  final Set<String> updatedAuthorIds;
  final List<InteractionNotice> notices;
  final void Function(String postId, ReactionType type) onToggleReaction;
  final void Function(String authorId) onOpenAuthor;
  final void Function(String authorId) onToggleFollow;
  final Set<String> followingIds;
  final VoidCallback onMarkNoticesRead;
  final Future<void> Function(Post post) onPostSafety;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  int _segment = 0; // 0 关注动态  1 互动回响
  String? _avatarFilterId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_segment == 1) widget.onMarkNoticesRead();
    });
  }

  List<Post> get _filteredPosts {
    if (_avatarFilterId == null) return widget.followingPosts;
    return widget.followingPosts
        .where((p) => p.authorId == _avatarFilterId)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '消息',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.twilightDark,
                ),
              ),
              const SizedBox(height: 12),
              _FrostedSegment(
                index: _segment,
                onChanged: (i) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _segment = i;
                    if (i == 0) _avatarFilterId = null;
                  });
                  if (i == 1) widget.onMarkNoticesRead();
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _segment == 0
                ? _FollowingActivityPane(
                    key: const ValueKey('following'),
                    profiles: widget.followingProfiles,
                    updatedAuthorIds: widget.updatedAuthorIds,
                    selectedAuthorId: _avatarFilterId,
                    posts: _filteredPosts,
                    followingIds: widget.followingIds,
                    onSelectAuthor: (id) {
                      setState(() {
                        _avatarFilterId = _avatarFilterId == id ? null : id;
                      });
                    },
                    onToggleReaction: widget.onToggleReaction,
                    onOpenAuthor: widget.onOpenAuthor,
                    onToggleFollow: widget.onToggleFollow,
                    onPostSafety: widget.onPostSafety,
                  )
                : _InteractionPane(
                    key: const ValueKey('interaction'),
                    notices: widget.notices,
                    onOpenAuthor: widget.onOpenAuthor,
                  ),
          ),
        ),
      ],
    );
  }
}

/// iOS 风格磨砂分段胶囊
class _FrostedSegment extends StatelessWidget {
  const _FrostedSegment({
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
            boxShadow: [
              BoxShadow(
                color: AppColors.twilightDark.withValues(alpha: 0.06),
                blurRadius: 10,
              ),
            ],
          ),
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: index,
            backgroundColor: Colors.transparent,
            thumbColor: Colors.white.withValues(alpha: 0.95),
            padding: const EdgeInsets.all(2),
            children: {
              0: _segLabel('关注动态', index == 0),
              1: _segLabel('互动回响', index == 1),
            },
            onValueChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ),
    );
  }

  Widget _segLabel(String text, bool selected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.twilightDark : AppColors.slate500,
        ),
      ),
    );
  }
}

class _FollowingActivityPane extends StatelessWidget {
  const _FollowingActivityPane({
    super.key,
    required this.profiles,
    required this.updatedAuthorIds,
    required this.selectedAuthorId,
    required this.posts,
    required this.followingIds,
    required this.onSelectAuthor,
    required this.onToggleReaction,
    required this.onOpenAuthor,
    required this.onToggleFollow,
    required this.onPostSafety,
  });

  final List<UserProfile> profiles;
  final Set<String> updatedAuthorIds;
  final String? selectedAuthorId;
  final List<Post> posts;
  final Set<String> followingIds;
  final ValueChanged<String> onSelectAuthor;
  final void Function(String postId, ReactionType type) onToggleReaction;
  final void Function(String authorId) onOpenAuthor;
  final void Function(String authorId) onToggleFollow;
  final Future<void> Function(Post post) onPostSafety;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 92,
            child: profiles.isEmpty
                ? const Center(
                    child: Text(
                      '还没有关注的人，去微光流遇见同频吧',
                      style: TextStyle(fontSize: 12, color: AppColors.slate500),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                    scrollDirection: Axis.horizontal,
                    itemCount: profiles.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final p = profiles[index];
                      final hasUpdate = updatedAuthorIds.contains(p.id);
                      final selected = selectedAuthorId == p.id;
                      return _BreathingAvatar(
                        profile: p,
                        hasUpdate: hasUpdate,
                        selected: selected,
                        onTap: () => onSelectAuthor(p.id),
                        onOpenProfile: () => onOpenAuthor(p.id),
                      );
                    },
                  ),
          ),
        ),
        if (posts.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                '关注的人还没有新的拍立得微光',
                style: TextStyle(fontSize: 13, color: AppColors.slate500),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = posts[index];
                  return FeedCard(
                    post: post,
                    isFollowing: followingIds.contains(post.authorId),
                    onReaction: (type) {
                      final adding = !post.hasReacted(type);
                      onToggleReaction(post.id, type);
                      if (adding && context.mounted) {
                        AppToast.show(context, '已向对方投递一份无言温暖 ✨');
                      }
                    },
                    onOpenSafety: () => onPostSafety(post),
                    onOpenAuthor: () => onOpenAuthor(post.authorId),
                    onToggleFollow: () => onToggleFollow(post.authorId),
                  );
                },
                childCount: posts.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _BreathingAvatar extends StatefulWidget {
  const _BreathingAvatar({
    required this.profile,
    required this.hasUpdate,
    required this.selected,
    required this.onTap,
    required this.onOpenProfile,
  });

  final UserProfile profile;
  final bool hasUpdate;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onOpenProfile;

  @override
  State<_BreathingAvatar> createState() => _BreathingAvatarState();
}

class _BreathingAvatarState extends State<_BreathingAvatar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onLongPress: widget.onOpenProfile,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _c,
              builder: (context, child) {
                final glow = widget.hasUpdate ? (0.55 + _c.value * 0.45) : 0.25;
                final scale = widget.hasUpdate ? (1 + _c.value * 0.04) : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.all(2.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.amber.withValues(alpha: glow),
                          AppColors.dawn.withValues(alpha: glow),
                        ],
                      ),
                      boxShadow: widget.hasUpdate
                          ? [
                              BoxShadow(
                                color: AppColors.dawn.withValues(alpha: 0.45),
                                blurRadius: 10,
                              ),
                            ]
                          : null,
                      border: widget.selected
                          ? Border.all(color: AppColors.twilight, width: 2)
                          : null,
                    ),
                    child: child,
                  ),
                );
              },
              child: UserAvatar(profile: widget.profile, size: 48),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: widget.onOpenProfile,
              child: Text(
                widget.profile.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      widget.selected ? FontWeight.w800 : FontWeight.w600,
                  color: widget.selected
                      ? AppColors.twilight
                      : AppColors.slate600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InteractionPane extends StatelessWidget {
  const _InteractionPane({
    super.key,
    required this.notices,
    required this.onOpenAuthor,
  });

  final List<InteractionNotice> notices;
  final void Function(String authorId) onOpenAuthor;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.emerald50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.emerald200),
          ),
          child: const Text(
            '这里是关注与回响通知',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.emerald700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          '可查看谁关注了你、谁送来了温暖回响。',
          style: TextStyle(fontSize: 11, color: AppColors.slate500),
        ),
        const SizedBox(height: 14),
        if (notices.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 48),
            child: Center(
              child: Text(
                '暂无互动回响',
                style: TextStyle(fontSize: 13, color: AppColors.slate500),
              ),
            ),
          )
        else
          ...notices.map((n) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Material(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => onOpenAuthor(n.actorId),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        UserAvatar(
                          profile: UserProfile(
                            id: n.actorId,
                            displayName: n.actorName,
                            bio: '',
                            city: '',
                            avatarUrl: n.actorAvatarUrl,
                          ),
                          size: 44,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.body,
                                style: const TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.slate800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _timeLabel(n.createdAt),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.slate400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (n.kind == NoticeKind.follow)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.twilightSurface,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              '新关注',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.twilight,
                              ),
                            ),
                          )
                        else if (n.reaction != null)
                          Text(
                            n.reaction!.emoji,
                            style: const TextStyle(fontSize: 18),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }

  String _timeLabel(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}分钟前';
    if (diff.inHours < 24) return '${diff.inHours}小时前';
    return '${diff.inDays}天前';
  }
}
