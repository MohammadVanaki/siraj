import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/quran/controller/mushaf_page_reader_controller.dart';
import 'package:mawsueat/app/features/quran/data/data_sources/surah_constants.dart';
import 'package:mawsueat/app/features/quran/data/models/ayah_model.dart';
import 'package:mawsueat/app/features/quran/data/models/surah_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';

import '../../data/data_sources/juz_constants.dart';
import '../widgets/quran_border_painter.dart';
import '../widgets/tafsir_bottom_sheet.dart';

class MushafPageReaderPage extends StatelessWidget {
  final int initialPage;
  final SurahModel? initialSurah;

  const MushafPageReaderPage({
    super.key,
    this.initialPage = 1,
    this.initialSurah,
  });

  static String toEasternArabic(dynamic input) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return input.toString().split('').map((c) {
      final d = int.tryParse(c);
      return d != null ? digits[d] : c;
    }).join();
  }

  static String getJuzNameArabic(int juzNumber) {
    if (juzNumber >= 1 && juzNumber <= JuzConstants.allJuzs.length) {
      return JuzConstants.allJuzs[juzNumber - 1].name;
    }
    return 'الجزء $juzNumber';
  }

  static String getSurahNameArabic(int surahNumber) {
    final s = SurahConstants.getByNumber(surahNumber);
    if (s != null) {
      final clean = s.englishNameTranslation;
      return clean.startsWith('سورة') ? clean : 'سورة $clean';
    }
    return 'سورة';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      MushafPageReaderController(initialPage: initialPage),
      tag: 'mushaf_reader_$initialPage',
    );

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: CustomAppBar(
          centerTitle: false,
          titleWidget: Obx(() {
            final page = controller.currentPage.value;
            final surahName = controller.getCurrentSurahName(page);
            final juzNum = controller.getCurrentJuzNumber(page);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  surahName,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IBMPlexSansArabic',
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'الجزء ${toEasternArabic(juzNum)} • الصفحة ${toEasternArabic(page)} من ${toEasternArabic(MushafPageReaderController.totalPages)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'IBMPlexSansArabic',
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            );
          }),
          actions: [
            // انتقال به صفحه
            ZoomTapAnimation(
              onTap: () => _showJumpToPageDialog(context, controller),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.onPrimary.withAlpha(45),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.find_in_page_outlined,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                    const Gap(5),
                    Text(
                      'انتقال',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBMPlexSansArabic',
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // تنظیم اندازه قلم
            ZoomTapAnimation(
              onTap: () => _showFontSizeSheet(context, controller),
              child: Container(
                margin: const EdgeInsets.only(
                  left: 12,
                  right: 4,
                  top: 8,
                  bottom: 8,
                ),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(12)
                      : colorScheme.onPrimary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.format_size_rounded,
                  size: 19,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
        body: PageView.builder(
          controller: controller.pageController,
          itemCount: MushafPageReaderController.totalPages,
          onPageChanged: controller.onPageChanged,
          itemBuilder: (context, index) {
            final pageNumber = index + 1;
            return _buildMushafPage(context, controller, pageNumber);
          },
        ),
      ),
    );
  }

  Widget _buildMushafPage(
    BuildContext context,
    MushafPageReaderController controller,
    int pageNumber,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final isLoading = controller.loadingPages.contains(pageNumber);
      final error = controller.pageErrors[pageNumber];
      final verses = controller.pageCache[pageNumber];

      if (isLoading && (verses == null || verses.isEmpty)) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.onPrimary,
                  ),
                ),
              ),
              const Gap(12),
              Text(
                'جاري تحميل الصفحة ${toEasternArabic(pageNumber)}...',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'IBMPlexSansArabic',
                  color: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        );
      }

      if (error != null && (verses == null || verses.isEmpty)) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 40, color: Colors.grey[400]),
              const Gap(10),
              Text(
                'تعذر تحميل الصفحة ${toEasternArabic(pageNumber)}',
                style: const TextStyle(fontSize: 13, fontFamily: 'IBMPlexSansArabic'),
              ),
              const Gap(12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.onPrimary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => controller.loadPage(pageNumber),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text(
                  'إعادة المحاولة',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
                ),
              ),
            ],
          ),
        );
      }

      if (verses == null || verses.isEmpty) {
        return const SizedBox.shrink();
      }

      final firstAyah = verses.first;
      final surahNumber = firstAyah.surahNumber;
      final juzNumber = firstAyah.juz ?? 1;

      final surahTitle = getSurahNameArabic(surahNumber);
      final juzTitle = getJuzNameArabic(juzNumber);
      final pageArabic = toEasternArabic(pageNumber);

      final bgFrameColor = isDark
          ? const Color(0xFF1B1D18)
          : const Color(0xFFFAF8EE);
      final borderPrimary = isDark
          ? const Color(0xFF7D966E)
          : const Color(0xFF4F6347);
      final borderSecondary = isDark
          ? const Color(0xFFC7B07B)
          : const Color(0xFF968453);

      return Column(
        children: [
          // 1. TOP HEADER (Right: Juz name | Center: ◀ Page ▶ | Left: Surah name)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  juzTitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontFamily: 'IBMPlexSansArabic',
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[300] : const Color(0xFF263238),
                  ),
                ),
                // Center: ◀  ۳۰۶  ▶ (in RTL: Right is ▶, Left is ◀)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ZoomTapAnimation(
                      onTap: () {
                        if (pageNumber > 1) {
                          controller.jumpToPage(pageNumber - 1);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          '▶',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: borderPrimary,
                          ),
                        ),
                      ),
                    ),
                    const Gap(6),
                    ZoomTapAnimation(
                      onTap: () => _showJumpToPageDialog(context, controller),
                      child: Text(
                        pageArabic,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'IBMPlexSansArabic',
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1B2019),
                        ),
                      ),
                    ),
                    const Gap(6),
                    ZoomTapAnimation(
                      onTap: () {
                        if (pageNumber < 604) {
                          controller.jumpToPage(pageNumber + 1);
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        child: Text(
                          '◀',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: borderPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  surahTitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontFamily: 'IBMPlexSansArabic',
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.grey[300] : const Color(0xFF263238),
                  ),
                ),
              ],
            ),
          ),

          // 2. ORNATE MUSHAF FRAME (Full height even if text is short)
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final minHeight = constraints.maxHeight > 8
                    ? constraints.maxHeight - 4
                    : 300.0;
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: minHeight),
                    child: CustomPaint(
                      painter: QuranBorderPainter(
                        primaryColor: borderPrimary,
                        secondaryColor: borderSecondary,
                        backgroundColor: bgFrameColor,
                        isDark: isDark,
                      ),
                      child: Container(
                        width: double.infinity,
                        constraints: BoxConstraints(minHeight: minHeight),
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
                        child: _buildPageContent(
                          context,
                          controller,
                          verses,
                          colorScheme,
                          isDark,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. BOTTOM FOOTER (Center: ◀  ۳۰۶  ▶ in RTL: Right is ▶, Left is ◀)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomTapAnimation(
                  onTap: () {
                    if (pageNumber > 1) {
                      controller.jumpToPage(pageNumber - 1);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      '▶',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: borderPrimary,
                      ),
                    ),
                  ),
                ),
                const Gap(8),
                ZoomTapAnimation(
                  onTap: () => _showJumpToPageDialog(context, controller),
                  child: Text(
                    pageArabic,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontFamily: 'IBMPlexSansArabic',
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1B2019),
                    ),
                  ),
                ),
                const Gap(8),
                ZoomTapAnimation(
                  onTap: () {
                    if (pageNumber < 604) {
                      controller.jumpToPage(pageNumber + 1);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      '◀',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: borderPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPageContent(
    BuildContext context,
    MushafPageReaderController controller,
    List<AyahModel> verses,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    // تقسیم آیات بر اساس سوره‌های مختلف در صورتی که صفحه شامل شروع سوره جدید باشد
    final List<Widget> widgets = [];
    int currentSurah = -1;
    List<AyahModel> currentSurahVerses = [];

    for (final v in verses) {
      if (v.surahNumber != currentSurah) {
        if (currentSurahVerses.isNotEmpty) {
          widgets.add(
            _buildVersesFlow(
              context,
              controller,
              currentSurahVerses,
              colorScheme,
            ),
          );
          currentSurahVerses = [];
        }
        currentSurah = v.surahNumber;

        // اگر سوره در این صفحه شروع شده است (آیه ۱)
        if (v.numberInSurah == 1) {
          final surah = SurahConstants.getByNumber(currentSurah);
          widgets.add(_buildSurahBanner(surah, colorScheme, isDark));

          // بنر بسم الله (غیر از سوره توبه و فاتحه)
          if (currentSurah != 1 && currentSurah != 9) {
            widgets.add(
              _buildBismillahBanner(
                colorScheme,
                controller.quranFontFamily.value,
              ),
            );
          }
        }
      }
      currentSurahVerses.add(v);
    }

    if (currentSurahVerses.isNotEmpty) {
      widgets.add(
        _buildVersesFlow(context, controller, currentSurahVerses, colorScheme),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget _buildSurahBanner(
    SurahModel? surah,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final title = surah?.name ?? 'سورة';
    final type = surah?.revelationTypeArabic ?? 'مكية';
    final count = surah?.numberOfAyahs ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withAlpha(16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onPrimary.withAlpha(45),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$type • ${toEasternArabic(count)} آيات',
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'IBMPlexSansArabic',
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBMPlexSansArabic',
              color: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillahBanner(
    ColorScheme colorScheme, [
    String fontFamily = 'uthman_taha',
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildVersesFlow(
    BuildContext context,
    MushafPageReaderController controller,
    List<AyahModel> verses,
    ColorScheme colorScheme,
  ) {
    return Obx(() {
      final fontSize = controller.quranFontSize.value;
      final fontFamily = controller.quranFontFamily.value;
      final textColor = colorScheme.onSurface;

      return Text.rich(
        TextSpan(
          children: verses.map((ayah) {
            final cleanText = ayah.displayArabicText;

            return TextSpan(
              children: [
                TextSpan(
                  text: cleanText,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      HapticFeedback.lightImpact();
                      _showAyahActionSheet(context, controller, ayah);
                    },
                ),
                TextSpan(
                  text: ' ﴿${toEasternArabic(ayah.numberInSurah)}﴾ ',
                  style: TextStyle(
                    fontSize: fontSize * 0.85,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4F6347),
                    fontFamily: fontFamily,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      HapticFeedback.selectionClick();
                      _showAyahActionSheet(context, controller, ayah);
                    },
                ),
              ],
            );
          }).toList(),
        ),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: fontSize,
          height: 2.2,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      );
    });
  }

  void _showAyahActionSheet(
    BuildContext context,
    MushafPageReaderController controller,
    AyahModel ayah,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final surah = SurahConstants.getByNumber(ayah.surahNumber);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(14),
            Text(
              '﴿ ${ayah.text} ﴾',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
                color: colorScheme.onPrimary,
                height: 1.8,
              ),
            ),
            const Gap(6),
            Center(
              child: Text(
                '${surah?.name ?? ""} • الآية ${ayah.numberInSurah}',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'IBMPlexSansArabic',
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ),
            const Gap(18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionItem(
                  icon: Icons.menu_book_rounded,
                  label: 'التفسير',
                  onTap: () {
                    Navigator.pop(ctx);
                    TafsirBottomSheet.show(context, ayah: ayah);
                  },
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
                _buildActionItem(
                  icon: Icons.copy_rounded,
                  label: 'نسخ الآية',
                  onTap: () {
                    Clipboard.setData(
                      ClipboardData(
                        text:
                            '﴿ ${ayah.text} ﴾\n[سورة ${surah?.name ?? ""} - الآية ${ayah.numberInSurah}]',
                      ),
                    );
                    Navigator.pop(ctx);
                    Get.snackbar(
                      'تم النسخ',
                      'تم نسخ الآية الكريمة إلى الحافظة',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
                _buildActionItem(
                  icon: Icons.share_rounded,
                  label: 'مشاركة',
                  onTap: () {
                    Navigator.pop(ctx);
                    Share.share(
                      '﴿ ${ayah.text} ﴾\n[سورة ${surah?.name ?? ""} - الآية ${ayah.numberInSurah}]\n\nعبر تطبيق السراج',
                    );
                  },
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return ZoomTapAnimation(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: colorScheme.onPrimary, size: 22),
          ),
          const Gap(6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'IBMPlexSansArabic',
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  void _showJumpToPageDialog(
    BuildContext context,
    MushafPageReaderController controller,
  ) {
    final textController = TextEditingController();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'انتقال إلى صفحة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                  color: colorScheme.onSurface,
                ),
              ),
              const Gap(6),
              Text(
                'أدخل رقم الصفحة بين ١ و ٦٠٤',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'IBMPlexSansArabic',
                  color: Colors.grey[600],
                ),
              ),
              const Gap(16),
              TextField(
                controller: textController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'مثال: 151',
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Gap(20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        'إلغاء',
                        style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
                      ),
                    ),
                  ),
                  const Gap(10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.onPrimary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        final val = int.tryParse(textController.text.trim());
                        if (val != null &&
                            val >= 1 &&
                            val <= MushafPageReaderController.totalPages) {
                          Get.back();
                          controller.jumpToPage(val);
                        } else {
                          Get.snackbar(
                            'رقم غير صحيح',
                            'يرجى إدخال رقم صفحة بين 1 و 604',
                          );
                        }
                      },
                      child: const Text(
                        'انتقال',
                        style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFontSizeSheet(
    BuildContext context,
    MushafPageReaderController controller,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'حجم خط القرآن الكريم',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: controller.decreaseFontSize,
                  icon: const Icon(
                    Icons.remove_circle_outline_rounded,
                    size: 30,
                  ),
                ),
                const Gap(20),
                Obx(
                  () => Text(
                    '${controller.quranFontSize.value.toInt()}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Gap(20),
                IconButton(
                  onPressed: controller.increaseFontSize,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 30),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
