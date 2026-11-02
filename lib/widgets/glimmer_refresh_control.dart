import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 微光页下拉刷新指示器：呼吸光点 + 涟漪波纹
class GlimmerRefreshIndicator extends StatelessWidget {
  const GlimmerRefreshIndicator({
    super.key,
    required this.refreshState,
    required this.pulledExtent,
    required this.refreshTriggerPullDistance,
    required this.refreshIndicatorExtent,
  });

  final RefreshIndicatorMode refreshState;
  final double pulledExtent;
  final double refreshTriggerPullDistance;
  final double refreshIndicatorExtent;

  @override
  Widget build(BuildContext context) {
    final progress = (pulledExtent / refreshTriggerPullDistance).clamp(0.0, 1.0);
    final refreshing = refreshState == RefreshIndicatorMode.refresh ||
        refreshState == RefreshIndicatorMode.armed;

    return SizedBox(
      height: pulledExtent.clamp(0.0, refreshIndicatorExtent + 36),
      child: Center(
        child: Opacity(
          opacity: progress.clamp(0.15, 1.0),
          child: Transform.scale(
            scale: 0.72 + 0.28 * progress,
            child: _GlimmerOrb(
              progress: progress,
              spinning: refreshing,
            ),
          ),
        ),
      ),
    );
  }
}

class _GlimmerOrb extends StatefulWidget {
  const _GlimmerOrb({
    required this.progress,
    required this.spinning,
  });

  final double progress;
  final bool spinning;

  @override
  State<_GlimmerOrb> createState() => _GlimmerOrbState();
}

class _GlimmerOrbState extends State<_GlimmerOrb>
    with TickerProviderStateMixin {
  late final AnimationController _spin;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _spin = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    if (widget.spinning) {
      _spin.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _GlimmerOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spinning && !_spin.isAnimating) {
      _spin.repeat();
    } else if (!widget.spinning && _spin.isAnimating) {
      _spin.stop();
      _spin.value = widget.progress;
    } else if (!widget.spinning) {
      _spin.value = widget.progress;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_spin, _pulse]),
      builder: (context, _) {
        final pulse = 0.85 + _pulse.value * 0.15;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 外圈涟漪
                  Transform.scale(
                    scale: pulse,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.amber.withValues(alpha: 0.22),
                            AppColors.dawn.withValues(alpha: 0.08),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 旋转光环
                  Transform.rotate(
                    angle: _spin.value * math.pi * 2,
                    child: CustomPaint(
                      size: const Size(44, 44),
                      painter: _ArcPainter(
                        progress: widget.spinning ? 1 : widget.progress,
                      ),
                    ),
                  ),
                  // 中心光点
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.amber, AppColors.dawn, AppColors.twilight],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.amber.withValues(alpha: 0.45),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.spinning ? '正在拾取晨曦微光…' : '下拉刷新海岸',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.twilightDark.withValues(alpha: 0.7),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..color = AppColors.twilight.withValues(alpha: 0.12);
    canvas.drawCircle(center, radius, bg);

    final sweep = (math.pi * 1.6) * progress.clamp(0.08, 1.0);
    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          AppColors.amber,
          AppColors.dawn,
          AppColors.twilight,
          AppColors.amber,
        ],
      ).createShader(rect);

    canvas.drawArc(rect, -math.pi / 2, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _ArcPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 刷新后卡片错落入场
class GlimmerRefreshEntrance extends StatelessWidget {
  const GlimmerRefreshEntrance({
    super.key,
    required this.index,
    required this.animKey,
    required this.child,
  });

  final int index;
  final int animKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('entrance_${animKey}_$index'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + (index.clamp(0, 6) * 55)),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 18),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
