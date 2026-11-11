import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/misbaha/controller/misbaha_controller.dart';
import 'package:mawsueat/app/features/misbaha/model/bead_theme.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class BeadThemeSheet extends StatelessWidget {
  const BeadThemeSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BeadThemeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = MisbahaController.to;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.75,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 90 : 40),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(12),
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Gap(16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.palette_rounded,
                    color: colorScheme.onPrimary,
                    size: 22,
                  ),
                  const Gap(10),
                  Text(
                    'مظهر ولون حبات المسبحة',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            Flexible(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shrinkWrap: true,
                itemCount: BeadTheme.themes.length,
                separatorBuilder: (context, index) => const Gap(8),
                itemBuilder: (context, index) {
                  final item = BeadTheme.themes[index];
                  return Obx(() {
                    final isSelected = controller.selectedTheme.value.id == item.id;
                    return ZoomTapAnimation(
                      onTap: () {
                        controller.selectTheme(item);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.onPrimary.withAlpha(isDark ? 40 : 20)
                              : (isDark ? Colors.white.withAlpha(8) : Colors.grey[100]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : (isDark ? Colors.white10 : Colors.grey[300]!),
                            width: isSelected ? 1.5 : 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Bead color preview circles
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [item.beadColors[0], item.beadColors[2]],
                                      center: const Alignment(-0.3, -0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: item.beadColors[1].withAlpha(100),
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const Gap(6),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [item.beadColors[1], item.beadColors[3]],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(16),
                            Expanded(
                              child: Text(
                                item.name,
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSansArabic',
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: colorScheme.onPrimary,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const Gap(12),
          ],
        ),
      ),
    );
  }
}
