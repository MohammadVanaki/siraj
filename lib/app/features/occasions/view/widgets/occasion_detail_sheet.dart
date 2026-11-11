import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../data/occasions_dataset.dart';
import '../../model/occasion_model.dart';

class OccasionDetailSheet extends StatelessWidget {
  final Occasion occasion;

  const OccasionDetailSheet({super.key, required this.occasion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isJoy = occasion.type == OccasionType.joy;
    final isMourning = occasion.type == OccasionType.mourning;

    Color badgeColor;
    if (isJoy) {
      badgeColor = const Color(0xFF2E7D32);
    } else if (isMourning) {
      badgeColor = const Color(0xFFC62828);
    } else {
      badgeColor = colorScheme.onPrimary;
    }

    final monthName = OccasionsDataset.hijriMonthNames[occasion.hijriMonth - 1];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
        children: [
          // شريط السحب العلوي
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          const Gap(16),

          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // بادج نوع المناسبة + التاريخ
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeColor.withAlpha(50)),
                        ),
                        child: Text(
                          occasion.typeName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: badgeColor,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              'assets/svgs/calendar-days.svg',
                              width: 13,
                              height: 13,
                              colorFilter: ColorFilter.mode(
                                colorScheme.onPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                            const Gap(6),
                            Text(
                              '${occasion.hijriDay} $monthName',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const Gap(14),

                  // عنوان المناسبة
                  Text(
                    occasion.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),

                  if (occasion.subtitle != null) ...[
                    const Gap(6),
                    Text(
                      occasion.subtitle!,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ],

                  const Gap(16),
                  const Divider(height: 1),
                  const Gap(16),

                  // نبذة وتفاصيل تاريخية
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/book-open-cover.svg',
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(
                          colorScheme.onPrimary,
                          BlendMode.srcIn,
                        ),
                      ),
                      const Gap(8),
                      Text(
                        'عن المناسبة',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ],
                  ),

                  const Gap(8),

                  Text(
                    occasion.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.7,
                      color: colorScheme.onSurface.withAlpha(220),
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),

                  // الأعمال المستحبة إن وجدت
                  if (occasion.recommendedActs.isNotEmpty) ...[
                    const Gap(20),
                    Row(
                      children: [
                        SvgPicture.asset(
                          'assets/svgs/checklist-task-budget.svg',
                          width: 16,
                          height: 16,
                          colorFilter: ColorFilter.mode(
                            badgeColor,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Gap(8),
                        Text(
                          'الأعمال والعبادات المستحبة',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ],
                    ),
                    const Gap(10),
                    ...occasion.recommendedActs.map((act) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: badgeColor,
                              ),
                            ),
                            const Gap(10),
                            Expanded(
                              child: Text(
                                act,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                  color: colorScheme.onSurface,
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],

                  // الزيارة أو الدعاء المستحب إن وجد
                  if (occasion.ziyarahText != null) ...[
                    const Gap(14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.onPrimary.withAlpha(35),
                        ),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/svgs/book-alt.svg',
                            width: 16,
                            height: 16,
                            colorFilter: ColorFilter.mode(
                              colorScheme.onPrimary,
                              BlendMode.srcIn,
                            ),
                          ),
                          const Gap(10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الزيارة والدعاء المأثور',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  occasion.ziyarahText!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary,
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Gap(24),
                ],
              ),
            ),
          ),

          // أزرار التحكم السفلية (مشاركة + نسخ + إغلاق)
          const Divider(height: 1),
          const Gap(12),

          Row(
            children: [
              Expanded(
                child: ZoomTapAnimation(
                  onTap: () {
                    final String shareText =
                        '📌 ${occasion.title}\n'
                        '📅 ${occasion.hijriDay} $monthName\n\n'
                        '${occasion.description}\n\n'
                        '${occasion.recommendedActs.isNotEmpty ? "✨ الأعمال المستحبة:\n" + occasion.recommendedActs.map((a) => "• $a").join("\n") : ""}\n\n'
                        'تطبيق السراج';
                    Share.share(shareText, subject: occasion.title);
                  },
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/svgs/share-square.svg',
                          width: 16,
                          height: 16,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                        const Gap(8),
                        const Text(
                          'مشاركة المناسبة',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Gap(10),
              ZoomTapAnimation(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: '${occasion.title}\n${occasion.description}',
                    ),
                  );
                  Get.snackbar(
                    'تم النسخ',
                    'تم نسخ تفاصيل المناسبة إلى الحافظة',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2),
                    margin: const EdgeInsets.all(12),
                  );
                },
                child: Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white12 : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/svgs/copy-alt.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onSurface,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
  }
}
