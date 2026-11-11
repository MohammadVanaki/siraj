import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/widgets/custom_app_bar.dart';
import 'package:mawsueat/app/core/common/widgets/custom_loading.dart';
import 'package:mawsueat/app/features/gallery/controller/gallery_controller.dart';
import 'package:mawsueat/app/features/gallery/view/widgets/category_filter_bar.dart';
import 'package:mawsueat/app/features/gallery/view/widgets/gallery_card.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GalleryController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'معرض الصور',
        actions: [
          // Search Toggle Button
          Obx(() {
            final isSearching = controller.isSearching.value;
            return ZoomTapAnimation(
              onTap: controller.toggleSearchMode,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSearching
                      ? colorScheme.onPrimary.withAlpha(isDark ? 50 : 30)
                      : (isDark ? Colors.white10 : colorScheme.onPrimary.withAlpha(20)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isSearching ? Icons.close_rounded : Icons.search_rounded,
                  size: 20,
                  color: colorScheme.onPrimary,
                ),
              ),
            );
          }),

          // Refresh Button
          ZoomTapAnimation(
            onTap: controller.fetchImages,
            child: Container(
              margin: const EdgeInsets.only(right: 4, left: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : colorScheme.onPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 20,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Optional Search Bar
            Obx(() {
              if (!controller.isSearching.value) return const SizedBox.shrink();

              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black.withAlpha(6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: colorScheme.onPrimary.withAlpha(40),
                    ),
                  ),
                  child: TextField(
                    controller: controller.searchTextController,
                    onChanged: controller.onSearchChanged,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'ابحث في الصور والعتبات والتصاميم...',
                      hintStyle: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[500],
                      ),
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: colorScheme.onPrimary,
                      ),
                      suffixIcon: controller.searchQuery.value.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                controller.searchTextController.clear();
                                controller.onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              );
            }),

            const Gap(8),

            // Horizontal Categories Bar
            const CategoryFilterBar(),

            const Gap(6),

            // Loading indicator bar when switching tabs / fetching
            Obx(() {
              if (controller.isLoadingImages.value) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      minHeight: 2.5,
                      backgroundColor: colorScheme.onPrimary.withAlpha(20),
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                    ),
                  ),
                );
              }
              return const SizedBox(height: 2.5);
            }),

            const Gap(6),

            // Main Grid / States View
            Expanded(
              child: Obx(() {
                if (controller.isLoadingImages.value && controller.images.isEmpty) {
                  return const Center(child: CustomLoading());
                }

                if (controller.images.isEmpty) {
                  return _buildEmptyState(context, controller, colorScheme, isDark);
                }

                return RefreshIndicator(
                  color: colorScheme.onPrimary,
                  onRefresh: controller.fetchImages,
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: controller.images.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) {
                      final item = controller.images[index];
                      return GalleryCard(
                        key: ValueKey(item.id),
                        item: item,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    GalleryController controller,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary.withAlpha(isDark ? 30 : 15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 48,
                color: colorScheme.onPrimary,
              ),
            ),
            const Gap(16),
            Text(
              'لا توجد صور في هذا القسم',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(6),
            Text(
              'جرّب اختيار قسم آخر أو تغيير عبارة البحث',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const Gap(18),
            ElevatedButton.icon(
              onPressed: () {
                controller.selectCategory('');
                controller.searchTextController.clear();
                controller.onSearchChanged('');
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'عرض الكل',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
