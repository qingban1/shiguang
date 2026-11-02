import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// UGC 安全抽屉：举报内容 / 举报用户 / 拉黑 / 删除自己的内容
Future<String?> showSafetySheet(
  BuildContext context, {
  required String title,
  bool isMine = false,
  bool alreadyBlocked = false,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (ctx) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          20 + MediaQuery.of(ctx).padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.slate300,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              isMine ? '管理我的动态' : '针对：$title',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.slate800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isMine
                  ? '你可以删除自己发布的内容。删除后不可恢复。'
                  : '拾岸微光坚持零容忍骚扰政策，请选择处理方式：',
              style: const TextStyle(fontSize: 11, color: AppColors.slate400),
            ),
            const SizedBox(height: 16),
            if (isMine) ...[
              _ActionTile(
                background: AppColors.rose50,
                foreground: AppColors.rose600,
                icon: Icons.delete_outline_rounded,
                label: '删除这条动态',
                onTap: () => Navigator.pop(ctx, 'delete_own'),
              ),
            ] else ...[
              _ActionTile(
                background: AppColors.slate100,
                foreground: AppColors.slate700,
                icon: Icons.flag_outlined,
                iconColor: AppColors.amber,
                label: '举报此内容',
                onTap: () => Navigator.pop(ctx, 'report_post'),
              ),
              const SizedBox(height: 8),
              _ActionTile(
                background: AppColors.slate100,
                foreground: AppColors.slate700,
                icon: Icons.person_search_outlined,
                iconColor: AppColors.twilight,
                label: '举报此用户',
                onTap: () => Navigator.pop(ctx, 'report_user'),
              ),
              const SizedBox(height: 8),
              _ActionTile(
                background: AppColors.rose50,
                foreground: AppColors.rose600,
                icon: alreadyBlocked
                    ? Icons.person_add_alt_1_outlined
                    : Icons.person_off_outlined,
                label: alreadyBlocked ? '解除拉黑' : '拉黑并隐藏其内容',
                onTap: () => Navigator.pop(
                  ctx,
                  alreadyBlocked ? 'unblock' : 'block',
                ),
              ),
            ],
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                backgroundColor: AppColors.slate100,
                foregroundColor: AppColors.slate500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('取消', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      );
    },
  );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.background,
    required this.foreground,
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor,
  });

  final Color background;
  final Color foreground;
  final IconData icon;
  final Color? iconColor;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 16, color: iconColor ?? foreground),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: foreground,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 14, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
