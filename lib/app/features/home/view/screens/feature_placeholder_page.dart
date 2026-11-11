import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';

class FeaturePlaceholderPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconPath;

  const FeaturePlaceholderPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: title,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withAlpha(isDark ? 40 : 25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: colorScheme.onPrimary.withAlpha(60),
                    width: 2,
                  ),
                ),
                child: iconPath.endsWith('.svg')
                    ? SvgPicture.asset(
                        iconPath,
                        colorFilter: ColorFilter.mode(
                          colorScheme.onPrimary,
                          BlendMode.srcIn,
                        ),
                      )
                    : Image.asset(
                        iconPath,
                        fit: BoxFit.contain,
                      ),
              ),
              const Gap(24),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                  color: colorScheme.onSurface,
                ),
              ),
              const Gap(8),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontFamily: 'IBMPlexSansArabic',
                ),
                textAlign: TextAlign.center,
              ),
              const Gap(24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.construction_rounded,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                    const Gap(8),
                    Text(
                      'قسم $title قيد التطوير والتفعيل',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
