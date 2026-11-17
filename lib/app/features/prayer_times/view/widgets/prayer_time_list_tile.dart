import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/prayer_times_controller.dart';
import '../../model/prayer_time_item.dart';
import 'prayer_offset_sheet.dart';

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

          // Time display and optional Offset Pill
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.formattedTime,
                style: TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.bold,
                  color: isPassed
                      ? (isDark ? Colors.grey[500] : Colors.grey[500])
                      : (isDark ? Colors.white : colorScheme.onSurface),
                  fontFamily: 'IBMPlexSansArabic',
                ),
              ),
              if (item.isAdhan && item.notificationOffsetMinutes != 0) ...[
                const Gap(3),
                GestureDetector(
                  onTap: () => PrayerOffsetSheet.show(context, item),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 1.5,
                    ),
                    decoration: BoxDecoration(
                      color: item.notificationOffsetMinutes < 0
                          ? Colors.amber.withAlpha(isDark ? 40 : 25)
                          : Colors.teal.withAlpha(isDark ? 40 : 25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: item.notificationOffsetMinutes < 0
                            ? Colors.amber.withAlpha(isDark ? 90 : 120)
                            : Colors.teal.withAlpha(isDark ? 90 : 120),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      item.offsetDescription,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: item.notificationOffsetMinutes < 0
                            ? (isDark ? Colors.amber[300] : Colors.amber[900])
                            : (isDark ? Colors.teal[300] : Colors.teal[800]),
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          const Gap(10),

          // Action Buttons: Tune/Offset + Bell (Only for Adhan prayers)
          if (item.isAdhan) ...[
            ZoomTapAnimation(
              onTap: () => PrayerOffsetSheet.show(context, item),
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: item.notificationOffsetMinutes != 0
                      ? colorScheme.onPrimary.withAlpha(isDark ? 35 : 20)
                      : (isDark
                          ? Colors.white.withAlpha(10)
                          : Colors.grey.withAlpha(20)),
                  shape: BoxShape.circle,
                  border: item.notificationOffsetMinutes != 0
                      ? Border.all(
                          color: colorScheme.onPrimary.withAlpha(100),
                          width: 1,
                        )
                      : null,
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 16,
                  color: item.notificationOffsetMinutes != 0
                      ? colorScheme.onPrimary
                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
              ),
            ),
            const Gap(8),
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
            ),
          ]
          else
            const SizedBox(width: 36),
        ],
      ),
    );
  }
}
