import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/occasions_controller.dart';
import '../../model/occasion_model.dart';
import '../../service/hijri_calendar_service.dart';

class CalendarGridWidget extends StatelessWidget {
  const CalendarGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final OccasionsController controller = Get.find<OccasionsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final weekDays = ['السبت', 'الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة'];

    return Column(
      children: [
        // 1. صف أسماء أيام الأسبوع
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withAlpha(8) : colorScheme.onPrimary.withAlpha(12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: weekDays.map((name) {
              final isFriday = name == 'الجمعة';
              return Expanded(
                child: Center(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isFriday ? FontWeight.bold : FontWeight.w600,
                      color: isFriday
                          ? (isDark ? const Color(0xFFEF5350) : const Color(0xFFE53935))
                          : isDark ? Colors.grey[400] : Colors.grey[700],
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const Gap(8),

        // 2. شبكة أيام الشهر (GridView)
        Obx(() {
          final days = controller.calendarDays;
          final selected = controller.selectedDay.value;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              childAspectRatio: 0.92,
            ),
            itemBuilder: (context, index) {
              final dayInfo = days[index];
              final isSelected = selected != null &&
                  dayInfo.gregorianDate.isAtSameMomentAs(selected.gregorianDate);
              final isToday = dayInfo.isToday;
              final isPast = dayInfo.isPast;
              final isHoliday = dayInfo.isHoliday;
              final isCurrentMonth = dayInfo.isSelectedMonth;
              final holidayColor = isDark ? const Color(0xFFEF5350) : const Color(0xFFE53935);

              // تقويم مدمج: الرقم الرئيسي هو الهجري (الأولوية) والفرعي هو الميلادي
              final primaryNumber = '${dayInfo.hijriDay}';
              final secondaryNumber = '${dayInfo.gregorianDate.day}';

              // تحديد لون وحالة نقاط المناسبات
              final hasJoy = dayInfo.hasJoyOccasion;
              final hasMourning = dayInfo.hasMourningOccasion;
              final hasGeneral = dayInfo.hasOccasions && !hasJoy && !hasMourning;

              // شفافية الخلية: الأيام السابقة تكون باهتة
              double cellOpacity = 1.0;
              if (isSelected || isToday) {
                cellOpacity = 1.0;
              } else if (!isCurrentMonth) {
                cellOpacity = 0.25;
              } else if (isPast) {
                cellOpacity = 0.40;
              } else {
                cellOpacity = 1.0;
              }

              return ZoomTapAnimation(
                onTap: () {
                  controller.selectDay(dayInfo);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : isToday
                            ? (isDark ? colorScheme.onPrimary.withAlpha(40) : colorScheme.onPrimary.withAlpha(20))
                            : isHoliday && isCurrentMonth
                                ? (isDark ? const Color(0xFFEF5350).withAlpha(isPast ? 10 : 22) : const Color(0xFFE53935).withAlpha(isPast ? 10 : 18))
                                : isDark
                                    ? (isCurrentMonth ? Colors.white.withAlpha(isPast ? 6 : 12) : Colors.transparent)
                                    : (isCurrentMonth ? Colors.grey.withAlpha(isPast ? 12 : 25) : Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.onPrimary
                          : isToday
                              ? colorScheme.onPrimary
                              : isHoliday && isCurrentMonth
                                  ? (isDark ? const Color(0xFFEF5350).withAlpha(isPast ? 20 : 50) : const Color(0xFFE53935).withAlpha(isPast ? 20 : 45))
                                  : isDark
                                      ? Colors.white.withAlpha(isPast ? 8 : 15)
                                      : Colors.grey.withAlpha(isPast ? 18 : 35),
                      width: isToday ? 1.5 : (isHoliday && isCurrentMonth ? 1.2 : 1.0),
                    ),
                  ),
                  child: Opacity(
                    opacity: cellOpacity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // الرقم الرئيسي لليوم
                        Text(
                          primaryNumber,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isPast && !isSelected && !isToday ? FontWeight.w500 : FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                    ? colorScheme.onPrimary
                                    : isHoliday
                                        ? holidayColor
                                        : colorScheme.onSurface,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),

                        // الرقم الفرعي الثانوي
                        Text(
                          secondaryNumber,
                          style: TextStyle(
                            fontSize: 9,
                            color: isSelected
                                ? Colors.white70
                                : isHoliday
                                    ? holidayColor.withAlpha(190)
                                    : isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),

                        const Gap(2),

                        // نقاط إشارة المناسبة
                        if (dayInfo.hasOccasions)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (hasJoy)
                                Container(
                                  width: 4.5,
                                  height: 4.5,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? Colors.white : const Color(0xFF2E7D32),
                                  ),
                                ),
                              if (hasMourning)
                                Container(
                                  width: 4.5,
                                  height: 4.5,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? Colors.white : const Color(0xFFC62828),
                                  ),
                                ),
                              if (hasGeneral)
                                Container(
                                  width: 4.5,
                                  height: 4.5,
                                  margin: const EdgeInsets.symmetric(horizontal: 1),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? Colors.white : colorScheme.onPrimary,
                                  ),
                                ),
                            ],
                          )
                        else
                          const SizedBox(height: 4.5),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}
