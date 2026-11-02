import 'package:flutter/material.dart';

import '../data/seed_data.dart';
import '../models/habit.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/network_image_box.dart';
import '../widgets/wallpaper_modal.dart';

class CollageScreen extends StatelessWidget {
  const CollageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final habit = SeedData.habit();
    final collages = SeedData.collages();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
      physics: const BouncingScrollPhysics(),
      children: [
        const Text(
          '微习惯画卷',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.twilightDark,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          '连续记录的碎片，终会聚成生活的美好长卷',
          style: TextStyle(fontSize: 12, color: AppColors.slate500),
        ),
        const SizedBox(height: 18),
        _HabitCard(habit: habit),
        const SizedBox(height: 22),
        const Text(
          '全社区微光画卷',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
            color: AppColors.slate600,
          ),
        ),
        const SizedBox(height: 12),
        ...collages.map((c) => _CollageCard(item: c)),
      ],
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({required this.habit});
  final HabitProgress habit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.9),
            AppColors.amberSurface.withValues(alpha: 0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.twilightDark.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded,
                  size: 16, color: AppColors.amber),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.twilightDark,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  habit.badge,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.amberDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(habit.totalDays, (i) {
              final done = i < habit.doneDays;
              final isToday = i == habit.doneDays - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i == habit.totalDays - 1 ? 0 : 6),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: done
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                NetworkImageBox(
                                  url: habit.dayImageUrls[
                                      i.clamp(0, habit.dayImageUrls.length - 1)],
                                ),
                                if (isToday)
                                  Container(
                                    color: AppColors.twilight
                                        .withValues(alpha: 0.22),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      '今日',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.amber.withValues(alpha: 0.4),
                                width: 1.5,
                              ),
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.amber,
                              ),
                            ),
                          ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _CollageCard extends StatelessWidget {
  const _CollageCard({required this.item});
  final CollageItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.twilightDark.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [AppColors.twilight, AppColors.dawn],
                  ),
                ),
                child: Text(
                  item.authorInitial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.authorLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate700,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final ok = await showWallpaperModal(
                    context,
                    imageUrls: item.imageUrls,
                  );
                  if (ok == true && context.mounted) {
                    AppToast.show(
                      context,
                      '壁纸预览已打开，可用系统截图保存',
                    );
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.twilight,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.open_in_full_rounded, size: 12),
                    SizedBox(width: 4),
                    Text(
                      '存为壁纸',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 1.35,
              children: item.imageUrls
                  .map((u) => NetworkImageBox(url: u))
                  .toList(),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            item.caption,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontStyle: FontStyle.italic,
              color: AppColors.slate500,
            ),
          ),
        ],
      ),
    );
  }
}
