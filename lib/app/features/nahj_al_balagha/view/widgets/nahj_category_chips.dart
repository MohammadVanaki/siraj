import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/nahj_controller.dart';
import '../../data/models/nahj_category_model.dart';

class NahjCategoryChips extends StatelessWidget {
  final NahjController controller;

  const NahjCategoryChips({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    return Obx(() {
      final categories = controller.categories;
      final selectedCategory = controller.selectedCategory.value;

      if (categories.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        height: 48,
        margin: const EdgeInsets.only(top: 6, bottom: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final isSelected = selectedCategory == cat.slug;

          return Container(
            margin: const EdgeInsets.only(left: 8),
            child: ZoomTapAnimation(
              onTap: () => controller.selectCategory(cat.slug),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? brandColor
                      : (isDark ? const Color(0xFF1E2226) : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? brandColor
                        : (isDark ? Colors.white12 : Colors.grey.shade300),
                    width: isSelected ? 1.4 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: brandColor.withAlpha(60),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _iconForCategory(cat.slug),
                      size: 16,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? Colors.grey[400] : Colors.grey[700]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat.titleArabic,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.grey[300] : Colors.grey[800]),
                      ),
                    ),
                    if (cat.count > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withAlpha(50)
                              : (isDark ? Colors.white10 : Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${cat.count}',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.grey[400] : Colors.grey[700]),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    });
  }

  IconData _iconForCategory(String slug) {
    switch (slug) {
      case 'sermons':
        return Icons.record_voice_over_rounded;
      case 'letters':
        return Icons.mail_outline_rounded;
      case 'wisdom':
        return Icons.lightbulb_outline_rounded;
      case 'rare_words':
        return Icons.auto_stories_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }
}
