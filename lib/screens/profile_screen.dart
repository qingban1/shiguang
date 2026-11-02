import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/app_settings.dart';
import '../models/post.dart';
import '../models/user_profile.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/user_avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.me,
    this.accountLabel,
    required this.myPosts,
    required this.totalResonance,
    required this.followingCount,
    required this.followerCount,
    required this.settings,
    required this.onOpenPost,
    required this.onEditProfile,
    required this.onOpenFollowing,
    required this.onOpenFollowers,
    required this.onSettingsChanged,
    required this.onOpenMailboxCollection,
    required this.blockedCount,
    required this.onOpenBlocked,
    required this.onOpenContentSafety,
    required this.reportCount,
    required this.pendingReportCount,
    required this.onChangePassword,
    required this.onLogout,
    required this.onDeleteAccount,
    required this.onOpenUserAgreement,
    required this.onOpenPrivacyPolicy,
  });

  final UserProfile me;
  final String? accountLabel;
  final List<Post> myPosts;
  final int totalResonance;
  final int followingCount;
  final int followerCount;
  final AppSettings settings;
  final void Function(Post post) onOpenPost;
  final VoidCallback onEditProfile;
  final VoidCallback onOpenFollowing;
  final VoidCallback onOpenFollowers;
  final ValueChanged<AppSettings> onSettingsChanged;
  final VoidCallback onOpenMailboxCollection;
  final int blockedCount;
  final VoidCallback onOpenBlocked;
  final VoidCallback onOpenContentSafety;
  final int reportCount;
  final int pendingReportCount;
  final VoidCallback onChangePassword;
  final VoidCallback onLogout;
  final VoidCallback onDeleteAccount;
  final VoidCallback onOpenUserAgreement;
  final VoidCallback onOpenPrivacyPolicy;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '个人中心',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.twilightDark,
                ),
              ),
            ),
            IconButton(
              onPressed: onEditProfile,
              tooltip: '设置资料',
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.7),
              ),
              icon: const Icon(
                Icons.settings_outlined,
                size: 20,
                color: AppColors.twilightDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ProfileHero(
          me: me,
          accountLabel: accountLabel,
          postCount: myPosts.length,
          followingCount: followingCount,
          followerCount: followerCount,
          onOpenFollowing: onOpenFollowing,
          onOpenFollowers: onOpenFollowers,
        ),
        const SizedBox(height: 18),
        const _SectionTitle(title: '账号与资料'),
        const SizedBox(height: 8),
        _SettingsGroup(
          children: [
            _SettingsTile(
              icon: Icons.person_outline_rounded,
              title: '编辑资料',
              subtitle: '头像、昵称、城市与简介',
              onTap: onEditProfile,
            ),
            _SettingsTile(
              icon: Icons.mail_outline_rounded,
              title: '确幸收集册',
              subtitle: '信箱拆开的来信归档',
              onTap: onOpenMailboxCollection,
            ),
            _SettingsTile(
              icon: Icons.lock_reset_rounded,
              title: '修改密码',
              subtitle: '验证当前密码后设置新密码',
              onTap: onChangePassword,
            ),
            _SettingsTile(
              icon: Icons.logout_rounded,
              title: '退出登录',
              subtitle: '退出后需重新登录，内容仍会保留在你的账号中',
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('退出登录？'),
                    content: const Text('退出后需重新登录才能进入拾岸微光。'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('取消'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('退出'),
                      ),
                    ],
                  ),
                );
                if (ok == true) onLogout();
              },
            ),
            _SettingsTile(
              icon: Icons.person_remove_outlined,
              title: '注销账号',
              subtitle: '永久删除账号、资料与相关内容，不可恢复',
              danger: true,
              onTap: onDeleteAccount,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _SectionTitle(title: '隐私与安全'),
        const SizedBox(height: 8),
        _SettingsGroup(
          children: [
            _SettingsSwitch(
              icon: Icons.person_add_alt_1_outlined,
              title: '允许他人关注我',
              subtitle: '关闭后新关注将不再展示在互动回响',
              value: settings.allowFollow,
              onChanged: (v) {
                onSettingsChanged(
                  AppSettings(
                    notifyResonance: settings.notifyResonance,
                    notifyFollow: settings.notifyFollow,
                    notifyMailbox: settings.notifyMailbox,
                    showCityOnPosts: settings.showCityOnPosts,
                    allowFollow: v,
                    reduceMotion: settings.reduceMotion,
                  ),
                );
              },
            ),
            _SettingsSwitch(
              icon: Icons.location_on_outlined,
              title: '动态展示城市',
              subtitle: '仅模糊城市级，不存储精细定位',
              value: settings.showCityOnPosts,
              onChanged: (v) {
                onSettingsChanged(
                  AppSettings(
                    notifyResonance: settings.notifyResonance,
                    notifyFollow: settings.notifyFollow,
                    notifyMailbox: settings.notifyMailbox,
                    showCityOnPosts: v,
                    allowFollow: settings.allowFollow,
                    reduceMotion: settings.reduceMotion,
                  ),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.person_off_outlined,
              title: '已拉黑创作者',
              subtitle: blockedCount == 0 ? '暂无拉黑' : '已拉黑 $blockedCount 人',
              onTap: onOpenBlocked,
            ),
            _SettingsTile(
              icon: Icons.shield_outlined,
              title: '内容安全中心',
              subtitle: pendingReportCount > 0
                  ? '$pendingReportCount 条待审核 · 共 $reportCount 条'
                  : (reportCount == 0
                      ? '举报记录与审核处理'
                      : '共 $reportCount 条举报记录'),
              onTap: onOpenContentSafety,
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _SectionTitle(title: '通知'),
        const SizedBox(height: 8),
        _SettingsGroup(
          children: [
            _SettingsSwitch(
              icon: Icons.auto_awesome_outlined,
              title: '回响提醒',
              subtitle: '有人送来治愈 / 加油 / 好运 / 抱抱',
              value: settings.notifyResonance,
              onChanged: (v) {
                onSettingsChanged(
                  AppSettings(
                    notifyResonance: v,
                    notifyFollow: settings.notifyFollow,
                    notifyMailbox: settings.notifyMailbox,
                    showCityOnPosts: settings.showCityOnPosts,
                    allowFollow: settings.allowFollow,
                    reduceMotion: settings.reduceMotion,
                  ),
                );
              },
            ),
            _SettingsSwitch(
              icon: Icons.favorite_border_rounded,
              title: '关注提醒',
              subtitle: '有人关注你时出现在互动回响',
              value: settings.notifyFollow,
              onChanged: (v) {
                onSettingsChanged(
                  AppSettings(
                    notifyResonance: settings.notifyResonance,
                    notifyFollow: v,
                    notifyMailbox: settings.notifyMailbox,
                    showCityOnPosts: settings.showCityOnPosts,
                    allowFollow: settings.allowFollow,
                    reduceMotion: settings.reduceMotion,
                  ),
                );
              },
            ),
            _SettingsSwitch(
              icon: Icons.markunread_outlined,
              title: '信箱提醒',
              subtitle: '拆信资格与微光点亮提醒',
              value: settings.notifyMailbox,
              onChanged: (v) {
                onSettingsChanged(
                  AppSettings(
                    notifyResonance: settings.notifyResonance,
                    notifyFollow: settings.notifyFollow,
                    notifyMailbox: v,
                    showCityOnPosts: settings.showCityOnPosts,
                    allowFollow: settings.allowFollow,
                    reduceMotion: settings.reduceMotion,
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _SectionTitle(title: '通用'),
        const SizedBox(height: 8),
        _SettingsGroup(
          children: [
            _SettingsSwitch(
              icon: Icons.motion_photos_off_outlined,
              title: '减少动效',
              subtitle: '减弱呼吸光圈与翻转动画强度',
              value: settings.reduceMotion,
              onChanged: (v) {
                onSettingsChanged(
                  AppSettings(
                    notifyResonance: settings.notifyResonance,
                    notifyFollow: settings.notifyFollow,
                    notifyMailbox: settings.notifyMailbox,
                    showCityOnPosts: settings.showCityOnPosts,
                    allowFollow: settings.allowFollow,
                    reduceMotion: v,
                  ),
                );
              },
            ),
            _SettingsTile(
              icon: Icons.info_outline_rounded,
              title: '关于拾岸微光',
              subtitle: '晨曦轻社区 · 正向回响',
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('拾岸微光'),
                    content: const Text(
                      '记录微小的生活，感知同频的呼吸。\n'
                      '支持关注与粉丝；互动请使用治愈 / 加油 / 好运 / 抱抱回响。\n'
                      '版本 0.1.0',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('知道了'),
                      ),
                    ],
                  ),
                );
              },
            ),
            _SettingsTile(
              key: const Key('settings_user_agreement'),
              icon: Icons.description_outlined,
              title: '用户协议',
              subtitle: '服务条款 · 零容忍骚扰政策',
              onTap: onOpenUserAgreement,
            ),
            _SettingsTile(
              key: const Key('settings_privacy_policy'),
              icon: Icons.privacy_tip_outlined,
              title: '隐私政策',
              subtitle: '信息收集、使用与注销说明',
              onTap: onOpenPrivacyPolicy,
            ),
            _SettingsTile(
              icon: Icons.chat_bubble_outline_rounded,
              title: '意见反馈',
              subtitle: '产品建议与体验反馈',
              onTap: () {
                AppToast.show(context, '感谢反馈，我们会认真阅读每一份建议');
              },
            ),
          ],
        ),
        const SizedBox(height: 18),
        const Center(
          child: Text(
            '拾岸微光 0.1.0 · 关注同频 · 温暖回响',
            style: TextStyle(fontSize: 11, color: AppColors.slate400),
          ),
        ),
        const SizedBox(height: 4),
        const Center(
          child: Text(
            '在动态卡片上回响，是表达善意的方式',
            style: TextStyle(fontSize: 11, color: AppColors.slate400),
          ),
        ),
      ],
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.me,
    this.accountLabel,
    required this.postCount,
    required this.followingCount,
    required this.followerCount,
    required this.onOpenFollowing,
    required this.onOpenFollowers,
  });

  final UserProfile me;
  final String? accountLabel;
  final int postCount;
  final int followingCount;
  final int followerCount;
  final VoidCallback onOpenFollowing;
  final VoidCallback onOpenFollowers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.twilightDark.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              UserAvatar(profile: me, size: 72),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      me.displayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.twilightDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      accountLabel == null || accountLabel!.isEmpty
                          ? '${me.city} · 拾岸旅人'
                          : '${me.city} · $accountLabel',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (me.bio.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                me.bio,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.slate700,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatBlock(
                  value: '$postCount',
                  label: '动态',
                  onTap: () => AppToast.show(context, '可在微光流查看自己的动态'),
                ),
              ),
              Expanded(
                child: _StatBlock(
                  value: '$followingCount',
                  label: '关注',
                  onTap: onOpenFollowing,
                ),
              ),
              Expanded(
                child: _StatBlock(
                  value: '$followerCount',
                  label: '粉丝',
                  onTap: onOpenFollowers,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final String value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
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
              style: const TextStyle(fontSize: 12, color: AppColors.slate500),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w800,
        color: AppColors.slate600,
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.88),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white),
        ),
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                const Divider(
                  height: 1,
                  indent: 52,
                  color: AppColors.slate100,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.danger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final accent = danger ? AppColors.rose600 : AppColors.twilight;
    final surface = danger ? AppColors.rose50 : AppColors.twilightSurface;
    return ListTile(
      onTap: onTap == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onTap!();
            },
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: accent),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: danger ? AppColors.rose600 : AppColors.slate800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.slate500),
      ),
      trailing: onTap == null
          ? null
          : const Icon(Icons.chevron_right_rounded, color: AppColors.slate300),
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.twilightSurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: AppColors.twilight),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.slate800,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: AppColors.slate500),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeTrackColor: AppColors.twilight.withValues(alpha: 0.45),
        activeThumbColor: AppColors.twilight,
        onChanged: (v) {
          HapticFeedback.selectionClick();
          onChanged(v);
        },
      ),
    );
  }
}
