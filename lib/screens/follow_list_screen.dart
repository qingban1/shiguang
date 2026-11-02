import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/app_colors.dart';
import '../widgets/glimmer_background.dart';
import '../widgets/user_avatar.dart';

enum FollowListMode { following, followers }

class FollowListScreen extends StatelessWidget {
  const FollowListScreen({
    super.key,
    required this.mode,
    required this.users,
    required this.followingIds,
    required this.onToggleFollow,
    required this.onOpenUser,
  });

  final FollowListMode mode;
  final List<UserProfile> users;
  final Set<String> followingIds;
  final void Function(String userId) onToggleFollow;
  final void Function(UserProfile user) onOpenUser;

  @override
  Widget build(BuildContext context) {
    final title = mode == FollowListMode.following ? '我的关注' : '我的粉丝';
    return GlimmerBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.twilightDark,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.emerald50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.emerald200),
                ),
                child: const Text(
                  '关注只为同频；表达善意请使用动态上的回响。',
                  style: TextStyle(fontSize: 11, color: AppColors.emerald700),
                ),
              ),
            ),
            Expanded(
              child: users.isEmpty
                  ? Center(
                      child: Text(
                        mode == FollowListMode.following
                            ? '还没有关注的人，去微光流遇见同频吧'
                            : '还没有粉丝，先投递一束微光',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.slate500,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: users.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final user = users[index];
                        final followed = followingIds.contains(user.id);
                        return Material(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => onOpenUser(user),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  UserAvatar(profile: user, size: 44),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.displayName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.twilightDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${user.city} · ${user.bio}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.slate500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!user.isMe) ...[
                                    const SizedBox(width: 8),
                                    _FollowChip(
                                      followed: followed,
                                      onTap: () => onToggleFollow(user.id),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowChip extends StatelessWidget {
  const _FollowChip({required this.followed, required this.onTap});

  final bool followed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: followed ? AppColors.slate100 : AppColors.twilight,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(
            followed ? '已关注' : '关注',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: followed ? AppColors.slate600 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
