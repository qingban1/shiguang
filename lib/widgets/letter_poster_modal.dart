import 'package:flutter/material.dart';

import '../models/coast_letter.dart';
import '../theme/app_colors.dart';
import 'network_image_box.dart';

/// 1080×1920 信笺海报预览（无 share_plus，保存为本地成功反馈）
Future<bool?> showLetterPosterModal(
  BuildContext context, {
  required CoastLetter letter,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'letter-poster',
    barrierColor: Colors.black.withValues(alpha: 0.82),
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (ctx, a1, a2) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFF8F0),
                  Color(0xFFF8F1FA),
                  AppColors.amberSurface,
                ],
              ),
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 28,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '拾岸微光 · 治愈信笺',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.twilightDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  letter.stampLabel,
                  style: const TextStyle(
                    fontSize: 9,
                    fontFamily: 'monospace',
                    color: AppColors.slate400,
                  ),
                ),
                const SizedBox(height: 12),
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: NetworkImageBox(url: letter.photoUrl),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  '“${letter.sentence}”',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: AppColors.slate700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '来自远方 · ${letter.city}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.slate400,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.twilight, AppColors.dawn],
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text(
                        '保存 1080×1920 信笺海报',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text(
                    '关闭',
                    style: TextStyle(fontSize: 11, color: AppColors.slate400),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
