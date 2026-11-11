import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/widgets/custom_app_bar.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../../controller/prayer_times_controller.dart';
import '../../service/prayer_audio_service.dart';
import '../../service/prayer_notification_service.dart';
import '../widgets/next_prayer_hero_card.dart';
import '../widgets/prayer_settings_sheet.dart';
import '../widgets/prayer_time_list_tile.dart';

class PrayerTimesPage extends StatelessWidget {
  const PrayerTimesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // Ensure services and controller are registered
    if (!Get.isRegistered<PrayerAudioService>()) {
      Get.put(PrayerAudioService());
    }
    if (!Get.isRegistered<PrayerNotificationService>()) {
      Get.put(PrayerNotificationService());
    }
    final controller = Get.put(PrayerTimesController());

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'الأوقات الشرعية',
        actions: [
          // GPS Refresh Button
          ZoomTapAnimation(
            onTap: () => controller.refreshLocation(),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : colorScheme.onPrimary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.my_location_rounded,
                size: 18,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          // Settings Button
          ZoomTapAnimation(
            onTap: () {
              Get.bottomSheet(
                const PrayerSettingsSheet(),
                isScrollControlled: true,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(left: 12, right: 4),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : colorScheme.onPrimary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/svgs/settings.svg',
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  colorScheme.onPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.todayPrayers.isEmpty) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.onPrimary),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.refreshLocation(),
            color: colorScheme.onPrimary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date and City header bar
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(12)
                          : colorScheme.onPrimary.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svgs/calendar-days.svg',
                              width: 16,
                              height: 16,
                              colorFilter: ColorFilter.mode(
                                colorScheme.onPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const Gap(8),
                            Text(
                              controller.hijriDateString.value,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                          ],
                        ),
                        Text(
                          controller.gregorianDateString.value,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(16),

                  // Hero Countdown Card
                  const NextPrayerHeroCard(),

                  const Gap(22),

                  // Section Title & Hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Get.bottomSheet(
                              const PrayerSettingsSheet(),
                              isScrollControlled: true,
                            );
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svgs/moon.svg',
                                width: 16,
                                height: 16,
                                colorFilter: ColorFilter.mode(
                                  colorScheme.onPrimary,
                                  BlendMode.srcIn,
                                ),
                              ),
                              const Gap(8),
                              Flexible(
                                child: Text(
                                  'المواقيت حسب أفق ${controller.locationCityName.value}',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'انقر الجرس لتفعيل الأذان',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ],
                  ),

                  const Gap(12),

                  // List of prayer times
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.todayPrayers.length,
                    itemBuilder: (context, index) {
                      final item = controller.todayPrayers[index];
                      final isNext =
                          controller.nextPrayer.value?.type == item.type;
                      return PrayerTimeListTile(item: item, isNext: isNext);
                    },
                  ),

                  const Gap(24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
