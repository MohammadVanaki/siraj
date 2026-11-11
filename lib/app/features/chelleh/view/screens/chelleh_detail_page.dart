import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../controller/chelleh_controller.dart';
import '../../model/arbaeen_dhikr_model.dart';
import '../widgets/chelleh_info_sheet.dart';
import '../widgets/chelleh_settings_sheet.dart';
import '../widgets/forty_days_matrix.dart';
import '../widgets/salawat_tap_counter.dart';

class ChellehDetailPage extends StatelessWidget {
  final ArbaeenDhikrModel dhikr;

  const ChellehDetailPage({super.key, required this.dhikr});

  @override
  Widget build(BuildContext context) {
    final controller = ChellehController.to;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'أربعينية ${dhikr.titleArabic}',
        actions: [
          // Info / Guide button
          ZoomTapAnimation(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const ChellehInfoSheet(),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : colorScheme.onPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.help_outline_rounded,
                size: 18,
                color: colorScheme.onPrimary,
              ),
            ),
          ),

          // Settings button
          ZoomTapAnimation(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const ChellehSettingsSheet(),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : colorScheme.onPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 18,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (!controller.isLoaded.value) {
          return Center(
            child: CircularProgressIndicator(
              color: colorScheme.onPrimary,
            ),
          );
        }

        final model = controller.chelleh.value;
        final activeDay = model.activeDayNumber;
        final completedCount = model.completedDays.length;
        final remainingDays = (40 - completedCount).clamp(0, 40);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Header Overview Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            const Color(0xFF1E2226),
                            const Color(0xFF15191C),
                          ]
                        : [
                            colorScheme.onPrimary.withAlpha(25),
                            colorScheme.onPrimary.withAlpha(10),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.onPrimary.withAlpha(isDark ? 40 : 30),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Niyyah & Day Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'النية المباركة للأربعينية:',
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSansArabic',
                                  fontSize: 12,
                                  color: colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Gap(2),
                              Text(
                                model.niyyah,
                                style: TextStyle(
                                  fontFamily: 'IBMPlexSansArabic',
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'اليوم $activeDay من 40',
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Gap(16),

                    // Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: model.overallProgress,
                        minHeight: 8,
                        backgroundColor: isDark
                            ? Colors.white12
                            : colorScheme.onPrimary.withAlpha(25),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.teal,
                        ),
                      ),
                    ),

                    const Gap(10),

                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'أُنجز: $completedCount يوماً (${(model.overallProgress * 100).toInt()}%)',
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 12,
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'متبقي: $remainingDays يوماً',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Gap(14),

              // 1.5. Full Dhikr / Surah Text Card
              if (dhikr.bodyArabic.isNotEmpty)
                _buildDhikrTextCard(context, dhikr, colorScheme, isDark),

              const Gap(16),

              // 2. Today's Tap Counter
              SalawatTapCounter(
                currentCount: model.currentDayCount,
                targetCount: model.targetCountPerDay,
                isCompleted: model.isTodayCompleted,
                dhikrTitle: 'ورد: ${dhikr.titleArabic}',
                dhikrText: dhikr.bodyArabic,
                onTap: controller.incrementSalawat,
                onReset: controller.resetTodayCount,
                onTargetChange: controller.updateTargetCount,
              ),

              const Gap(16),

              // 3. 40 Days Grid Matrix
              FortyDaysMatrix(
                completedDays: model.completedDays,
                activeDay: activeDay,
                totalDays: model.totalDays,
                missedDays: model.missedDays,
                onDayTap: controller.toggleDayCompletion,
              ),

              const Gap(16),

              // 4. Spiritual Hadith Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withAlpha(8) : Colors.amber.withAlpha(20),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.amber.withAlpha(isDark ? 40 : 50),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.format_quote_rounded,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const Gap(10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'سرّ الأربعين:',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            '«مَنْ أَخْلَصَ لِلَّهِ أَرْبَعِينَ صَبَاحاً ظَهَرَتْ يَنَابِيعُ الْحِكْمَةِ مِنْ قَلْبِهِ عَلَى لِسَانِهِ.»',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 13,
                              height: 1.6,
                              color: colorScheme.onSurface.withAlpha(220),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(24),
            ],
          ),
        );
      }),
    );
  }

  /// کارت نمایش متن کامل ذکر یا سوره
  Widget _buildDhikrTextCard(
    BuildContext context,
    ArbaeenDhikrModel dhikr,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final bool isLongText = dhikr.bodyArabic.length > 150;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2226) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.onPrimary.withAlpha(isDark ? 35 : 25),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withAlpha(20),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                  const Gap(8),
                  Text(
                    'نص الذكر المبارك (${dhikr.titleArabic}):',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              ZoomTapAnimation(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: dhikr.bodyArabic));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'تم نسخ النص بنجاح 📋',
                        style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
                      ),
                      backgroundColor: colorScheme.onPrimary,
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: colorScheme.onPrimary,
                      ),
                      const Gap(4),
                      Text(
                        'نسخ',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Gap(12),
          Container(
            constraints: isLongText ? const BoxConstraints(maxHeight: 220) : null,
            child: SingleChildScrollView(
              child: Text(
                dhikr.bodyArabic,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 15,
                  height: 1.8,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface.withAlpha(230),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
