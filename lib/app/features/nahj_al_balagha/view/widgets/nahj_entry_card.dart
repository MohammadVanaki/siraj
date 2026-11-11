import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../data/models/nahj_entry_model.dart';

class NahjEntryCard extends StatelessWidget {
  final NahjEntryModel entry;
  final int index;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkTap;

  const NahjEntryCard({
    super.key,
    required this.entry,
    required this.index,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    final excerpt = entry.excerptArabic ?? entry.bodyArabic ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ZoomTapAnimation(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2226) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isBookmarked
                  ? Colors.amber.shade700.withAlpha(isDark ? 90 : 60)
                  : (isDark ? Colors.white10 : Colors.grey.shade200),
              width: isBookmarked ? 1.4 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 40 : 8),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Number pill, Title, Bookmark button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item Number Badge
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: brandColor.withAlpha(isDark ? 30 : 15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: brandColor.withAlpha(40),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.itemNumber}',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: brandColor,
                      ),
                    ),
                  ),

                  const Gap(12),

                  // Title and Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.titleArabic,
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bookmark Button
                  ZoomTapAnimation(
                    onTap: onBookmarkTap,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        isBookmarked
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_border_rounded,
                        color: isBookmarked
                            ? Colors.amber.shade700
                            : (isDark ? Colors.white30 : Colors.grey.shade400),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),

              // Excerpt text preview
              if (excerpt.isNotEmpty) ...[
                const Gap(12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha(4)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    excerpt.replaceAll('\r', '').replaceAll('\n\n', '\n'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 13,
                      height: 1.6,
                      color: isDark ? Colors.grey[300] : const Color(0xFF4A4A4A),
                    ),
                  ),
                ),
              ],

              const Gap(10),

              // Footer: Category tag & Commentaries badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category tag
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: brandColor.withAlpha(isDark ? 20 : 10),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _categoryArabic(entry.category),
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: brandColor,
                      ),
                    ),
                  ),

                  // Read arrow
                  Row(
                    children: [
                      Text(
                        'قراءة النص',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: brandColor,
                        ),
                      ),
                      const Gap(2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: brandColor,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryArabic(String cat) {
    switch (cat) {
      case 'sermons':
        return 'الخطب';
      case 'letters':
        return 'الرسائل';
      case 'wisdom':
        return 'الحكم';
      case 'rare_words':
        return 'غريب الكلام';
      default:
        return 'نهج البلاغة';
    }
  }
}
