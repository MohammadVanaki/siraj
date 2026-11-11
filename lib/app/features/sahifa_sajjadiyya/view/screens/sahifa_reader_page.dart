import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:mawsueat/app/core/common/widgets/custom_app_bar.dart';
import '../../controller/sahifa_reader_controller.dart';
import '../../data/models/sahifa_dua_model.dart';
import '../widgets/sahifa_reader_settings_sheet.dart';

class SahifaReaderPage extends GetView<SahifaReaderController> {
  const SahifaReaderPage({super.key});

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
        titleWidget: Obx(() {
          final dua = controller.dua.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dua?.titleArabic ?? 'الصحيفة السجادية',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                'الإمام علي بن الحسين زين العابدين (ع)',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontFamily: 'IBMPlexSansArabic',
                ),
              ),
            ],
          );
        }),
        actions: [
          // دکمه نشانه‌گذاری
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isBookmarked.value
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: controller.isBookmarked.value
                    ? Colors.amber[700]
                    : colorScheme.onSurface,
              ),
              onPressed: () => controller.toggleBookmark(context),
              tooltip: 'حفظ في المفضلة',
            ),
          ),

          // دکمه تنظیمات قلم و اندازه
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            color: colorScheme.onSurface,
            onPressed: () => SahifaReaderSettingsSheet.show(context, controller),
            tooltip: 'خيارات القراءة',
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, primaryColor, colorScheme, isDark),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: LoadingAnimationWidget.waveDots(
                  color: primaryColor,
                  size: 36,
                ),
              );
            }

            final dua = controller.dua.value;
            if (dua == null) {
              return const Center(
                child: Text(
                  'لم يتم العثور على نص الدعاء',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
                ),
              );
            }

            final paragraphs = dua.paragraphs;

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 32),
              child: Column(
                children: [
                  // عنوان پرشکوه دعا در بالای صفحه
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        dua.titleArabic,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),

                  const Gap(20),

                  // فرازهای دعا با تایپوگرافی ویژه
                  ...List.generate(paragraphs.length, (pIndex) {
                    final paragraph = paragraphs[pIndex];
                    final arabicNum = SahifaDuaModel.toArabicDigits(pIndex + 1);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2226)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withAlpha(12)
                                : primaryColor.withValues(alpha: 0.12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 30 : 5),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // متن فراز
                            Text(
                              paragraph,
                              textAlign: TextAlign.justify,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: controller.fontSize.value,
                                height: 2.15,
                                fontFamily: 'IBMPlexSansArabic',
                                color: colorScheme.onSurface,
                                letterSpacing: 0.2,
                              ),
                            ),

                            const Gap(10),

                            // فوتر هر فراز (شماره و دکمه کپی)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(
                                          alpha: 0.10,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.menu_book_rounded,
                                            size: 13,
                                            color: primaryColor,
                                          ),
                                          const Gap(4),
                                          Text(
                                            arabicNum,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'IBMPlexSansArabic',
                                              color: primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                ZoomTapAnimation(
                                  onTap: () => controller.copyParagraph(
                                    context,
                                    paragraph,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white.withAlpha(10)
                                          : primaryColor.withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.copy_rounded,
                                      size: 15,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const Gap(24),

                  // اختتامیه دعا
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: primaryColor),
                      const Gap(8),
                      Text(
                        'انتهى الدعاء المبارك بحمد الله',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'IBMPlexSansArabic',
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      const Gap(8),
                      Icon(Icons.star_rounded, size: 14, color: primaryColor),
                    ],
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }


  /// نوار ابزار پایین صفحه خوانش (Font Size, Share, Copy)
  Widget _buildBottomBar(
    BuildContext context,
    Color primaryColor,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2226) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
            width: 0.8,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // دکمه‌های کنترل سریع قلم (A- / A+)
          Row(
            children: [
              ZoomTapAnimation(
                onTap: controller.decreaseFontSize,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'A-',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(8),
              ZoomTapAnimation(
                onTap: controller.increaseFontSize,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'A+',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // دکمه‌های کپی و اشتراک‌گذاری سریع
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.copy_rounded, color: primaryColor, size: 20),
                onPressed: () => controller.copyFullDua(context),
                tooltip: 'نسخ الدعاء كاملاً',
              ),
              IconButton(
                icon: Icon(Icons.share_rounded, color: primaryColor, size: 20),
                onPressed: controller.shareDua,
                tooltip: 'مشاركة الدعاء',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
