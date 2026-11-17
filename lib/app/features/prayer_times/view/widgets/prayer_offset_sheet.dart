import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

import '../../controller/prayer_times_controller.dart';
import '../../model/prayer_time_item.dart';

class PrayerOffsetSheet extends StatefulWidget {
  final PrayerTimeItem item;

  const PrayerOffsetSheet({super.key, required this.item});

  static Future<void> show(BuildContext context, PrayerTimeItem item) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PrayerOffsetSheet(item: item),
    );
  }

  @override
  State<PrayerOffsetSheet> createState() => _PrayerOffsetSheetState();
}

class _PrayerOffsetSheetState extends State<PrayerOffsetSheet> {
  late int _offsetMinutes;
  final controller = PrayerTimesController.to;

  @override
  void initState() {
    super.initState();
    _offsetMinutes = widget.item.notificationOffsetMinutes;
  }

  void _updateOffset(int value) {
    // Clamp between -60 and +60 minutes
    final clamped = value.clamp(-60, 60);
    setState(() {
      _offsetMinutes = clamped;
    });
  }

  String _formatPreviewTime(int offset) {
    final base = widget.item.displayWallClock ?? widget.item.dateTime;
    final shifted = base.add(Duration(minutes: offset));
    return DateFormat('hh:mm a', 'ar').format(shifted);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final previewTimeStr = _formatPreviewTime(_offsetMinutes);

    Color statusColor;
    String statusTitle;
    String statusSubtitle;

    if (_offsetMinutes == 0) {
      statusColor = colorScheme.onPrimary;
      statusTitle = 'في موعد الأذان تماماً';
      statusSubtitle = 'سيصلك التنبيه عند حلول وقت ${widget.item.arabicName} بالضبط';
    } else if (_offsetMinutes < 0) {
      statusColor = Colors.amber[700]!;
      statusTitle = 'قبل الأذان بـ ${_offsetMinutes.abs()} دقيقة';
      statusSubtitle = 'تنبيه مبكر للاستعداد والتذكير بالصلاة';
    } else {
      statusColor = Colors.teal[600]!;
      statusTitle = 'بعد الأذان بـ $_offsetMinutes دقيقة';
      statusSubtitle = 'تنبيه متأخر وفق رغبتك أو للاحتياط';
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet Handle Bar
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(100),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Title and Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withAlpha(25),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: SvgPicture.asset(
                          widget.item.iconAsset,
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                            colorScheme.onPrimary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const Gap(10),
                      Text(
                        'ضبط تنبيه ${widget.item.arabicName}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),

              const Divider(height: 20),

              // Live Preview Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(10)
                      : colorScheme.onPrimary.withAlpha(15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: statusColor.withAlpha(isDark ? 80 : 100),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الوقت الشرعي الفعلي:',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                        Text(
                          widget.item.formattedTime,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active_rounded,
                              size: 16,
                              color: statusColor,
                            ),
                            const Gap(6),
                            Text(
                              'وقت انطلاق التنبيه:',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                                fontFamily: 'IBMPlexSansArabic',
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withAlpha(isDark ? 50 : 25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            previewTimeStr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              fontFamily: 'IBMPlexSansArabic',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(8),
                    Text(
                      '$statusTitle • $statusSubtitle',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(18),

              // Interactive Stepper
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Minus 1 button
                    ZoomTapAnimation(
                      onTap: () => _updateOffset(_offsetMinutes - 1),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(15)
                              : Colors.grey.withAlpha(35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.remove_rounded, size: 24),
                      ),
                    ),

                    const Gap(20),

                    // Current offset value display
                    Container(
                      constraints: const BoxConstraints(minWidth: 130),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(10)
                            : Colors.grey.withAlpha(20),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withAlpha(25)
                              : Colors.grey.withAlpha(60),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _offsetMinutes == 0
                                ? '0'
                                : (_offsetMinutes > 0
                                    ? '+$_offsetMinutes'
                                    : '$_offsetMinutes'),
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              fontFamily: 'IBMPlexSansArabic',
                            ),
                          ),
                          Text(
                            'دقيقة',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                              fontFamily: 'IBMPlexSansArabic',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Gap(20),

                    // Plus 1 button
                    ZoomTapAnimation(
                      onTap: () => _updateOffset(_offsetMinutes + 1),
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withAlpha(15)
                              : Colors.grey.withAlpha(35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add_rounded, size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(16),

              // Quick Preset Chips
              Text(
                'خيارات سريعة:',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[300] : Colors.grey[800],
                  fontFamily: 'IBMPlexSansArabic',
                ),
              ),
              const Gap(8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildPresetChip(-15, 'قبل 15 د', isDark, colorScheme),
                    const Gap(6),
                    _buildPresetChip(-10, 'قبل 10 د', isDark, colorScheme),
                    const Gap(6),
                    _buildPresetChip(-5, 'قبل 5 د', isDark, colorScheme),
                    const Gap(6),
                    _buildPresetChip(0, 'في الموعد (0)', isDark, colorScheme),
                    const Gap(6),
                    _buildPresetChip(5, 'بعد 5 د', isDark, colorScheme),
                    const Gap(6),
                    _buildPresetChip(10, 'بعد 10 د', isDark, colorScheme),
                    const Gap(6),
                    _buildPresetChip(15, 'بعد 15 د', isDark, colorScheme),
                  ],
                ),
              ),

              const Gap(14),

              // Info note
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                  const Gap(6),
                  Expanded(
                    child: Text(
                      'هذا الإعداد يتحكم فقط بوقت انطلاق إشعار وصوت الأذان، ولا يغير الوقت الشرعي الفعلي للصلاة.',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontFamily: 'IBMPlexSansArabic',
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(18),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    controller.setPrayerOffset(
                      widget.item.type,
                      _offsetMinutes,
                    );
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.onPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'تأكيد وحفظ التعديل',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ),
              ),

              const Gap(6),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(
    int value,
    String label,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    final isSelected = _offsetMinutes == value;
    return ZoomTapAnimation(
      onTap: () => _updateOffset(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.onPrimary
              : (isDark
                  ? Colors.white.withAlpha(10)
                  : Colors.grey.withAlpha(20)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colorScheme.onPrimary
                : (isDark
                    ? Colors.white.withAlpha(20)
                    : Colors.grey.withAlpha(40)),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white : Colors.black87),
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
      ),
    );
  }
}
