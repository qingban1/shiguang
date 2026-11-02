import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/coast_letter.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/letter_poster_modal.dart';
import 'letter_collection_screen.dart';
import 'open_letter_flow.dart';
import 'send_letter_sheet.dart';

class MailboxScreen extends StatefulWidget {
  const MailboxScreen({
    super.key,
    required this.dayState,
    required this.pool,
    required this.collection,
    required this.myThanksReceived,
    required this.authorAlias,
    required this.city,
    required this.onSendLetter,
    required this.onOpenLetter,
    required this.onThankLetter,
    required this.onArchiveLetter,
  });

  final MailboxDayState dayState;
  final List<CoastLetter> pool;
  final List<CoastLetter> collection;
  final int myThanksReceived;
  final String authorAlias;
  final String city;
  final Future<void> Function(CoastLetter letter) onSendLetter;
  final Future<CoastLetter?> Function() onOpenLetter;
  final Future<void> Function(String letterId) onThankLetter;
  final Future<void> Function(CoastLetter letter) onArchiveLetter;

  @override
  State<MailboxScreen> createState() => _MailboxScreenState();
}

class _MailboxScreenState extends State<MailboxScreen> {
  CoastLetter? _todayOpened;

  @override
  void initState() {
    super.initState();
    _syncOpened();
  }

  @override
  void didUpdateWidget(covariant MailboxScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncOpened();
  }

  void _syncOpened() {
    final id = widget.dayState.openedLetterId;
    if (id == null) {
      _todayOpened = null;
      return;
    }
    CoastLetter? found;
    for (final l in widget.pool) {
      if (l.id == id) found = l;
    }
    for (final l in widget.collection) {
      if (l.id == id) found = l;
    }
    _todayOpened = found;
  }

  Future<void> _send() async {
    if (widget.dayState.hasSent) {
      AppToast.show(context, '今日已投递过信封，明天再来吧');
      return;
    }
    final letter = await showSendLetterSheet(
      context,
      authorAlias: widget.authorAlias,
      city: widget.city,
    );
    if (letter == null || !mounted) return;
    await widget.onSendLetter(letter);
    if (!mounted) return;
    HapticFeedback.mediumImpact();
    AppToast.show(context, '信封已投向公共海岸，今日拆信资格已解锁');
  }

  Future<void> _open() async {
    if (!widget.dayState.hasSent) {
      AppToast.show(context, '请先投递今日信封，才能拆取远方来信');
      return;
    }
    if (widget.dayState.hasOpened && _todayOpened != null) {
      await _showOpened(_todayOpened!);
      return;
    }
    if (widget.dayState.hasOpened) {
      AppToast.show(context, '今日来信已拆取，明天再相遇');
      return;
    }

    final letter = await widget.onOpenLetter();
    if (!mounted) return;
    if (letter == null) {
      AppToast.show(context, '公共池暂无更多来信，稍后再试');
      return;
    }
    setState(() => _todayOpened = letter);
    await _showOpened(letter);
  }

  Future<void> _showOpened(CoastLetter letter) async {
    await showOpenLetterFlow(
      context,
      letter: letter,
      alreadyThanked: widget.dayState.hasThanked,
      onThank: () async {
        await widget.onThankLetter(letter.id);
        if (mounted) {
          AppToast.show(context, '已点亮对方信箱的一抹微光');
        }
      },
      onArchive: () async {
        await widget.onArchiveLetter(letter);
        if (mounted) {
          AppToast.show(context, '已收入确幸收集册');
        }
      },
      onPoster: () async {
        final ok = await showLetterPosterModal(context, letter: letter);
        if (ok == true && mounted) {
          AppToast.show(context, '已打开信笺预览，可用系统截图保存');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = widget.dayState;
    final canOpen = day.hasSent && !day.hasOpened;
    final reopen = day.hasSent && day.hasOpened;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                '海岸信箱',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.twilightDark,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LetterCollectionScreen(
                      letters: widget.collection,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.twilight,
                backgroundColor: AppColors.twilightSurface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                '收集册 ${widget.collection.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          '每日一投一拆 · 看完即止 · 轻量回响',
          style: TextStyle(fontSize: 12, color: AppColors.slate500),
        ),
        const SizedBox(height: 16),
        _StatusCard(
          hasSent: day.hasSent,
          hasOpened: day.hasOpened,
          thanksReceived: widget.myThanksReceived,
          poolSize: widget.pool.length,
        ),
        const SizedBox(height: 16),
        _ActionCard(
          title: '投出今日信封',
          subtitle: day.hasSent
              ? '今日已投递，等待远方回响'
              : '封入 1 张实景照片 + 1 句温暖短句',
          icon: Icons.outgoing_mail,
          enabled: !day.hasSent,
          gradient: true,
          onTap: _send,
        ),
        const SizedBox(height: 10),
        _ActionCard(
          title: reopen ? '再次翻阅今日来信' : '拆取远方来信',
          subtitle: !day.hasSent
              ? '需先投递，才能解锁今日唯一拆信资格'
              : (day.hasOpened
                  ? '今日已拆过，可回看这封信'
                  : '随机匹配陌生人的日常确幸盲盒'),
          icon: Icons.mark_email_unread_rounded,
          enabled: canOpen || reopen,
          gradient: false,
          highlight: canOpen,
          onTap: _open,
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.rose50,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.rose600.withValues(alpha: 0.18),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '回响规则',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.rose600,
                ),
              ),
              SizedBox(height: 6),
              Text(
                '读信后可点「谢谢你的微光」点亮对方信箱。看完即止，互不打扰。',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.45,
                  color: AppColors.slate600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          '今日仪式进度',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.slate600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _StepPill(
                index: '1',
                label: '投递',
                done: day.hasSent,
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                size: 16, color: AppColors.slate300),
            Expanded(
              child: _StepPill(
                index: '2',
                label: '拆信',
                done: day.hasOpened,
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                size: 16, color: AppColors.slate300),
            Expanded(
              child: _StepPill(
                index: '3',
                label: '微光',
                done: day.hasThanked,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.hasSent,
    required this.hasOpened,
    required this.thanksReceived,
    required this.poolSize,
  });

  final bool hasSent;
  final bool hasOpened;
  final int thanksReceived;
  final int poolSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.92),
            AppColors.twilightSurface.withValues(alpha: 0.75),
          ],
        ),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.twilightDark.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: AppColors.brandGradient,
            ),
            child: const Icon(Icons.mail_outline_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasSent
                      ? (hasOpened ? '今日仪式已完成' : '已投递 · 可拆信')
                      : '今日尚未投递',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.twilightDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '信箱微光 $thanksReceived · 公共池 $poolSize 封',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.gradient = false,
    this.highlight = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool enabled;
  final bool gradient;
  final bool highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = !enabled
        ? AppColors.slate100
        : (gradient
            ? null
            : (highlight
                ? AppColors.amberSurface
                : Colors.white.withValues(alpha: 0.9)));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: enabled && gradient ? AppColors.flyGradient : null,
            color: bg,
            border: Border.all(
              color: highlight
                  ? AppColors.amber.withValues(alpha: 0.45)
                  : Colors.white,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: enabled && gradient
                      ? Colors.white
                      : (enabled
                          ? AppColors.twilightDark
                          : AppColors.slate400),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: enabled && gradient
                              ? Colors.white
                              : AppColors.twilightDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: enabled && gradient
                              ? Colors.white.withValues(alpha: 0.9)
                              : AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: enabled && gradient
                      ? Colors.white70
                      : AppColors.slate300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.index,
    required this.label,
    required this.done,
  });

  final String index;
  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: done ? AppColors.twilightSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: done
              ? AppColors.twilight.withValues(alpha: 0.35)
              : AppColors.slate200,
        ),
      ),
      child: Column(
        children: [
          Text(
            index,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: done ? AppColors.twilight : AppColors.slate400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: done ? AppColors.twilightDark : AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 从公共池随机抽取一封非自己的信
CoastLetter? pickRandomLetter({
  required List<CoastLetter> pool,
  required String? excludeId,
  required Set<String> openedHistoryIds,
}) {
  final candidates = pool
      .where((l) => !l.isMine && l.id != excludeId)
      .toList();
  if (candidates.isEmpty) return null;
  // 优先未读过的
  final fresh =
      candidates.where((l) => !openedHistoryIds.contains(l.id)).toList();
  final list = fresh.isNotEmpty ? fresh : candidates;
  return list[Random().nextInt(list.length)];
}
