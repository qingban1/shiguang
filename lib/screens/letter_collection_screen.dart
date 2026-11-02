import 'package:flutter/material.dart';

import '../models/coast_letter.dart';
import '../theme/app_colors.dart';
import '../widgets/app_toast.dart';
import '../widgets/glimmer_background.dart';
import '../widgets/letter_poster_modal.dart';
import '../widgets/network_image_box.dart';

class LetterCollectionScreen extends StatelessWidget {
  const LetterCollectionScreen({
    super.key,
    required this.letters,
  });

  final List<CoastLetter> letters;

  @override
  Widget build(BuildContext context) {
    return GlimmerBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            '确幸收集册',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.twilightDark,
            ),
          ),
        ),
        body: letters.isEmpty
            ? const Center(
                child: Text(
                  '还没有归档的来信\n拆信后可一键收入情绪避难所',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppColors.slate500),
                ),
              )
            : GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: letters.length,
                itemBuilder: (context, index) {
                  final letter = letters[index];
                  return GestureDetector(
                    onTap: () async {
                      final ok = await showLetterPosterModal(
                        context,
                        letter: letter,
                      );
                      if (ok == true && context.mounted) {
                        AppToast.show(context, '已打开信笺预览，可用系统截图保存');
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white),
                        boxShadow: [
                          BoxShadow(
                            color:
                                AppColors.twilightDark.withValues(alpha: 0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: NetworkImageBox(url: letter.photoUrl),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            letter.sentence,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.35,
                              color: AppColors.slate700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            letter.city,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.slate400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
