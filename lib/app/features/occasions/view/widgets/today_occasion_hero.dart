import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/occasions_controller.dart';
import '../../model/occasion_model.dart';
import 'occasion_detail_sheet.dart';

class TodayOccasionHero extends StatelessWidget {
  const TodayOccasionHero({super.key});

  @override
  Widget build(BuildContext context) {
    final OccasionsController controller = Get.find<OccasionsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final today = controller.todayInfo.value;
      if (today == null) return const SizedBox.shrink();

      final hasOccasions = today.occasions.isNotEmpty;
      final firstOccasion = hasOccasions ? today.occasions.first : null;
      final isJoy = firstOccasion?.type == OccasionType.joy;
      final isMourning = firstOccasion?.type == OccasionType.mourning;

      // ألوان متناغمة حسب نوع مناسبة اليوم
      Color cardGradientStart;
      Color cardGradientEnd;
      Color accentColor;

      if (isJoy) {
        cardGradientStart = isDark ? const Color(0xFF143825) : const Color(0xFFE8F5E9);
        cardGradientEnd = isDark ? const Color(0xFF0D2418) : const Color(0xFFC8E6C9);
        accentColor = const Color(0xFF2E7D32);
      } else if (isMourning) {
        cardGradientStart = isDark ? const Color(0xFF381419) : const Color(0xFFFFEBEE);
        cardGradientEnd = isDark ? const Color(0xFF240D10) : const Color(0xFFFFCDD2);
        accentColor = const Color(0xFFC62828);
      } else {
        cardGradientStart = isDark
            ? colorScheme.onPrimary.withAlpha(40)
            : colorScheme.onPrimary.withAlpha(25);
        cardGradientEnd = isDark
            ? colorScheme.onPrimary.withAlpha(15)
            : colorScheme.onPrimary.withAlpha(8);
        accentColor = colorScheme.onPrimary;
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [cardGradientStart, cardGradientEnd],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: accentColor.withAlpha(50),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 50 : 15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // السطر العلوي: بادج اليوم + زر القفز لليوم
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svgs/calendar-days.svg',
                            width: 14,
                            height: 14,
                            colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
                          ),
                          const Gap(6),
                          Text(
                            'اليوم المبارك',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: accentColor,
                              fontFamily: 'IBMPlexSansArabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(8),
                    Text(
                      today.weekDayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ],
                ),
                ZoomTapAnimation(
                  onTap: () => controller.jumpToToday(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white12 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.onPrimary.withAlpha(30),
                      ),
                    ),
                    child: Text(
                      'اليوم الحالي',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const Gap(12),

            // التاريخ الهجري البارز
            Text(
              '${today.hijriDay} ${today.hijriMonthName} ${today.hijriYear} هـ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),

            const Gap(4),

            // التاريخ الميلادي المقابل
            Row(
              children: [
                Text(
                  'الموافق: ${today.gregorianDate.day} ${today.gregorianMonthName} ${today.gregorianDate.year} م',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                ),
                if (controller.adjustmentDays.value != 0) ...[
                  const Gap(6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withAlpha(20),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${controller.adjustmentDays.value > 0 ? "+" : ""}${controller.adjustmentDays.value} يوم',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            if (hasOccasions) ...[
              const Gap(14),
              const Divider(height: 1),
              const Gap(12),

              // مناسبات اليوم
              ...today.occasions.map((occ) {
                return ZoomTapAnimation(
                  onTap: () {
                    Get.bottomSheet(
                      OccasionDetailSheet(occasion: occ),
                      isScrollControlled: true,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black26 : Colors.white70,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: accentColor.withAlpha(40),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accentColor,
                          ),
                        ),
                        const Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                occ.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                              if (occ.subtitle != null) ...[
                                const Gap(2),
                                Text(
                                  occ.subtitle!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Gap(8),
                        if (occ.recommendedActs.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'الأعمال',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: accentColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Gap(4),
                                Icon(Icons.arrow_forward_ios_rounded, size: 10, color: accentColor),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ] else ...[
              const Gap(10),
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  const Gap(6),
                  Text(
                    'لا توجد مناسبة رئيسية خاصة مسجلة لهذا اليوم',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}
