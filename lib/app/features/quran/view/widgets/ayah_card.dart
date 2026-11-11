import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/quran/controller/surah_detail_controller.dart';
import 'package:mawsueat/app/features/quran/data/models/ayah_model.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'tafsir_bottom_sheet.dart';

class AyahCard extends StatelessWidget {
  final AyahModel ayah;
  final SurahDetailController controller;

  const AyahCard({super.key, required this.ayah, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final isPlaying =
          controller.activePlayingAyah.value == ayah.numberInSurah;
      final isAudioPlaying = controller.isAudioPlaying.value;
      final isHighlighted = isPlaying && isAudioPlaying;

      return AnimatedContainer(
        key: controller.getAyahKey(ayah.numberInSurah),
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isHighlighted
              ? colorScheme.onPrimary.withAlpha(isDark ? 32 : 18)
              : (isDark ? Colors.white.withAlpha(8) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isHighlighted
                ? colorScheme.onPrimary
                : (isDark
                    ? Colors.white.withAlpha(12)
                    : colorScheme.onPrimary.withAlpha(15)),
            width: isHighlighted ? 1.8 : 1,
          ),
          boxShadow: isHighlighted
              ? [
                  BoxShadow(
                    color: colorScheme.onPrimary.withAlpha(35),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : (isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(5),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ayah Top Toolbar (Ayah Number + Quick Actions)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? colorScheme.onPrimary.withAlpha(isDark ? 45 : 25)
                    : colorScheme.onPrimary.withAlpha(12),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Row(
              children: [
                // Ayah badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.onPrimary.withAlpha(80),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    'الآية ${ayah.numberInSurah}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansArabic',
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),

                if (ayah.juz != null) ...[
                  const Gap(8),
                  Text(
                    'الجزء ${ayah.juz}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ],

                const Spacer(),

                // Tafsir button
                ZoomTapAnimation(
                  onTap: () {
                    controller.openTafsir(ayah);
                    TafsirBottomSheet.show(
                      context,
                      ayah: ayah,
                      controller: controller,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 18,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                const Gap(4),

                // Audio play button for Ayah
                Obx(() {
                  final isThisPlaying = controller.isAudioPlaying.value &&
                      controller.activePlayingAyah.value == ayah.numberInSurah;
                  final isThisLoading = controller.isAudioLoading.value &&
                      controller.activePlayingAyah.value == ayah.numberInSurah;

                  return ZoomTapAnimation(
                    onTap: () {
                      if (isThisPlaying) {
                        controller.pauseAudio();
                      } else if (controller.activePlayingAyah.value == ayah.numberInSurah &&
                          controller.audioPosition.value > Duration.zero) {
                        controller.resumeAudio();
                      } else {
                        controller.playAyah(ayah, isConsecutive: true);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(5),
                      child: isThisLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.8,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onPrimary),
                              ),
                            )
                          : Icon(
                              isThisPlaying
                                  ? Icons.pause_circle_rounded
                                  : Icons.play_circle_outline_rounded,
                              size: 19,
                              color: isThisPlaying
                                  ? colorScheme.onPrimary
                                  : (isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600]),
                            ),
                    ),
                  );
                }),
                const Gap(4),

                // Copy button
                ZoomTapAnimation(
                  onTap: () => controller.copyAyah(ayah),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      Icons.copy_rounded,
                      size: 17,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
                const Gap(4),

                // Share button
                ZoomTapAnimation(
                  onTap: () => controller.shareAyah(ayah),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: Icon(
                      Icons.share_rounded,
                      size: 17,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Quran Ayah Arabic Text
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Obx(
              () => Text(
                ayah.displayArabicText,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: controller.quranFontSize.value,
                  height: 2.1,
                  fontFamily: controller.quranFontFamily.value,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    });
  }
}
