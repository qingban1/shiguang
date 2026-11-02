import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../theme/app_colors.dart';
import 'network_image_box.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.profile,
    this.size = 44,
  });

  final UserProfile profile;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: profile.avatarUrl.isEmpty
            ? _LetterFallback(letter: profile.avatarLetter, size: size)
            : Stack(
                fit: StackFit.expand,
                children: [
                  NetworkImageBox(url: profile.avatarUrl),
                  // 网络图失败时底层仍有字母感：由 NetworkImageBox 处理
                ],
              ),
      ),
    );
  }
}

class _LetterFallback extends StatelessWidget {
  const _LetterFallback({required this.letter, required this.size});

  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [AppColors.twilight, AppColors.dawn],
        ),
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.38,
        ),
      ),
    );
  }
}
