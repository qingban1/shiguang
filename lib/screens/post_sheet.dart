import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/content_filter.dart';
import '../data/seed_data.dart';
import '../models/mood_tag.dart';
import '../models/share_category.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/network_image_box.dart';

class PostDraft {
  const PostDraft({
    required this.body,
    required this.imageUrl,
    required this.mood,
    required this.category,
    required this.useHandStyle,
  });

  final String body;
  final String imageUrl;
  final MoodTag mood;
  final ShareCategory category;
  final bool useHandStyle;
}

/// 投递微光全屏 Sheet
Future<PostDraft?> showPostSheet(BuildContext context) {
  return showModalBottomSheet<PostDraft>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _PostSheetBody(),
  );
}

class _PostSheetBody extends StatefulWidget {
  const _PostSheetBody();

  @override
  State<_PostSheetBody> createState() => _PostSheetBodyState();
}

class _PostSheetBodyState extends State<_PostSheetBody> {
  final _controller = TextEditingController();
  int _photoIndex = 0;
  MoodTag _mood = MoodTag.presets.first;
  ShareCategory _category = ShareCategory.daily;
  bool _handStyle = false;

  List<String> get _photos => PhotoPresets.forCategory(_category);
  List<String> get _watermarks => PhotoPresets.watermarksFor(_category);

  String get _defaultBody {
    switch (_category.id) {
      case 'food':
        return '把今天探到的一味暖食放进海岸。';
      case 'selfie':
        return '认真和今天的自己打个照面。';
      case 'scenery':
        return '把眼前的一束光写进拾岸。';
      case 'pet':
        return '和毛孩共享一个软乎乎的瞬间。';
      default:
        return '把今天的一束微光放进海岸。';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _selectCategory(ShareCategory category) {
    setState(() {
      _category = category;
      _photoIndex = 0;
    });
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    final text =
        _controller.text.trim().isEmpty ? _defaultBody : _controller.text.trim();
    final check = ContentFilter.validatePostText(text);
    if (!check.ok) {
      AppToast.show(context, check.message);
      return;
    }
    Navigator.pop(
      context,
      PostDraft(
        body: text,
        imageUrl: _photos[_photoIndex % _photos.length],
        mood: _mood,
        category: _category,
        useHandStyle: _handStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: AppColors.meshA,
          borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
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
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.slate300,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '取消',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.slate500),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '投递此刻微光',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.twilightDark,
                        ),
                      ),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.flyGradient,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: TextButton(
                        onPressed: _submit,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          '放飞',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '分享类型',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate600,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ShareCategory.presets.map((c) {
                      final selected = c == _category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () => _selectCategory(c),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.amber
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: selected
                                    ? AppColors.amber
                                    : AppColors.slate200,
                              ),
                            ),
                            child: Text(
                              c.display,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : AppColors.slate600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.twilightDark.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              NetworkImageBox(
                                url: _photos[_photoIndex % _photos.length],
                              ),
                              Positioned(
                                left: 10,
                                bottom: 10,
                                child: _ChipButton(
                                  label: '更换相纸',
                                  icon: Icons.cameraswitch_rounded,
                                  onTap: () {
                                    setState(() {
                                      _photoIndex =
                                          (_photoIndex + 1) % _photos.length;
                                    });
                                  },
                                ),
                              ),
                              Positioned(
                                right: 10,
                                bottom: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _watermarks[
                                        _photoIndex % _watermarks.length],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                      color: AppColors.amberLight
                                          .withValues(alpha: 0.95),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    _category.display,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.twilightDark,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _controller,
                        maxLength: 140,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: _handStyle ? 15 : 12,
                          height: 1.5,
                          color: AppColors.slate700,
                          fontStyle:
                              _handStyle ? FontStyle.italic : FontStyle.normal,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: '${_category.hint}（140字内）',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const Divider(height: 1, color: AppColors.slate100),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            '${_controller.text.length} / 140',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.slate400,
                            ),
                          ),
                          const Spacer(),
                          _FontChip(
                            label: '宋体',
                            selected: !_handStyle,
                            onTap: () => setState(() => _handStyle = false),
                          ),
                          const SizedBox(width: 6),
                          _FontChip(
                            label: '手写',
                            selected: _handStyle,
                            italic: true,
                            onTap: () => setState(() => _handStyle = true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  '绑定同频微状态 (单选)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.slate600,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: MoodTag.presets.map((tag) {
                    final selected = tag == _mood;
                    return GestureDetector(
                      onTap: () => setState(() => _mood = tag),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.twilight : Colors.white,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: selected
                                ? AppColors.twilight
                                : AppColors.slate200,
                          ),
                        ),
                        child: Text(
                          tag.display,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color:
                                selected ? Colors.white : AppColors.slate600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FontChip extends StatelessWidget {
  const _FontChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.italic = false,
  });

  final String label;
  final bool selected;
  final bool italic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? AppColors.twilightSurface : AppColors.slate100,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: selected ? AppColors.twilight : AppColors.slate500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
