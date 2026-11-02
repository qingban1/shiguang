import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/post.dart';
import '../theme/app_colors.dart';
import 'network_image_box.dart';

/// 拍立得 3D 翻转卡片
class PolaroidCard extends StatefulWidget {
  const PolaroidCard({super.key, required this.post});

  final Post post;

  @override
  State<PolaroidCard> createState() => _PolaroidCardState();
}

class _PolaroidCardState extends State<PolaroidCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _flipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.mediumImpact();
    setState(() => _flipped = !_flipped);
    if (_flipped) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final angle = _controller.value * math.pi;
            final showFront = angle <= math.pi / 2;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0012)
                ..rotateY(angle),
              child: showFront
                  ? _FrontFace(post: widget.post)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _BackFace(post: widget.post),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _FrontFace extends StatelessWidget {
  const _FrontFace({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          NetworkImageBox(url: post.imageUrl),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'TAP 翻转心语',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.twilightDark,
                ),
              ),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wb_twilight_rounded,
                    size: 11,
                    color: AppColors.amberLight,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    post.stampLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.95),
                      fontFamily: 'monospace',
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackFace extends StatelessWidget {
  const _BackFace({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.memoCream, AppColors.memoPink],
        ),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Glimmer Memo #${post.memoNo > 0 ? post.memoNo : '新'}',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: AppColors.twilightDark.withValues(alpha: 0.55),
                ),
              ),
              Icon(
                Icons.format_quote_rounded,
                size: 16,
                color: AppColors.dawn,
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: Text(
                '“${post.memoBack}”',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.55,
                  color: AppColors.slate700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Text(
            '录于 ${post.city}',
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.slate400,
            ),
          ),
        ],
      ),
    );
  }
}
