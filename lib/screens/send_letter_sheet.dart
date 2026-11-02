import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/content_filter.dart';
import '../data/seed_data.dart';
import '../models/coast_letter.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/network_image_box.dart';

Future<CoastLetter?> showSendLetterSheet(
  BuildContext context, {
  required String authorAlias,
  required String city,
}) {
  return showModalBottomSheet<CoastLetter>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _SendLetterBody(authorAlias: authorAlias, city: city),
  );
}

class _SendLetterBody extends StatefulWidget {
  const _SendLetterBody({required this.authorAlias, required this.city});

  final String authorAlias;
  final String city;

  @override
  State<_SendLetterBody> createState() => _SendLetterBodyState();
}

class _SendLetterBodyState extends State<_SendLetterBody> {
  final _controller = TextEditingController();
  int _photoIndex = 0;

  static const _photos = [
    ...PhotoPresets.daily,
    ...PhotoPresets.food,
    ...PhotoPresets.scenery,
  ];

  static const _stamps = [
    '晨曦 · 微晴 · 小确幸',
    '午后 · 暖风 · 生活切片',
    '黄昏 · 霞光 · 海岸印记',
    '夜晚 · 灯火 · 温柔片刻',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _seal() {
    final text = _controller.text.trim();
    final check = ContentFilter.validateLetterText(text);
    if (!check.ok) {
      AppToast.show(context, check.message);
      return;
    }
    HapticFeedback.mediumImpact();
    final letter = CoastLetter(
      id: 'sent_${DateTime.now().millisecondsSinceEpoch}',
      photoUrl: _photos[_photoIndex % _photos.length],
      sentence: text,
      stampLabel: _stamps[_photoIndex % _stamps.length],
      city: widget.city,
      createdAt: DateTime.now(),
      authorAlias: widget.authorAlias,
      authorId: 'me_local',
      isMine: true,
      thankCount: 0,
    );
    Navigator.pop(context, letter);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final canSeal = _controller.text.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: AppColors.meshA,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.slate300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  '封入海岸信封',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.twilightDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '每日一投一拆 · 投递后解锁今日拆信资格',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppColors.slate500),
                ),
                const SizedBox(height: 16),
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        NetworkImageBox(
                          url: _photos[_photoIndex % _photos.length],
                        ),
                        Positioned(
                          left: 10,
                          bottom: 10,
                          child: Material(
                            color: Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(999),
                            child: InkWell(
                              onTap: () => setState(() {
                                _photoIndex =
                                    (_photoIndex + 1) % _photos.length;
                              }),
                              borderRadius: BorderRadius.circular(999),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                child: Text(
                                  '更换实景相纸',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.amber.withValues(alpha: 0.2)),
                  ),
                  child: TextField(
                    controller: _controller,
                    maxLength: 48,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.slate800,
                    ),
                    decoration: const InputDecoration(
                      hintText: '写下一句温暖短句（48字内）…',
                      counterText: '',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_controller.text.length} / 48',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 10, color: AppColors.slate400),
                ),
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: canSeal
                        ? AppColors.flyGradient
                        : const LinearGradient(
                            colors: [AppColors.slate300, AppColors.slate300],
                          ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextButton(
                    onPressed: canSeal ? _seal : null,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      '投出信封',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
