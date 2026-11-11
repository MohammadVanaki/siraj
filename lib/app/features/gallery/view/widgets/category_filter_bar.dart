import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/gallery/controller/gallery_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GalleryController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final categories = controller.categories;
      final selectedId = controller.selectedCategoryId.value;

      if (categories.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          separatorBuilder: (_, __) => const Gap(8),
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedId == category.id;

            return ZoomTapAnimation(
              onTap: () => controller.selectCategory(category.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : (isDark ? Colors.white10 : Colors.black.withAlpha(8)),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: colorScheme.onPrimary.withAlpha(80),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.title,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : colorScheme.onSurface.withAlpha(200),
                      ),
                    ),
                    if (category.count != null) ...[
                      const Gap(6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withAlpha(50)
                              : (isDark ? Colors.white12 : Colors.black.withAlpha(15)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${category.count}',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : colorScheme.onSurface.withAlpha(160),
                          ),
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
