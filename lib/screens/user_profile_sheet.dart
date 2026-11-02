import 'package:flutter/material.dart';

import '../models/post.dart';
import '../models/reaction_type.dart';
import '../models/user_profile.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/feed_card.dart';
import '../widgets/user_avatar.dart';

/// 他人个人主页：资料 + 全部帖子；可举报 / 拉黑 / 管理单条内容
Future<void> showUserProfileSheet(
  BuildContext context, {
  required UserProfile profile,
  required List<Post> posts,
  required bool isFollowing,
  bool isBlocked = false,
  required VoidCallback onToggleFollow,
  required void Function(String postId, ReactionType type) onToggleReaction,
  required Future<void> Function(Post post) onPostSafety,
  required VoidCallback onReportUser,
  required VoidCallback onToggleBlock,
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return _UserProfilePage(
        profile: profile,
        posts: posts,
        isFollowing: isFollowing,
        isBlocked: isBlocked,
        onToggleFollow: onToggleFollow,
        onToggleReaction: onToggleReaction,
        onPostSafety: onPostSafety,
        onReportUser: onReportUser,
        onToggleBlock: onToggleBlock,
      );
    },
  );
}

class _UserProfilePage extends StatefulWidget {
  const _UserProfilePage({
    required this.profile,
    required this.posts,
    required this.isFollowing,
    required this.isBlocked,
    required this.onToggleFollow,
    required this.onToggleReaction,
    required this.onPostSafety,
    required this.onReportUser,
    required this.onToggleBlock,
  });

  final UserProfile profile;
  final List<Post> posts;
  final bool isFollowing;
  final bool isBlocked;
  final VoidCallback onToggleFollow;
  final void Function(String postId, ReactionType type) onToggleReaction;
  final Future<void> Function(Post post) onPostSafety;
  final VoidCallback onReportUser;
  final VoidCallback onToggleBlock;

  @override
  State<_UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<_UserProfilePage> {
  late bool _following;
  late bool _blocked;

  @override
  void initState() {
    super.initState();
    _following = widget.isFollowing;
    _blocked = widget.isBlocked;
  }

  int get _resonance =>
      widget.posts.fold<int>(0, (s, p) => s + p.totalResonance);

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final sorted = List<Post>.from(widget.posts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.fromLTRB(20, 10, 20, 24 + bottom),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.slate300,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Center(child: UserAvatar(profile: widget.profile, size: 76)),
              const SizedBox(height: 12),
              Text(
                widget.profile.displayName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.twilightDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.profile.city,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.slate500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.profile.bio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.slate700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatChip(
                      value: '${sorted.length}',
                      label: '微光',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _StatChip(
                      value: '$_resonance',
                      label: '回响',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: _following ? AppColors.slate100 : AppColors.twilight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextButton(
                    onPressed: _blocked
                        ? null
                        : () {
                            final next = !_following;
                            widget.onToggleFollow();
                            setState(() => _following = next);
                            AppToast.show(
                              context,
                              next ? '已关注，可在足迹查看' : '已取消关注',
                            );
                          },
                    style: TextButton.styleFrom(
                      foregroundColor:
                          _following ? AppColors.slate600 : Colors.white,
                      disabledForegroundColor: AppColors.slate400,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _blocked ? '已拉黑' : (_following ? '已关注' : '关注'),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: widget.onReportUser,
                      icon: const Icon(Icons.flag_outlined, size: 16),
                      label: const Text('举报用户'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.slate700,
                        side: const BorderSide(color: AppColors.slate200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        widget.onToggleBlock();
                        setState(() => _blocked = !_blocked);
                      },
                      icon: Icon(
                        _blocked
                            ? Icons.person_add_alt_1_outlined
                            : Icons.person_off_outlined,
                        size: 16,
                      ),
                      label: Text(_blocked ? '解除拉黑' : '拉黑'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.rose600,
                        side: BorderSide(
                          color: AppColors.rose400.withValues(alpha: 0.45),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Text(
                    '全部微光',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.twilightDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${sorted.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (sorted.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 36),
                  child: Center(
                    child: Text(
                      '还没有发布过微光动态',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.slate500,
                      ),
                    ),
                  ),
                )
              else
                ...sorted.map(
                  (post) => FeedCard(
                    post: post,
                    showAuthorHeader: false,
                    isFollowing: _following,
                    onReaction: (type) {
                      final adding = !post.hasReacted(type);
                      widget.onToggleReaction(post.id, type);
                      if (adding && mounted) {
                        AppToast.show(context, '已向对方投递一份无言温暖 ✨');
                      }
                      setState(() {});
                    },
                    onOpenSafety: () => widget.onPostSafety(post),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.twilightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.twilight.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.twilightDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }
}
