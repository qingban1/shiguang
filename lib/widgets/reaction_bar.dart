import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/post.dart';
import '../models/reaction_type.dart';
import '../theme/app_colors.dart';
import 'particle_burst.dart';

class ReactionBar extends StatelessWidget {
  const ReactionBar({
    super.key,
    required this.post,
    required this.onToggle,
  });

  final Post post;
  final void Function(ReactionType type, Offset globalPosition) onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ReactionType.values.map((type) {
        final active = post.hasReacted(type);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: _ReactionChip(
              type: type,
              count: post.countOf(type),
              active: active,
              onTapDown: (details) {
                HapticFeedback.lightImpact();
                final adding = !post.hasReacted(type);
                onToggle(type, details.globalPosition);
                if (adding) {
                  ParticleBurstOverlay.show(
                    context: context,
                    globalPosition: details.globalPosition,
                    type: type,
                  );
                }
              },
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ReactionChip extends StatelessWidget {
  const _ReactionChip({
    required this.type,
    required this.count,
    required this.active,
    required this.onTapDown,
  });

  final ReactionType type;
  final int count;
  final bool active;
  final void Function(TapDownDetails details) onTapDown;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTapDown: onTapDown,
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
          decoration: BoxDecoration(
            color: active
                ? AppColors.amber.withValues(alpha: 0.18)
                : type.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? AppColors.amber : type.border,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(type.emoji, style: const TextStyle(fontSize: 11)),
                const SizedBox(width: 2),
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: type.foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: type.foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
