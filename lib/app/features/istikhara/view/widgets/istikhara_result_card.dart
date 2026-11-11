import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/istikhara/controller/istikhara_controller.dart';
import 'package:mawsueat/app/features/istikhara/data/models/istikhara_model.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class IstikharaResultCard extends StatelessWidget {
  final IstikharaResultModel result;

  const IstikharaResultCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IstikharaController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = result.status.color;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Result Status Badge Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withAlpha(isDark ? 55 : 35),
                  statusColor.withAlpha(isDark ? 25 : 12),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: statusColor.withAlpha(isDark ? 100 : 70),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withAlpha(isDark ? 40 : 25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    result.status.icon,
                    size: 38,
                    color: statusColor,
                  ),
                ),
                const Gap(10),
                Text(
                  'نتيجة الاستخارة',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const Gap(4),
                Text(
                  result.displayAnswer,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),

          const Gap(16),

          // 2. Quranic Ayah Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242020) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black.withAlpha(12),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 40 : 10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Surah & Meta Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMetaChip(
                      label: result.surahName,
                      icon: Icons.menu_book_rounded,
                      colorScheme: colorScheme,
                      isDark: isDark,
                    ),
                    const Gap(8),
                    _buildMetaChip(
                      label: 'آية ${result.ayahNumber}',
                      icon: Icons.numbers_rounded,
                      colorScheme: colorScheme,
                      isDark: isDark,
                    ),
                    const Gap(8),
                    _buildMetaChip(
                      label: 'صفحة ${result.pageNumber}',
                      icon: Icons.bookmark_outline_rounded,
                      colorScheme: colorScheme,
                      isDark: isDark,
                    ),
                  ],
                ),

                const Gap(18),

                // Ayah Text in Islamic Calligraphic style
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withAlpha(isDark ? 20 : 10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: colorScheme.onPrimary.withAlpha(isDark ? 40 : 25),
                    ),
                  ),
                  child: Text(
                    '﴿ ${result.ayahText} ﴾',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 18,
                      height: 2.0,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Gap(16),

          // 3. General Guidance & Advice
          _buildAdviceSection(
            title: 'التفسير والتوجيه العام',
            icon: Icons.lightbulb_outline_rounded,
            content: result.generalAdvice,
            accentColor: colorScheme.onPrimary,
            isDark: isDark,
            colorScheme: colorScheme,
          ),

          // 4. Work Advice (if present)
          if (result.workAdvice != null && result.workAdvice!.isNotEmpty) ...[
            const Gap(12),
            _buildAdviceSection(
              title: 'العمل والتجارة',
              icon: Icons.work_outline_rounded,
              content: result.workAdvice!,
              accentColor: const Color(0xFF3B82F6),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ],

          // 5. Marriage Advice (if present)
          if (result.marriageAdvice != null && result.marriageAdvice!.isNotEmpty) ...[
            const Gap(12),
            _buildAdviceSection(
              title: 'الزواج والارتباط',
              icon: Icons.favorite_border_rounded,
              content: result.marriageAdvice!,
              accentColor: const Color(0xFFEC4899),
              isDark: isDark,
              colorScheme: colorScheme,
            ),
          ],

          // 6. Disclaimer (if present)
          if (result.disclaimer != null && result.disclaimer!.trim().isNotEmpty) ...[
            const Gap(12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(8) : Colors.amber.withAlpha(15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.amber.withAlpha(60),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: isDark ? Colors.grey[400] : const Color(0xFFD97706),
                  ),
                  const Gap(10),
                  Expanded(
                    child: Text(
                      result.disclaimer!,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12,
                        height: 1.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const Gap(22),

          // 6. Action Buttons (Share, Copy, New Istikhara)
          Row(
            children: [
              Expanded(
                child: ZoomTapAnimation(
                  onTap: controller.reset,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.onPrimary.withAlpha(70),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                        Gap(8),
                        Text(
                          'استخارة جديدة',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(10),
              // Copy Button
              ZoomTapAnimation(
                onTap: controller.copyResult,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.copy_rounded,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
              const Gap(8),
              // Share Button
              ZoomTapAnimation(
                onTap: controller.shareResult,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.share_rounded,
                    color: colorScheme.onPrimary,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          const Gap(24),
        ],
      ),
    );
  }

  Widget _buildMetaChip({
    required String label,
    required IconData icon,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? Colors.white10 : Colors.black.withAlpha(8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onPrimary),
          const Gap(5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withAlpha(200),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceSection({
    required String title,
    required IconData icon,
    required String content,
    required Color accentColor,
    required bool isDark,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242020) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withAlpha(isDark ? 50 : 30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const Gap(8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const Gap(10),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13.5,
              height: 1.6,
              color: colorScheme.onSurface.withAlpha(220),
            ),
          ),
        ],
      ),
    );
  }
}
