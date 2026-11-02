import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/seed_data.dart';
import '../models/mood_tag.dart';
import '../models/post.dart';
import '../models/reaction_type.dart';
import '../models/share_category.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/feed_card.dart';
import '../widgets/glimmer_refresh_control.dart';
import '../widgets/radar_banner.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    super.key,
    required this.posts,
    required this.radarMood,
    required this.filterByRadar,
    required this.categoryFilter,
    required this.followingIds,
    required this.onToggleReaction,
    required this.onRefresh,
    required this.onRadarTap,
    required this.onCategoryFilter,
    required this.onToggleFollow,
    required this.onOpenAuthor,
    required this.onPostSafety,
  });

  final List<Post> posts;
  final MoodTag radarMood;
  final bool filterByRadar;
  final ShareCategory? categoryFilter;
  final Set<String> followingIds;
  final void Function(String postId, ReactionType type) onToggleReaction;
  final Future<void> Function() onRefresh;
  final VoidCallback onRadarTap;
  final ValueChanged<ShareCategory?> onCategoryFilter;
  final void Function(String authorId) onToggleFollow;
  final void Function(String authorId) onOpenAuthor;
  final Future<void> Function(Post post) onPostSafety;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen>
    with SingleTickerProviderStateMixin {
  bool _refreshing = false;
  int _entranceKey = 0;
  late final AnimationController _headerSpin;

  @override
  void initState() {
    super.initState();
    _headerSpin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void dispose() {
    _headerSpin.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (_refreshing) return;
    HapticFeedback.lightImpact();
    setState(() => _refreshing = true);
    _headerSpin.repeat();
    await widget.onRefresh();
    // 让动画多转一会儿，体感更完整
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;
    _headerSpin.stop();
    _headerSpin.value = 0;
    setState(() {
      _refreshing = false;
      _entranceKey++;
    });
    HapticFeedback.selectionClick();
    AppToast.show(context, '微光流已刷新');
  }

  @override
  Widget build(BuildContext context) {
    final radarCount = SeedData.radarCountFor(widget.radarMood);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Text(
                          '拾岸微光',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.twilightDark,
                          ),
                        ),
                        SizedBox(width: 8),
                        _EditionBadge(),
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: const CircleBorder(
                      side: BorderSide(color: Colors.white60),
                    ),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _refreshing ? null : _refresh,
                      child: SizedBox(
                        width: 36,
                        height: 36,
                        child: Center(
                          child: RotationTransition(
                            turns: _headerSpin,
                            child: Icon(
                              Icons.refresh_rounded,
                              size: 16,
                              color: _refreshing
                                  ? AppColors.twilight
                                  : AppColors.slate600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              RadarBanner(
                mood: widget.radarMood,
                count: radarCount,
                filterActive: widget.filterByRadar,
                onTap: () {
                  widget.onRadarTap();
                  final msg = widget.filterByRadar
                      ? '已恢复全部微光动态'
                      : '已筛选全部正在 [${widget.radarMood.label}] 的同频动态';
                  AppToast.show(context, msg);
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CategoryFilterChip(
                      label: '全部',
                      selected: widget.categoryFilter == null,
                      onTap: () => widget.onCategoryFilter(null),
                    ),
                    ...ShareCategory.presets.map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _CategoryFilterChip(
                          label: c.display,
                          selected: widget.categoryFilter == c,
                          onTap: () => widget.onCategoryFilter(c),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              CupertinoSliverRefreshControl(
                refreshTriggerPullDistance: 110,
                refreshIndicatorExtent: 72,
                onRefresh: _refresh,
                builder: (
                  context,
                  refreshState,
                  pulledExtent,
                  refreshTriggerPullDistance,
                  refreshIndicatorExtent,
                ) {
                  return GlimmerRefreshIndicator(
                    refreshState: refreshState,
                    pulledExtent: pulledExtent,
                    refreshTriggerPullDistance: refreshTriggerPullDistance,
                    refreshIndicatorExtent: refreshIndicatorExtent,
                  );
                },
              ),
              if (widget.posts.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      '暂时没有同频微光，换个状态再看看海岸',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.slate500,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final post = widget.posts[index];
                        return GlimmerRefreshEntrance(
                          index: index,
                          animKey: _entranceKey,
                          child: FeedCard(
                            post: post,
                            isFollowing:
                                widget.followingIds.contains(post.authorId),
                            onReaction: (type) {
                              final adding = !post.hasReacted(type);
                              widget.onToggleReaction(post.id, type);
                              if (adding) {
                                AppToast.show(
                                  context,
                                  '已向对方投递一份无言温暖 ✨',
                                );
                              }
                            },
                            onOpenSafety: () => widget.onPostSafety(post),
                            onOpenAuthor: () =>
                                widget.onOpenAuthor(post.authorId),
                            onToggleFollow: post.isMine
                                ? null
                                : () {
                                    final adding = !widget.followingIds
                                        .contains(post.authorId);
                                    widget.onToggleFollow(post.authorId);
                                    AppToast.show(
                                      context,
                                      adding
                                          ? '已关注 ${post.authorName}'
                                          : '已取消关注',
                                    );
                                  },
                          ),
                        );
                      },
                      childCount: widget.posts.length,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EditionBadge extends StatelessWidget {
  const _EditionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.twilightSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.twilight.withValues(alpha: 0.2)),
      ),
      child: const Text(
        '晨曦版',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.twilight,
        ),
      ),
    );
  }
}

class _CategoryFilterChip extends StatelessWidget {
  const _CategoryFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.twilight : Colors.white.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? AppColors.twilight
                : AppColors.slate200.withValues(alpha: 0.9),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.slate600,
          ),
        ),
      ),
    );
  }
}
