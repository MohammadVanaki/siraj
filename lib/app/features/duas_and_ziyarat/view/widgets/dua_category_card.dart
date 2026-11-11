import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../data/models/dua_media_item.dart';

class DuaCategoryCard extends StatelessWidget {
  final DuaCategoryModel category;
  final bool isAudio;
  final VoidCallback onTap;
  final EdgeInsetsGeometry? margin;

  const DuaCategoryCard({
    super.key,
    required this.category,
    required this.isAudio,
    required this.onTap,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final countLabel = isAudio
        ? '${category.itemCount} ${category.itemCount <= 2 ? "ملفات صوتية" : "ملفاً صوتياً"}'
        : '${category.itemCount} ${category.itemCount <= 2 ? "تسجيلات مرئية" : "تسجيلاً مرئياً"}';

    return ZoomTapAnimation(
      onTap: onTap,
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(15)
                : colorScheme.onPrimary.withAlpha(20),
            width: 1.0,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            // Category Icon Badge
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withAlpha(18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.onPrimary.withAlpha(50),
                  width: 1,
                ),
              ),
              child: Center(
                child: Icon(
                  category.icon ?? (isAudio ? Icons.headphones_rounded : Icons.ondemand_video_rounded),
                  size: 24,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),

            const Gap(14),

            // Title & Subtitle & Count Badge
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        category.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const Gap(8),
                      // Count Badge
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
                          countLabel,
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
                  if (category.subtitle.trim().isNotEmpty) ...[
                    const Gap(4),
                    Text(
                      category.subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
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
