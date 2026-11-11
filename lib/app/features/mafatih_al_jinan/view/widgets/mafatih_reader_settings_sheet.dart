import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/mafatih_reader_controller.dart';
import '../../data/models/mafatih_item_model.dart';

class MafatihReaderSettingsSheet extends StatelessWidget {
  final MafatihReaderController controller;

  const MafatihReaderSettingsSheet({super.key, required this.controller});

  static void show(BuildContext context, MafatihReaderController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => MafatihReaderSettingsSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = colorScheme.onPrimary;

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 14,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2226) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 80 : 30),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // دستگیره بالا (Top Drag Handle)
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Gap(16),

          // عنوان شیت و دکمه بستن
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.tune_rounded, color: primaryColor, size: 20),
                  const Gap(8),
                  Text(
                    'خيارات القراءة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansArabic',
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const Gap(16),

          // تنظیم اندازه قلم (Font Size Slider)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(8) : primaryColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withAlpha(12) : primaryColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'حجم الخط',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBMPlexSansArabic',
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Obx(() {
                      final sizeInt = controller.fontSize.value.round();
                      return Text(
                        '${MafatihItemModel.toArabicDigits(sizeInt)} نقطة',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'IBMPlexSansArabic',
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ],
                ),
                const Gap(8),
                Row(
                  children: [
                    // کوچک کردن قلم
                    IconButton(
                      icon: const Icon(Icons.text_decrease_rounded, size: 20),
                      onPressed: controller.decreaseFontSize,
                      tooltip: 'تصغير',
                    ),
                    Expanded(
                      child: Obx(
                        () => SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: primaryColor,
                            inactiveTrackColor: primaryColor.withValues(alpha: 0.20),
                            thumbColor: primaryColor,
                            overlayColor: primaryColor.withValues(alpha: 0.15),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: controller.fontSize.value,
                            min: MafatihReaderController.minFontSize,
                            max: MafatihReaderController.maxFontSize,
                            divisions: 18,
                            onChanged: controller.updateFontSize,
                          ),
                        ),
                      ),
                    ),
                    // بزرگ کردن قلم
                    IconButton(
                      icon: const Icon(Icons.text_increase_rounded, size: 22),
                      onPressed: controller.increaseFontSize,
                      tooltip: 'تكبير',
                    ),
                  ],
                ),
                // دکمه بازنشانی سایز به پیش‌فرض
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                    icon: Icon(Icons.refresh_rounded, size: 14, color: primaryColor),
                    label: Text(
                      'إعادة تعيين للحجم الافتراضي',
                      style: TextStyle(
                        fontSize: 11,
                        fontFamily: 'IBMPlexSansArabic',
                        color: primaryColor,
                      ),
                    ),
                    onPressed: controller.resetFontSize,
                  ),
                ),
              ],
            ),
          ),

          const Gap(14),

          // دکمه‌های عملیاتی: کپی تمام متن و اشتراک‌گذاری
          Row(
            children: [
              Expanded(
                child: ZoomTapAnimation(
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.copyFullText(context);
                  },
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withAlpha(10) : primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy_all_rounded, size: 18, color: primaryColor),
                        const Gap(8),
                        Text(
                          'نسخ كامل النص',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontFamily: 'IBMPlexSansArabic',
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Gap(10),

              Expanded(
                child: ZoomTapAnimation(
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.shareText(context);
                  },
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_rounded, size: 18, color: Colors.white),
                        Gap(8),
                        Text(
                          'مشاركة الدعاء',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontFamily: 'IBMPlexSansArabic',
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
