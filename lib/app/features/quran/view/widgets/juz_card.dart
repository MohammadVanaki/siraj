import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../data/models/juz_model.dart';
import '../../data/models/surah_model.dart';

class JuzCard extends StatelessWidget {
  final JuzModel juz;
  final SurahModel? startSurah;
  final SurahModel? endSurah;
  final VoidCallback onTap;

  const JuzCard({
    super.key,
    required this.juz,
    this.startSurah,
    this.endSurah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final startSurahName = startSurah?.name ?? '';
    final endSurahName = endSurah?.name ?? '';
    final rangeText = (startSurahName.isNotEmpty && endSurahName.isNotEmpty)
        ? (startSurahName == endSurahName
            ? startSurahName
            : '$startSurahName إلى $endSurahName')
        : '';

    return ZoomTapAnimation(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(15)
                : colorScheme.onPrimary.withAlpha(20),
            width: 1,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(8),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Juz Number inside ornamental badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.onPrimary.withAlpha(50),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '${juz.number}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IBMPlexSansArabic',
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ),

            const Gap(14),

            // Juz Name, Beginning text, and Surahs range
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      const Gap(8),
                      // Surah count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${juz.surahCount} ${juz.surahCount == 1 ? "سورة" : "سور"}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimary,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(4),
                  // Start verse text
                  Text(
                    '﴿ ${juz.startVerseText} ﴾',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onPrimary,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (rangeText.isNotEmpty) ...[
                    const Gap(2),
                    Text(
                      rangeText,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Trailing arrow / icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const Gap(4),
          ],
        ),
      ),
    );
  }
}
