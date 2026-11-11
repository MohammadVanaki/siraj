import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/mafatih_controller.dart';
import '../../data/models/mafatih_item_model.dart';

class MafatihSearchBar extends StatelessWidget {
  final MafatihController controller;

  const MafatihSearchBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // فیلد متنی جستجو
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2226) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withAlpha(20)
                      : primaryColor.withAlpha(28),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 40 : 6),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: controller.searchController,
                textDirection: TextDirection.rtl,
                onChanged: controller.onSearchChanged,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'IBMPlexSansArabic',
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث في أدعية وزيارات مفاتيح الجنان...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    fontFamily: 'IBMPlexSansArabic',
                    color: isDark ? Colors.grey[500] : Colors.grey[400],
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: primaryColor,
                    size: 20,
                  ),
                  suffixIcon: Obx(() {
                    if (controller.searchQuery.value.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: controller.clearSearch,
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),

          const Gap(10),

          // دکمه فیلتر ادعیه و زیارات نشان‌شده (Bookmarks Filter)
          Obx(() {
            final isFavOnly = controller.showOnlyBookmarks.value;
            final count = controller.bookmarkedIds.length;

            return ZoomTapAnimation(
              onTap: controller.toggleBookmarksFilter,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isFavOnly
                      ? primaryColor
                      : (isDark ? const Color(0xFF1E2226) : Colors.white),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isFavOnly
                        ? primaryColor
                        : (isDark
                            ? Colors.white.withAlpha(20)
                            : primaryColor.withAlpha(28)),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isFavOnly ? primaryColor : Colors.black)
                          .withAlpha(isDark ? 50 : (isFavOnly ? 60 : 8)),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isFavOnly
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isFavOnly
                          ? Colors.white
                          : (count > 0
                              ? Colors.amber[700]
                              : (isDark ? Colors.grey[400] : Colors.grey[600])),
                      size: 19,
                    ),
                    if (count > 0) ...[
                      const Gap(4),
                      Text(
                        MafatihItemModel.toArabicDigits(count),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          color: isFavOnly
                              ? Colors.white
                              : (isDark ? Colors.grey[300] : Colors.grey[700]),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
