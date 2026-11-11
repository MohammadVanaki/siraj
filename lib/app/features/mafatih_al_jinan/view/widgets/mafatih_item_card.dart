import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../data/models/mafatih_item_model.dart';

class MafatihItemCard extends StatelessWidget {
  final MafatihItemModel item;
  final int index;
  final bool isBookmarked;
  final VoidCallback onTap;
  final VoidCallback onBookmarkToggle;

  const MafatihItemCard({
    super.key,
    required this.item,
    required this.index,
    required this.isBookmarked,
    required this.onTap,
    required this.onBookmarkToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = colorScheme.onPrimary;

    final arabicIndex = MafatihItemModel.toArabicDigits(index + 1);
    final paragraphsCount = item.paragraphs.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ZoomTapAnimation(
        onTap: onTap,
        begin: 1.0,
        end: 0.98,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2226) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(20)
                  : primaryColor.withAlpha(28),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 50 : 8),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // گرادیان ملایم حاشیه راست
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16),
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // شماره دعا در قالب نشان دایره‌ای
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryColor.withValues(alpha: isDark ? 0.20 : 0.10),
                          border: Border.all(
                            color: primaryColor.withValues(alpha: isDark ? 0.40 : 0.30),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            arabicIndex,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBMPlexSansArabic',
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ),

                      const Gap(14),

                      // عنوان و پیش‌نمایش متن
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.titleArabic,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IBMPlexSansArabic',
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              item.previewSnippet,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.5,
                                height: 1.45,
                                fontFamily: 'IBMPlexSansArabic',
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                            ),
                            const Gap(6),

                            // تگ تعداد صفحات و زمان مطالعه
                            Row(
                              children: [
                                if (paragraphsCount > 0) ...[
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withAlpha(10)
                                          : primaryColor.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.menu_book_rounded,
                                          size: 11,
                                          color: primaryColor,
                                        ),
                                        const Gap(4),
                                        Text(
                                          MafatihItemModel.toArabicDigits(paragraphsCount),
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'IBMPlexSansArabic',
                                            color: primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Gap(6),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withAlpha(8)
                                        : Colors.grey.withAlpha(20),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 11,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                      const Gap(3),
                                      Text(
                                        '~ ${MafatihItemModel.toArabicDigits(item.estimatedReadingMinutes)} دقيقة',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontFamily: 'IBMPlexSansArabic',
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const Gap(10),

                      // دکمه نشانه‌گذاری و آیکون فلش
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ZoomTapAnimation(
                            onTap: onBookmarkToggle,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isBookmarked
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color: isBookmarked
                                    ? Colors.amber[700]
                                    : (isDark ? Colors.grey[600] : Colors.grey[400]),
                                size: 22,
                              ),
                            ),
                          ),
                          const Gap(6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 13,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
