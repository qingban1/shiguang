import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';

enum DockTab { feed, mailbox, messages, profile }

class FloatingDock extends StatelessWidget {
  const FloatingDock({
    super.key,
    required this.current,
    required this.onSelect,
    required this.onPost,
  });

  final DockTab current;
  final ValueChanged<DockTab> onSelect;
  final VoidCallback onPost;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      margin: const EdgeInsets.fromLTRB(14, 0, 14, 18),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
        boxShadow: [
          BoxShadow(
            color: AppColors.twilightDark.withValues(alpha: 0.15),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _DockItem(
              icon: Icons.explore_rounded,
              label: '微光',
              selected: current == DockTab.feed,
              onTap: () => onSelect(DockTab.feed),
            ),
          ),
          Expanded(
            child: _DockItem(
              icon: Icons.mail_outline_rounded,
              label: '信箱',
              selected: current == DockTab.mailbox,
              onTap: () => onSelect(DockTab.mailbox),
            ),
          ),
          Expanded(
            child: Center(
              child: Transform.translate(
                offset: const Offset(0, -14),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onPost();
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.postButtonGradient,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.amber.withValues(alpha: 0.45),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: _DockItem(
              icon: Icons.notifications_none_rounded,
              label: '消息',
              selected: current == DockTab.messages,
              onTap: () => onSelect(DockTab.messages),
            ),
          ),
          Expanded(
            child: _DockItem(
              icon: Icons.water_rounded,
              label: '足迹',
              selected: current == DockTab.profile,
              onTap: () => onSelect(DockTab.profile),
            ),
          ),
        ],
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.twilight : AppColors.slate400;
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
