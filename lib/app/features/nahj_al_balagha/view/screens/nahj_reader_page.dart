import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../controller/nahj_reader_controller.dart';
import '../widgets/nahj_commentary_sheet.dart';
import '../widgets/nahj_reader_settings_sheet.dart';

class NahjReaderPage extends GetView<NahjReaderController> {
  const NahjReaderPage({super.key});

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
        titleWidget: Obx(() {
          final entry = controller.entry.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                entry?.titleArabic ?? 'نهج البلاغة',
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
                'أمير المؤمنين علي بن أبي طالب (عليه السلام)',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
          // Bookmark Button
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isBookmarked.value
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: controller.isBookmarked.value
                    ? Colors.amber.shade700
                    : colorScheme.onSurface,
              ),
              onPressed: () => controller.toggleBookmark(context),
              tooltip: 'حفظ في المفضلة',
            ),
          ),

          // Reader Settings Button
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            color: colorScheme.onSurface,
            onPressed: () => NahjReaderSettingsSheet.show(context, controller),
            tooltip: 'خيارات القراءة والخط',
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(context, brandColor, colorScheme, isDark),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Obx(() {
            if (controller.isLoading.value && controller.entry.value?.bodyArabic == null) {
              return Center(
                child: LoadingAnimationWidget.waveDots(
                  color: brandColor,
                  size: 36,
                ),
              );
            }

            final entry = controller.entry.value;
            if (entry == null) {
              return const Center(
                child: Text(
                  'لم يتم العثور على نص المقطع',
                  style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
                ),
              );
            }

            final String arabicText =
                entry.bodyArabic ?? entry.excerptArabic ?? '';

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
              children: [
                // 1. Entry Header Badge
                _buildEntryHeaderCard(entry, brandColor, isDark),

                const Gap(16),

                // 2. Arabic Text
                _buildArabicTextSection(arabicText, colorScheme, isDark),

                // 3. Shurooh / Commentaries Button Banner
                const Gap(20),
                _buildCommentaryBanner(context, brandColor, isDark),

                const Gap(20),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// هدر مشخصات بخش (شماره و عنوان)
  Widget _buildEntryHeaderCard(
    dynamic entry,
    Color brandColor,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: brandColor.withAlpha(isDark ? 25 : 12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: brandColor.withAlpha(isDark ? 40 : 25),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: brandColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${entry.itemNumber}',
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Text(
                    entry.titleArabic,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: brandColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(12),
          Text(
            _categoryName(entry.category),
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// متن عربی اصلی نهج‌البلاغه
  Widget _buildArabicTextSection(
    String arabicText,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2226) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 40 : 8),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'النص العربي الشريف',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              Icon(
                Icons.format_quote_rounded,
                size: 20,
                color: Colors.teal.withAlpha(120),
              ),
            ],
          ),
          const Divider(height: 18),
          Obx(() {
            return SelectableText(
              arabicText.replaceAll('\r', ''),
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: controller.fontFamily.value,
                fontSize: controller.fontSize.value,
                height: 2.2,
                color: colorScheme.onSurface,
              ),
            );
          }),
        ],
      ),
    );
  }


  /// بنر دسترسی سریع به شروح نهج‌البلاغه
  Widget _buildCommentaryBanner(
    BuildContext context,
    Color brandColor,
    bool isDark,
  ) {
    return ZoomTapAnimation(
      onTap: () => NahjCommentarySheet.show(context, controller),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF282218), const Color(0xFF1E1A14)]
                : [Colors.amber.shade50, Colors.amber.shade100.withAlpha(120)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.amber.shade700.withAlpha(isDark ? 80 : 50),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade700.withAlpha(isDark ? 50 : 30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_stories_rounded,
                color: Colors.amber,
                size: 24,
              ),
            ),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'شروح نهج البلاغة',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const Gap(2),
                  Text(
                    'ابن أبي الحديد • ابن ميثم البحراني • محمد تقي جعفري',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 11.5,
                      color: isDark ? Colors.grey[300] : Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.amber.shade800,
            ),
          ],
        ),
      ),
    );
  }

  /// نوار پایین برای کپی، اشتراک‌گذاری و شروح
  Widget _buildBottomBar(
    BuildContext context,
    Color brandColor,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF171A1D) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // شروح
          _bottomActionItem(
            icon: Icons.menu_book_rounded,
            label: 'الشروح',
            onTap: () => NahjCommentarySheet.show(context, controller),
            color: Colors.amber.shade700,
          ),

          // نسخ النص
          _bottomActionItem(
            icon: Icons.copy_rounded,
            label: 'نسخ',
            onTap: () => controller.copyText(context),
            color: colorScheme.onSurface,
          ),

          // مشاركة
          _bottomActionItem(
            icon: Icons.share_rounded,
            label: 'مشاركة',
            onTap: controller.shareText,
            color: colorScheme.onSurface,
          ),

          // إعدادات الخط
          _bottomActionItem(
            icon: Icons.format_size_rounded,
            label: 'الخط',
            onTap: () => NahjReaderSettingsSheet.show(context, controller),
            color: brandColor,
          ),
        ],
      ),
    );
  }

  Widget _bottomActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return ZoomTapAnimation(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const Gap(2),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryName(String cat) {
    switch (cat) {
      case 'sermons':
        return 'الخطب';
      case 'letters':
        return 'الرسائل';
      case 'wisdom':
        return 'الحكم';
      case 'rare_words':
        return 'غريب الكلام';
      default:
        return 'نهج البلاغة';
    }
  }
}
