import 'package:flutter/material.dart';

import '../models/mood_tag.dart';
import '../theme/app_colors.dart';

class RadarBanner extends StatelessWidget {
  const RadarBanner({
    super.key,
    required this.mood,
    required this.count,
    required this.filterActive,
    required this.onTap,
  });

  final MoodTag mood;
  final int count;
  final bool filterActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppColors.amberSurface.withValues(alpha: 0.9),
                AppColors.dawnSurface.withValues(alpha: 0.8),
                AppColors.twilightSurface.withValues(alpha: 0.8),
              ],
            ),
            border: Border.all(
              color: filterActive
                  ? AppColors.amber
                  : AppColors.amber.withValues(alpha: 0.3),
              width: filterActive ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.amber.withValues(alpha: 0.08),
                blurRadius: 8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _BreathingDot(),
                const SizedBox(width: 10),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.slate700,
                        height: 1.25,
                      ),
                      children: [
                        const TextSpan(text: '✨ 此时全社区有 '),
                        TextSpan(
                          text: '$count',
                          style: const TextStyle(
                            color: AppColors.amberDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        TextSpan(
                          text: ' 人正同在 [${mood.label}]',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  filterActive ? '取消' : '同频流',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.twilightDark,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: AppColors.twilightDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BreathingDot extends StatefulWidget {
  @override
  State<_BreathingDot> createState() => _BreathingDotState();
}

class _BreathingDotState extends State<_BreathingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      height: 12,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = _c.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: (1 - t) * 0.7,
                child: Transform.scale(
                  scale: 1 + t,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: AppColors.amber,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
