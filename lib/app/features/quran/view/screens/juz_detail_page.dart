import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../controller/juz_detail_controller.dart';
import '../../data/data_sources/surah_constants.dart';
import '../../data/models/ayah_model.dart';
import '../../data/models/juz_model.dart';
import '../../data/models/surah_model.dart';
import '../widgets/tafsir_bottom_sheet.dart';

class JuzDetailPage extends StatelessWidget {
  final JuzModel juz;

  const JuzDetailPage({super.key, required this.juz});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      JuzDetailController(juz: juz),
      tag: 'juz_${juz.number}',
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
          titleWidget: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                juz.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'بداية الجزء: ﴿ ${juz.startVerseText} ﴾',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'IBMPlexSansArabic',
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          actions: [
            ZoomTapAnimation(
              onTap: () => _showFontSizeSheet(context, controller),
              child: Container(
                margin: const EdgeInsets.only(left: 12, right: 4, top: 8, bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(12) : colorScheme.onPrimary.withAlpha(20),
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
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                    ),
                  ),
                  const Gap(12),
                  Text(
                    'جاري تحميل آيات ${juz.name}...',
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

          if (controller.errorMessage.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 40, color: Colors.grey[400]),
                  const Gap(10),
                  Text(
                    'تعذر تحميل آيات الجزء',
                    style: const TextStyle(fontSize: 14, fontFamily: 'IBMPlexSansArabic'),
                  ),
                  const Gap(12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.onPrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: controller.loadJuzVerses,
                    icon: const Icon(Icons.refresh_rounded, size: 16),
                    label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
                  ),
                ],
              ),
            );
          }

          if (controller.ayahs.isEmpty) {
            return const Center(
              child: Text(
                'لا تتوفر آيات لهذا الجزء',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(8) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? Colors.white.withAlpha(15) : colorScheme.onPrimary.withAlpha(25),
                  width: 1.5,
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(6),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              padding: const EdgeInsets.all(18),
              child: _buildJuzContent(context, controller, colorScheme, isDark),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildJuzContent(
    BuildContext context,
    JuzDetailController controller,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final List<Widget> widgets = [];
    int currentSurah = -1;
    List<AyahModel> currentSurahVerses = [];

    for (final v in controller.ayahs) {
      if (v.surahNumber != currentSurah) {
        if (currentSurahVerses.isNotEmpty) {
          widgets.add(_buildVersesFlow(context, controller, currentSurahVerses, colorScheme));
          currentSurahVerses = [];
        }
        currentSurah = v.surahNumber;

        final surah = SurahConstants.getByNumber(currentSurah);
        widgets.add(_buildSurahBanner(surah, colorScheme, isDark));

        if (v.numberInSurah == 1 && currentSurah != 1 && currentSurah != 9) {
          widgets.add(_buildBismillahBanner(colorScheme));
        }
      }
      currentSurahVerses.add(v);
    }

    if (currentSurahVerses.isNotEmpty) {
      widgets.add(_buildVersesFlow(context, controller, currentSurahVerses, colorScheme));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  Widget _buildSurahBanner(SurahModel? surah, ColorScheme colorScheme, bool isDark) {
    final title = surah?.name ?? 'سورة';
    final type = surah?.revelationTypeArabic ?? 'مكية';
    final count = surah?.numberOfAyahs ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 14),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.onPrimary.withAlpha(16),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.onPrimary.withAlpha(45), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$type • $count آية',
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

  Widget _buildBismillahBanner(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'IBMPlexSansArabic',
            color: colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildVersesFlow(
    BuildContext context,
    JuzDetailController controller,
    List<AyahModel> verses,
    ColorScheme colorScheme,
  ) {
    return Obx(() {
      final fontSize = controller.quranFontSize.value;
      final textColor = colorScheme.onSurface;
      final numberColor = colorScheme.onPrimary;

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
                      _showAyahActionSheet(context, ayah);
                    },
                ),
                TextSpan(
                  text: ' ﴿${ayah.numberInSurahArabic}﴾ ',
                  style: TextStyle(
                    fontSize: fontSize * 0.85,
                    fontWeight: FontWeight.bold,
                    color: numberColor,
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      HapticFeedback.selectionClick();
                      _showAyahActionSheet(context, ayah);
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
          fontFamily: 'IBMPlexSansArabic',
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      );
    });
  }

  void _showAyahActionSheet(BuildContext context, AyahModel ayah) {
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
                ),
                _buildActionItem(
                  icon: Icons.copy_rounded,
                  label: 'نسخ الآية',
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                      text: '﴿ ${ayah.text} ﴾\n[سورة ${surah?.name ?? ""} - الآية ${ayah.numberInSurah}]',
                    ));
                    Navigator.pop(ctx);
                    Get.snackbar('تم النسخ', 'تم نسخ الآية الكريمة إلى الحافظة', snackPosition: SnackPosition.BOTTOM);
                  },
                  colorScheme: colorScheme,
                ),
                _buildActionItem(
                  icon: Icons.share_rounded,
                  label: 'مشاركة',
                  onTap: () {
                    Navigator.pop(ctx);
                    Share.share('﴿ ${ayah.text} ﴾\n[سورة ${surah?.name ?? ""} - الآية ${ayah.numberInSurah}]\n\nعبر تطبيق السراج');
                  },
                  colorScheme: colorScheme,
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

  void _showFontSizeSheet(BuildContext context, JuzDetailController controller) {
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
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'IBMPlexSansArabic'),
            ),
            const Gap(16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: controller.decreaseFontSize,
                  icon: const Icon(Icons.remove_circle_outline_rounded, size: 30),
                ),
                const Gap(20),
                Obx(() => Text(
                      '${controller.quranFontSize.value.toInt()}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
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

