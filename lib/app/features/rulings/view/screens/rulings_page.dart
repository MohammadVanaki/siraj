import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/widgets/custom_app_bar.dart';
import 'package:mawsueat/app/core/common/widgets/custom_loading.dart';
import 'package:mawsueat/app/features/rulings/controller/rulings_controller.dart';
import 'package:mawsueat/app/features/rulings/view/widgets/marja_selector_bar.dart';
import 'package:mawsueat/app/features/rulings/view/widgets/ruling_card.dart';
import 'package:mawsueat/app/features/rulings/view/widgets/ruling_category_chips.dart';
import 'package:mawsueat/app/features/rulings/view/widgets/send_question_sheet.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class RulingsPage extends StatelessWidget {
  const RulingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RulingsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'الاستفتاءات الشرعية',
        actions: [
          // Search Toggle
          Obx(() {
            final isSearching = controller.isSearching.value;
            return ZoomTapAnimation(
              onTap: controller.toggleSearch,
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
          // Send Question Action
          ZoomTapAnimation(
            onTap: () => SendQuestionSheet.show(context),
            child: Container(
              margin: const EdgeInsets.only(right: 4, left: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : colorScheme.onPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 20,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.onPrimary,
        elevation: 4,
        onPressed: () => SendQuestionSheet.show(context),
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white, size: 20),
        label: const Text(
          'إرسال استفتاء',
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Optional Search Input
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
                      hintText: 'ابحث في الفتاوى والأحكام والمسائل...',
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

            // 1. Marja Selector (مراجع التقليد)
            const MarjaSelectorBar(),

            const Gap(8),

            // 2. Category Chips (الأبواب الفقهية)
            const RulingCategoryChips(),

            const Gap(6),

            // Loading bar
            Obx(() {
              if (controller.isLoading.value) {
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

            // 3. Rulings List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.rulings.isEmpty) {
                  return const Center(child: CustomLoading());
                }

                if (controller.rulings.isEmpty) {
                  return _buildEmptyState(context, controller, colorScheme, isDark);
                }

                return RefreshIndicator(
                  color: colorScheme.onPrimary,
                  onRefresh: controller.fetchRulings,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: controller.rulings.length,
                    itemBuilder: (context, index) {
                      final ruling = controller.rulings[index];
                      return RulingCard(
                        key: ValueKey(ruling.id),
                        ruling: ruling,
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
    RulingsController controller,
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
                Icons.menu_book_rounded,
                size: 48,
                color: colorScheme.onPrimary,
              ),
            ),
            const Gap(16),
            Text(
              'لا توجد مسائل مطابقة',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(6),
            Text(
              'جرّب اختيار مرجع آخر أو تغيير باب الفقه أو نص البحث',
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
                controller.selectMarja(0);
                controller.selectCategory(0);
                controller.searchTextController.clear();
                controller.onSearchChanged('');
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'عرض كافة المسائل',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
