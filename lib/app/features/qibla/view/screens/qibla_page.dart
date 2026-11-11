import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/widgets/custom_app_bar.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/qibla_controller.dart';
import '../widgets/ar_camera_view.dart';
import '../widgets/compass_2d_view.dart';
import '../widgets/qibla_permission_view.dart';

class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final QiblaController controller = Get.put(QiblaController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : colorScheme.surface,
      appBar: CustomAppBar(
        backgroundColor: isDark
            ? Colors.black.withAlpha(200)
            : colorScheme.surface,
        title: 'اتجاه القبلة',
        actions: [
          // زر تبديل الوضع (واقع معزز AR / بوصلة 2D)
          Obx(() {
            final isReady = controller.status.value == QiblaStatus.ready;
            if (!isReady) return const SizedBox.shrink();

            final isAr = controller.isArMode.value;
            return ZoomTapAnimation(
              onTap: () => controller.toggleMode(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isAr
                      ? colorScheme.onPrimary
                      : (isDark
                            ? Colors.white24
                            : colorScheme.onPrimary.withAlpha(20)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAr ? Icons.camera_alt_rounded : Icons.explore_rounded,
                      size: 16,
                      color: isAr ? Colors.white : colorScheme.onPrimary,
                    ),
                    const Gap(4),
                    Text(
                      isAr ? 'AR' : '2D',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isAr ? Colors.white : colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          // زر إرشادات المعايرة
          ZoomTapAnimation(
            onTap: () => _showCalibrationDialog(context),
            child: Container(
              margin: const EdgeInsets.only(left: 8, right: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : colorScheme.onPrimary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.info_outline_rounded,
                size: 20,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final status = controller.status.value;

          if (status != QiblaStatus.ready) {
            return QiblaPermissionView(controller: controller);
          }

          if (controller.isArMode.value) {
            return ArCameraView(controller: controller);
          } else {
            return Compass2dView(controller: controller);
          }
        }),
      ),
    );
  }

  /// حوار إرشادات معايرة البوصلة
  void _showCalibrationDialog(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF222222) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.tune_rounded, color: colorScheme.onPrimary),
            const Gap(8),
            Text(
              'معايرة البوصلة',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'للحصول على أعلى دقة في تحديد القبلة:',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(10),
            _stepRow('1', 'ابتعد عن الأجهزة الإلكترونية والمعادن والمغناطيس.'),
            const Gap(8),
            _stepRow(
              '2',
              'قم بتحريك هاتفك في الهواء على شكل الرقم (8) الإنجليزي لمعايرة الحساس.',
            ),
            const Gap(8),
            _stepRow(
              '3',
              'امسك الهاتف بشكل مستوٍ أو وجه الكاميرا أفقياً أمامك.',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'حسناً',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepRow(String num, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.amber.withAlpha(50),
            shape: BoxShape.circle,
          ),
          child: Text(
            num,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.amber,
              fontFamily: 'IBMPlexSansArabic',
            ),
          ),
        ),
        const Gap(8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'IBMPlexSansArabic',
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
