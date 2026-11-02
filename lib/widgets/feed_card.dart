import 'package:flutter/material.dart';

import '../data/seed_data.dart';
import '../models/post.dart';
import '../models/reaction_type.dart';
import '../models/user_profile.dart';
import '../theme/app_colors.dart';
import 'polaroid_card.dart';
import 'reaction_bar.dart';
import 'user_avatar.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({
    super.key,
    required this.post,
    required this.onReaction,
    required this.onOpenSafety,
    this.isFollowing = false,
    this.showAuthorHeader = true,
    this.authorProfile,
    this.onOpenAuthor,
    this.onToggleFollow,
  });

  final Post post;
  final void Function(ReactionType type) onReaction;
  final VoidCallback onOpenSafety;
  final bool isFollowing;
  final bool showAuthorHeader;
  final UserProfile? authorProfile;
  final VoidCallback? onOpenAuthor;
  final VoidCallback? onToggleFollow;

  UserProfile get _author {
    if (authorProfile != null) return authorProfile!;
    return SeedData.userById(post.authorId) ??
        UserProfile(
          id: post.authorId,
          displayName: post.authorName,
          bio: '',
          city: post.city,
          avatarUrl: '',
        );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.twilightDark.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.twilightDark.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showAuthorHeader && !post.isMine)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  InkWell(
                    onTap: onOpenAuthor,
                    customBorder: const CircleBorder(),
                    child: UserAvatar(profile: _author, size: 36),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: onOpenAuthor,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          post.authorName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.twilightDark,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (onToggleFollow != null)
                    GestureDetector(
                      onTap: onToggleFollow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isFollowing
                              ? AppColors.slate100
                              : AppColors.twilightSurface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isFollowing
                                ? AppColors.slate200
                                : AppColors.twilight.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Text(
                          isFollowing ? '已关注' : '关注',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isFollowing
                                ? AppColors.slate600
                                : AppColors.twilight,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              post.body,
              style: const TextStyle(
                fontSize: 15,
                height: 1.55,
                letterSpacing: 0.3,
                color: AppColors.slate800,
              ),
            ),
          ),
          const SizedBox(height: 12),
          PolaroidCard(post: post),
          const SizedBox(height: 14),
          Divider(height: 1, color: AppColors.slate100.withValues(alpha: 0.85)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.amberSurface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: AppColors.amber.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          post.category.display,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.amberDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(post.mood.emoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          post.mood.label,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.twilightDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${post.relativeTimeLabel()} · ${post.city}',
                  style: const TextStyle(fontSize: 11, color: AppColors.slate400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ReactionBar(
            post: post,
            onToggle: (type, _) => onReaction(type),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
              onPressed: onOpenSafety,
              icon: const Icon(
                Icons.more_horiz,
                size: 18,
                color: AppColors.slate400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
