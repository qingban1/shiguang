import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/legal_docs.dart';
import '../data/seed_data.dart';
import '../data/storage_service.dart';
import '../models/app_settings.dart';
import '../models/auth_account.dart';
import '../models/coast_letter.dart';
import '../models/content_report.dart';
import '../models/interaction_notice.dart';
import '../models/mood_tag.dart';
import '../models/post.dart';
import '../models/reaction_type.dart';
import '../models/share_category.dart';
import '../models/user_profile.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/floating_dock.dart';
import '../widgets/glimmer_background.dart';
import '../widgets/safety_sheet.dart';
import 'blocked_list_screen.dart';
import 'content_safety_screen.dart';
import 'delete_account_flow.dart';
import 'edit_profile_sheet.dart';
import 'feed_screen.dart';
import 'follow_list_screen.dart';
import 'legal_doc_screen.dart';
import 'letter_collection_screen.dart';
import 'mailbox_screen.dart';
import 'messages_screen.dart';
import 'password_sheets.dart';
import 'post_sheet.dart';
import 'profile_screen.dart';
import 'report_sheet.dart';
import 'user_profile_sheet.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.onLoggedOut,
    this.onSessionExpired,
  });

  final VoidCallback onLoggedOut;
  final VoidCallback? onSessionExpired;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _storage = StorageService.instance;

  DockTab _tab = DockTab.feed;
  bool _loading = true;
  List<Post> _posts = [];
  Set<String> _blocked = {};
  Set<String> _hiddenPosts = {};
  Set<String> _hiddenAuthors = {};
  List<ContentReport> _reports = [];
  MoodTag _radarMood = MoodTag.presets.first;
  bool _filterByRadar = false;
  ShareCategory? _categoryFilter;

  UserProfile _me = SeedData.defaultMe();
  Set<String> _following = {};
  Set<String> _followers = {};

  MailboxDayState _mailboxDay = MailboxDayState(
    dateKey: MailboxDayState.todayKey(),
  );
  List<CoastLetter> _letterPool = [];
  List<CoastLetter> _letterCollection = [];
  int _myThanksReceived = 0;
  List<InteractionNotice> _notices = [];
  AppSettings _settings = AppSettings();
  AuthAccount? _account;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final loginState = await _storage.checkLoginState();
    if (!loginState.loggedIn) {
      if (!mounted) return;
      if (loginState.expired) {
        widget.onSessionExpired?.call();
      } else {
        widget.onLoggedOut();
      }
      return;
    }
    final posts = await _storage.loadPosts();
    final blocked = await _storage.loadBlockedAuthors();
    final hiddenPosts = await _storage.loadHiddenPostIds();
    final hiddenAuthors = await _storage.loadHiddenAuthorIds();
    final reports = await _storage.loadReports();
    final moodId = await _storage.loadRadarMoodId();
    final me = await _storage.loadMeProfile();
    final following = await _storage.loadFollowingIds();
    final followers = await _storage.loadFollowerIds();
    final mailboxDay = await _storage.loadMailboxDay();
    final letterPool = await _storage.loadLetterPool();
    final letterCollection = await _storage.loadLetterCollection();
    final thanks = await _storage.loadMyThanksReceived();
    final notices = await _storage.loadNotices();
    final settings = await _storage.loadAppSettings();
    final account = await _storage.loadCurrentAccount();
    if (!mounted) return;
    setState(() {
      _posts = posts;
      _blocked = blocked;
      _hiddenPosts = hiddenPosts;
      _hiddenAuthors = hiddenAuthors;
      _reports = reports;
      _me = me;
      _following = following;
      _followers = followers;
      _mailboxDay = mailboxDay;
      _letterPool = letterPool;
      _letterCollection = letterCollection;
      _myThanksReceived = thanks;
      _notices = notices;
      _settings = settings;
      _account = account;
      if (moodId != null) {
        _radarMood = MoodTag.byId(moodId);
      }
      _loading = false;
    });
  }

  Future<void> _logout() async {
    await _storage.logout();
    if (!mounted) return;
    widget.onLoggedOut();
  }

  Future<void> _changePassword() async {
    final input = await showChangePasswordSheet(context);
    if (input == null || !mounted) return;
    final result = await _storage.changePassword(
      oldPassword: input.oldPassword,
      newPassword: input.newPassword,
    );
    if (!mounted) return;
    AppToast.show(context, result.message);
    if (result.message.contains('过期')) {
      widget.onSessionExpired?.call();
    }
  }

  Future<void> _deleteAccount() async {
    final password = await showDeleteAccountFlow(context);
    if (password == null || !mounted) return;
    final result = await _storage.deleteCurrentAccount(password: password);
    if (!mounted) return;
    AppToast.show(context, result.message);
    if (result.ok) {
      widget.onLoggedOut();
    }
  }

  Future<void> _persist() async {
    await _storage.savePosts(_posts);
    await _storage.saveBlockedAuthors(_blocked);
    await _storage.saveHiddenPostIds(_hiddenPosts);
    await _storage.saveHiddenAuthorIds(_hiddenAuthors);
    await _storage.saveReports(_reports);
    await _storage.saveMeProfile(_me);
    await _storage.saveFollowingIds(_following);
    await _storage.saveFollowerIds(_followers);
    await _storage.saveMailboxDay(_mailboxDay);
    await _storage.saveLetterPool(_letterPool);
    await _storage.saveLetterCollection(_letterCollection);
    await _storage.saveMyThanksReceived(_myThanksReceived);
    await _storage.saveNotices(_notices);
    await _storage.saveAppSettings(_settings);
  }

  bool _isVisuallyHidden(Post p) {
    if (_blocked.contains(p.authorId)) return true;
    if (_hiddenAuthors.contains(p.authorId)) return true;
    if (_hiddenPosts.contains(p.id)) return true;
    return false;
  }

  /// 拉黑或审核隐藏作者：限制关注 / 回响 / 打开主页等互动
  bool _isInteractionRestricted(String authorId) {
    return _blocked.contains(authorId) || _hiddenAuthors.contains(authorId);
  }

  List<UserProfile> get _followingProfiles {
    return _profilesForIds(_following);
  }

  List<Post> get _followingPosts {
    return _posts
        .where(
          (p) => _following.contains(p.authorId) && !_isVisuallyHidden(p),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Set<String> get _updatedAuthorIds {
    final now = DateTime.now();
    return _followingPosts
        .where((p) => now.difference(p.createdAt).inHours < 36)
        .map((p) => p.authorId)
        .toSet();
  }

  void _markNoticesRead() {
    var changed = false;
    for (final n in _notices) {
      if (!n.read) {
        n.read = true;
        changed = true;
      }
    }
    if (changed) {
      setState(() {});
      _persist();
    }
  }

  List<Post> get _visiblePosts {
    var list = _posts.where((p) => !_isVisuallyHidden(p)).toList();
    if (_filterByRadar) {
      list = list.where((p) => p.mood.id == _radarMood.id).toList();
    }
    final cat = _categoryFilter;
    if (cat != null) {
      list = list.where((p) => p.category.id == cat.id).toList();
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<Post> get _myPosts {
    return _posts.where((p) => p.isMine).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int get _totalResonance {
    final mine = _myPosts;
    if (mine.isNotEmpty) {
      return mine.fold<int>(0, (s, p) => s + p.totalResonance);
    }
    return _posts.fold<int>(0, (s, p) => s + p.totalResonance);
  }

  UserProfile? _resolveUser(String id) {
    if (id == UserProfile.meId || id == _me.id) return _me;
    return SeedData.userById(id);
  }

  List<UserProfile> _profilesForIds(Iterable<String> ids) {
    final list = <UserProfile>[];
    for (final id in ids) {
      if (_blocked.contains(id)) continue;
      final u = _resolveUser(id);
      if (u != null) list.add(u);
    }
    return list;
  }

  void _toggleReaction(String postId, ReactionType type) {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    final authorId = _posts[index].authorId;
    if (_isInteractionRestricted(authorId)) {
      AppToast.show(context, '对方内容已隐藏，无法互动');
      return;
    }
    if (_hiddenPosts.contains(postId)) {
      AppToast.show(context, '该内容已隐藏，无法互动');
      return;
    }
    setState(() {
      _posts[index].toggleReaction(type);
    });
    _persist();
  }

  void _blockAuthor(String authorId) {
    if (authorId == UserProfile.meId) return;
    setState(() {
      _blocked.add(authorId);
      _following.remove(authorId);
      _followers.remove(authorId);
    });
    _persist();
  }

  void _unblockAuthor(String authorId) {
    setState(() {
      _blocked.remove(authorId);
    });
    _persist();
  }

  void _clearBlocked() {
    setState(() {
      _blocked.clear();
    });
    _persist();
  }

  void _deleteOwnPost(String postId) {
    setState(() {
      _posts.removeWhere((p) => p.id == postId && p.isMine);
      _hiddenPosts.remove(postId);
    });
    _persist();
  }

  Future<void> _submitReport({
    required ReportTargetType type,
    required String targetId,
    required String authorId,
    required String label,
    required ReportReason reason,
    required String note,
  }) async {
    final result = await _storage.submitReport(
      targetType: type,
      targetId: targetId,
      targetAuthorId: authorId,
      targetLabel: label,
      reason: reason,
      note: note,
    );
    if (!mounted) return;
    if (result.ok && result.report != null) {
      setState(() {
        _reports = [result.report!, ..._reports];
      });
    }
    AppToast.show(context, result.message);
  }

  Future<void> _handlePostSafety(Post post) async {
    final action = await showSafetySheet(
      context,
      title: post.authorName,
      isMine: post.isMine,
      alreadyBlocked: _blocked.contains(post.authorId),
    );
    if (!mounted || action == null) return;

    if (action == 'delete_own') {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('删除动态？'),
          content: const Text('删除后不可恢复。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.rose600),
              child: const Text('删除'),
            ),
          ],
        ),
      );
      if (ok == true) {
        _deleteOwnPost(post.id);
        if (mounted) AppToast.show(context, '动态已删除');
      }
      return;
    }

    if (action == 'block') {
      _blockAuthor(post.authorId);
      AppToast.show(context, '已拉黑，对方内容已隐藏');
      return;
    }
    if (action == 'unblock') {
      _unblockAuthor(post.authorId);
      AppToast.show(context, '已解除拉黑');
      return;
    }

    if (action == 'report_post' || action == 'report_user') {
      final draft = await showReportSheet(
        context,
        title: action == 'report_post' ? post.body : post.authorName,
        initialType: action == 'report_post'
            ? ReportTargetType.post
            : ReportTargetType.user,
        allowUserReport: false,
      );
      if (draft == null || !mounted) return;
      await _submitReport(
        type: action == 'report_post'
            ? ReportTargetType.post
            : ReportTargetType.user,
        targetId:
            action == 'report_post' ? post.id : post.authorId,
        authorId: post.authorId,
        label: action == 'report_post'
            ? '${post.authorName} · ${post.body}'
            : post.authorName,
        reason: draft.reason,
        note: draft.note,
      );
    }
  }

  Future<void> _openContentSafety() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setLocal) {
              return ContentSafetyScreen(
                reports: List<ContentReport>.from(_reports)
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
                onStartReview: (id) async {
                  final r = await _storage.startReview(id);
                  if (!context.mounted) return;
                  AppToast.show(context, r.message);
                  if (r.ok) {
                    final list = await _storage.loadReports();
                    if (!mounted) return;
                    setState(() => _reports = list);
                    setLocal(() {});
                  }
                },
                onResolve: (id, upheld) async {
                  final r = await _storage.resolveReport(
                    reportId: id,
                    upheld: upheld,
                  );
                  if (!context.mounted) return;
                  AppToast.show(context, r.message);
                  final list = await _storage.loadReports();
                  final hiddenPosts = await _storage.loadHiddenPostIds();
                  final hiddenAuthors = await _storage.loadHiddenAuthorIds();
                  if (!mounted) return;
                  setState(() {
                    _reports = list;
                    _hiddenPosts = hiddenPosts;
                    _hiddenAuthors = hiddenAuthors;
                  });
                  setLocal(() {});
                },
              );
            },
          );
        },
      ),
    );
    if (mounted) setState(() {});
  }

  List<UserProfile> get _blockedProfiles {
    final list = <UserProfile>[];
    for (final id in _blocked) {
      final u = _resolveUser(id);
      list.add(
        u ??
            UserProfile(
              id: id,
              displayName: '已屏蔽创作者',
              bio: '内容已隐藏',
              city: '拾岸',
              avatarUrl: '',
              initial: '屏',
            ),
      );
    }
    list.sort((a, b) => a.displayName.compareTo(b.displayName));
    return list;
  }

  Future<void> _openBlockedList() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setLocal) {
              return BlockedListScreen(
                users: _blockedProfiles,
                onUnblock: (id) {
                  _unblockAuthor(id);
                  setLocal(() {});
                  AppToast.show(context, '已解除拉黑');
                },
                onClearAll: () {
                  _clearBlocked();
                  setLocal(() {});
                  AppToast.show(context, '已清空拉黑名单');
                },
              );
            },
          );
        },
      ),
    );
    if (mounted) setState(() {});
  }

  void _toggleFollow(String userId) {
    if (userId == UserProfile.meId) return;
    if (_isInteractionRestricted(userId)) {
      AppToast.show(context, '对方已隐藏或拉黑，无法互动');
      return;
    }
    setState(() {
      if (_following.contains(userId)) {
        _following.remove(userId);
      } else {
        _following.add(userId);
      }
    });
    _persist();
  }

  Future<void> _refreshFeed() async {
    final posts = await _storage.loadPosts();
    final blocked = await _storage.loadBlockedAuthors();
    final hiddenPosts = await _storage.loadHiddenPostIds();
    final hiddenAuthors = await _storage.loadHiddenAuthorIds();
    if (!mounted) return;
    setState(() {
      _posts = posts;
      _blocked = blocked;
      _hiddenPosts = hiddenPosts;
      _hiddenAuthors = hiddenAuthors;
    });
  }

  void _onRadarTap() {
    setState(() {
      _filterByRadar = !_filterByRadar;
    });
    _storage.saveRadarMoodId(_radarMood.id);
  }

  List<Post> _postsByAuthor(String authorId) {
    return _posts
        .where(
          (p) =>
              p.authorId == authorId &&
              !_isVisuallyHidden(p),
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _openAuthor(String authorId) async {
    if (_isInteractionRestricted(authorId)) {
      AppToast.show(context, '该用户内容已隐藏，主页暂不可访问');
      return;
    }
    final profile = _resolveUser(authorId);
    if (profile == null) {
      AppToast.show(context, '暂无法查看该创作者');
      return;
    }
    if (profile.isMe) {
      setState(() => _tab = DockTab.profile);
      return;
    }
    await showUserProfileSheet(
      context,
      profile: profile,
      posts: _postsByAuthor(authorId),
      isFollowing: _following.contains(authorId),
      isBlocked: _blocked.contains(authorId),
      onToggleFollow: () => _toggleFollow(authorId),
      onToggleReaction: _toggleReaction,
      onPostSafety: (post) async {
        Navigator.of(context).maybePop();
        await _handlePostSafety(post);
      },
      onReportUser: () async {
        Navigator.of(context).maybePop();
        final draft = await showReportSheet(
          context,
          title: profile.displayName,
          initialType: ReportTargetType.user,
          allowUserReport: false,
        );
        if (draft == null || !mounted) return;
        await _submitReport(
          type: ReportTargetType.user,
          targetId: authorId,
          authorId: authorId,
          label: profile.displayName,
          reason: draft.reason,
          note: draft.note,
        );
      },
      onToggleBlock: () {
        Navigator.of(context).maybePop();
        if (_blocked.contains(authorId)) {
          _unblockAuthor(authorId);
          AppToast.show(context, '已解除拉黑');
        } else {
          _blockAuthor(authorId);
          AppToast.show(context, '已拉黑，对方内容已隐藏');
        }
      },
    );
  }

  Future<void> _editProfile() async {
    final updated = await showEditProfileSheet(context, profile: _me);
    if (updated == null || !mounted) return;
    setState(() {
      _me = updated;
      for (var i = 0; i < _posts.length; i++) {
        if (_posts[i].isMine) {
          _posts[i] = _posts[i].copyWith(
            authorName: updated.displayName,
            city: updated.city,
          );
        }
      }
    });
    await _persist();
    await _storage.syncCurrentAccountProfile(_me);
    final account = await _storage.loadCurrentAccount();
    if (mounted) {
      setState(() => _account = account);
      AppToast.show(context, '个人资料已更新');
    }
  }

  Future<void> _openFollowListLive(FollowListMode mode) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setLocal) {
              return FollowListScreen(
                mode: mode,
                users: _profilesForIds(
                  mode == FollowListMode.following ? _following : _followers,
                ),
                followingIds: Set<String>.from(_following),
                onToggleFollow: (id) {
                  _toggleFollow(id);
                  setLocal(() {});
                },
                onOpenUser: (user) async {
                  Navigator.pop(context);
                  await _openAuthor(user.id);
                },
              );
            },
          );
        },
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _sendCoastLetter(CoastLetter letter) async {
    setState(() {
      _letterPool.insert(0, letter);
      _mailboxDay.hasSent = true;
      _mailboxDay.sentLetterId = letter.id;
      if (_myThanksReceived == 0) {
        _myThanksReceived = 3;
      }
    });
    await _persist();
  }

  Future<CoastLetter?> _openCoastLetter() async {
    if (!_mailboxDay.hasSent || _mailboxDay.hasOpened) return null;
    final openedIds = _letterCollection.map((e) => e.id).toSet();
    if (_mailboxDay.openedLetterId != null) {
      openedIds.add(_mailboxDay.openedLetterId!);
    }
    final picked = pickRandomLetter(
      pool: _letterPool,
      excludeId: _mailboxDay.sentLetterId,
      openedHistoryIds: openedIds,
    );
    if (picked == null) return null;
    setState(() {
      _mailboxDay.hasOpened = true;
      _mailboxDay.openedLetterId = picked.id;
    });
    await _persist();
    return picked;
  }

  Future<void> _thankCoastLetter(String letterId) async {
    setState(() {
      _mailboxDay.hasThanked = true;
      for (final letter in _letterPool) {
        if (letter.id == letterId) {
          letter.thankCount += 1;
        }
      }
    });
    await _persist();
  }

  Future<void> _archiveCoastLetter(CoastLetter letter) async {
    if (_letterCollection.any((e) => e.id == letter.id)) return;
    setState(() {
      _letterCollection.insert(0, letter);
    });
    await _persist();
  }

  Future<void> _openPost() async {
    final draft = await showPostSheet(context);
    if (draft == null || !mounted) return;

    final memoNo = await _storage.nextMemoNo();
    final stamp = '刚刚 · ${_me.city} · ${draft.category.label}';
    final post = Post(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      authorId: UserProfile.meId,
      authorName: _me.displayName,
      body: draft.body,
      memoBack: draft.body,
      imageUrl: draft.imageUrl,
      mood: draft.mood,
      category: draft.category,
      stampLabel: stamp,
      city: _me.city,
      createdAt: DateTime.now(),
      memoNo: memoNo,
      isMine: true,
      healCount: 1,
      cheerCount: 1,
      luckCount: 0,
      hugCount: 0,
    );

    setState(() {
      _posts.insert(0, post);
      _radarMood = draft.mood;
      _categoryFilter = null;
      _tab = DockTab.feed;
      _filterByRadar = false;
    });
    await _persist();
    if (mounted) {
      AppToast.show(context, '${draft.category.label}已放飞入社区海面 🌊');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: GlimmerBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            bottom: false,
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.twilight),
                  )
                : Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: KeyedSubtree(
                            key: ValueKey(_tab),
                            child: _buildTab(),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FloatingDock(
                          current: _tab,
                          onSelect: (t) => setState(() => _tab = t),
                          onPost: _openPost,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab() {
    switch (_tab) {
      case DockTab.feed:
        return FeedScreen(
          posts: _visiblePosts,
          radarMood: _radarMood,
          filterByRadar: _filterByRadar,
          categoryFilter: _categoryFilter,
          followingIds: _following,
          onToggleReaction: _toggleReaction,
          onRefresh: _refreshFeed,
          onRadarTap: _onRadarTap,
          onCategoryFilter: (c) => setState(() => _categoryFilter = c),
          onToggleFollow: _toggleFollow,
          onOpenAuthor: _openAuthor,
          onPostSafety: _handlePostSafety,
        );
      case DockTab.mailbox:
        return MailboxScreen(
          dayState: _mailboxDay,
          pool: _letterPool,
          collection: _letterCollection,
          myThanksReceived: _myThanksReceived,
          authorAlias: '匿名旅人·${_me.avatarLetter}',
          city: _me.city,
          onSendLetter: _sendCoastLetter,
          onOpenLetter: _openCoastLetter,
          onThankLetter: _thankCoastLetter,
          onArchiveLetter: _archiveCoastLetter,
        );
      case DockTab.messages:
        return MessagesScreen(
          followingProfiles: _followingProfiles,
          followingPosts: _followingPosts,
          updatedAuthorIds: _updatedAuthorIds,
          notices: List<InteractionNotice>.from(_notices)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
          followingIds: _following,
          onToggleReaction: _toggleReaction,
          onOpenAuthor: _openAuthor,
          onToggleFollow: _toggleFollow,
          onMarkNoticesRead: _markNoticesRead,
          onPostSafety: _handlePostSafety,
        );
      case DockTab.profile:
        final drawer = _myPosts.isNotEmpty
            ? _myPosts
            : _visiblePosts.take(12).toList();
        final forDrawer = drawer.isEmpty
            ? SeedData.initialPosts()
                .map((p) => p.copyWith(isMine: true))
                .toList()
            : drawer;
        return ProfileScreen(
          me: _me,
          accountLabel: _account?.maskedAccount,
          myPosts: forDrawer,
          totalResonance: _totalResonance,
          followingCount: _following.length,
          followerCount: _followers.length,
          settings: _settings,
          blockedCount: _blocked.length,
          onOpenPost: (_) {
            setState(() => _tab = DockTab.feed);
          },
          onEditProfile: _editProfile,
          onOpenFollowing: () => _openFollowListLive(FollowListMode.following),
          onOpenFollowers: () => _openFollowListLive(FollowListMode.followers),
          onSettingsChanged: (s) {
            setState(() => _settings = s);
            _persist();
            AppToast.show(context, '设置已保存');
          },
          onOpenMailboxCollection: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LetterCollectionScreen(
                  letters: _letterCollection,
                ),
              ),
            );
          },
          onOpenBlocked: _openBlockedList,
          onOpenContentSafety: _openContentSafety,
          reportCount: _reports.length,
          pendingReportCount: _reports.where((r) => r.isOpen).length,
          onChangePassword: _changePassword,
          onLogout: _logout,
          onDeleteAccount: _deleteAccount,
          onOpenUserAgreement: () =>
              openLegalDoc(context, LegalDocType.userAgreement),
          onOpenPrivacyPolicy: () =>
              openLegalDoc(context, LegalDocType.privacyPolicy),
        );
    }
  }
}
