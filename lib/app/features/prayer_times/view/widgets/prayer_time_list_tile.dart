import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/prayer_times_controller.dart';
import '../../model/prayer_time_item.dart';

class PrayerTimeListTile extends StatelessWidget {
  final PrayerTimeItem item;
  final bool isNext;

  const PrayerTimeListTile({
    super.key,
    required this.item,
    this.isNext = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = PrayerTimesController.to;

    final isPassed = item.isPassed && !isNext;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isNext
            ? (isDark
                ? colorScheme.onPrimary.withAlpha(40)
                : colorScheme.onPrimary.withAlpha(20))
            : (isDark
                ? const Color(0xFF1E1E1E)
                : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext
              ? colorScheme.onPrimary.withAlpha(150)
              : (isDark
                  ? Colors.white.withAlpha(15)
                  : Colors.grey.withAlpha(40)),
          width: isNext ? 1.5 : 1.0,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          // Icon Container
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isNext
                  ? colorScheme.onPrimary
                  : (isDark
                      ? Colors.white.withAlpha(20)
                      : colorScheme.onPrimary.withAlpha(25)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SvgPicture.asset(
              item.iconAsset,
              width: 20,
              height: 20,
              colorFilter: ColorFilter.mode(
                isNext
                    ? Colors.white
                    : (isPassed
                        ? Colors.grey
                        : colorScheme.onPrimary),
                BlendMode.srcIn,
              ),
            ),
          ),

          const Gap(14),

          // Title & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.arabicName,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            isNext ? FontWeight.bold : FontWeight.w600,
                        color: isPassed
                            ? (isDark ? Colors.grey[500] : Colors.grey[600])
                            : (isDark ? Colors.white : Colors.black87),
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    if (isNext) ...[
                      const Gap(8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'التالي',
                          style: TextStyle(
                            fontSize: 10,
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (!item.isAdhan)
                  Text(
                    'وقت شرعي',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
              ],
            ),
          ),

          // Time display
          Text(
            item.formattedTime,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isPassed
                  ? (isDark ? Colors.grey[500] : Colors.grey[500])
                  : (isDark ? Colors.white : colorScheme.onSurface),
              fontFamily: 'IBMPlexSansArabic',
            ),
          ),

          const Gap(12),

          // Alarm / Bell Toggle (Only for Adhan prayers: Fajr, Dhuhr, Asr, Maghrib, Isha)
          if (item.isAdhan)
            ZoomTapAnimation(
              onTap: () => controller.togglePrayerAlarm(item.type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.isAlarmEnabled
                      ? (isDark
                          ? colorScheme.onPrimary.withAlpha(40)
                          : colorScheme.onPrimary.withAlpha(25))
                      : (isDark
                          ? Colors.white.withAlpha(10)
                          : Colors.grey.withAlpha(20)),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.isAlarmEnabled
                      ? Icons.notifications_active_rounded
                      : Icons.notifications_off_outlined,
                  size: 20,
                  color: item.isAlarmEnabled
                      ? (isDark ? Colors.white : colorScheme.onPrimary)
                      : (isDark ? Colors.grey[600] : Colors.grey[400]),
                ),
              ),
            )
          else
            const SizedBox(width: 36),
        ],
      ),
    );
  }
}
