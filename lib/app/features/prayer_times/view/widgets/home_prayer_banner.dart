import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:mawsueat/app/core/routes/routes.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/prayer_times_controller.dart';

class HomePrayerBanner extends StatelessWidget {
  const HomePrayerBanner({super.key});

  static final Map<int, Map<String, String>> _dailyDhikr = {
    DateTime.saturday: {
      'day': 'السبت',
      'dhikr': 'يَا رَبَّ الْعَالَمِينَ',
    },
    DateTime.sunday: {
      'day': 'الأحد',
      'dhikr': 'يَا ذَا الْجَلالِ وَ الإِكْرَامِ',
    },
    DateTime.monday: {
      'day': 'الإثنين',
      'dhikr': 'يَا قَاضِيَ الْحَاجَاتِ',
    },
    DateTime.tuesday: {
      'day': 'الثلاثاء',
      'dhikr': 'يَا أَرْحَمَ الرَّاحِمِينَ',
    },
    DateTime.wednesday: {
      'day': 'الأربعاء',
      'dhikr': 'يَا حَيُّ يَا قَيُّومُ',
    },
    DateTime.thursday: {
      'day': 'الخميس',
      'dhikr': 'لا إِلَهَ إِلا اللَّهُ الْمَلِكُ الْحَقُّ الْمُبِينُ',
    },
    DateTime.friday: {
      'day': 'الجمعة',
      'dhikr': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَ آلِ مُحَمَّدٍ',
    },
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (!Get.isRegistered<PrayerTimesController>()) {
      Get.put(PrayerTimesController());
    }
    final controller = PrayerTimesController.to;

    return Obx(() {
      final next = controller.nextPrayer.value;
      if (next == null) return const SizedBox.shrink();

      final isAdhan = next.isAdhan;
      final prayerLabel = isAdhan ? 'أذان ${next.arabicName}' : next.arabicName;

      final now = DateTime.now();
      final hijri = HijriCalendar.now();
      final dayInfo = _dailyDhikr[now.weekday] ?? {
        'day': 'اليوم',
        'dhikr': 'لا إِلَهَ إِلا اللَّهُ',
      };
      final dayName = dayInfo['day']!;
      final dhikr = dayInfo['dhikr']!;
      final hijriFormatted = '${hijri.hDay} ${hijri.longMonthName} ${hijri.hYear} هـ';

      return ZoomTapAnimation(
        onTap: () => Get.toNamed(Routes.prayerTimes),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1F2428)
                : colorScheme.onPrimary.withAlpha(16),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.onPrimary.withAlpha(isDark ? 50 : 32),
              width: 1.2,
            ),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: colorScheme.onPrimary.withAlpha(10),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Row: Hijri Date & Location Horizon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 14,
                          color: colorScheme.onPrimary,
                        ),
                        const Gap(5),
                        Flexible(
                          child: Text(
                            '$dayName، $hijriFormatted',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                              fontFamily: 'IBMPlexSansArabic',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(8),
                  // City Horizon Tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withAlpha(isDark ? 35 : 22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: colorScheme.onPrimary,
                        ),
                        const Gap(3),
                        Text(
                          controller.locationCityName.value,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const Gap(8),

              // 2. Dhikr of the day
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(10)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(16)
                        : colorScheme.onPrimary.withAlpha(20),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'ذِكر اليوم: ',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    Expanded(
                      child: Text(
                        dhikr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withAlpha(220),
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(10),

              // 3. Bottom Row: Prayer icon, prayer name, countdown, and exact time
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6.5),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: SvgPicture.asset(
                      next.iconAsset,
                      width: 13,
                      height: 13,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      'الصلاة القادمة: $prayerLabel',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ),
                  // Countdown badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(15)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withAlpha(20)
                            : Colors.grey.withAlpha(40),
                      ),
                    ),
                    child: Obx(
                      () => Text(
                        controller.countdownString.value,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                          fontFamily: 'IBMPlexSansArabic',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const Gap(6),
                  Text(
                    next.formattedTime,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimary,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                  const Gap(3),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
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
