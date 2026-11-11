import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/occasions_controller.dart';
import '../../service/hijri_calendar_service.dart';

class LunarAdjustmentDialog extends StatelessWidget {
  const LunarAdjustmentDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final OccasionsController controller = Get.find<OccasionsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final options = [-2, -1, 0, 1, 2];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    'assets/svgs/moon.svg',
                    width: 20,
                    height: 20,
                    colorFilter: ColorFilter.mode(
                      colorScheme.onPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تعديل التاريخ الهجري',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                      Text(
                        'لمطابقة رؤية الهلال حسب بلدك ومرجعك',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Gap(16),
            const Divider(height: 1),
            const Gap(16),

            Obx(() {
              final currentAdj = controller.adjustmentDays.value;
              return Column(
                children: options.map((opt) {
                  final isSelected = currentAdj == opt;
                  final now = DateTime.now();
                  final previewH = HijriCalendarService.fromGregorian(now, adjustmentDays: opt);
                  final previewText =
                      '${previewH.hDay} ${HijriCalendarService.getHijriMonthName(previewH.hMonth)} ${previewH.hYear} هـ';

                  String optLabel = 'تلقائي (0 يوم)';
                  if (opt > 0) optLabel = 'تقديم (+$opt يوم)';
                  if (opt < 0) optLabel = 'تأخير ($opt يوم)';

                  return ZoomTapAnimation(
                    onTap: () {
                      controller.setAdjustment(opt);
                      Get.back();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.onPrimary.withAlpha(25)
                            : isDark
                                ? Colors.white.withAlpha(8)
                                : Colors.grey.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? colorScheme.onPrimary : Colors.grey,
                            size: 18,
                          ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  optLabel,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: colorScheme.onSurface,
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                                Text(
                                  previewText,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? colorScheme.onPrimary
                                        : isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }),

            const Gap(10),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  'إغلاق',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
