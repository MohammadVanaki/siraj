import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/surah_detail_controller.dart';
import '../../data/models/reciter_model.dart';
import '../../data/models/tafsir_source.dart';
import 'reciter_selector_sheet.dart';
import 'tafsir_selector_sheet.dart';

class QuranFontOption {
  final String id;
  final String name;
  final String fontFamily;

  const QuranFontOption({
    required this.id,
    required this.name,
    required this.fontFamily,
  });
}

class SurahSettingsSheet extends StatelessWidget {
  final SurahDetailController controller;

  const SurahSettingsSheet({
    super.key,
    required this.controller,
  });

  static const List<QuranFontOption> availableFonts = [
    QuranFontOption(
      id: 'uthman_taha',
      name: 'خط عثمان طه (مصحف المدينة)',
      fontFamily: 'uthman_taha',
    ),
    QuranFontOption(
      id: 'dijlah',
      name: 'خط دجلة (عثماني)',
      fontFamily: 'IBMPlexSansArabic',
    ),
    QuranFontOption(
      id: 'aljazeera',
      name: 'خط الجزيرة',
      fontFamily: 'aljazeera',
    ),
    QuranFontOption(
      id: 'IBMPlexSansArabic',
      name: 'خط آی‌بی‌ام پلکس (IBM Plex Sans)',
      fontFamily: 'IBMPlexSansArabic',
    ),
    QuranFontOption(
      id: 'SegoeUI',
      name: 'خط سگو (بسيط)',
      fontFamily: 'SegoeUI',
    ),
  ];

  static Future<void> show(
    BuildContext context, {
    required SurahDetailController controller,
  }) {
    return Get.dialog(
      SurahSettingsSheet(controller: controller),
      barrierDismissible: true,
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      backgroundColor: colorScheme.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                    const Gap(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إعدادات القراءة',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBMPlexSansArabic',
                              color: colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'تخصيص الخطوط والتفسير والعرض',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontFamily: 'IBMPlexSansArabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                    ZoomTapAnimation(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(15)
                              : Colors.black.withAlpha(8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Settings Body
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // طريقة العرض
                    Row(
                      children: [
                        Icon(
                          Icons.dashboard_customize_outlined,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                        const Gap(8),
                        Text(
                          'طريقة العرض',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    Obx(() {
                      final currentMode = controller.viewMode.value;

                      return Row(
                        children: [
                          Expanded(
                            child: ZoomTapAnimation(
                              onTap: () =>
                                  controller.setViewMode(QuranViewMode.cards),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: currentMode == QuranViewMode.cards
                                      ? colorScheme.onPrimary
                                      : (isDark
                                          ? Colors.white.withAlpha(10)
                                          : Colors.black.withAlpha(5)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: currentMode == QuranViewMode.cards
                                        ? colorScheme.onPrimary
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.view_agenda_outlined,
                                      size: 20,
                                      color: currentMode == QuranViewMode.cards
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[700]),
                                    ),
                                    const Gap(6),
                                    Text(
                                      'آية بعد آية (منفصل)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            currentMode == QuranViewMode.cards
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        fontFamily: 'IBMPlexSansArabic',
                                        color: currentMode == QuranViewMode.cards
                                            ? Colors.white
                                            : (isDark
                                                ? Colors.grey[300]
                                                : Colors.grey[800]),
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
                              onTap: () =>
                                  controller.setViewMode(QuranViewMode.mushaf),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: currentMode == QuranViewMode.mushaf
                                      ? colorScheme.onPrimary
                                      : (isDark
                                          ? Colors.white.withAlpha(10)
                                          : Colors.black.withAlpha(5)),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: currentMode == QuranViewMode.mushaf
                                        ? colorScheme.onPrimary
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.menu_book_rounded,
                                      size: 20,
                                      color: currentMode == QuranViewMode.mushaf
                                          ? Colors.white
                                          : (isDark
                                              ? Colors.grey[400]
                                              : Colors.grey[700]),
                                    ),
                                    const Gap(6),
                                    Text(
                                      'المصحف (متصل)',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight:
                                            currentMode == QuranViewMode.mushaf
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                        fontFamily: 'IBMPlexSansArabic',
                                        color: currentMode == QuranViewMode.mushaf
                                            ? Colors.white
                                            : (isDark
                                                ? Colors.grey[300]
                                                : Colors.grey[800]),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    const Gap(20),

                    // تنظیم سایز خط
                    Row(
                      children: [
                        Icon(
                          Icons.format_size_rounded,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                        const Gap(8),
                        Text(
                          'حجم خط الآيات',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const Spacer(),
                        Obx(() => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: colorScheme.onPrimary.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${controller.quranFontSize.value.toInt()} pt',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBMPlexSansArabic',
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            )),
                      ],
                    ),
                    const Gap(12),
                    Row(
                      children: [
                        ZoomTapAnimation(
                          onTap: controller.decreaseQuranFontSize,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withAlpha(12)
                                  : colorScheme.onPrimary.withAlpha(18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.remove_rounded,
                                size: 18, color: colorScheme.onPrimary),
                          ),
                        ),
                        Expanded(
                          child: Obx(
                            () => SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: colorScheme.onPrimary,
                                thumbColor: colorScheme.onPrimary,
                                inactiveTrackColor:
                                    colorScheme.onPrimary.withAlpha(35),
                                trackHeight: 4,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 7),
                              ),
                              child: Slider(
                                value: controller.quranFontSize.value,
                                min: 18.0,
                                max: 36.0,
                                divisions: 9,
                                onChanged: (val) {
                                  controller.setQuranFontSize(val);
                                },
                              ),
                            ),
                          ),
                        ),
                        ZoomTapAnimation(
                          onTap: controller.increaseQuranFontSize,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withAlpha(12)
                                  : colorScheme.onPrimary.withAlpha(18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.add_rounded,
                                size: 18, color: colorScheme.onPrimary),
                          ),
                        ),
                      ],
                    ),

                    const Gap(20),

                    // نوع خط الآیات
                    Row(
                      children: [
                        Icon(
                          Icons.font_download_rounded,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                        const Gap(8),
                        Text(
                          'نوع خط الآيات',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    Obx(() {
                      final currentFont = controller.quranFontFamily.value;

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 2.1,
                        ),
                        itemCount: availableFonts.length,
                        itemBuilder: (context, index) {
                          final font = availableFonts[index];
                          final isSelected = currentFont == font.fontFamily;

                          return ZoomTapAnimation(
                            onTap: () =>
                                controller.setQuranFontFamily(font.fontFamily),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorScheme.onPrimary.withAlpha(20)
                                    : (isDark
                                        ? Colors.white.withAlpha(10)
                                        : Colors.black.withAlpha(5)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.check_circle_rounded
                                            : Icons.radio_button_unchecked_rounded,
                                        size: 14,
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : (isDark
                                                ? Colors.grey[500]
                                                : Colors.grey[400]),
                                      ),
                                      const Gap(6),
                                      Expanded(
                                        child: Text(
                                          font.name,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.w600,
                                            fontFamily: 'IBMPlexSansArabic',
                                            color: isSelected
                                                ? colorScheme.onPrimary
                                                : colorScheme.onSurface,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Gap(4),
                                  Text(
                                    '﴿بِسْمِ اللَّهِ﴾',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontFamily: font.fontFamily,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? colorScheme.onPrimary
                                          : (isDark
                                              ? Colors.grey[300]
                                              : Colors.grey[700]),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }),

                    const Gap(20),

                    // بخش تفسیر
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                        const Gap(8),
                        Text(
                          'التفسير المعتمد',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    ZoomTapAnimation(
                      onTap: () {
                        // بستن مدال فعلی و باز کردن انتخابگر تفسیر
                        Navigator.of(context).pop();
                        TafsirSelectorSheet.show(
                          context,
                          tafsirs: controller.availableTafsirs.isNotEmpty
                              ? controller.availableTafsirs
                              : TafsirSource.defaultTafsirs,
                          currentTafsir: controller.selectedTafsir.value,
                          onSelect: (newTafsir) {
                            controller.changeTafsir(newTafsir);
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(10)
                              : colorScheme.onPrimary.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.onPrimary.withAlpha(40),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(
                                () => Text(
                                  controller.selectedTafsir.value.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'IBMPlexSansArabic',
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'تغيير',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IBMPlexSansArabic',
                                color: colorScheme.onPrimary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Gap(20),

                    // بخش انتخاب القارئ
                    Row(
                      children: [
                        Icon(
                          Icons.record_voice_over_rounded,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                        const Gap(8),
                        Text(
                          'القارئ المعتمد',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    ZoomTapAnimation(
                      onTap: () {
                        Navigator.of(context).pop();
                        ReciterSelectorSheet.show(
                          context,
                          reciters: controller.availableReciters.isNotEmpty
                              ? controller.availableReciters
                              : ReciterModel.defaultReciters,
                          currentReciter: controller.selectedReciter.value,
                          onSelect: (newReciter) {
                            controller.changeReciter(newReciter);
                          },
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(10)
                              : colorScheme.onPrimary.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.onPrimary.withAlpha(40),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Obx(
                                () => Text(
                                  '${controller.selectedReciter.value.name} (${controller.selectedReciter.value.subName})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'IBMPlexSansArabic',
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'تغيير',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IBMPlexSansArabic',
                                color: colorScheme.onPrimary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Gap(16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
