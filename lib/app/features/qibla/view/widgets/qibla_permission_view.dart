import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/qibla_controller.dart';

class QiblaPermissionView extends StatelessWidget {
  final QiblaController controller;

  const QiblaPermissionView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final status = controller.status.value;
      final msg = controller.statusMessage.value;

      String iconPath = 'assets/svgs/land-layer-location.svg';
      String title = 'تحديد اتجاه القبلة';
      String actionText = 'منح الصلاحيات';
      VoidCallback onAction = () => controller.retry();

      switch (status) {
        case QiblaStatus.loading:
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const Gap(20),
                Text(
                  msg,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );

        case QiblaStatus.gpsDisabled:
          iconPath = 'assets/svgs/signal-stream-slash.svg';
          title = 'خدمة الموقع (GPS) متوقفة';
          actionText = 'إعادة الفحص';
          onAction = () => controller.retry();
          break;

        case QiblaStatus.permissionPermanentlyDenied:
          iconPath = 'assets/svgs/settings.svg';
          title = 'صلاحيات الموقع مطلوبة';
          actionText = 'فتح إعدادات الهاتف';
          onAction = () => controller.openAppSettingsPage();
          break;

        case QiblaStatus.permissionDenied:
          iconPath = 'assets/svgs/land-layer-location.svg';
          title = 'صلاحيات مطلوبة';
          actionText = 'طلب الصلاحيات';
          onAction = () => controller.initQibla();
          break;

        case QiblaStatus.sensorUnavailable:
          iconPath = 'assets/svgs/triangle-warning.svg';
          title = 'حساس البوصلة غير متوفر';
          actionText = 'إعادة المحاولة';
          onAction = () => controller.retry();
          break;

        default:
          iconPath = 'assets/svgs/triangle-warning.svg';
          title = 'حدث خطأ';
          actionText = 'إعادة المحاولة';
          onAction = () => controller.retry();
      }

      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1E1E1E)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 50 : 20),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: colorScheme.onPrimary.withAlpha(40),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(18),
                  child: SvgPicture.asset(
                    iconPath,
                    colorFilter: ColorFilter.mode(
                      colorScheme.onPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const Gap(18),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(10),
                Text(
                  msg,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const Gap(24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ZoomTapAnimation(
                    onTap: onAction,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colorScheme.onPrimary,
                            colorScheme.onPrimary.withAlpha(200),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.onPrimary.withAlpha(80),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        actionText,
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
