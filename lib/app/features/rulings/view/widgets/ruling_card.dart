import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/rulings/controller/rulings_controller.dart';
import 'package:mawsueat/app/features/rulings/data/models/ruling_model.dart';
import 'package:mawsueat/app/features/rulings/view/screens/ruling_detail_page.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class RulingCard extends StatelessWidget {
  final RulingModel ruling;

  const RulingCard({super.key, required this.ruling});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RulingsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ZoomTapAnimation(
      onTap: () => Get.to(() => RulingDetailPage(ruling: ruling)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242020) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black.withAlpha(10),
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
            // Top Meta Row: Marja badge & Category & Code
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withAlpha(isDark ? 35 : 18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.person_pin_rounded,
                            size: 13,
                            color: colorScheme.onPrimary,
                          ),
                          const Gap(4),
                          Text(
                            ruling.marjaName,
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.black.withAlpha(6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ruling.categoryTitle,
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface.withAlpha(180),
                        ),
                      ),
                    ),
                  ],
                ),
                if (ruling.rulingNumber != null)
                  Text(
                    ruling.rulingNumber!,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
              ],
            ),

            const Gap(12),

            // Title
            Text(
              ruling.title,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
                height: 1.4,
              ),
            ),

            const Gap(10),

            // Question summary
            Text(
              '« ${ruling.question} »',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                height: 1.5,
              ),
            ),

            const Gap(12),

            // Answer Box Preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withAlpha(isDark ? 20 : 10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.onPrimary.withAlpha(isDark ? 40 : 20),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 16,
                    color: colorScheme.onPrimary,
                  ),
                  const Gap(8),
                  Expanded(
                    child: Text(
                      ruling.answer,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurface.withAlpha(220),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Gap(12),

            // Bottom Action Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'انقر لعرض التفاصيل الكاملة',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 11,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    // Copy
                    ZoomTapAnimation(
                      onTap: () => controller.copyRuling(ruling),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black.withAlpha(6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 15,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const Gap(8),
                    // Share
                    ZoomTapAnimation(
                      onTap: () => controller.shareRuling(ruling),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black.withAlpha(6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.share_rounded,
                          size: 15,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    const Gap(8),
                    // Bookmark
                    ZoomTapAnimation(
                      onTap: () => controller.toggleBookmark(ruling),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black.withAlpha(6),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          ruling.isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 16,
                          color: ruling.isFavorite ? Colors.amber[700] : colorScheme.onSurface.withAlpha(180),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
