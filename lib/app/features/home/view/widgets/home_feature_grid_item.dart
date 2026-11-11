import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomeFeatureGridItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String iconPath;
  final VoidCallback onTap;
  final Color? color;
  final bool isHighlighted;

  const HomeFeatureGridItem({
    super.key,
    required this.title,
    this.subtitle,
    required this.iconPath,
    required this.onTap,
    this.color,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = color ?? colorScheme.onPrimary;
    final isSvg = iconPath.toLowerCase().endsWith('.svg');

    return ZoomTapAnimation(
      onTap: onTap,
      begin: 1.0,
      end: 0.94,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(10) : brandColor.withAlpha(8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(16)
                : brandColor.withAlpha(22),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon container with soft circular ambient backdrop
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(10)
                    : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 25 : 8),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: isSvg
                    ? SvgPicture.asset(
                        iconPath,
                        width: 44,
                        height: 44,
                        colorFilter: ColorFilter.mode(
                          brandColor,
                          BlendMode.srcIn,
                        ),
                      )
                    : Image.asset(
                        iconPath,
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                        cacheWidth: 124,
                        cacheHeight: 124,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.auto_stories_rounded,
                            size: 38,
                            color: brandColor,
                          );
                        },
                      ),
              ),
            ),
            const Gap(6),
            // Title
            Flexible(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                  height: 1.15,
                  color: colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
