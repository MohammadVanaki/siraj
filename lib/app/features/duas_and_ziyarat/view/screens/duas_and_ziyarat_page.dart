import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../controller/duas_controller.dart';
import '../widgets/dua_category_card.dart';
import 'dua_category_items_page.dart';

class DuasAndZiyaratPage extends GetView<DuasController> {
  const DuasAndZiyaratPage({super.key});

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
              'الأدعية والزيارات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
                color: colorScheme.onSurface,
              ),
            ),
            Text(
              'اختر المجموعة للتصفح والاستماع والمشاهدة',
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
              // تب‌های صوتيات / مرئيات
              _buildTabSelector(context, colorScheme, isDark),

              // نوار جستجوی گروه‌ها
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withAlpha(10) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withAlpha(15)
                          : colorScheme.onPrimary.withAlpha(25),
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
                    final isAudioTab = controller.selectedTab.value == DuasMediaType.audio;
                    return TextField(
                      controller: controller.searchController,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
                        hintText: isAudioTab
                            ? 'ابحث في مجموعات الصوتيات...'
                            : 'ابحث في مجموعات المرئيات...',
                        hintStyle: TextStyle(
                          fontSize: 12.5,
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    );
                  }),
                ),
              ),

              // محتوای تب فعال (لیست گروه‌ها)
              Expanded(
                child: Obx(() {
                  final tab = controller.selectedTab.value;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: tab == DuasMediaType.audio
                        ? _buildAudioCategories(context, colorScheme, isDark)
                        : _buildVideoCategories(context, colorScheme, isDark),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withAlpha(12)
              : colorScheme.onPrimary.withAlpha(12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(15)
                : colorScheme.onPrimary.withAlpha(25),
            width: 0.8,
          ),
        ),
        child: Obx(() {
          final current = controller.selectedTab.value;
          return Row(
            children: [
              Expanded(
                child: _buildTabButton(
                  title: 'صوتيات',
                  icon: Icons.headphones_rounded,
                  isSelected: current == DuasMediaType.audio,
                  onTap: () => controller.setTab(DuasMediaType.audio),
                  colorScheme: colorScheme,
                  isDark: isDark,
                ),
              ),
              const Gap(6),
              Expanded(
                child: _buildTabButton(
                  title: 'مرئيات',
                  icon: Icons.ondemand_video_rounded,
                  isSelected: current == DuasMediaType.video,
                  onTap: () => controller.setTab(DuasMediaType.video),
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
                    color: colorScheme.onPrimary.withAlpha(50),
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
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.grey[400] : Colors.grey[700]),
              ),
              const Gap(8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
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

  Widget _buildAudioCategories(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    if (controller.filteredAudioCategories.isEmpty) {
      if (controller.isLoadingData.value) {
        return Center(
          child: CircularProgressIndicator(
            color: colorScheme.onPrimary,
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: colorScheme.onPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              key: const ValueKey('audio_cats_empty'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 50,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const Gap(10),
                  Text(
                    'لم يتم العثور على أي مجموعة صوتية',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: colorScheme.onPrimary,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final int crossAxisCount;
          if (width >= 1100) {
            crossAxisCount = 3;
          } else if (width >= 650) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 1;
          }

          final double horizontalPadding = width >= 600 ? 20 : 16;
          const double spacing = 12;

          if (crossAxisCount == 1) {
            return ListView.builder(
              key: const ValueKey('audio_cats_list'),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(horizontalPadding, 4, horizontalPadding, 30),
              itemCount: controller.filteredAudioCategories.length,
              itemBuilder: (context, index) {
                final category = controller.filteredAudioCategories[index];
                return DuaCategoryCard(
                  category: category,
                  isAudio: true,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  onTap: () {
                    Get.to(() => DuaCategoryItemsPage(
                          category: category,
                          isAudio: true,
                        ));
                  },
                );
              },
            );
          }

          return GridView.builder(
            key: const ValueKey('audio_cats_grid'),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 30),
            itemCount: controller.filteredAudioCategories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              mainAxisExtent: 94,
            ),
            itemBuilder: (context, index) {
              final category = controller.filteredAudioCategories[index];
              return DuaCategoryCard(
                category: category,
                isAudio: true,
                margin: EdgeInsets.zero,
                onTap: () {
                  Get.to(() => DuaCategoryItemsPage(
                        category: category,
                        isAudio: true,
                      ));
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVideoCategories(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    if (controller.filteredVideoCategories.isEmpty) {
      if (controller.isLoadingData.value) {
        return Center(
          child: CircularProgressIndicator(
            color: colorScheme.onPrimary,
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: controller.refreshData,
        color: colorScheme.onPrimary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              key: const ValueKey('video_cats_empty'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 50,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const Gap(10),
                  Text(
                    'لم يتم العثور على أي مجموعة مرئية',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshData,
      color: colorScheme.onPrimary,
      child: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final int crossAxisCount;
        if (width >= 1100) {
          crossAxisCount = 3;
        } else if (width >= 650) {
          crossAxisCount = 2;
        } else {
          crossAxisCount = 1;
        }

        final double horizontalPadding = width >= 600 ? 20 : 16;
        const double spacing = 12;

        if (crossAxisCount == 1) {
          return ListView.builder(
            key: const ValueKey('video_cats_list'),
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(horizontalPadding, 4, horizontalPadding, 30),
            itemCount: controller.filteredVideoCategories.length,
            itemBuilder: (context, index) {
              final category = controller.filteredVideoCategories[index];
              return DuaCategoryCard(
                category: category,
                isAudio: false,
                margin: const EdgeInsets.symmetric(vertical: 6),
                onTap: () {
                  Get.to(() => DuaCategoryItemsPage(
                        category: category,
                        isAudio: false,
                      ));
                },
              );
            },
          );
        }

        return GridView.builder(
          key: const ValueKey('video_cats_grid'),
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontalPadding, 6, horizontalPadding, 30),
          itemCount: controller.filteredVideoCategories.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            mainAxisExtent: 94,
          ),
          itemBuilder: (context, index) {
            final category = controller.filteredVideoCategories[index];
            return DuaCategoryCard(
              category: category,
              isAudio: false,
              margin: EdgeInsets.zero,
              onTap: () {
                Get.to(() => DuaCategoryItemsPage(
                      category: category,
                      isAudio: false,
                    ));
              },
            );
          },
        );
      },
    ),
    );
  }
}
