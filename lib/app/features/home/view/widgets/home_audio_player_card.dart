import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../controller/home_audio_player_controller.dart';

class HomeAudioPlayerCard extends StatelessWidget {
  const HomeAudioPlayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (!Get.isRegistered<HomeAudioPlayerController>()) {
      Get.put(HomeAudioPlayerController());
    }
    final controller = HomeAudioPlayerController.to;

    return Obx(() {
      final isPlaying = controller.isPlaying.value;
      final isLoading = controller.isLoading.value;
      final position = controller.position.value;
      final duration = controller.duration.value;

      final totalSeconds = duration.inSeconds.toDouble();
      final currentSeconds = position.inSeconds.toDouble().clamp(
            0.0,
            totalSeconds > 0 ? totalSeconds : double.infinity,
          );

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withAlpha(10)
              : colorScheme.onPrimary.withAlpha(8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(16)
                : colorScheme.onPrimary.withAlpha(20),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Play / Pause Button
            ZoomTapAnimation(
              onTap: controller.togglePlayPause,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onPrimary.withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                ),
              ),
            ),

            const Gap(10),

            // Content Area: Title & Timing on top, sleek slider underneath
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Reciter below it, alongside Live Duration
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Title and Reciter Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.title.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                            const Gap(1),
                            Text(
                              controller.reciter.value,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.onSurface.withAlpha(150),
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Gap(8),
                      // Time indicator
                      Text(
                        totalSeconds > 0
                            ? '${controller.formatDuration(position)} / ${controller.formatDuration(duration)}'
                            : (isPlaying ? '...' : '--:--'),
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ],
                  ),

                  const Gap(2),

                  // Compact Slider
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 2.8,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 4.5,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 10,
                      ),
                      activeTrackColor: colorScheme.onPrimary,
                      inactiveTrackColor: isDark
                          ? Colors.white.withAlpha(25)
                          : colorScheme.onPrimary.withAlpha(30),
                      thumbColor: colorScheme.onPrimary,
                    ),
                    child: Slider(
                      min: 0.0,
                      max: totalSeconds > 0 ? totalSeconds : 1.0,
                      value: totalSeconds > 0
                          ? currentSeconds.clamp(0.0, totalSeconds)
                          : 0.0,
                      onChanged: totalSeconds > 0
                          ? (val) {
                              controller.seek(Duration(seconds: val.toInt()));
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
