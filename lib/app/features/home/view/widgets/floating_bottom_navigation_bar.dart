import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/home/view/controller/bottom_navigation_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class FloatingBottomNavigationBar extends StatelessWidget {
  const FloatingBottomNavigationBar({
    super.key,
    required this.controller,
  });

  final BottomNavigationController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    final List<Map<String, String>> navItems = [
      {
        'title': 'الرئيسية',
        'activeIcon': 'assets/svgs/fill/house-chimney.svg',
        'inactiveIcon': 'assets/svgs/house.svg',
      },
      {
        'title': 'المفضلة',
        'activeIcon': 'assets/svgs/fill/wishlist-star.svg',
        'inactiveIcon': 'assets/svgs/wishlist-star.svg',
      },
      {
        'title': 'الإعدادات',
        'activeIcon': 'assets/svgs/fill/settings.svg',
        'inactiveIcon': 'assets/svgs/settings.svg',
      },
    ];

    return SafeArea(
      bottom: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 90 : 25),
              blurRadius: 18,
              offset: const Offset(0, 6),
              spreadRadius: 1,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF1E1C1C).withAlpha(235)
                    : Colors.white.withAlpha(240),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(22)
                      : brandColor.withAlpha(28),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(navItems.length, (index) {
                  return Expanded(
                    child: Obx(() {
                      final isSelected = controller.selectedIndex.value == index;
                      final item = navItems[index];

                      return ZoomTapAnimation(
                        onTap: () => controller.onItemTapped(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? brandColor.withAlpha(isDark ? 36 : 22)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                isSelected
                                    ? item['activeIcon']!
                                    : item['inactiveIcon']!,
                                width: 20,
                                height: 20,
                                colorFilter: ColorFilter.mode(
                                  isSelected
                                      ? brandColor
                                      : (isDark
                                          ? Colors.grey[400]!
                                          : Colors.grey[600]!),
                                  BlendMode.srcIn,
                                ),
                              ),
                              if (isSelected) ...[
                                const Gap(7),
                                Flexible(
                                  child: Text(
                                    item['title']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'IBMPlexSansArabic',
                                      color: brandColor,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
