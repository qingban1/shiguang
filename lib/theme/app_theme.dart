import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: null,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.twilight,
        primary: AppColors.twilight,
        secondary: AppColors.dawn,
        tertiary: AppColors.amber,
        surface: AppColors.meshA,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.meshA,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.twilightDark,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: false,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.slate800,
        displayColor: AppColors.twilightDark,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: AppColors.slate400.withValues(alpha: 0.9),
          fontSize: 12,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.slate800.withValues(alpha: 0.92),
        contentTextStyle: const TextStyle(fontSize: 12, color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 6,
      ),
      dividerColor: AppColors.slate100.withValues(alpha: 0.8),
    );
  }
}
