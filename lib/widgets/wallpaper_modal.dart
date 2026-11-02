import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'network_image_box.dart';

Future<bool?> showWallpaperModal(
  BuildContext context, {
  required List<String> imageUrls,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'wallpaper',
    barrierColor: Colors.black.withValues(alpha: 0.8),
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (ctx, a1, a2) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            constraints: const BoxConstraints(maxHeight: 520),
            margin: const EdgeInsets.symmetric(horizontal: 28),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white, width: 2),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.twilightSurface,
                  Colors.white,
                  AppColors.amberSurface,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 6),
                const Text(
                  '拾岸微光 · 生活画卷壁纸',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.twilightDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateTime.now().year}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().day.toString().padLeft(2, '0')} · 晨曦与黄昏连载',
                  style: const TextStyle(
                    fontSize: 9,
                    fontFamily: 'monospace',
                    color: AppColors.slate400,
                  ),
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                      physics: const NeverScrollableScrollPhysics(),
                      children: imageUrls
                          .take(4)
                          .map((u) => NetworkImageBox(url: u))
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
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
                        '保存 1080×1920 高清壁纸',
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
