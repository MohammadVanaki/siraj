import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/widgets/custom_app_bar.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../../controller/occasions_controller.dart';
import '../widgets/calendar_grid_widget.dart';
import '../widgets/lunar_adjustment_dialog.dart';
import '../widgets/occasion_card_widget.dart';
import '../widgets/today_occasion_hero.dart';

class OccasionsPage extends StatelessWidget {
  const OccasionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OccasionsController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        centerTitle: false,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'المناسبات والتقويم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
            Text(
              'التقويم الهجري والميلادي',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
          ],
        ),
        actions: [
          // زر تعديل رؤية الهلال
          ZoomTapAnimation(
            onTap: () {
              Get.dialog(const LunarAdjustmentDialog());
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
                'assets/svgs/moon.svg',
                width: 16,
                height: 16,
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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. بطاقة مناسبة اليوم الرئيسي
              const TodayOccasionHero(),

              const Gap(18),

              // 2. شريط التنقل بين الأشهر
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(12) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(15)
                        : Colors.grey.withAlpha(35),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // زر الشهر السابق (على اليمين في واجهة الـ RTL)
                    ZoomTapAnimation(
                      onTap: () => controller.prevMonth(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () => Column(
                          children: [
                            Text(
                              controller.currentMonthTitle,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                            const Gap(2),
                            Text(
                              controller.currentMonthSubtitle,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? Colors.grey[400]
                                    : Colors.grey[600],
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // زر الشهر التالي (على اليسار في واجهة الـ RTL)
                    ZoomTapAnimation(
                      onTap: () => controller.nextMonth(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(14),

              // 3. شبكة أيام التقويم
              const CalendarGridWidget(),

              const Gap(18),

              // 4. مناسبات وتفاصيل اليوم المحدد
              _buildSelectedDaySection(context, controller),

              const Gap(24),
            ],
          ),
        ),
      ),
    );
  }

  /// قسم تفاصيل اليوم المحدد
  Widget _buildSelectedDaySection(
    BuildContext context,
    OccasionsController controller,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final selected = controller.selectedDay.value;
      if (selected == null) return const SizedBox.shrink();

      final hasOccasions = selected.occasions.isNotEmpty;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(15)
                : Colors.grey.withAlpha(35),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: selected.isHoliday
                        ? (isDark
                              ? const Color(0xFFEF5350).withAlpha(30)
                              : const Color(0xFFE53935).withAlpha(20))
                        : colorScheme.onPrimary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selected.weekDayName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: selected.isHoliday
                          ? (isDark
                                ? const Color(0xFFEF5350)
                                : const Color(0xFFE53935))
                          : colorScheme.onPrimary,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ),
                if (selected.isHoliday) ...[
                  const Gap(6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFFEF5350).withAlpha(25)
                          : const Color(0xFFE53935).withAlpha(15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFFEF5350).withAlpha(50)
                            : const Color(0xFFE53935).withAlpha(40),
                        width: 0.8,
                      ),
                    ),
                    child: Text(
                      selected.isFriday ? 'عطلة نهاية الأسبوع' : 'عطلة رسمية',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? const Color(0xFFEF5350)
                            : const Color(0xFFE53935),
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ),
                ],
                const Gap(8),
                Expanded(
                  child: Text(
                    '${selected.hijriDay} ${selected.hijriMonthName} ${selected.hijriYear} هـ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ),
              ],
            ),

            const Gap(4),

            Text(
              'الموافق: ${selected.gregorianDate.day} ${selected.gregorianMonthName} ${selected.gregorianDate.year} م',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),

            const Gap(14),
            const Divider(height: 1),
            const Gap(14),

            if (hasOccasions) ...[
              Text(
                'المناسبات في هذا اليوم (${selected.occasions.length}):',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  fontFamily: 'IBMPlexSansArabic',
                ),
              ),
              const Gap(10),
              ...selected.occasions.map((occ) {
                return OccasionCardWidget(occasion: occ, showDateBadge: false);
              }),
            ] else ...[
              Row(
                children: [
                  Icon(
                    Icons.event_available_rounded,
                    size: 16,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  const Gap(8),
                  Text(
                    'لا توجد مناسبات مسجلة في هذا اليوم',
                    style: TextStyle(
                      fontSize: 13,
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
