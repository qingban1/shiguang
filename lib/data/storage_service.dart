import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../models/auth_account.dart';
import '../models/coast_letter.dart';
import '../models/content_report.dart';
import '../models/interaction_notice.dart';
import '../models/post.dart';
import '../models/user_profile.dart';
import 'mailbox_seed.dart';
import 'notice_seed.dart';
import 'seed_data.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const _kPosts = 'glimmer_posts_v2';
  static const _kBlocked = 'glimmer_blocked_v1';
  static const _kMemoSeq = 'glimmer_memo_seq_v1';
  static const _kRadarMood = 'glimmer_radar_mood_v1';
  static const _kMeProfile = 'glimmer_me_profile_v1';
  static const _kFollowing = 'glimmer_following_v1';
  static const _kFollowers = 'glimmer_followers_v1';
  static const _kLetterPool = 'glimmer_letter_pool_v1';
  static const _kLetterCollection = 'glimmer_letter_collection_v1';
  static const _kMailboxDay = 'glimmer_mailbox_day_v1';
  static const _kMyThanksReceived = 'glimmer_my_thanks_v1';
  static const _kNotices = 'glimmer_notices_v1';
  static const _kAppSettings = 'glimmer_app_settings_v1';
  static const _kAuthAccounts = 'glimmer_auth_accounts_v1';
  static const _kAuthSession = 'glimmer_auth_session_v2';
  static const _kVerifyCode = 'glimmer_verify_code_v1';
  static const _kReports = 'glimmer_reports_v1';
  static const _kHiddenPosts = 'glimmer_hidden_posts_v1';
  static const _kHiddenAuthors = 'glimmer_hidden_authors_v1';

  /// 登录保持时长
  static const sessionTtl = Duration(days: 30);

  /// 验证码有效期
  static const verifyCodeTtl = Duration(minutes: 5);

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    final p = _prefs;
    if (p == null) {
      throw StateError('StorageService 未初始化，请先调用 init()');
    }
    return p;
  }

  Future<List<Post>> loadPosts() async {
    await init();
    final raw = prefs.getString(_kPosts);
    if (raw == null || raw.isEmpty) {
      final seed = SeedData.initialPosts();
      await savePosts(seed);
      return seed;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final posts = list
          .map((e) => Post.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
      // 合并新增种子帖，保留用户已有回响状态
      final existingIds = posts.map((p) => p.id).toSet();
      var merged = false;
      for (final seed in SeedData.initialPosts()) {
        if (!existingIds.contains(seed.id)) {
          posts.add(seed);
          merged = true;
        }
      }
      if (merged) await savePosts(posts);
      return posts;
    } catch (_) {
      final seed = SeedData.initialPosts();
      await savePosts(seed);
      return seed;
    }
  }

  Future<void> savePosts(List<Post> posts) async {
    await init();
    final encoded = jsonEncode(posts.map((e) => e.toJson()).toList());
    await prefs.setString(_kPosts, encoded);
  }

  Future<Set<String>> loadBlockedAuthors() async {
    await init();
    final list = prefs.getStringList(_kBlocked) ?? const <String>[];
    return list.toSet();
  }

  Future<void> saveBlockedAuthors(Set<String> ids) async {
    await init();
    await prefs.setStringList(_kBlocked, ids.toList());
  }

  Future<Set<String>> loadHiddenPostIds() async {
    await init();
    return (prefs.getStringList(_kHiddenPosts) ?? const <String>[]).toSet();
  }

  Future<void> saveHiddenPostIds(Set<String> ids) async {
    await init();
    await prefs.setStringList(_kHiddenPosts, ids.toList());
  }

  Future<Set<String>> loadHiddenAuthorIds() async {
    await init();
    return (prefs.getStringList(_kHiddenAuthors) ?? const <String>[]).toSet();
  }

  Future<void> saveHiddenAuthorIds(Set<String> ids) async {
    await init();
    await prefs.setStringList(_kHiddenAuthors, ids.toList());
  }

  Future<List<ContentReport>> loadReports() async {
    await init();
    final raw = prefs.getString(_kReports);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) => ContentReport.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveReports(List<ContentReport> reports) async {
    await init();
    await prefs.setString(
      _kReports,
      jsonEncode(reports.map((e) => e.toJson()).toList()),
    );
  }

  /// 提交举报：防重复 / 防短时恶意刷报
  Future<({bool ok, String message, ContentReport? report})> submitReport({
    required ReportTargetType targetType,
    required String targetId,
    required String targetAuthorId,
    required String targetLabel,
    required ReportReason reason,
    required String note,
  }) async {
    final reports = await loadReports();
    final now = DateTime.now();

    final openDup = reports.any(
      (r) =>
          r.targetType == targetType &&
          r.targetId == targetId &&
          r.isOpen,
    );
    if (openDup) {
      return (ok: false, message: '该对象已有进行中的举报，请勿重复提交', report: null);
    }

    final rejectedRecently = reports.any(
      (r) =>
          r.targetType == targetType &&
          r.targetId == targetId &&
          r.status == ReportStatus.rejected &&
          r.resolvedAt != null &&
          now.difference(r.resolvedAt!).inHours < 24,
    );
    if (rejectedRecently) {
      return (ok: false, message: '该举报近期已驳回，24 小时内不可再次提交', report: null);
    }

    final hourAgo = now.subtract(const Duration(hours: 1));
    final recentCount =
        reports.where((r) => r.createdAt.isAfter(hourAgo)).length;
    if (recentCount >= 5) {
      return (ok: false, message: '提交过于频繁，请稍后再试', report: null);
    }

    final report = ContentReport(
      id: 'rpt_${now.millisecondsSinceEpoch}',
      targetType: targetType,
      targetId: targetId,
      targetAuthorId: targetAuthorId,
      targetLabel: targetLabel,
      reason: reason,
      note: note.trim(),
      createdAt: now,
      status: ReportStatus.pending,
    );
    reports.insert(0, report);
    await saveReports(reports);
    return (ok: true, message: '举报已提交，将进入审核流程', report: report);
  }

  Future<({bool ok, String message})> startReview(String reportId) async {
    final reports = await loadReports();
    final i = reports.indexWhere((r) => r.id == reportId);
    if (i < 0) return (ok: false, message: '举报不存在');
    if (reports[i].status != ReportStatus.pending) {
      return (ok: false, message: '当前状态不可开始审核');
    }
    reports[i].status = ReportStatus.reviewing;
    await saveReports(reports);
    return (ok: true, message: '已进入审核');
  }

  Future<({bool ok, String message})> resolveReport({
    required String reportId,
    required bool upheld,
    String note = '',
  }) async {
    final reports = await loadReports();
    final i = reports.indexWhere((r) => r.id == reportId);
    if (i < 0) return (ok: false, message: '举报不存在');
    final r = reports[i];
    if (!r.isOpen) return (ok: false, message: '该举报已处理完毕');

    r.status = upheld ? ReportStatus.upheld : ReportStatus.rejected;
    r.resolvedAt = DateTime.now();
    r.resolutionNote = note.trim().isEmpty
        ? (upheld ? '违规成立，已隐藏相关内容' : '经审核未发现违规')
        : note.trim();
    await saveReports(reports);

    if (upheld) {
      if (r.targetType == ReportTargetType.post) {
        final hidden = await loadHiddenPostIds();
        hidden.add(r.targetId);
        await saveHiddenPostIds(hidden);
      } else {
        final hiddenAuthors = await loadHiddenAuthorIds();
        hiddenAuthors.add(r.targetAuthorId.isEmpty ? r.targetId : r.targetAuthorId);
        await saveHiddenAuthorIds(hiddenAuthors);
      }
    }
    return (
      ok: true,
      message: upheld ? '已判定成立并隐藏相关内容' : '已驳回该举报',
    );
  }

  Future<int> nextMemoNo() async {
    await init();
    final current = prefs.getInt(_kMemoSeq) ?? 1100;
    final next = current + 1;
    await prefs.setInt(_kMemoSeq, next);
    return next;
  }

  Future<String?> loadRadarMoodId() async {
    await init();
    return prefs.getString(_kRadarMood);
  }

  Future<void> saveRadarMoodId(String? id) async {
    await init();
    if (id == null) {
      await prefs.remove(_kRadarMood);
    } else {
      await prefs.setString(_kRadarMood, id);
    }
  }

  Future<UserProfile> loadMeProfile() async {
    await init();
    final raw = prefs.getString(_kMeProfile);
    if (raw == null || raw.isEmpty) {
      final me = SeedData.defaultMe();
      await saveMeProfile(me);
      return me;
    }
    try {
      return UserProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      final me = SeedData.defaultMe();
      await saveMeProfile(me);
      return me;
    }
  }

  Future<void> saveMeProfile(UserProfile profile) async {
    await init();
    await prefs.setString(_kMeProfile, jsonEncode(profile.toJson()));
  }

  Future<Set<String>> loadFollowingIds() async {
    await init();
    final list = prefs.getStringList(_kFollowing);
    if (list == null) {
      // 默认关注一位，方便首次进入可见
      final seed = <String>{'author_coffee'};
      await saveFollowingIds(seed);
      return seed;
    }
    return list.toSet();
  }

  Future<void> saveFollowingIds(Set<String> ids) async {
    await init();
    await prefs.setStringList(_kFollowing, ids.toList());
  }

  Future<Set<String>> loadFollowerIds() async {
    await init();
    final list = prefs.getStringList(_kFollowers);
    if (list == null) {
      final seed = SeedData.defaultFollowerIds().toSet();
      await saveFollowerIds(seed);
      return seed;
    }
    return list.toSet();
  }

  Future<void> saveFollowerIds(Set<String> ids) async {
    await init();
    await prefs.setStringList(_kFollowers, ids.toList());
  }

  Future<List<CoastLetter>> loadLetterPool() async {
    await init();
    final raw = prefs.getString(_kLetterPool);
    if (raw == null || raw.isEmpty) {
      final seed = MailboxSeed.publicPool();
      await saveLetterPool(seed);
      return seed;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CoastLetter.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      final seed = MailboxSeed.publicPool();
      await saveLetterPool(seed);
      return seed;
    }
  }

  Future<void> saveLetterPool(List<CoastLetter> letters) async {
    await init();
    await prefs.setString(
      _kLetterPool,
      jsonEncode(letters.map((e) => e.toJson()).toList()),
    );
  }

  Future<List<CoastLetter>> loadLetterCollection() async {
    await init();
    final raw = prefs.getString(_kLetterCollection);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => CoastLetter.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveLetterCollection(List<CoastLetter> letters) async {
    await init();
    await prefs.setString(
      _kLetterCollection,
      jsonEncode(letters.map((e) => e.toJson()).toList()),
    );
  }

  Future<MailboxDayState> loadMailboxDay() async {
    await init();
    final today = MailboxDayState.todayKey();
    final raw = prefs.getString(_kMailboxDay);
    if (raw == null || raw.isEmpty) {
      return MailboxDayState(dateKey: today);
    }
    try {
      final state = MailboxDayState.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      if (state.dateKey != today) {
        return MailboxDayState(dateKey: today);
      }
      return state;
    } catch (_) {
      return MailboxDayState(dateKey: today);
    }
  }

  Future<void> saveMailboxDay(MailboxDayState state) async {
    await init();
    await prefs.setString(_kMailboxDay, jsonEncode(state.toJson()));
  }

  Future<int> loadMyThanksReceived() async {
    await init();
    return prefs.getInt(_kMyThanksReceived) ?? 0;
  }

  Future<void> saveMyThanksReceived(int count) async {
    await init();
    await prefs.setInt(_kMyThanksReceived, count);
  }

  Future<List<InteractionNotice>> loadNotices() async {
    await init();
    final raw = prefs.getString(_kNotices);
    if (raw == null || raw.isEmpty) {
      final seed = NoticeSeed.initial();
      await saveNotices(seed);
      return seed;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) => InteractionNotice.fromJson(
              Map<String, dynamic>.from(e as Map),
            ),
          )
          .toList();
    } catch (_) {
      final seed = NoticeSeed.initial();
      await saveNotices(seed);
      return seed;
    }
  }

  Future<void> saveNotices(List<InteractionNotice> notices) async {
    await init();
    await prefs.setString(
      _kNotices,
      jsonEncode(notices.map((e) => e.toJson()).toList()),
    );
  }

  Future<AppSettings> loadAppSettings() async {
    await init();
    final raw = prefs.getString(_kAppSettings);
    if (raw == null || raw.isEmpty) {
      final s = AppSettings();
      await saveAppSettings(s);
      return s;
    }
    try {
      return AppSettings.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return AppSettings();
    }
  }

  Future<void> saveAppSettings(AppSettings settings) async {
    await init();
    await prefs.setString(_kAppSettings, jsonEncode(settings.toJson()));
  }

  Future<List<AuthAccount>> loadAuthAccounts() async {
    await init();
    final raw = prefs.getString(_kAuthAccounts);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) => AuthAccount.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveAuthAccounts(List<AuthAccount> accounts) async {
    await init();
    await prefs.setString(
      _kAuthAccounts,
      jsonEncode(accounts.map((e) => e.toJson()).toList()),
    );
  }

  Future<AuthSession?> loadAuthSession() async {
    await init();
    // 兼容旧版仅存 accountId 的会话
    final legacy = prefs.getString('glimmer_auth_session_v1');
    final raw = prefs.getString(_kAuthSession);
    if ((raw == null || raw.isEmpty) && legacy != null && legacy.isNotEmpty) {
      final now = DateTime.now();
      return AuthSession(
        accountId: legacy,
        issuedAt: now,
        expiresAt: now.add(sessionTtl),
      );
    }
    if (raw == null || raw.isEmpty) return null;
    try {
      return AuthSession.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAuthSession(AuthSession? session) async {
    await init();
    await prefs.remove('glimmer_auth_session_v1');
    if (session == null) {
      await prefs.remove(_kAuthSession);
    } else {
      await prefs.setString(_kAuthSession, jsonEncode(session.toJson()));
    }
  }

  Future<AuthSession> _issueSession(String accountId) async {
    final now = DateTime.now();
    final session = AuthSession(
      accountId: accountId,
      issuedAt: now,
      expiresAt: now.add(sessionTtl),
    );
    await saveAuthSession(session);
    return session;
  }

  /// 登录保持：有效会话则顺延过期时间
  Future<void> touchSession() async {
    final session = await loadAuthSession();
    if (session == null || session.isExpired) return;
    final accounts = await loadAuthAccounts();
    if (!accounts.any((a) => a.id == session.accountId)) return;
    await _issueSession(session.accountId);
  }

  /// 返回值：loggedIn / expired（曾登录但已过期）
  Future<({bool loggedIn, bool expired})> checkLoginState() async {
    final session = await loadAuthSession();
    if (session == null) {
      return (loggedIn: false, expired: false);
    }
    final accounts = await loadAuthAccounts();
    final exists = accounts.any((a) => a.id == session.accountId);
    if (!exists) {
      await saveAuthSession(null);
      return (loggedIn: false, expired: false);
    }
    if (session.isExpired) {
      await saveAuthSession(null);
      return (loggedIn: false, expired: true);
    }
    await touchSession();
    return (loggedIn: true, expired: false);
  }

  Future<bool> isLoggedIn() async {
    final state = await checkLoginState();
    return state.loggedIn;
  }

  Future<AuthAccount?> loadCurrentAccount() async {
    final session = await loadAuthSession();
    if (session == null || session.isExpired) return null;
    final accounts = await loadAuthAccounts();
    for (final a in accounts) {
      if (a.id == session.accountId) return a;
    }
    return null;
  }

  Future<AuthAccount?> findAccountByLogin(String account) async {
    final key = account.trim().toLowerCase();
    final accounts = await loadAuthAccounts();
    for (final a in accounts) {
      if (a.account.trim().toLowerCase() == key) return a;
    }
    return null;
  }

  Future<PendingVerifyCode?> _loadVerifyCode() async {
    await init();
    final raw = prefs.getString(_kVerifyCode);
    if (raw == null || raw.isEmpty) return null;
    try {
      return PendingVerifyCode.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveVerifyCode(PendingVerifyCode? code) async {
    await init();
    if (code == null) {
      await prefs.remove(_kVerifyCode);
    } else {
      await prefs.setString(_kVerifyCode, jsonEncode(code.toJson()));
    }
  }

  Future<({bool ok, String message, String? code})> sendVerificationCode({
    required String account,
    required VerifyPurpose purpose,
  }) async {
    final login = account.trim();
    if (!_looksLikeAccount(login)) {
      return (ok: false, message: '请输入有效的手机号或邮箱', code: null);
    }
    final existing = await findAccountByLogin(login);
    if (purpose == VerifyPurpose.register && existing != null) {
      return (ok: false, message: '该账号已注册，请直接登录', code: null);
    }
    if (purpose == VerifyPurpose.reset && existing == null) {
      return (ok: false, message: '账号不存在，请先注册', code: null);
    }
    final code = (100000 + Random().nextInt(900000)).toString();
    await _saveVerifyCode(
      PendingVerifyCode(
        account: login.toLowerCase(),
        code: code,
        purpose: purpose,
        expiresAt: DateTime.now().add(verifyCodeTtl),
      ),
    );
    return (ok: true, message: '验证码已发送', code: code);
  }

  Future<({bool ok, String message})> _consumeVerifyCode({
    required String account,
    required String code,
    required VerifyPurpose purpose,
  }) async {
    final pending = await _loadVerifyCode();
    if (pending == null) {
      return (ok: false, message: '请先获取验证码');
    }
    if (pending.purpose != purpose) {
      return (ok: false, message: '验证码用途不匹配，请重新获取');
    }
    if (pending.account != account.trim().toLowerCase()) {
      return (ok: false, message: '验证码与账号不匹配');
    }
    if (pending.isExpired) {
      await _saveVerifyCode(null);
      return (ok: false, message: '验证码已过期，请重新获取');
    }
    if (pending.code != code.trim()) {
      return (ok: false, message: '验证码不正确');
    }
    await _saveVerifyCode(null);
    return (ok: true, message: '验证成功');
  }

  Future<({bool ok, String message, AuthAccount? account})> registerAccount({
    required String account,
    required String password,
    required String displayName,
    required String verifyCode,
    required bool agreedTerms,
  }) async {
    final login = account.trim();
    final name = displayName.trim();
    if (!agreedTerms) {
      return (ok: false, message: '请先阅读并同意用户协议与隐私政策', account: null);
    }
    if (login.isEmpty) {
      return (ok: false, message: '请输入手机号或邮箱', account: null);
    }
    if (!_looksLikeAccount(login)) {
      return (ok: false, message: '请输入有效的手机号或邮箱', account: null);
    }
    if (password.length < 6) {
      return (ok: false, message: '密码至少 6 位', account: null);
    }
    if (name.isEmpty) {
      return (ok: false, message: '请填写昵称', account: null);
    }
    if (await findAccountByLogin(login) != null) {
      return (ok: false, message: '该账号已注册，请直接登录', account: null);
    }
    final verified = await _consumeVerifyCode(
      account: login,
      code: verifyCode,
      purpose: VerifyPurpose.register,
    );
    if (!verified.ok) {
      return (ok: false, message: verified.message, account: null);
    }

    final now = DateTime.now();
    final created = AuthAccount(
      id: 'acc_${now.millisecondsSinceEpoch}',
      account: login,
      passwordHash: AuthAccount.hashPassword(password),
      displayName: name,
      city: '杭州',
      bio: '记录微小的生活，感知同频的呼吸。',
      avatarUrl:
          'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=200&q=80',
      agreedTermsAt: now,
      verifiedAt: now,
    );
    final accounts = await loadAuthAccounts();
    accounts.add(created);
    await saveAuthAccounts(accounts);
    await _issueSession(created.id);
    await saveMeProfile(_profileFromAccount(created));
    return (ok: true, message: '注册成功', account: created);
  }

  Future<({bool ok, String message, AuthAccount? account})> loginAccount({
    required String account,
    required String password,
    required bool agreedTerms,
  }) async {
    final login = account.trim();
    if (!agreedTerms) {
      return (ok: false, message: '请先阅读并同意用户协议与隐私政策', account: null);
    }
    if (login.isEmpty || password.isEmpty) {
      return (ok: false, message: '请输入账号和密码', account: null);
    }
    if (!_looksLikeAccount(login)) {
      return (ok: false, message: '请输入有效的手机号或邮箱', account: null);
    }
    final found = await findAccountByLogin(login);
    if (found == null) {
      return (ok: false, message: '账号不存在，请先注册', account: null);
    }
    if (!found.matchesPassword(password)) {
      return (ok: false, message: '密码不正确', account: null);
    }
    await _issueSession(found.id);
    await saveMeProfile(_profileFromAccount(found));
    return (ok: true, message: '登录成功', account: found);
  }

  Future<void> logout() async {
    await saveAuthSession(null);
    await _saveVerifyCode(null);
  }

  Future<({bool ok, String message})> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final current = await loadCurrentAccount();
    if (current == null) {
      return (ok: false, message: '当前未登录或登录已过期');
    }
    if (!current.matchesPassword(oldPassword)) {
      return (ok: false, message: '当前密码不正确');
    }
    if (newPassword.length < 6) {
      return (ok: false, message: '新密码至少 6 位');
    }
    if (oldPassword == newPassword) {
      return (ok: false, message: '新密码不能与当前密码相同');
    }
    final accounts = await loadAuthAccounts();
    final i = accounts.indexWhere((a) => a.id == current.id);
    if (i < 0) {
      return (ok: false, message: '账号不存在');
    }
    accounts[i].passwordHash = AuthAccount.hashPassword(newPassword);
    await saveAuthAccounts(accounts);
    await _issueSession(current.id);
    return (ok: true, message: '密码已更新');
  }

  Future<({bool ok, String message})> resetPassword({
    required String account,
    required String verifyCode,
    required String newPassword,
  }) async {
    final login = account.trim();
    if (!_looksLikeAccount(login)) {
      return (ok: false, message: '请输入有效的手机号或邮箱');
    }
    if (newPassword.length < 6) {
      return (ok: false, message: '新密码至少 6 位');
    }
    final found = await findAccountByLogin(login);
    if (found == null) {
      return (ok: false, message: '账号不存在，请先注册');
    }
    final verified = await _consumeVerifyCode(
      account: login,
      code: verifyCode,
      purpose: VerifyPurpose.reset,
    );
    if (!verified.ok) return verified;

    final accounts = await loadAuthAccounts();
    final i = accounts.indexWhere((a) => a.id == found.id);
    if (i < 0) return (ok: false, message: '账号不存在');
    accounts[i].passwordHash = AuthAccount.hashPassword(newPassword);
    await saveAuthAccounts(accounts);
    await saveAuthSession(null);
    return (ok: true, message: '密码已重置，请使用新密码登录');
  }

  /// 注销：校验密码后删除账号与个人相关内容，并清除登录态
  Future<({bool ok, String message})> deleteCurrentAccount({
    required String password,
  }) async {
    final current = await loadCurrentAccount();
    if (current == null) {
      return (ok: false, message: '当前未登录或登录已过期');
    }
    if (password.isEmpty) {
      return (ok: false, message: '请输入当前密码');
    }
    if (!current.matchesPassword(password)) {
      return (ok: false, message: '密码不正确，无法注销');
    }

    final accounts = await loadAuthAccounts();
    accounts.removeWhere((a) => a.id == current.id);
    await saveAuthAccounts(accounts);

    // 删除个人资料与用户生成内容
    final posts = await loadPosts();
    final myPostIds = posts
        .where((p) => p.isMine || p.authorId == UserProfile.meId)
        .map((p) => p.id)
        .toSet();
    posts.removeWhere((p) => p.isMine || p.authorId == UserProfile.meId);
    await savePosts(posts);

    final reports = await loadReports();
    reports.removeWhere(
      (r) =>
          r.targetAuthorId == UserProfile.meId ||
          myPostIds.contains(r.targetId) ||
          (r.targetType == ReportTargetType.user &&
              r.targetId == UserProfile.meId),
    );
    await saveReports(reports);

    final hiddenPosts = await loadHiddenPostIds();
    hiddenPosts.removeAll(myPostIds);
    await saveHiddenPostIds(hiddenPosts);

    final hiddenAuthors = await loadHiddenAuthorIds();
    hiddenAuthors.remove(UserProfile.meId);
    await saveHiddenAuthorIds(hiddenAuthors);

    // 处理账号相关信箱 UGC：移除本人投递
    final pool = await loadLetterPool();
    pool.removeWhere(
      (l) => l.isMine || l.authorId == UserProfile.meId || l.authorId == current.id,
    );
    await saveLetterPool(pool);

    await saveMeProfile(SeedData.defaultMe());
    await saveFollowingIds({});
    await saveFollowerIds({});
    await saveBlockedAuthors({});
    await saveLetterCollection([]);
    await saveMyThanksReceived(0);
    await saveNotices([]);
    await saveMailboxDay(
      MailboxDayState(dateKey: MailboxDayState.todayKey()),
    );
    await saveAppSettings(AppSettings());
    await saveAuthSession(null);
    await _saveVerifyCode(null);

    return (ok: true, message: '账号已注销');
  }

  Future<void> syncCurrentAccountProfile(UserProfile profile) async {
    final current = await loadCurrentAccount();
    if (current == null) return;
    final accounts = await loadAuthAccounts();
    final i = accounts.indexWhere((a) => a.id == current.id);
    if (i < 0) return;
    accounts[i].displayName = profile.displayName;
    accounts[i].bio = profile.bio;
    accounts[i].city = profile.city;
    accounts[i].avatarUrl = profile.avatarUrl;
    await saveAuthAccounts(accounts);
  }

  UserProfile _profileFromAccount(AuthAccount account) {
    return UserProfile(
      id: UserProfile.meId,
      displayName: account.displayName,
      bio: account.bio,
      city: account.city,
      avatarUrl: account.avatarUrl,
      initial: account.displayName.isEmpty
          ? '拾'
          : String.fromCharCodes(account.displayName.runes.take(1)),
    );
  }

  bool _looksLikeAccount(String value) {
    final v = value.trim();
    if (RegExp(r'^1\d{10}$').hasMatch(v)) return true;
    if (RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) return true;
    return false;
  }
}
