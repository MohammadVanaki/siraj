// lib/pages/settings_page.dart
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/config/get_version.dart';
import 'package:mawsueat/app/config/launch_url.dart';
import 'package:mawsueat/app/config/share_app.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import 'package:mawsueat/app/core/common/widgets/internal_page.dart';
import 'package:mawsueat/app/features/about/view/screens/about_page.dart';
import 'package:mawsueat/app/features/setting/view/controller/settings_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SettingPage extends StatelessWidget {
  final SettingsController controller = Get.put(SettingsController());

  SettingPage({super.key, required this.isDrawer});
  final bool isDrawer;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentScheme = controller.selectedColorScheme.value;
      final brandColor = currentScheme.onPrimary;
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      return Scaffold(
        backgroundColor: controller.backgroundColor.value,
        appBar: isDrawer
            ? AppBar(
                title: Text(
                  "الإعدادات",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'IBMPlexSansArabic',
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                centerTitle: true,
                leading: ZoomTapAnimation(
                  onTap: () {
                    if (Navigator.canPop(context)) {
                      Navigator.of(context).pop();
                    } else {
                      Get.back();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(20)
                          : brandColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 16,
                      color: brandColor,
                    ),
                  ),
                ),
                elevation: 0,
                backgroundColor: Colors.transparent,
              )
            : null,
        body: InternalPage(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 115),
            children: [
              // 🌟 هدر معرفی اپلیکیشن و نسخه
              _buildHeaderCard(context, brandColor, isDark),

              const Gap(16),

              // 🎨 بخش انتخاب رنگ‌های مظهر (Theme Palette)
              _buildThemeCard(context, brandColor, isDark),

              const Gap(14),

              // 🔔 بخش اعلان‌ها و نوتیفیکیشن
              _buildNotificationCard(context, brandColor, isDark),

              const Gap(14),

              // 📤 کارت ابزارهای ارتباطی و اشتراک‌گذاری
              _buildActionsCard(context, brandColor, isDark),

              const Gap(20),

              // 📄 فوتر زیبا با نشان تعاملی Powered by Dijlah IT
              _buildFooter(context, brandColor, isDark),
            ],
          ),
        ),
      );
    });
  }

  /// هدر معرفی برنامه با آیکون و نسخه
  Widget _buildHeaderCard(
    BuildContext context,
    Color brandColor,
    bool isDark,
  ) {
    final appVersionController = Get.isRegistered<AppVersionController>()
        ? Get.find<AppVersionController>()
        : Get.put(AppVersionController());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: isDark
              ? [
                  brandColor.withAlpha(35),
                  const Color(0xFF242222),
                ]
              : [
                  brandColor.withAlpha(22),
                  Colors.white,
                ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(20)
              : brandColor.withAlpha(35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(70)
                : brandColor.withAlpha(15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: isDark ? const Color(0xFF1E1C1C) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: brandColor.withAlpha(35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(5),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/appIcon.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Gap(14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      Constants.appTitle,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBMPlexSansArabic',
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: brandColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Obx(
                        () => Text(
                          appVersionController.version.value.isNotEmpty
                              ? 'v${appVersionController.version.value}'
                              : 'v1.0.0',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: brandColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(3),
                Text(
                  'تطبيق السراج للمناسك والأدعية والزيارات',
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'IBMPlexSansArabic',
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// کارت انتخاب رنگ تم
  Widget _buildThemeCard(
    BuildContext context,
    Color brandColor,
    bool isDark,
  ) {
    return _buildCard(
      context: context,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: brandColor.withAlpha(isDark ? 35 : 20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.palette_rounded,
                  size: 21,
                  color: brandColor,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "ألوان المظهر",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    const Gap(2),
                    Text(
                      "اختر النمط اللوني المناسب لواجهة التطبيق",
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'IBMPlexSansArabic',
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withAlpha(35)
                  : brandColor.withAlpha(10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: controller.themeColorSchemes.map((scheme) {
                final isSelected =
                    controller.selectedColorScheme.value.primary ==
                        scheme.primary;
                return _buildThemeColorItem(
                  context,
                  scheme,
                  isSelected,
                  brandColor,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// دکمه دایره‌ای زیبا با گرادینت و حاشیه متحرک برای انتخاب رنگ
  Widget _buildThemeColorItem(
    BuildContext context,
    ThemeColorScheme scheme,
    bool isSelected,
    Color brandColor,
  ) {
    return ZoomTapAnimation(
      begin: 1.0,
      end: 0.94,
      onTap: () {
        if (isSelected) return;
        controller.isDarkMode.value = false;
        controller.setTheme(
          scheme,
          isDarkMode: false,
          themeindex: scheme.index,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? scheme.onPrimary : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: scheme.onPrimary.withAlpha(90),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [scheme.primary, scheme.onPrimary],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isSelected
              ? const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  /// کارت بخش نوتیفیکیشن با وضعیت فعال/غیرفعال
  Widget _buildNotificationCard(
    BuildContext context,
    Color brandColor,
    bool isDark,
  ) {
    final isEnabled = controller.isNotificationsEnabled.value;
    return _buildCard(
      context: context,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: (isEnabled ? brandColor : Colors.grey)
                  .withAlpha(isDark ? 35 : 20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isEnabled
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_outlined,
              size: 21,
              color: isEnabled ? brandColor : Colors.grey,
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      "الإشعارات والتنبيهات",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    const Gap(8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isEnabled
                            ? Colors.green.withAlpha(25)
                            : Colors.grey.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isEnabled ? "مفعّلة" : "معطّلة",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isEnabled
                              ? Colors.green.shade700
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(3),
                Text(
                  "استلام التنبيهات للأوقات الشرعية والأذكار",
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'IBMPlexSansArabic',
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isEnabled,
            activeThumbColor: brandColor,
            activeTrackColor: brandColor.withAlpha(120),
            onChanged: (value) => controller.toggleNotifications(value),
          ),
        ],
      ),
    );
  }

  /// کارت گروهی شامل اشتراک‌گذاری و درباره برنامه
  Widget _buildActionsCard(
    BuildContext context,
    Color brandColor,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242222) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(15)
              : brandColor.withAlpha(25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(80)
                : brandColor.withAlpha(15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildActionTile(
            context: context,
            icon: Icons.share_rounded,
            title: "مشاركة التطبيق",
            subtitle: "شارك التطبيق وانشر الأجر مع الأهل والأصدقاء",
            onTap: () => shareApp(context),
            brandColor: brandColor,
            isDark: isDark,
          ),
          Divider(
            height: 1,
            thickness: 0.8,
            indent: 70,
            endIndent: 16,
            color: isDark
                ? Colors.white.withAlpha(15)
                : brandColor.withAlpha(20),
          ),
          _buildActionTile(
            context: context,
            icon: Icons.info_outline_rounded,
            title: "حول التطبيق",
            subtitle: "مسيرة الكتاب ومصادر المحتوى وإرشادات العمل",
            onTap: () => Get.to(() => const AboutPage(isDrawer: true)),
            brandColor: brandColor,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// آیتم تکی برای اکشن‌های کلیک‌پذیر
  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color brandColor,
    required bool isDark,
  }) {
    return ZoomTapAnimation(
      onTap: onTap,
      begin: 1.0,
      end: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: brandColor.withAlpha(isDark ? 35 : 20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 21,
                color: brandColor,
              ),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                  const Gap(3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'IBMPlexSansArabic',
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: brandColor.withAlpha(isDark ? 25 : 15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: brandColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// سازنده کارت استاندارد با سایه و انحنای متناسب با تم برنامه
  Widget _buildCard({
    required BuildContext context,
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = theme.colorScheme.onPrimary;

    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF242222) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(15)
              : brandColor.withAlpha(25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withAlpha(80)
                : brandColor.withAlpha(15),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// فوتر شیک پایین صفحه با نشان Powered by Dijlah IT
  Widget _buildFooter(BuildContext context, Color brandColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // عبارت کلیک‌پذیر Powered by Dijlah IT
          ZoomTapAnimation(
            onTap: () => urlLauncher('https://dijlah.org'),
            begin: 1.0,
            end: 0.95,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Powered by ',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    Text(
                      'Dijlah IT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: brandColor,
                        fontFamily: 'IBMPlexSansArabic',
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Gap(14),

          // حقوق کپی‌رایت
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                size: 13,
                color: brandColor.withAlpha(120),
              ),
              const Gap(6),
              Text(
                "تطبيق السراج — جميع الحقوق محفوظة",
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'IBMPlexSansArabic',
                  color: Colors.grey.shade500,
                ),
              ),
              const Gap(6),
              Icon(
                Icons.star_rounded,
                size: 13,
                color: brandColor.withAlpha(120),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

