import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../../../core/routes/routes.dart';
import '../../controller/nahj_controller.dart';
import '../widgets/nahj_category_chips.dart';
import '../widgets/nahj_entry_card.dart';
import '../widgets/nahj_search_bar.dart';

class NahjPage extends GetView<NahjController> {
  const NahjPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        centerTitle: false,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'نهج البلاغة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'خطب ورسائل وحكم أمير المؤمنين علي بن أبي طالب (ع)',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // 1. Search Bar & Bookmark filter
              NahjSearchBar(controller: controller),

              // 2. Category Chips (الخطب، الرسائل، الحكم، غريب الكلام)
              NahjCategoryChips(controller: controller),

              // 3. Entries List
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.entries.isEmpty) {
                    return _buildLoadingState(brandColor);
                  }

                  if (controller.hasError.value && controller.entries.isEmpty) {
                    return _buildErrorState(brandColor, colorScheme);
                  }

                  final list = controller.displayedEntries;

                  if (list.isEmpty) {
                    return _buildEmptyState(brandColor, colorScheme);
                  }

                  final bool isBookmarks = controller.showOnlyBookmarks.value;
                  final bool showLoadingMore =
                      !isBookmarks && controller.isLoadingMore.value;

                  return RefreshIndicator(
                    onRefresh: () async {
                      if (isBookmarks) {
                        controller.reloadBookmarks();
                      } else {
                        await controller.fetchEntries(reset: true);
                      }
                    },
                    color: brandColor,
                    child: ListView.builder(
                      controller: controller.scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                      itemCount: list.length + (showLoadingMore ? 2 : 1),
                      itemBuilder: (context, index) {
                        // Header Banner on first item
                        if (index == 0) {
                          return _buildHeaderBanner(
                            context,
                            brandColor,
                            colorScheme,
                            isDark,
                          );
                        }

                        final entryIndex = index - 1;

                        // Loading more indicator at end of list
                        if (showLoadingMore && entryIndex == list.length) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: LoadingAnimationWidget.waveDots(
                                color: brandColor,
                                size: 28,
                              ),
                            ),
                          );
                        }

                        final entry = list[entryIndex];
                        final isBookmarked = controller.isBookmarked(entry.id);

                        return NahjEntryCard(
                          entry: entry,
                          index: entryIndex,
                          isBookmarked: isBookmarked,
                          onTap: () async {
                            await Get.toNamed(
                              Routes.nahjReader,
                              arguments: entry,
                            );
                            controller.reloadBookmarks();
                          },
                          onBookmarkTap: () =>
                              controller.toggleBookmark(entry),
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// بنر ترویجی ابتدای لیست
  Widget _buildHeaderBanner(
    BuildContext context,
    Color brandColor,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF241F21), const Color(0xFF17191C)]
              : [brandColor.withAlpha(25), brandColor.withAlpha(8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: brandColor.withAlpha(isDark ? 40 : 25),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: brandColor.withAlpha(isDark ? 30 : 20),
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              'assets/icons/Nahj-al-Balagha.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.menu_book_rounded,
                color: brandColor,
              ),
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'كلام أمير المؤمنين (ع)',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Gap(3),
                Text(
                  '«كَلَامُهُ دُونَ كَلَامِ الْخَالِقِ وَفَوْقَ كَلَامِ الْمَخْلُوقِ» — مجموع ما اختاره الشريف الرضي من كلام الوصي.',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    height: 1.5,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(Color brandColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.waveDots(
            color: brandColor,
            size: 38,
          ),
          const Gap(12),
          const Text(
            'جاري تحميل نهج البلاغة...',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Color brandColor, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey.shade400),
            const Gap(12),
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 14),
            ),
            const Gap(16),
            ElevatedButton.icon(
              onPressed: () => controller.fetchEntries(reset: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: brandColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color brandColor, ColorScheme colorScheme) {
    final bool isFilter = controller.showOnlyBookmarks.value;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isFilter ? Icons.bookmark_border_rounded : Icons.search_off_rounded,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const Gap(12),
            Text(
              isFilter
                  ? 'لم تقم بإضافة أي مقطع إلى المفضلة بعد'
                  : 'لم يتم العثور على نتائج تطابق بحثك',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 14,
                color: colorScheme.onSurface.withAlpha(180),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
