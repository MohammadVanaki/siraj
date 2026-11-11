import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../controller/quran_controller.dart';
import '../widgets/juz_card.dart';
import '../widgets/juz_surahs_sheet.dart';
import '../widgets/surah_card.dart';
import 'mushaf_page_reader_page.dart';
import 'surah_detail_page.dart';

class QuranPage extends GetView<QuranController> {
  const QuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        centerTitle: false,
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'القرآن الكريم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'المصحف الشريف والتفاسير المباركة',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
          ],
        ),
        actions: [
          // دکمه باز کردن صفحات المصحف الشریف (صفحه ۱ تا ۶۰۴)
          ZoomTapAnimation(
            onTap: () {
              Get.to(() => const MushafPageReaderPage(initialPage: 1));
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onPrimary.withAlpha(50),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  Gap(5),
                  Text(
                    'المصحف',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansArabic',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // انتخاب تب بین سوره‌ها و جزء‌ها
          _buildTabSelector(context, colorScheme, isDark),

          // نوار جستجو
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(10) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white.withAlpha(15) : colorScheme.onPrimary.withAlpha(25),
                ),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Obx(() {
                final isSurahsTab = controller.selectedTab.value == QuranTab.surahs;
                final hint = isSurahsTab
                    ? 'ابحث باسم السورة أو رقمها...'
                    : 'ابحث برقم الجزء أو اسمه أو السورة...';

                return TextField(
                  controller: controller.searchController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(
                      fontSize: 13,
                      fontFamily: 'IBMPlexSansArabic',
                      color: isDark ? Colors.grey[500] : Colors.grey[400],
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: colorScheme.onPrimary,
                    ),
                    suffixIcon: controller.searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              controller.searchController.clear();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                );
              }),
            ),
          ),

          // فیلترهای مکية / مدنية / الكل (فقط در تب سوره‌ها نمایش داده می‌شود)
          Obx(() {
            if (controller.selectedTab.value != QuranTab.surahs) {
              return const SizedBox.shrink();
            }

            final active = controller.activeFilter.value;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  _buildFilterChip(
                    context: context,
                    label: 'الكل (١١٤)',
                    isSelected: active == RevelationFilter.all,
                    onTap: () => controller.setFilter(RevelationFilter.all),
                  ),
                  const Gap(8),
                  _buildFilterChip(
                    context: context,
                    label: 'مكية (٨٦)',
                    isSelected: active == RevelationFilter.meccan,
                    onTap: () => controller.setFilter(RevelationFilter.meccan),
                  ),
                  const Gap(8),
                  _buildFilterChip(
                    context: context,
                    label: 'مدنية (٢٨)',
                    isSelected: active == RevelationFilter.medinan,
                    onTap: () => controller.setFilter(RevelationFilter.medinan),
                  ),
                ],
              ),
            );
          }),

          const Gap(4),

          // محتوای اصلی (لیست سوره‌ها یا جزء‌ها بر اساس تب فعال)
          Expanded(
            child: Obx(() {
              if (controller.selectedTab.value == QuranTab.surahs) {
                return _buildSurahsList(context, colorScheme, isDark);
              } else {
                return _buildJuzsList(context, colorScheme, isDark);
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(BuildContext context, ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(3.5),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(12) : colorScheme.onPrimary.withAlpha(12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(15) : colorScheme.onPrimary.withAlpha(25),
            width: 0.8,
          ),
        ),
        child: Obx(() {
          final current = controller.selectedTab.value;
          return Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  title: 'السور (١١٤)',
                  icon: Icons.auto_stories_rounded,
                  isSelected: current == QuranTab.surahs,
                  onTap: () => controller.setTab(QuranTab.surahs),
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ),
              const Gap(4),
              Expanded(
                child: _buildTabButton(
                  title: 'الأجزاء (٣٠)',
                  icon: Icons.collections_bookmark_rounded,
                  isSelected: current == QuranTab.juzs,
                  onTap: () => controller.setTab(QuranTab.juzs),
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return ZoomTapAnimation(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.onPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorScheme.onPrimary.withAlpha(60),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
              const Gap(6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontFamily: 'IBMPlexSansArabic',
                  color: isSelected
                      ? Colors.white
                      : (isDark ? Colors.grey[400] : Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahsList(BuildContext context, ColorScheme colorScheme, bool isDark) {
    if (controller.isLoading.value && controller.allSurahs.isEmpty) {
      return Center(
        child: SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            strokeCap: StrokeCap.round,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
          ),
        ),
      );
    }

    if (controller.filteredSurahs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 54,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const Gap(12),
            Text(
              'لم يتم العثور على أي سورة مطابقة',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: colorScheme.onPrimary,
      onRefresh: controller.loadSurahs,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: controller.filteredSurahs.length,
        itemBuilder: (context, index) {
          final surah = controller.filteredSurahs[index];
          return SurahCard(
            surah: surah,
            onTap: () {
              Get.to(() => SurahDetailPage(
                    surah: surah,
                    initialTafsir: controller.selectedTafsir.value,
                  ));
            },
          );
        },
      ),
    );
  }

  Widget _buildJuzsList(BuildContext context, ColorScheme colorScheme, bool isDark) {
    if (controller.filteredJuzs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 54,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const Gap(12),
            Text(
              'لم يتم العثور على أي جزء مطابق',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontFamily: 'IBMPlexSansArabic',
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: controller.filteredJuzs.length,
      itemBuilder: (context, index) {
        final juz = controller.filteredJuzs[index];
        final startSurah = controller.getSurahByNumber(juz.startSurahNumber);
        final endSurah = controller.getSurahByNumber(juz.endSurahNumber);

        return JuzCard(
          juz: juz,
          startSurah: startSurah,
          endSurah: endSurah,
          onTap: () {
            JuzSurahsSheet.show(
              context,
              juz: juz,
              controller: controller,
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ZoomTapAnimation(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.onPrimary
              : (isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : (isDark ? Colors.grey[300] : Colors.grey[800]),
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
      ),
    );
  }
}
