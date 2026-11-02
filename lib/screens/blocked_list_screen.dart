import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/app_colors.dart';
import '../widgets/glimmer_background.dart';
import '../widgets/user_avatar.dart';

class BlockedListScreen extends StatelessWidget {
  const BlockedListScreen({
    super.key,
    required this.users,
    required this.onUnblock,
    required this.onClearAll,
  });

  final List<UserProfile> users;
  final void Function(String userId) onUnblock;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    return GlimmerBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            '已拉黑创作者',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.twilightDark,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (users.isNotEmpty)
              TextButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('清空拉黑名单？'),
                      content: Text('将解除 ${users.length} 位创作者的屏蔽。'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('取消'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('清空'),
                        ),
                      ],
                    ),
                  );
                  if (ok == true && context.mounted) {
                    onClearAll();
                  }
                },
                child: const Text(
                  '清空',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.rose600,
                  ),
                ),
              ),
          ],
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
                  color: AppColors.rose50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.rose400.withValues(alpha: 0.35),
                  ),
                ),
                child: const Text(
                  '拉黑后将隐藏对方内容并限制双方互动。解除后可再次看见其公开微光。',
                  style: TextStyle(fontSize: 11, color: AppColors.rose600),
                ),
              ),
            ),
            Expanded(
              child: users.isEmpty
                  ? const Center(
                      child: Text(
                        '暂无拉黑创作者',
                        style: TextStyle(
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
                        return Material(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(18),
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
                                        user.bio.isEmpty
                                            ? user.city
                                            : '${user.city} · ${user.bio}',
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
                                const SizedBox(width: 8),
                                Material(
                                  color: AppColors.slate100,
                                  borderRadius: BorderRadius.circular(999),
                                  child: InkWell(
                                    onTap: () => onUnblock(user.id),
                                    borderRadius: BorderRadius.circular(999),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 7,
                                      ),
                                      child: Text(
                                        '解除',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.slate600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
