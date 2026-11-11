import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mawsueat/app/core/common/widgets/custom_app_bar.dart';
import 'package:mawsueat/app/core/routes/routes.dart';
import '../../controller/mafatih_controller.dart';
import '../../data/models/mafatih_item_model.dart';
import '../widgets/mafatih_item_card.dart';
import '../widgets/mafatih_search_bar.dart';

class MafatihPage extends GetView<MafatihController> {
  const MafatihPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        centerTitle: false,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'مفاتيح الجنان',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'الأدعية والزيارات والأعمال والمناجاة',
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
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
            children: [
              // نوار جستجو و فیلتر نشانه‌گذاری‌ها
              MafatihSearchBar(controller: controller),

              // محتوای اصلی لیست
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value && controller.allItems.isEmpty) {
                    return _buildLoadingState(primaryColor);
                  }

                  if (controller.errorMessage.value != null && controller.allItems.isEmpty) {
                    return _buildErrorState(primaryColor, colorScheme);
                  }

                  final list = controller.filteredItems;

                  if (list.isEmpty) {
                    return _buildEmptyState(primaryColor, colorScheme);
                  }

                  return RefreshIndicator(
                    onRefresh: () => controller.fetchItems(forceRefresh: true),
                    color: primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
                      itemCount: list.length + 1, // +1 for the header banner
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return _buildHeaderBanner(
                            context,
                            primaryColor,
                            colorScheme,
                            isDark,
                          );
                        }

                        final itemIndex = index - 1;
                        final item = list[itemIndex];
                        final isBookmarked = controller.isBookmarked(item.id);

                        return MafatihItemCard(
                          item: item,
                          index: itemIndex,
                          isBookmarked: isBookmarked,
                          onTap: () {
                            Get.toNamed(
                              Routes.mafatihReader,
                              arguments: item,
                            );
                          },
                          onBookmarkToggle: () {
                            controller.toggleBookmark(item.id);
                          },
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

  /// بنر معرفی بالای لیست
  Widget _buildHeaderBanner(
    BuildContext context,
    Color primaryColor,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isDark
                ? [
                    const Color(0xFF1E2824),
                    const Color(0xFF151C19),
                  ]
                : [
                    primaryColor.withValues(alpha: 0.12),
                    primaryColor.withValues(alpha: 0.04),
                  ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          border: Border.all(
            color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.20),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                color: primaryColor,
                size: 24,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'كتاب مفاتيح الجنان',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansArabic',
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Gap(4),
                  Text(
                    'كتابٌ جامعٌ للأدعية والزيارات والأعمال المستحبّة، ألّفه الشيخ عباس القمي، ويُعدّ من أشهر الكتب في هذا المجال. يضمّ مجموعة واسعة من الأدعية والمناجاة والزيارات وأعمال الأيام والليالي والمناسبات الدينية، ليكون رفيقًا للمؤمن في عبادته وصلته بالله تعالى وأهل البيت (عليهم السلام)',
                    style: TextStyle(
                      fontSize: 11,
                      height: 1.5,
                      fontFamily: 'IBMPlexSansArabic',
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.waveDots(
            color: primaryColor,
            size: 38,
          ),
          const Gap(14),
          const Text(
            'جاري تحميل أبواب مفاتيح الجنان...',
            style: TextStyle(
              fontSize: 13,
              fontFamily: 'IBMPlexSansArabic',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Color primaryColor, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 48,
              color: primaryColor.withValues(alpha: 0.8),
            ),
            const Gap(12),
            Text(
              controller.errorMessage.value ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontFamily: 'IBMPlexSansArabic',
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(16),
            ElevatedButton.icon(
              onPressed: () => controller.fetchItems(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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

  Widget _buildEmptyState(Color primaryColor, ColorScheme colorScheme) {
    final isFilteringFavs = controller.showOnlyBookmarks.value;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isFilteringFavs
                  ? Icons.bookmark_border_rounded
                  : Icons.search_off_rounded,
              size: 48,
              color: primaryColor.withValues(alpha: 0.6),
            ),
            const Gap(12),
            Text(
              isFilteringFavs
                  ? 'لم تقم بإضافة أي دعاء أو زيارة إلى المفضلة بعد'
                  : 'لم يتم العثور على أي نتيجة مطابقة للبحث',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(6),
            Text(
              isFilteringFavs
                  ? 'يمكنك الضغط على أيقونة الإشارة المرجعية بجانب أي عنوان لحفظه هنا'
                  : 'تأكد من كتابة الكلمات بشكل صحيح أو امسح البحث',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                color: Colors.grey,
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
            if (!isFilteringFavs) ...[
              const Gap(14),
              OutlinedButton.icon(
                onPressed: controller.clearSearch,
                icon: const Icon(Icons.clear_rounded, size: 16),
                label: const Text('مسح البحث'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
