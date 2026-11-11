import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/quran_controller.dart';
import '../../data/models/juz_model.dart';
import '../screens/juz_detail_page.dart';
import '../screens/surah_detail_page.dart';

class JuzSurahsSheet extends StatelessWidget {
  final JuzModel juz;
  final QuranController controller;

  const JuzSurahsSheet({
    super.key,
    required this.juz,
    required this.controller,
  });

  static Future<void> show(
    BuildContext context, {
    required JuzModel juz,
    required QuranController controller,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => JuzSurahsSheet(
        juz: juz,
        controller: controller,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 20,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          juz.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'بداية الجزء: ﴿ ${juz.startVerseText} ﴾',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onPrimary,
                            fontFamily: 'IBMPlexSansArabic',
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // زر قراءة الجزء كاملاً
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: ZoomTapAnimation(
                onTap: () {
                  Navigator.pop(context);
                  Get.to(() => JuzDetailPage(juz: juz));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.onPrimary.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_stories_rounded, size: 18, color: Colors.white),
                      const Gap(8),
                      Text(
                        'قراءة ${juz.name} كاملاً',
                        style: const TextStyle(
                          fontSize: 13.5,
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

            const Divider(height: 1, thickness: 0.5),

            // List of surahs in this Juz
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: juz.surahs.length,
                separatorBuilder: (_, __) => const Gap(8),
                itemBuilder: (context, index) {
                  final ref = juz.surahs[index];
                  final surah = controller.getSurahByNumber(ref.surahNumber);
                  if (surah == null) return const SizedBox.shrink();

                  final isFullSurah = (ref.startAyah == 1 &&
                      ref.endAyah == surah.numberOfAyahs);
                  final versesText = isFullSurah
                      ? 'كامل السورة (${surah.numberOfAyahs} آيات)'
                      : 'الآيات من ${ref.startAyah} إلى ${ref.endAyah}';

                  return ZoomTapAnimation(
                    onTap: () {
                      Navigator.pop(context);
                      Get.to(() => SurahDetailPage(
                            surah: surah,
                            initialTafsir: controller.selectedTafsir.value,
                            initialAyahNumber: ref.startAyah,
                          ));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(10)
                            : colorScheme.onPrimary.withAlpha(8),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.onPrimary.withAlpha(20),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Surah number badge
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary.withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                '${surah.number}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBMPlexSansArabic',
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ),
                          const Gap(12),
                          // Surah name & range
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      surah.name,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'IBMPlexSansArabic',
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const Gap(8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 1.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: surah.isMeccan
                                            ? Colors.orange.withAlpha(25)
                                            : Colors.teal.withAlpha(25),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        surah.revelationTypeArabic,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: surah.isMeccan
                                              ? Colors.orange[800]
                                              : Colors.teal[800],
                                          fontFamily: 'IBMPlexSansArabic',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(4),
                                Text(
                                  versesText,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const Gap(4),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
