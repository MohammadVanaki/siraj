import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/sahifa_reader_controller.dart';
import '../../data/models/sahifa_dua_model.dart';

class SahifaReaderSettingsSheet extends StatelessWidget {
  final SahifaReaderController controller;

  const SahifaReaderSettingsSheet({super.key, required this.controller});

  static void show(BuildContext context, SahifaReaderController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SahifaReaderSettingsSheet(controller: controller),
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
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.format_size_rounded, size: 18, color: primaryColor),
                        const Gap(6),
                        Text(
                          'حجم الخط',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    Obx(
                      () => Text(
                        SahifaDuaModel.toArabicDigits(controller.fontSize.value.toInt()),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ),
                  ],
                ),

                const Gap(8),

                // اسلایدر با دکمه‌های کم و زیاد
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                      color: primaryColor,
                      onPressed: controller.decreaseFontSize,
                    ),
                    Expanded(
                      child: Obx(
                        () => SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: primaryColor,
                            inactiveTrackColor: primaryColor.withValues(alpha: 0.2),
                            thumbColor: primaryColor,
                            overlayColor: primaryColor.withValues(alpha: 0.15),
                            trackHeight: 4,
                          ),
                          child: Slider(
                            value: controller.fontSize.value,
                            min: SahifaReaderController.minFontSize,
                            max: SahifaReaderController.maxFontSize,
                            divisions: 12,
                            onChanged: (val) {
                              controller.fontSize.value = val;
                            },
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      color: primaryColor,
                      onPressed: controller.increaseFontSize,
                    ),
                  ],
                ),

                // پیش‌نمایش زنده قلم
                const Gap(8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black26 : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black12,
                    ),
                  ),
                  child: Obx(
                    () => Text(
                      'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ✦ الرَّحْمَٰنِ الرَّحِيمِ',
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: controller.fontSize.value,
                        fontFamily: 'IBMPlexSansArabic',
                        color: colorScheme.onSurface,
                        height: 1.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(16),

          // دکمه‌های عملیات سریع (کپی، اشتراک، ریست قلم)
          Row(
            children: [
              Expanded(
                child: ZoomTapAnimation(
                  onTap: () {
                    controller.copyFullDua(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy_rounded, color: primaryColor, size: 16),
                        const Gap(6),
                        Text(
                          'نسخ الدعاء',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
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
                  onTap: controller.shareDua,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_rounded, color: Colors.white, size: 16),
                        Gap(6),
                        Text(
                          'مشاركة الدعاء',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
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
