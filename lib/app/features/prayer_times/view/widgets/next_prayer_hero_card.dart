import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../controller/prayer_times_controller.dart';
import '../../service/prayer_audio_service.dart';

class NextPrayerHeroCard extends StatelessWidget {
  const NextPrayerHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = PrayerTimesController.to;

    return Obx(() {
      final next = controller.nextPrayer.value;
      final audioService =
          Get.isRegistered<PrayerAudioService>() ? PrayerAudioService.to : null;
      final isPlaying = audioService?.isPlaying.value ?? false;

      if (next == null) {
        return const SizedBox.shrink();
      }

      final isAdhan = next.isAdhan;
      final prayerTitle = isAdhan ? 'أذان ${next.arabicName}' : next.arabicName;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1E3A4A),
                    const Color(0xFF0F2027),
                  ]
                : [
                    colorScheme.onPrimary.withAlpha(235),
                    colorScheme.onPrimary,
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : colorScheme.onPrimary)
                  .withAlpha(50),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Header Badge & Location Horizon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(35),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset(
                            next.iconAsset,
                            width: 14,
                            height: 14,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const Gap(6),
                          Text(
                            'الوقت القادم',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'IBMPlexSansArabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    // City Horizon Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(30),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white70,
                            size: 12,
                          ),
                          const Gap(4),
                          Text(
                            'بحسب أفق ${controller.locationCityName.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontFamily: 'IBMPlexSansArabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isPlaying)
                  InkWell(
                    onTap: () => audioService?.stopAdhan(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(200),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.stop, color: Colors.white, size: 14),
                          Gap(4),
                          Text(
                            'إيقاف الأذان',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontFamily: 'IBMPlexSansArabic',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const Gap(16),

            // Row 2: Prayer Name & Formatted Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prayerTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'الوقت: ${next.formattedTime}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 14,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ],
                ),
                // Countdown box
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'متبقي حتى الأذان',
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 11,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    const Gap(4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(40),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        controller.countdownString.value,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Gap(16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: controller.dayProgress.value,
                backgroundColor: Colors.white.withAlpha(40),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 5,
              ),
            ),
          ],
        ),
      );
    });
  }
}
