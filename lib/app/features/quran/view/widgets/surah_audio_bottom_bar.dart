import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/surah_detail_controller.dart';
import '../../data/models/reciter_model.dart';
import 'reciter_selector_sheet.dart';
import 'tafsir_bottom_sheet.dart';

class SurahAudioBottomBar extends StatelessWidget {
  final SurahDetailController controller;

  const SurahAudioBottomBar({
    super.key,
    required this.controller,
  });

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      if (!controller.showAudioPlayer.value) {
        return const SizedBox.shrink();
      }

      final isPlaying = controller.isAudioPlaying.value;
      final isLoading = controller.isAudioLoading.value;
      final duration = controller.audioDuration.value;
      final position = controller.audioPosition.value;
      final reciter = controller.selectedReciter.value;
      final playingAyah = controller.activePlayingAyah.value;

      final title = playingAyah != null
          ? 'الآية ($playingAyah) - سورة ${controller.surah.name}'
          : 'سورة ${controller.surah.name}';

      return SafeArea(
        top: false,
        bottom: true,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? const Color(0xFF222020)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.onPrimary.withAlpha(50),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row: Title, Reciter, and Close Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.headphones_rounded,
                    size: 18,
                    color: colorScheme.onPrimary,
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(2),
                      ZoomTapAnimation(
                        onTap: () {
                          ReciterSelectorSheet.show(
                            context,
                            reciters: controller.availableReciters.isNotEmpty
                                ? controller.availableReciters
                                : ReciterModel.defaultReciters,
                            currentReciter: reciter,
                            onSelect: (newReciter) {
                              controller.changeReciter(newReciter);
                            },
                          );
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              reciter.name,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onPrimary,
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 16,
                              color: colorScheme.onPrimary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Player Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Previous Ayah Button
                    ZoomTapAnimation(
                      onTap: controller.playPreviousAyah,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.skip_next_rounded,
                          size: 22,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                    const Gap(4),

                    // Play / Pause Button
                    ZoomTapAnimation(
                      onTap: () {
                        if (isPlaying) {
                          controller.pauseAudio();
                        } else {
                          controller.togglePlaySurah();
                        }
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Icon(
                                  isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  size: 22,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                    const Gap(4),

                    // Next Ayah Button
                    ZoomTapAnimation(
                      onTap: controller.playNextAyah,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.skip_previous_rounded,
                          size: 22,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                    const Gap(6),

                    // Tafsir of Active Ayah
                    ZoomTapAnimation(
                      onTap: () {
                        final currentAyahNumber =
                            controller.activePlayingAyah.value ?? 1;
                        final currentAyah = controller.ayahs.firstWhereOrNull(
                          (a) => a.numberInSurah == currentAyahNumber,
                        );
                        if (currentAyah != null) {
                          controller.openTafsir(currentAyah);
                          TafsirBottomSheet.show(
                            context,
                            ayah: currentAyah,
                            controller: controller,
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 20,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                    const Gap(6),

                    // Consecutive Play Toggle Button
                    ZoomTapAnimation(
                      onTap: () {
                        controller.isConsecutivePlay.toggle();
                        if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
                        Get.snackbar(
                          'التلاوة المتتالية',
                          controller.isConsecutivePlay.value
                              ? 'تم تفعيل التلاوة المتتالية لجميع الآيات'
                              : 'تم إيقاف التلاوة المتتالية (تشغيل آية واحدة)',
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 2),
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          borderRadius: 12,
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          controller.isConsecutivePlay.value
                              ? Icons.repeat_rounded
                              : Icons.repeat_one_rounded,
                          size: 20,
                          color: controller.isConsecutivePlay.value
                              ? colorScheme.onPrimary
                              : (isDark ? Colors.grey[500] : Colors.grey[400]),
                        ),
                      ),
                    ),
                    const Gap(4),

                    // Close Button
                    ZoomTapAnimation(
                      onTap: controller.closeAudioPlayer,
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Progress Slider Row
            Row(
              children: [
                Text(
                  _formatDuration(position),
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'IBMPlexSansArabic',
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: colorScheme.onPrimary,
                      thumbColor: colorScheme.onPrimary,
                      inactiveTrackColor: colorScheme.onPrimary.withAlpha(35),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 5,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 10,
                      ),
                    ),
                    child: Slider(
                      value: duration.inMilliseconds > 0
                          ? position.inMilliseconds
                              .clamp(0, duration.inMilliseconds)
                              .toDouble()
                          : 0.0,
                      max: duration.inMilliseconds > 0
                          ? duration.inMilliseconds.toDouble()
                          : 1.0,
                      onChanged: (val) {
                        controller.seekAudio(
                          Duration(milliseconds: val.toInt()),
                        );
                      },
                    ),
                  ),
                ),
                Text(
                  _formatDuration(duration),
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'IBMPlexSansArabic',
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      );
    });
  }
}
