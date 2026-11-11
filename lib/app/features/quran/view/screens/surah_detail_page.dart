import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../../../config/retry_widget.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../controller/surah_detail_controller.dart';
import '../../data/models/surah_model.dart';
import '../../data/models/tafsir_source.dart';
import '../widgets/ayah_card.dart';
import '../widgets/mushaf_view_widget.dart';
import '../widgets/surah_audio_bottom_bar.dart';
import '../widgets/surah_settings_sheet.dart';

class SurahDetailPage extends StatelessWidget {
  final SurahModel surah;
  final TafsirSource initialTafsir;
  final int? initialAyahNumber;

  const SurahDetailPage({
    super.key,
    required this.surah,
    required this.initialTafsir,
    this.initialAyahNumber,
  });

  @override
  Widget build(BuildContext context) {
    // ایجاد کنترلر اختصاصی برای سوره
    final tag = 'surah_${surah.number}';
    final controller = Get.isRegistered<SurahDetailController>(tag: tag)
        ? Get.find<SurahDetailController>(tag: tag)
        : Get.put(
            SurahDetailController(
              surah: surah,
              initialTafsir: initialTafsir,
              initialAyahNumber: initialAyahNumber,
            ),
            tag: tag,
          );

    if (initialAyahNumber != null && controller.ayahs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.scrollToAyah(initialAyahNumber!);
      });
    }

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
              surah.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              '${surah.revelationTypeArabic} • ${surah.numberOfAyahs} آية',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
          ],
        ),
        actions: [
          // دکمه پخش / مکث صوت سوره
          ZoomTapAnimation(
            onTap: controller.togglePlaySurah,
            child: Obx(
              () => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: controller.isAudioPlaying.value
                      ? colorScheme.onPrimary
                      : (isDark
                          ? Colors.white.withAlpha(15)
                          : colorScheme.onPrimary.withAlpha(20)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.onPrimary.withAlpha(40),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  controller.isAudioPlaying.value
                      ? Icons.pause_rounded
                      : Icons.headphones_rounded,
                  size: 20,
                  color: controller.isAudioPlaying.value
                      ? Colors.white
                      : colorScheme.onPrimary,
                ),
              ),
            ),
          ),

          // دکمه تنظیمات
          ZoomTapAnimation(
            onTap: () {
              SurahSettingsSheet.show(context, controller: controller);
            },
            child: Container(
              margin:
                  const EdgeInsets.only(left: 12, right: 4, top: 8, bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(15)
                    : colorScheme.onPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.onPrimary.withAlpha(40),
                  width: 0.8,
                ),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 20,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    strokeCap: StrokeCap.round,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                  ),
                ),
                const Gap(14),
                Text(
                  'جاري تحميل الآيات الكريمة...',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onPrimary,
                    fontFamily: 'IBMPlexSansArabic',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(
            child: RetryWidget(
              onTap: controller.loadVerses,
            ),
          );
        }

        if (controller.ayahs.isEmpty) {
          return Center(
            child: Text(
              'لا تتوفر آيات لهذه السورة حالياً',
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'IBMPlexSansArabic',
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          );
        }

        // حالت نمایش صفحه مصحف (پیوسته و متصل)
        if (controller.viewMode.value == QuranViewMode.mushaf) {
          return MushafViewWidget(controller: controller);
        }

        // حالت نمایش آیه به آیه (کارت‌های منفصل)
        final showBismillah = surah.number != 1 && surah.number != 9;

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 32),
          itemCount: controller.ayahs.length + (showBismillah ? 1 : 0),
          itemBuilder: (context, index) {
            // بنر بسم الله الرحمن الرحیم
            if (showBismillah && index == 0) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(6) : colorScheme.onPrimary.withAlpha(10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.onPrimary.withAlpha(25),
                  ),
                ),
                child: Center(
                  child: Text(
                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansArabic',
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              );
            }

            final ayahIndex = showBismillah ? index - 1 : index;
            final ayah = controller.ayahs[ayahIndex];

            return AyahCard(
              ayah: ayah,
              controller: controller,
            );
          },
        );
      }),
      bottomNavigationBar: SurahAudioBottomBar(controller: controller),
    );
  }
}
