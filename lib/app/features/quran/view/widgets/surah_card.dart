import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mawsueat/app/features/quran/data/models/surah_model.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SurahCard extends StatelessWidget {
  final SurahModel surah;
  final VoidCallback onTap;

  const SurahCard({super.key, required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
            // Surah Number inside ornamental badge
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
                  '${surah.number}',
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

            // Surah Name and Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        surah.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Gap(8),
                      // Revelation type tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: surah.isMeccan
                              ? Colors.orange.withAlpha(25)
                              : Colors.teal.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          surah.revelationTypeArabic,
                          style: TextStyle(
                            fontSize: 10,
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
                  Row(
                    children: [
                      Text(
                        '${surah.numberOfAyahs} آيات',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                      const Gap(8),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.grey.withAlpha(100)),
                      ),
                      const Gap(8),
                      Text(
                        surah.englishName,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ],
                  ),
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
