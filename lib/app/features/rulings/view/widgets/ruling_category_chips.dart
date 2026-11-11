import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/rulings/controller/rulings_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class RulingCategoryChips extends StatelessWidget {
  const RulingCategoryChips({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RulingsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final categories = controller.categories;
      final selectedId = controller.selectedCategoryId.value;

      if (categories.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const Gap(8),
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = selectedId == cat.id;

            return ZoomTapAnimation(
              onTap: () => controller.selectCategory(cat.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.onPrimary.withAlpha(isDark ? 50 : 25)
                      : (isDark ? Colors.white10 : Colors.black.withAlpha(6)),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : Colors.transparent,
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cat.title,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface.withAlpha(200),
                      ),
                    ),
                    if (cat.count > 0) ...[
                      const Gap(6),
                      Text(
                        '(${cat.count})',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? colorScheme.onPrimary
                              : (isDark ? Colors.grey[400] : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
