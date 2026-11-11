import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/nahj_reader_controller.dart';
import '../../data/models/nahj_commentator_model.dart';

class NahjCommentarySheet extends StatelessWidget {
  final NahjReaderController controller;

  const NahjCommentarySheet({super.key, required this.controller});

  static void show(BuildContext context, NahjReaderController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NahjCommentarySheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2226) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Gap(14),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(isDark ? 40 : 25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.amber,
                      size: 18,
                    ),
                  ),
                  const Gap(8),
                  const Text(
                    'شروح نهج البلاغة المباركة',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const Gap(8),

          // Commentator Selector Chips
          Obx(() {
            final list = controller.commentators;
            final selected = controller.selectedCommentator.value;

            if (list.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final commentator = list[index];
                  final isSelected = selected?.id == commentator.id;

                  return Container(
                    margin: const EdgeInsets.only(left: 8),
                    child: ZoomTapAnimation(
                      onTap: () => controller.selectCommentator(commentator),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? brandColor
                              : (isDark ? Colors.white10 : Colors.grey.shade100),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? brandColor
                                : (isDark ? Colors.white12 : Colors.grey.shade300),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              commentator.nameArabic,
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.grey[300] : Colors.grey[800]),
                              ),
                            ),
                            const Gap(4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white24
                                    : (isDark ? Colors.white10 : Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                commentator.language.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),

          const Divider(height: 18),

          // Commentary Content
          Expanded(
            child: Obx(() {
              if (controller.isLoadingCommentary.value) {
                return Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: brandColor,
                    size: 32,
                  ),
                );
              }

              final comm = controller.activeCommentary.value;
              if (comm == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.library_books_rounded,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                      const Gap(10),
                      Text(
                        'لا يتوفر شرح لهذا المقطع لدى الشارح المختار',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final text = comm.bodyArabic ?? comm.excerptArabic ?? '';

              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(4)
                              : Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? Colors.white10 : Colors.grey.shade200,
                          ),
                        ),
                        child: Text(
                          text.replaceAll('\r', ''),
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 15,
                            height: 2.0,
                            color: isDark ? Colors.grey[200] : const Color(0xFF2C2C2C),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const Gap(12),

                  // Copy Commentary Button
                  ZoomTapAnimation(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            'تم نسخ الشرح بنجاح 📋',
                            style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
                          ),
                          backgroundColor: Colors.teal.shade800,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: brandColor.withAlpha(isDark ? 30 : 15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: brandColor.withAlpha(40)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.copy_rounded, size: 16, color: brandColor),
                          const Gap(6),
                          Text(
                            'نسخ نص الشرح',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: brandColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
