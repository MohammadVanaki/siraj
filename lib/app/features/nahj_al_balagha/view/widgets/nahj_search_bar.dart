import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/nahj_controller.dart';

class NahjSearchBar extends StatefulWidget {
  final NahjController controller;

  const NahjSearchBar({super.key, required this.controller});

  @override
  State<NahjSearchBar> createState() => _NahjSearchBarState();
}

class _NahjSearchBarState extends State<NahjSearchBar> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController =
        TextEditingController(text: widget.controller.searchQuery.value);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          // Search Input Field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E2226) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
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
              child: TextField(
                controller: _textController,
                onChanged: widget.controller.onSearchChanged,
                style: const TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 13.5,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث في خطب ورسائل وحكم نهج البلاغة...',
                  hintStyle: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12.5,
                    color: Colors.grey.shade500,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                  ),
                  suffixIcon: Obx(() {
                    if (widget.controller.searchQuery.value.isNotEmpty) {
                      return IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        onPressed: () {
                          _textController.clear();
                          widget.controller.clearSearch();
                        },
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

          // Bookmark filter button
          Obx(() {
            final isFiltering = widget.controller.showOnlyBookmarks.value;
            final count = widget.controller.bookmarkedIds.length;

            return ZoomTapAnimation(
              onTap: widget.controller.toggleBookmarksFilter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isFiltering
                      ? Colors.amber.shade700
                      : (isDark ? const Color(0xFF1E2226) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isFiltering
                        ? Colors.amber.shade700
                        : (isDark ? Colors.white12 : Colors.grey.shade300),
                  ),
                  boxShadow: isFiltering
                      ? [
                          BoxShadow(
                            color: Colors.amber.withAlpha(80),
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
                      isFiltering
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      size: 20,
                      color: isFiltering
                          ? Colors.white
                          : (count > 0 ? Colors.amber.shade700 : Colors.grey),
                    ),
                    if (count > 0) ...[
                      const Gap(4),
                      Text(
                        '$count',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isFiltering ? Colors.white : Colors.amber.shade800,
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
