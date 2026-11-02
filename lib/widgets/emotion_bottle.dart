import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 情绪温度琉璃瓶（足迹页）
class EmotionBottle extends StatefulWidget {
  const EmotionBottle({super.key, required this.total});

  final int total;

  @override
  State<EmotionBottle> createState() => _EmotionBottleState();
}

class _EmotionBottleState extends State<EmotionBottle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String get _label {
    if (widget.total >= 1000) return '温暖充盈';
    if (widget.total >= 300) return '微光涌动';
    return '初见暖意';
  }

  @override
  Widget build(BuildContext context) {
    final formatted = _format(widget.total);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            AppColors.twilightSurface.withValues(alpha: 0.6),
            AppColors.dawnSurface.withValues(alpha: 0.5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.twilightDark.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '情绪温度箱 · 已收集微光回响',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: AppColors.twilightDark.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              final s = 1 + (_c.value * 0.05);
              return Transform.scale(
                scale: s,
                child: Container(
                  width: 96,
                  height: 128,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.85),
                      width: 4,
                    ),
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ..._buildDots(),
                      Positioned(
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            _label,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                              color: AppColors.twilightDark,
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
          const SizedBox(height: 14),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: formatted,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.twilightDark,
                  ),
                ),
                const TextSpan(
                  text: '  次善意碰撞',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.slate500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '这里只有纯粹的共振，没有任何点对点打扰',
            style: TextStyle(fontSize: 11, color: AppColors.slate500),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildDots() {
    const colors = [
      AppColors.amber,
      AppColors.dawn,
      AppColors.twilightLight,
      AppColors.emerald400,
      AppColors.rose400,
    ];
    final rand = Random(7);
    return List.generate(colors.length, (i) {
      final left = 14.0 + rand.nextDouble() * 42;
      final top = 16.0 + rand.nextDouble() * 55;
      final size = 12.0 + rand.nextDouble() * 6;
      return Positioned(
        left: left,
        top: top,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: colors[i],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colors[i].withValues(alpha: 0.45),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      );
    });
  }

  String _format(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
