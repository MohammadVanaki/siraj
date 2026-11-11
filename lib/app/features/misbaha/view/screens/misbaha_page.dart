import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/widgets/custom_app_bar.dart';
import 'package:mawsueat/app/features/misbaha/controller/misbaha_controller.dart';
import 'package:mawsueat/app/features/misbaha/view/widgets/animated_beads_view.dart';
import 'package:mawsueat/app/features/misbaha/view/widgets/bead_theme_sheet.dart';
import 'package:mawsueat/app/features/misbaha/view/widgets/dhikr_selection_sheet.dart';
import 'package:mawsueat/app/features/misbaha/view/widgets/misbaha_counter_display.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class MisbahaPage extends StatelessWidget {
  const MisbahaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MisbahaController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'المسبحة',
        actions: [
          // Sound toggle action
          Obx(() {
            final isSound = controller.isSoundEnabled.value;
            return ZoomTapAnimation(
              onTap: controller.toggleSound,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSound
                      ? colorScheme.onPrimary.withAlpha(isDark ? 50 : 30)
                      : (isDark ? Colors.white10 : Colors.grey[200]),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSound ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  size: 20,
                  color: isSound ? colorScheme.onPrimary : Colors.grey,
                ),
              ),
            );
          }),

          // Vibration toggle action
          Obx(() {
            final isVib = controller.isVibrationEnabled.value;
            return ZoomTapAnimation(
              onTap: controller.toggleVibration,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isVib
                      ? colorScheme.onPrimary.withAlpha(isDark ? 50 : 30)
                      : (isDark ? Colors.white10 : Colors.grey[200]),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isVib ? Icons.vibration_rounded : Icons.smartphone_rounded,
                  size: 20,
                  color: isVib ? colorScheme.onPrimary : Colors.grey,
                ),
              ),
            );
          }),

          // Reset count action
          ZoomTapAnimation(
            onTap: () => _showResetDialog(context, controller),
            child: Container(
              margin: const EdgeInsets.only(right: 8, left: 3),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : colorScheme.onPrimary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.refresh_rounded,
                size: 20,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top Counter & Progress Card
            const MisbahaCounterDisplay(),

            // Center: Spacious Horizontal Interactive Beads View
            Expanded(
              child: Stack(
                children: [
                  // Animated horizontal beads view
                  AnimatedBeadsView(onTap: controller.increment),

                  // Guidance hint pill
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withAlpha(150)
                              : Colors.white.withAlpha(210),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? Colors.white12 : Colors.black12,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 50 : 15),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swipe_rounded,
                              size: 16,
                              color: colorScheme.onPrimary,
                            ),
                            const Gap(8),
                            Text(
                              'اسحب الحبات أفقياً أو انقر في أي مكان للتسبيح',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface.withAlpha(190),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom action bar
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 6, 18, 16),
              child: Row(
                children: [
                  // Select Dhikr Button
                  Expanded(
                    child: ZoomTapAnimation(
                      onTap: () => DhikrSelectionSheet.show(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 13),
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
                            Icon(
                              Icons.menu_book_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            Gap(8),
                            Text(
                              'اختيار الذكر',
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

                  // Bead Theme Selector Button
                  ZoomTapAnimation(
                    onTap: () => BeadThemeSheet.show(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.palette_rounded,
                            color: colorScheme.onPrimary,
                            size: 18,
                          ),
                          const Gap(6),
                          Text(
                            'المظهر',
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, MisbahaController controller) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: theme.scaffoldBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'تصفير العدّاد',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        content: Text(
          'هل تريد إعادة ضبط العدّاد إلى الصفر؟',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 14,
            color: isDark ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              controller.reset();
              Get.back();
            },
            child: const Text(
              'تأكيد',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
