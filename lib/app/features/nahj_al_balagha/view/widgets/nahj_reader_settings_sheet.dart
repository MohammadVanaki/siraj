import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/nahj_reader_controller.dart';

class NahjReaderSettingsSheet extends StatelessWidget {
  final NahjReaderController controller;

  const NahjReaderSettingsSheet({super.key, required this.controller});

  static void show(BuildContext context, NahjReaderController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NahjReaderSettingsSheet(controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2226) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Gap(16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.tune_rounded, color: brandColor, size: 20),
                  const Gap(8),
                  const Text(
                    'خيارات القراءة والعرض',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

          const Divider(height: 20),

          // 1. Font Size
          const Text(
            'حجم خط القراءة:',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Obx(() {
            final size = controller.fontSize.value;
            return Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.text_decrease_rounded),
                  onPressed: () => controller.updateFontSize(size - 1),
                ),
                Expanded(
                  child: Slider(
                    value: size,
                    min: 14.0,
                    max: 32.0,
                    divisions: 18,
                    activeColor: brandColor,
                    onChanged: controller.updateFontSize,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.text_increase_rounded),
                  onPressed: () => controller.updateFontSize(size + 1),
                ),
                Container(
                  width: 36,
                  alignment: Alignment.center,
                  child: Text(
                    '${size.toInt()}',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: brandColor,
                    ),
                  ),
                ),
              ],
            );
          }),

          const Gap(14),

          // 2. Font Family
          const Text(
            'نوع الخط:',
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),
          Obx(() {
            final currentFamily = controller.fontFamily.value;
            return Row(
              children: [
                _fontOption(
                  label: 'خط دجلة (افتراضي)',
                  family: 'dijlah',
                  isSelected: currentFamily == 'dijlah',
                  brandColor: brandColor,
                  isDark: isDark,
                ),
                const Gap(8),
                _fontOption(
                  label: 'Segoe UI',
                  family: 'SegoeUI',
                  isSelected: currentFamily == 'SegoeUI',
                  brandColor: brandColor,
                  isDark: isDark,
                ),
              ],
            );
          }),


        ],
      ),
    );
  }

  Widget _fontOption({
    required String label,
    required String family,
    required bool isSelected,
    required Color brandColor,
    required bool isDark,
  }) {
    return Expanded(
      child: ZoomTapAnimation(
        onTap: () => controller.updateFontFamily(family),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? brandColor
                : (isDark ? Colors.white10 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? brandColor
                  : (isDark ? Colors.white12 : Colors.grey.shade300),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: family,
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey[300] : Colors.grey[800]),
            ),
          ),
        ),
      ),
    );
  }
}
