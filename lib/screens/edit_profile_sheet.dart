import 'package:flutter/material.dart';

import '../data/seed_data.dart';
import '../models/user_profile.dart';
import '../theme/app_colors.dart';
import '../widgets/network_image_box.dart';

Future<UserProfile?> showEditProfileSheet(
  BuildContext context, {
  required UserProfile profile,
}) {
  return showModalBottomSheet<UserProfile>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditProfileBody(profile: profile),
  );
}

class _EditProfileBody extends StatefulWidget {
  const _EditProfileBody({required this.profile});
  final UserProfile profile;

  @override
  State<_EditProfileBody> createState() => _EditProfileBodyState();
}

class _EditProfileBodyState extends State<_EditProfileBody> {
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _city;
  late String _avatarUrl;

  static final _avatars = <String>[
    ...PhotoPresets.selfie,
    ...PhotoPresets.daily,
  ];

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.profile.displayName);
    _bio = TextEditingController(text: widget.profile.bio);
    _city = TextEditingController(text: widget.profile.city);
    _avatarUrl = widget.profile.avatarUrl.isEmpty
        ? _avatars.first
        : widget.profile.avatarUrl;
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _city.dispose();
    super.dispose();
  }

  void _cycleAvatar() {
    final i = _avatars.indexOf(_avatarUrl);
    setState(() {
      _avatarUrl = _avatars[(i < 0 ? 0 : i + 1) % _avatars.length];
    });
  }

  void _save() {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    Navigator.pop(
      context,
      widget.profile.copyWith(
        displayName: name,
        bio: _bio.text.trim(),
        city: _city.text.trim().isEmpty ? '拾岸' : _city.text.trim(),
        avatarUrl: _avatarUrl,
        initial: String.fromCharCodes(name.runes.take(1)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.meshA,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          20 + MediaQuery.of(context).padding.bottom,
        ),
        child: SingleChildScrollView(
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
              const SizedBox(height: 14),
              const Text(
                '编辑个人资料',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.twilightDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '头像 · 昵称 · 简介',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.slate500),
              ),
              const SizedBox(height: 16),
              Center(
                child: GestureDetector(
                  onTap: _cycleAvatar,
                  child: Stack(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 84,
                          height: 84,
                          child: NetworkImageBox(url: _avatarUrl),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.twilight,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.cameraswitch_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                '点击头像更换',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.slate400),
              ),
              const SizedBox(height: 14),
              _Field(label: '昵称', controller: _name, maxLength: 16),
              const SizedBox(height: 10),
              _Field(label: '城市', controller: _city, maxLength: 12),
              const SizedBox(height: 10),
              _Field(
                label: '简介',
                controller: _bio,
                maxLength: 80,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppColors.flyGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextButton(
                  onPressed: _save,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text(
                    '保存资料',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.maxLength,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final int? maxLength;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.slate500,
            ),
          ),
          TextField(
            controller: controller,
            maxLength: maxLength,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 14, color: AppColors.slate800),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              counterText: '',
            ),
          ),
        ],
      ),
    );
  }
}
