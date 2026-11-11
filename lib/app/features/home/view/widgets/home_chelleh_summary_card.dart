import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/routes/routes.dart';
import 'package:mawsueat/app/features/chelleh/controller/chelleh_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomeChellehSummaryCard extends StatelessWidget {
  const HomeChellehSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    final ChellehController controller = Get.isRegistered<ChellehController>()
        ? Get.find<ChellehController>()
        : Get.put(ChellehController());

    return Obx(() {
      if (!controller.isLoaded.value) {
        return const SizedBox.shrink();
      }

      final model = controller.chelleh.value;
      final activeDay = model.activeDayNumber;
      final completedCount = model.completedDays.length;
      final isTodayDone = model.isTodayCompleted;
      final progressPercent = (model.overallProgress * 100).toInt();

      return ZoomTapAnimation(
        onTap: () => Get.toNamed(Routes.chelleh),
        begin: 1.0,
        end: 0.98,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: isDark ? const Color(0xFF241F21) : Colors.white,
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(22)
                  : brandColor.withAlpha(30),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 80 : 18),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Decorative ambient background glow
                Positioned(
                  right: -30,
                  top: -30,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: brandColor.withAlpha(isDark ? 16 : 14),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Avatar, Title, Day Pill
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: brandColor.withAlpha(isDark ? 30 : 18),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: Image.asset(
                              'assets/icons/Arbaeen.png',
                              fit: BoxFit.contain,
                              cacheWidth: 88,
                              cacheHeight: 88,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        model.title.isNotEmpty
                                            ? model.title
                                            : 'عهد الأربعين',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'IBMPlexSansArabic',
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    const Gap(6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isTodayDone
                                            ? Colors.teal.withAlpha(isDark ? 40 : 25)
                                            : Colors.amber.withAlpha(isDark ? 40 : 25),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        isTodayDone ? 'مكتمل اليوم' : 'قيد الإنجاز',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'IBMPlexSansArabic',
                                          color: isTodayDone
                                              ? (isDark ? Colors.tealAccent : Colors.teal[800])
                                              : (isDark ? Colors.amberAccent : Colors.amber[900]),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Gap(2),
                                Text(
                                  model.niyyah,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Day badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: brandColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: brandColor.withAlpha(60),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'اليوم $activeDay / ${model.totalDays}',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'IBMPlexSansArabic',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Gap(14),

                      // Progress Bar & Percentage
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'مستوى التقدم في الأربعينية',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'IBMPlexSansArabic',
                                  color: colorScheme.onSurface.withAlpha(180),
                                ),
                              ),
                              Text(
                                '$progressPercent% مكتمل',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBMPlexSansArabic',
                                  color: brandColor,
                                ),
                              ),
                            ],
                          ),
                          const Gap(6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: model.overallProgress,
                              minHeight: 7,
                              backgroundColor: isDark
                                  ? Colors.white10
                                  : brandColor.withAlpha(20),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isTodayDone ? Colors.teal : brandColor,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Gap(14),

                      // 3 Key Stats Box
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withAlpha(35)
                              : brandColor.withAlpha(8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withAlpha(10)
                                : brandColor.withAlpha(15),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Stat 1: Current Day
                            Expanded(
                              child: _buildStatItem(
                                title: 'اليوم الحالي',
                                value: '$activeDay',
                                subtitle: 'من 40 يوماً',
                                valueColor: colorScheme.onSurface,
                                isDark: isDark,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: isDark
                                  ? Colors.white.withAlpha(15)
                                  : brandColor.withAlpha(20),
                            ),
                            // Stat 2: Completed Days
                            Expanded(
                              child: _buildStatItem(
                                title: 'الأيام المنجزة',
                                value: '$completedCount',
                                subtitle: 'أيام كاملة',
                                valueColor: Colors.teal,
                                isDark: isDark,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: isDark
                                  ? Colors.white.withAlpha(15)
                                  : brandColor.withAlpha(20),
                            ),
                            // Stat 3: Today's Salawat
                            Expanded(
                              child: _buildStatItem(
                                title: 'صلوات اليوم',
                                value: '${model.currentDayCount}',
                                subtitle: '/ ${model.targetCountPerDay}',
                                valueColor: isTodayDone
                                    ? Colors.teal
                                    : brandColor,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Gap(12),

                      // Quick Action Bottom Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Icon(
                                  isTodayDone
                                      ? Icons.check_circle_rounded
                                      : Icons.access_time_rounded,
                                  size: 14,
                                  color: isTodayDone
                                      ? Colors.teal
                                      : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                ),
                                const Gap(5),
                                Expanded(
                                  child: Text(
                                    isTodayDone
                                        ? 'تم إنجاز ورد اليوم بنجاح'
                                        : 'متبقي ${model.targetCountPerDay - model.currentDayCount > 0 ? model.targetCountPerDay - model.currentDayCount : 0} صلوات',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'IBMPlexSansArabic',
                                      color: isTodayDone
                                          ? Colors.teal
                                          : (isDark ? Colors.grey[400] : Colors.grey[600]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'متابعة الأربعينية',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBMPlexSansArabic',
                                  color: brandColor,
                                ),
                              ),
                              const Gap(4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 11,
                                color: brandColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required String subtitle,
    required Color valueColor,
    required bool isDark,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'IBMPlexSansArabic',
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        const Gap(2),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
                color: valueColor,
              ),
            ),
            const Gap(3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9.5,
                fontFamily: 'IBMPlexSansArabic',
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
