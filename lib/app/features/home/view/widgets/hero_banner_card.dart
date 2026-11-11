import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HeroBannerCard extends StatelessWidget {
  final VoidCallback onTap;

  const HeroBannerCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.onPrimary;
    final isDark = theme.brightness == Brightness.dark;

    return ZoomTapAnimation(
      onTap: onTap,
      begin: 1.0,
      end: 0.97,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF383333),
                    const Color(0xFF221F1F),
                  ]
                : [
                    primaryColor,
                    primaryColor.withAlpha((255 * 0.85).round()),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : primaryColor).withAlpha(80),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Decorative background circles
              Positioned(
                left: -30,
                top: -30,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(isDark ? 10 : 20),
                  ),
                ),
              ),
              Positioned(
                left: 40,
                bottom: -50,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(isDark ? 8 : 15),
                  ),
                ),
              ),
              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(isDark ? 30 : 45),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/svgs/star.svg',
                                  width: 12,
                                  height: 12,
                                  colorFilter: const ColorFilter.mode(
                                    Colors.amberAccent,
                                    BlendMode.srcIn,
                                  ),
                                ),
                                const Gap(5),
                                const Text(
                                  'القسم الرئيسي',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(12),
                          const Text(
                            'موسوعة أهل البيت',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBMPlexSansArabic',
                              letterSpacing: 0.3,
                            ),
                          ),
                          const Gap(6),
                          Text(
                            'المكتبة الشاملة • الأبواب والموضوعات التخصصية',
                            style: TextStyle(
                              color: Colors.white.withAlpha(220),
                              fontSize: 12,
                              fontFamily: 'IBMPlexSansArabic',
                            ),
                          ),
                          const Gap(16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'دخول الموسوعة',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFF221F1F)
                                        : primaryColor,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                                const Gap(6),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: isDark
                                      ? const Color(0xFF221F1F)
                                      : primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(10),
                    // Icon / Graphic Representation
                    Container(
                      width: 84,
                      height: 84,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(isDark ? 25 : 35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(60),
                          width: 2,
                        ),
                      ),
                      child: SvgPicture.asset(
                        'assets/svgs/books.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
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
