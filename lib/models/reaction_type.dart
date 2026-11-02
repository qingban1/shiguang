import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 四种正向回响（无私信键盘）
enum ReactionType {
  heal,
  cheer,
  luck,
  hug,
}

extension ReactionTypeX on ReactionType {
  String get emoji {
    switch (this) {
      case ReactionType.heal:
        return '✨';
      case ReactionType.cheer:
        return '☕️';
      case ReactionType.luck:
        return '🌿';
      case ReactionType.hug:
        return '🫂';
    }
  }

  String get label {
    switch (this) {
      case ReactionType.heal:
        return '治愈';
      case ReactionType.cheer:
        return '加油';
      case ReactionType.luck:
        return '好运';
      case ReactionType.hug:
        return '抱抱';
    }
  }

  Color get particleColor {
    switch (this) {
      case ReactionType.heal:
        return AppColors.amber;
      case ReactionType.cheer:
        return AppColors.dawn;
      case ReactionType.luck:
        return AppColors.emerald400;
      case ReactionType.hug:
        return AppColors.twilight;
    }
  }

  Color get foreground {
    switch (this) {
      case ReactionType.heal:
        return AppColors.twilightDark;
      case ReactionType.cheer:
        return AppColors.amberDark;
      case ReactionType.luck:
        return AppColors.emerald700;
      case ReactionType.hug:
        return AppColors.rose600;
    }
  }

  Color get background {
    switch (this) {
      case ReactionType.heal:
        return AppColors.twilightSurface.withValues(alpha: 0.6);
      case ReactionType.cheer:
        return AppColors.amberSurface.withValues(alpha: 0.7);
      case ReactionType.luck:
        return AppColors.emerald50;
      case ReactionType.hug:
        return AppColors.dawnSurface;
    }
  }

  Color get border {
    switch (this) {
      case ReactionType.heal:
        return AppColors.twilight.withValues(alpha: 0.15);
      case ReactionType.cheer:
        return AppColors.amber.withValues(alpha: 0.2);
      case ReactionType.luck:
        return AppColors.emerald200.withValues(alpha: 0.6);
      case ReactionType.hug:
        return AppColors.dawn.withValues(alpha: 0.3);
    }
  }

  static ReactionType fromName(String name) {
    return ReactionType.values.firstWhere(
      (e) => e.name == name,
      orElse: () => ReactionType.heal,
    );
  }
}
