import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/coast_letter.dart';
import '../theme/app_colors.dart';
import '../widgets/network_image_box.dart';

/// 仪式感拆信盲盒：信封动效 → 展开信纸卡片
Future<bool?> showOpenLetterFlow(
  BuildContext context, {
  required CoastLetter letter,
  required bool alreadyThanked,
  required VoidCallback onThank,
  required VoidCallback onArchive,
  required VoidCallback onPoster,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'open-letter',
    barrierColor: Colors.black.withValues(alpha: 0.72),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (ctx, a1, a2) {
      return _OpenLetterStage(
        letter: letter,
        alreadyThanked: alreadyThanked,
        onThank: onThank,
        onArchive: onArchive,
        onPoster: onPoster,
      );
    },
  );
}

class _OpenLetterStage extends StatefulWidget {
  const _OpenLetterStage({
    required this.letter,
    required this.alreadyThanked,
    required this.onThank,
    required this.onArchive,
    required this.onPoster,
  });

  final CoastLetter letter;
  final bool alreadyThanked;
  final VoidCallback onThank;
  final VoidCallback onArchive;
  final VoidCallback onPoster;

  @override
  State<_OpenLetterStage> createState() => _OpenLetterStageState();
}

class _OpenLetterStageState extends State<_OpenLetterStage>
    with TickerProviderStateMixin {
  late final AnimationController _seal;
  late final AnimationController _reveal;
  bool _opened = false;
  late bool _thanked;

  @override
  void initState() {
    super.initState();
    _thanked = widget.alreadyThanked;
    _seal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _reveal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _playOpen();
  }

  Future<void> _playOpen() async {
    HapticFeedback.mediumImpact();
    await _seal.forward();
    if (!mounted) return;
    HapticFeedback.heavyImpact();
    setState(() => _opened = true);
    await _reveal.forward();
    if (mounted) HapticFeedback.selectionClick();
  }

  @override
  void dispose() {
    _seal.dispose();
    _reveal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              child: _opened ? _buildCard() : _buildEnvelope(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnvelope() {
    return AnimatedBuilder(
      animation: _seal,
      builder: (context, _) {
        final flap = Curves.easeInOut.transform(_seal.value) * math.pi * 0.72;
        final shake = math.sin(_seal.value * math.pi * 6) * (1 - _seal.value) * 4;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: SizedBox(
            width: 280,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 260,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF6EDE3), Color(0xFFE8D5C4)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: Colors.white70),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _seal.value < 0.55 ? '正在拆封海岸信封…' : '远方来信即将展开',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.twilightDark,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateX(-flap),
                    child: Container(
                      width: 260,
                      height: 78,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.dawn.withValues(alpha: 0.95),
                            AppColors.amber.withValues(alpha: 0.85),
                          ],
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.markunread_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    return FadeTransition(
      opacity: _reveal,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _reveal, curve: Curves.easeOutCubic)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 340),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFF9F2), Color(0xFFF8F0FA), Color(0xFFFFF4EA)],
            ),
            border: Border.all(color: AppColors.amber.withValues(alpha: 0.28)),
            boxShadow: [
              BoxShadow(
                color: AppColors.twilight.withValues(alpha: 0.18),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    '远方来信',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.twilightDark,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    widget.letter.stampLabel,
                    style: const TextStyle(
                      fontSize: 9,
                      fontFamily: 'monospace',
                      color: AppColors.slate400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AspectRatio(
                aspectRatio: 1.15,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetworkImageBox(url: widget.letter.photoUrl),
                      Positioned(
                        right: 8,
                        bottom: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.42),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.letter.stampLabel,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '“${widget.letter.sentence}”',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  fontStyle: FontStyle.italic,
                  color: AppColors.slate700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '来自远方海岸 · ${widget.letter.city}',
                style: const TextStyle(fontSize: 11, color: AppColors.slate400),
              ),
              const SizedBox(height: 6),
              const Text(
                '看完即止 · 可点亮「谢谢你的微光」',
                style: TextStyle(fontSize: 10, color: AppColors.slate500),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: _thanked
                        ? const LinearGradient(
                            colors: [AppColors.slate300, AppColors.slate300],
                          )
                        : AppColors.flyGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TextButton(
                    onPressed: _thanked
                        ? null
                        : () {
                            HapticFeedback.lightImpact();
                            widget.onThank();
                            setState(() => _thanked = true);
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      _thanked ? '已点亮对方信箱微光' : '谢谢你的微光',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onArchive();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.twilight,
                        side: BorderSide(
                          color: AppColors.twilight.withValues(alpha: 0.35),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('收入收集册', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onPoster,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.amberDark,
                        side: BorderSide(
                          color: AppColors.amber.withValues(alpha: 0.4),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('信笺海报', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  '收起信件',
                  style: TextStyle(fontSize: 12, color: AppColors.slate500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
