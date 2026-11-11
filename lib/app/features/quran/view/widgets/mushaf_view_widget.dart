import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/surah_detail_controller.dart';
import '../../data/data_sources/juz_constants.dart';
import '../../data/data_sources/surah_constants.dart';
import '../../data/models/ayah_model.dart';
import '../../data/models/surah_model.dart';
import 'quran_border_painter.dart';
import 'tafsir_bottom_sheet.dart';

class MushafViewWidget extends StatelessWidget {
  final SurahDetailController controller;

  const MushafViewWidget({
    super.key,
    required this.controller,
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
    if (controller.mushafPageController == null) {
      final initialPage = controller.currentMushafPage.value;
      controller.mushafPageController =
          PageController(initialPage: initialPage - 1);
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: PageView.builder(
        controller: controller.mushafPageController,
        itemCount: 604,
        onPageChanged: controller.onMushafPageChanged,
        itemBuilder: (context, index) {
          final pageNumber = index + 1;
          return _buildMushafPage(context, pageNumber, colorScheme, isDark);
        },
      ),
    );
  }

  Widget _buildMushafPage(
    BuildContext context,
    int pageNumber,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Obx(() {
      final isLoading = controller.loadingMushafPages.contains(pageNumber);
      final error = controller.mushafPageErrors[pageNumber];
      final verses = controller.mushafPagesCache[pageNumber];

      if (verses == null && isLoading) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                ),
              ),
              const Gap(12),
              Text(
                'جاري تحميل الصفحة ${toEasternArabic(pageNumber)}...',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'IBMPlexSansArabic',
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }

      if (verses == null && error != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off_rounded, size: 38, color: Colors.grey[400]),
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
                onPressed: () => controller.loadMushafPage(pageNumber),
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.loadMushafPage(pageNumber);
        });
        return const SizedBox.shrink();
      }

      final firstAyah = verses.first;
      final surahNumber = firstAyah.surahNumber;
      final juzNumber = firstAyah.juz ?? 1;

      final surahTitle = getSurahNameArabic(surahNumber);
      final juzTitle = getJuzNameArabic(juzNumber);
      final pageArabic = toEasternArabic(pageNumber);

      final bgFrameColor =
          isDark ? const Color(0xFF1B1D18) : const Color(0xFFFAF8EE);
      final borderPrimary =
          isDark ? const Color(0xFF7D966E) : const Color(0xFF4F6347);
      final borderSecondary =
          isDark ? const Color(0xFFC7B07B) : const Color(0xFF968453);

      return Column(
        children: [
          // 1. TOP HEADER (Right: Juz name | Center: ◀ Page ▶ | Left: Surah name)
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Right: Juz name (e.g. الجزء السادس عشر)
                Text(
                  juzTitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontFamily: 'uthman_taha',
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
                          controller.jumpToMushafPage(pageNumber - 1);
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
                      onTap: () => _showJumpToPageDialog(context),
                      child: Text(
                        pageArabic,
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'uthman_taha',
                          fontWeight: FontWeight.bold,
                          color:
                              isDark ? Colors.white : const Color(0xFF1B2019),
                        ),
                      ),
                    ),
                    const Gap(6),
                    ZoomTapAnimation(
                      onTap: () {
                        if (pageNumber < 604) {
                          controller.jumpToMushafPage(pageNumber + 1);
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

                // Left: Surah name (e.g. سورة مريم)
                Text(
                  surahTitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontFamily: 'uthman_taha',
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
                final minHeight = constraints.maxHeight > 8 ? constraints.maxHeight - 4 : 300.0;
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
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
                        padding: const EdgeInsets.fromLTRB(30, 26, 30, 26),
                        child: _buildPageVersesFlow(context, verses, isDark),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 3. BOTTOM FOOTER (Center: ◀  ۳۰۶  ▶ in RTL: Right is ▶, Left is ◀)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ZoomTapAnimation(
                  onTap: () {
                    if (pageNumber > 1) {
                      controller.jumpToMushafPage(pageNumber - 1);
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
                  onTap: () => _showJumpToPageDialog(context),
                  child: Text(
                    pageArabic,
                    style: TextStyle(
                      fontSize: 15.5,
                      fontFamily: 'uthman_taha',
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF1B2019),
                    ),
                  ),
                ),
                const Gap(8),
                ZoomTapAnimation(
                  onTap: () {
                    if (pageNumber < 604) {
                      controller.jumpToMushafPage(pageNumber + 1);
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

  Widget _buildPageVersesFlow(
    BuildContext context,
    List<AyahModel> verses,
    bool isDark,
  ) {
    final List<Widget> widgets = [];
    int currentSurah = -1;
    List<AyahModel> currentSurahVerses = [];

    for (final v in verses) {
      if (v.surahNumber != currentSurah) {
        if (currentSurahVerses.isNotEmpty) {
          widgets.add(
            _buildVersesRichText(context, currentSurahVerses, isDark),
          );
          currentSurahVerses = [];
        }
        currentSurah = v.surahNumber;

        // اگر سوره در این صفحه شروع شده است (آیه ۱)
        if (v.numberInSurah == 1) {
          final sModel = SurahConstants.getByNumber(currentSurah);
          widgets.add(_buildSurahBanner(sModel, isDark));

          if (currentSurah != 1 && currentSurah != 9) {
            widgets.add(_buildBismillahBanner(isDark, controller.quranFontFamily.value));
          }
        }
      }
      currentSurahVerses.add(v);
    }

    if (currentSurahVerses.isNotEmpty) {
      widgets.add(
        _buildVersesRichText(context, currentSurahVerses, isDark),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget _buildSurahBanner(
    SurahModel? surah,
    bool isDark,
  ) {
    final title = surah != null
        ? (surah.englishNameTranslation.startsWith('سورة')
            ? surah.englishNameTranslation
            : 'سورة ${surah.englishNameTranslation}')
        : 'سورة';
    final type = surah?.revelationTypeArabic ?? 'مكية';
    final count = surah != null ? toEasternArabic(surah.numberOfAyahs) : '٠';

    final bannerBg =
        isDark ? const Color(0xFF232720) : const Color(0xFFF3EEDF);
    final borderCol =
        isDark ? const Color(0xFF7D966E) : const Color(0xFF4F6347);
    final goldCol =
        isDark ? const Color(0xFFC7B07B) : const Color(0xFF968453);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: borderCol.withAlpha(isDark ? 30 : 20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$type • $count آيات',
            style: TextStyle(
              fontSize: 11.5,
              fontFamily: 'IBMPlexSansArabic',
              color: goldCol,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBMPlexSansArabic',
              color: borderCol,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillahBanner(bool isDark, [String fontFamily = 'uthman_taha']) {
    final col = isDark ? const Color(0xFFC7B07B) : const Color(0xFF4F6347);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
            color: col,
          ),
        ),
      ),
    );
  }

  Widget _buildVersesRichText(
    BuildContext context,
    List<AyahModel> verses,
    bool isDark,
  ) {
    return Obx(() {
      final fontSize = controller.quranFontSize.value;
      final fontFamily = controller.quranFontFamily.value;
      final activeAyah = controller.activePlayingAyah.value;
      final activeSurah = controller.activePlayingSurah.value;
      final isAudioPlaying = controller.isAudioPlaying.value;

      final textColor =
          isDark ? const Color(0xFFE8E5DA) : const Color(0xFF1B2019);

      final ayahMarkerColor =
          isDark ? const Color(0xFF7D966E) : const Color(0xFF4F6347);

      final highlightBg =
          isDark ? const Color(0xFF264228) : const Color(0xFFD2EBD4);

      return Text.rich(
        TextSpan(
          children: verses.map((ayah) {
            final cleanText = ayah.displayArabicText;
            final isHighlighted = isAudioPlaying &&
                (activeSurah == ayah.surahNumber) &&
                (activeAyah == ayah.numberInSurah);

            return TextSpan(
              children: [
                // متن آیه شریفه
                TextSpan(
                  text: cleanText,
                  style: TextStyle(
                    backgroundColor:
                        isHighlighted ? highlightBg : Colors.transparent,
                    color: isHighlighted
                        ? (isDark ? Colors.white : const Color(0xFF1B2019))
                        : textColor,
                    fontWeight:
                        isHighlighted ? FontWeight.bold : FontWeight.w600,
                    fontFamily: fontFamily,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      HapticFeedback.lightImpact();
                      if (isAudioPlaying &&
                          activeSurah == ayah.surahNumber &&
                          activeAyah == ayah.numberInSurah) {
                        controller.pauseAudio();
                      } else if (activeSurah == ayah.surahNumber &&
                          activeAyah == ayah.numberInSurah &&
                          controller.audioPosition.value > Duration.zero) {
                        controller.resumeAudio();
                      } else {
                        controller.playAyah(ayah, isConsecutive: true);
                      }
                    },
                ),

                // نشان پایانی شماره آیه ﴿۱۲﴾
                TextSpan(
                  text: ' ﴿${toEasternArabic(ayah.numberInSurah)}﴾ ',
                  style: TextStyle(
                    fontSize: fontSize * 0.85,
                    fontWeight: FontWeight.bold,
                    backgroundColor:
                        isHighlighted ? highlightBg : Colors.transparent,
                    color: ayahMarkerColor,
                    fontFamily: fontFamily,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      HapticFeedback.selectionClick();
                      controller.openTafsir(ayah);
                      TafsirBottomSheet.show(
                        context,
                        ayah: ayah,
                        controller: controller,
                      );
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
          height: 2.15,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      );
    });
  }

  void _showJumpToPageDialog(BuildContext context) {
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
                'أدخل رقم الصفحة بين 1 و 604',
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
                  hintText: 'مثال: 50',
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
                        if (val != null && val >= 1 && val <= 604) {
                          Get.back();
                          controller.jumpToMushafPage(val);
                        } else {
                          Get.snackbar(
                            'رقم غير صحيح',
                            'يرجى إدخال رقم صفحة بين 1 و 604',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: const Text(
                        'انتقال',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontWeight: FontWeight.bold,
                        ),
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
}
