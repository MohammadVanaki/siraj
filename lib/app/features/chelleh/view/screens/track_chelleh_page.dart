import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../../../core/common/widgets/custom_app_bar.dart';
import '../../../../core/routes/routes.dart';
import '../../controller/chelleh_controller.dart';
import '../widgets/chelleh_info_sheet.dart';
import '../widgets/chelleh_settings_sheet.dart';
import '../widgets/forty_days_matrix.dart';
import '../widgets/salawat_tap_counter.dart';

class TrackChellehPage extends StatefulWidget {
  final bool isStandalone;

  const TrackChellehPage({
    super.key,
    this.isStandalone = true,
  });

  @override
  State<TrackChellehPage> createState() => _TrackChellehPageState();
}

class _TrackChellehPageState extends State<TrackChellehPage> {
  final ChellehController controller = Get.isRegistered<ChellehController>()
      ? Get.find<ChellehController>()
      : Get.put(ChellehController());

  @override
  void initState() {
    super.initState();
    // Check and prompt if any day was missed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.checkAndPromptMissedDays(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: widget.isStandalone
          ? CustomAppBar(
              title: 'تكميل ومتابعة العهد (الأربعينية)',
              actions: [
                // Button to Create New Chelleh
                ZoomTapAnimation(
                  onTap: () => Get.toNamed(Routes.chellehCreate),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(20)
                          : brandColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.add_circle_outline_rounded,
                      size: 19,
                      color: brandColor,
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
                    margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(20)
                          : brandColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      size: 18,
                      color: brandColor,
                    ),
                  ),
                ),

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
                    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(20)
                          : brandColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.help_outline_rounded,
                      size: 18,
                      color: brandColor,
                    ),
                  ),
                ),
              ],
            )
          : null,
      body: Obx(() {
        if (!controller.isLoaded.value) {
          return Center(
            child: CircularProgressIndicator(color: brandColor),
          );
        }

        final model = controller.chelleh.value;
        final activeDay = model.activeDayNumber;
        final totalDays = model.totalDays;
        final completedCount = model.completedDays.length;
        final remainingDays = (totalDays - completedCount).clamp(0, totalDays);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            // Missed Days Alert Banner (if any day was skipped)
            if (model.hasMissedDays)
              _buildMissedDaysAlert(context, model.missedDays, brandColor, isDark),

            // 1. Header Overview Card
            _buildOverviewCard(
              context,
              model: model,
              activeDay: activeDay,
              totalDays: totalDays,
              completedCount: completedCount,
              remainingDays: remainingDays,
              brandColor: brandColor,
              isDark: isDark,
            ),

            const Gap(16),

            // 2. Daily Action Section (Dhikr Counter OR Surah Reader)
            if (model.isDhikr)
              SalawatTapCounter(
                currentCount: model.currentDayCount,
                targetCount: model.targetCountPerDay,
                isCompleted: model.isTodayCompleted,
                dhikrTitle: 'ورد اليوم: ${model.title}',
                dhikrText: model.bodyArabic,
                onTap: controller.incrementSalawat,
                onReset: controller.resetTodayCount,
                onTargetChange: controller.updateTargetCount,
              )
            else
              _buildSurahReadingCard(context, model, brandColor, isDark),

            const Gap(16),

            // 3. Days Grid Matrix
            FortyDaysMatrix(
              completedDays: model.completedDays,
              activeDay: activeDay,
              totalDays: totalDays,
              missedDays: model.missedDays,
              onDayTap: controller.toggleDayCompletion,
            ),

            const Gap(16),

            // 4. Spiritual Hadith Card
            _buildSpiritualCard(colorScheme, isDark),

            const Gap(16),

            // 5. Actions Card (Restart from Day 1 / Create New)
            _buildQuickActionsRow(context, brandColor, isDark),
          ],
        );
      }),
    );
  }

  /// بنر هشدار در صورت رد شدن روزی از چله
  Widget _buildMissedDaysAlert(
    BuildContext context,
    List<int> missedDays,
    Color brandColor,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2318) : const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.shade700.withAlpha(isDark ? 80 : 60),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.amber.shade700,
            size: 22,
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'انقطاع في الورد (الأيام: ${missedDays.join('، ')})',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade800,
                  ),
                ),
                const Gap(3),
                Text(
                  'لم يتم تسجيل ورد الأيام السابقة. يمكنك البدء من اليوم الأول لتصفير الانقطاع، أو متابعة العهد الحالي.',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    color: isDark ? Colors.grey[300] : Colors.grey[800],
                  ),
                ),
                const Gap(8),
                Row(
                  children: [
                    ZoomTapAnimation(
                      onTap: controller.restartChellehFromDayOne,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'البدء مجددًا',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const Gap(8),
                    ZoomTapAnimation(
                      onTap: controller.continueCurrentChelleh,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white12 : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'متابعة العهد',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 11.5,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// کارت مرور کلی پیشرفت چله
  Widget _buildOverviewCard(
    BuildContext context, {
    required dynamic model,
    required int activeDay,
    required int totalDays,
    required int completedCount,
    required int remainingDays,
    required Color brandColor,
    required bool isDark,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final percent = (model.overallProgress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF222022), const Color(0xFF17191C)]
              : [brandColor.withAlpha(25), brandColor.withAlpha(10)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: brandColor.withAlpha(isDark ? 45 : 30),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title & Active Day Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.title,
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Gap(3),
                    Text(
                      'النية: ${model.niyyah}',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12.5,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: brandColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: brandColor.withAlpha(70),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  'اليوم $activeDay من $totalDays',
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
                  : brandColor.withAlpha(25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.teal),
            ),
          ),

          const Gap(10),

          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أُنجز: $completedCount يوماً ($percent%)',
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
    );
  }

  /// کارت اختصاصی قرائت سوره یا ادعیه بدون تکرار عددی
  Widget _buildSurahReadingCard(
    BuildContext context,
    dynamic model,
    Color brandColor,
    bool isDark,
  ) {
    final bool isDoneToday = model.isTodayCompleted;
    final String bodyText = model.bodyArabic ?? '';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2226) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDoneToday
              ? Colors.teal.withAlpha(isDark ? 90 : 60)
              : brandColor.withAlpha(isDark ? 40 : 25),
          width: isDoneToday ? 1.5 : 1.2,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: isDoneToday
                      ? Colors.teal.withAlpha(15)
                      : brandColor.withAlpha(8),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.teal.withAlpha(isDark ? 40 : 20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.teal,
                      size: 18,
                    ),
                  ),
                  const Gap(8),
                  const Text(
                    'نص الورد اليومي',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDoneToday
                      ? Colors.teal.withAlpha(25)
                      : Colors.amber.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDoneToday ? 'مكتمل اليوم ✓' : 'في انتظار القراءة',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDoneToday ? Colors.teal : Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),

          const Gap(14),

          // Arabic Text Reader Container
          if (bodyText.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 280),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(6) : const Color(0xFFFAFAFA),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                ),
              ),
              child: SingleChildScrollView(
                child: Text(
                  bodyText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 16,
                    height: 2.1,
                    color: isDark ? Colors.grey[200] : const Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ),

          const Gap(16),

          // Action Button: Complete Today's Reading
          ZoomTapAnimation(
            onTap: controller.toggleTodayReadingCompletion,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDoneToday ? Colors.teal : brandColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (isDoneToday ? Colors.teal : brandColor).withAlpha(70),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDoneToday
                        ? Icons.check_circle_rounded
                        : Icons.done_all_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const Gap(8),
                  Text(
                    isDoneToday
                        ? 'تمت قراءة ورد اليوم بنجاح ✓ تقبل الله'
                        : 'إتمام وتثبيت قراءة اليوم 📖',
                    style: const TextStyle(
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
        ],
      ),
    );
  }

  /// کارت حکمت و سر الأربعين
  Widget _buildSpiritualCard(ColorScheme colorScheme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(8) : Colors.amber.withAlpha(20),
        borderRadius: BorderRadius.circular(18),
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
                  'سرّ الأربعين واستدامة الذكر:',
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
    );
  }

  /// دکمه‌های سریع برای ایجاد چله جدید یا شروع از اول
  Widget _buildQuickActionsRow(
    BuildContext context,
    Color brandColor,
    bool isDark,
  ) {
    return Row(
      children: [
        // Create new Chelleh
        Expanded(
          child: ZoomTapAnimation(
            onTap: () => Get.toNamed(Routes.chellehCreate),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withAlpha(10) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.grey.shade300,
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, size: 18),
                  Gap(6),
                  Text(
                    'إنشاء عهد جديد',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const Gap(10),

        // Restart from day 1
        Expanded(
          child: ZoomTapAnimation(
            onTap: () => _confirmRestartDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(isDark ? 20 : 10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.red.withAlpha(isDark ? 40 : 30),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restart_alt_rounded, size: 18, color: Colors.redAccent),
                  Gap(6),
                  Text(
                    'البدء مجددًا',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmRestartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text(
            'إعادة البدء من اليوم الأول؟',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'سيتم تصفير الأيام المنجزة والبدء من جديد اليوم. هل أنت متأكد؟',
            style: TextStyle(fontFamily: 'IBMPlexSansArabic', fontSize: 13.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'IBMPlexSansArabic')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                controller.restartChellehFromDayOne();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              child: const Text(
                'نعم، أعد البدء',
                style: TextStyle(fontFamily: 'IBMPlexSansArabic', color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
