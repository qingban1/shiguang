import 'package:flutter/material.dart';

/// 拾岸微光色彩体系（对照原型 Twilight / Dawn / Amber）
class AppColors {
  AppColors._();

  // 主色 Twilight
  static const Color twilight = Color(0xFF6C5CE7);
  static const Color twilightDark = Color(0xFF4A3B69);
  static const Color twilightLight = Color(0xFF8E7CF0);
  static const Color twilightSurface = Color(0xFFF4F1FA);

  // 辅色 Dawn
  static const Color dawn = Color(0xFFFF8FA3);
  static const Color dawnDark = Color(0xFFF3A6B2);
  static const Color dawnLight = Color(0xFFFFD6E0);
  static const Color dawnSurface = Color(0xFFFFF0F5);

  // 点缀 Amber
  static const Color amber = Color(0xFFFF9F43);
  static const Color amberDark = Color(0xFFFF7800);
  static const Color amberLight = Color(0xFFFFEAA7);
  static const Color amberSurface = Color(0xFFFFF9E6);

  // 晨曦三色网格背景
  static const Color meshA = Color(0xFFFAF7FD);
  static const Color meshB = Color(0xFFFFF0F5);
  static const Color meshC = Color(0xFFFFFBF4);

  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);

  static const Color emerald50 = Color(0xFFECFDF5);
  static const Color emerald100 = Color(0xFFD1FAE5);
  static const Color emerald200 = Color(0xFFA7F3D0);
  static const Color emerald400 = Color(0xFF34D399);
  static const Color emerald700 = Color(0xFF047857);

  static const Color rose50 = Color(0xFFFFF1F2);
  static const Color rose400 = Color(0xFFFB7185);
  static const Color rose600 = Color(0xFFE11D48);

  static const Color memoCream = Color(0xFFFFF9F5);
  static const Color memoPink = Color(0xFFFDF4F8);

  static const LinearGradient meshGradient = LinearGradient(
    begin: Alignment(-0.8, -1),
    end: Alignment(0.9, 1),
    colors: [meshA, meshB, meshC],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient postButtonGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [amber, dawn, twilight],
  );

  static const LinearGradient flyGradient = LinearGradient(
    colors: [amber, dawn],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [amber, dawn, twilight],
  );
}
