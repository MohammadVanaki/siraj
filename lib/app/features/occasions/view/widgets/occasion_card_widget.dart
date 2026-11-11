import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../data/occasions_dataset.dart';
import '../../model/occasion_model.dart';
import 'occasion_detail_sheet.dart';

class OccasionCardWidget extends StatelessWidget {
  final Occasion occasion;
  final bool showDateBadge;

  const OccasionCardWidget({
    super.key,
    required this.occasion,
    this.showDateBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final isJoy = occasion.type == OccasionType.joy;
    final isMourning = occasion.type == OccasionType.mourning;

    Color themeColor;
    if (isJoy) {
      themeColor = const Color(0xFF2E7D32);
    } else if (isMourning) {
      themeColor = const Color(0xFFC62828);
    } else {
      themeColor = colorScheme.onPrimary;
    }

    final monthName = OccasionsDataset.hijriMonthNames[occasion.hijriMonth - 1];

    return ZoomTapAnimation(
      onTap: () {
        Get.bottomSheet(
          OccasionDetailSheet(occasion: occasion),
          isScrollControlled: true,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withAlpha(12) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white.withAlpha(15) : Colors.grey.withAlpha(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 30 : 8),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // الشريط اللوني الجانبي
              Container(
                width: 5,
                decoration: BoxDecoration(
                  color: themeColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
              ),

              const Gap(12),

              // التاريخ الهجري
              if (showDateBadge) ...[
                Container(
                  width: 50,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: themeColor.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${occasion.hijriDay}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                      Text(
                        monthName.split(' ').first,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: themeColor,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(12),
              ],

              // العنوان والتفاصيل
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              occasion.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                          ),
                          if (occasion.isMajor) ...[
                            const Gap(6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: themeColor.withAlpha(20),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'بارز',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (occasion.subtitle != null) ...[
                        const Gap(3),
                        Text(
                          occasion.subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const Gap(8),

              // سهم الفتح
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: isDark ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
