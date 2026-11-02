import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class GlimmerBackground extends StatelessWidget {
  const GlimmerBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.meshGradient),
      child: child,
    );
  }
}
