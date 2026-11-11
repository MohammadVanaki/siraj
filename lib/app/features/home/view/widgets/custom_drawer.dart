import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/config/get_version.dart';
import 'package:mawsueat/app/config/launch_url.dart';
import 'package:mawsueat/app/config/share_app.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:mawsueat/app/core/routes/routes.dart';
import 'package:mawsueat/app/features/about/view/screens/about_page.dart';
import 'package:mawsueat/app/features/home/view/controller/bottom_navigation_controller.dart';
import 'package:mawsueat/app/features/setting/view/screens/setting_page.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key, required this.sliderDrawerKey});
  final GlobalKey<ScaffoldState> sliderDrawerKey;

  void _closeDrawer() {
    sliderDrawerKey.currentState?.closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    final AppVersionController appVersionController =
        Get.isRegistered<AppVersionController>()
            ? Get.find<AppVersionController>()
            : Get.put(AppVersionController());

    final List<Map<String, dynamic>> mainFeatures = [
      {
        "title": 'الرئيسية',
        "icon": 'house',
        "onTap": () {
          _closeDrawer();
          if (Get.isRegistered<BottomNavigationController>()) {
            Get.find<BottomNavigationController>().onItemTapped(0);
          }
          if (Get.currentRoute != Routes.home) {
            Get.offAllNamed(Routes.home);
          }
        },
      },
      {
        "title": 'القرآن الكريم',
        "icon": 'book-open-cover',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.quran);
        },
      },
      {
        "title": 'موسوعة أهل البيت',
        "icon": 'books',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.mawsueat);
        },
      },
      {
        "title": 'المكتبة',
        "icon": 'index-book',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.library);
        },
      },
      {
        "title": 'نهج البلاغة',
        "icon": 'book-alt',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.nahj);
        },
      },
      {
        "title": 'مفاتيح الجنان',
        "icon": 'book-alt',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.mafatihAlJinan);
        },
      },
      {
        "title": 'الصحيفة السجادية',
        "icon": 'book-open-cover',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.sahifaSajjadiyya);
        },
      },
      {
        "title": 'الأوقات الشرعية',
        "icon": 'moon',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.prayerTimes);
        },
      },
      {
        "title": 'اتجاه القبلة',
        "icon": 'land-layer-location',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.qibla);
        },
      },
      {
        "title": 'المسبحة',
        "icon": 'fingerprint',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.misbaha);
        },
      },
      {
        "title": 'المناسبات',
        "icon": 'calendar-days',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.occasions);
        },
      },
      {
        "title": 'الاستخارة',
        "icon": 'guide-alt',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.istikhara);
        },
      },
      {
        "title": 'الاستفتاءات',
        "icon": 'checklist-task-budget',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.rulings);
        },
      },
      {
        "title": 'الأربعينيات المباركة',
        "icon": 'list-check',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.chelleh);
        },
      },
      {
        "title": 'معرض الصور',
        "icon": 'file-image',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.gallery);
        },
      },
      {
        "title": 'الأدعية والزيارات',
        "icon": 'book-open-cover',
        "onTap": () {
          _closeDrawer();
          Get.toNamed(Routes.duasAndZiyarat);
        },
      },
    ];

    final List<Map<String, dynamic>> extraItems = [
      {
        "title": 'المفضلة',
        "icon": 'wishlist-star',
        "onTap": () {
          _closeDrawer();
          if (Get.isRegistered<BottomNavigationController>()) {
            Get.find<BottomNavigationController>().onItemTapped(1);
            if (Get.currentRoute != Routes.home) {
              Get.offAllNamed(Routes.home);
            }
          } else {
            Get.toNamed(Routes.favorites);
          }
        },
      },
      {
        "title": 'الإعدادات',
        "icon": 'settings',
        "onTap": () {
          _closeDrawer();
          if (Get.isRegistered<BottomNavigationController>()) {
            Get.find<BottomNavigationController>().onItemTapped(2);
            if (Get.currentRoute != Routes.home) {
              Get.offAllNamed(Routes.home);
            }
          } else {
            Get.to(() => SettingPage(isDrawer: true));
          }
        },
      },
      {
        "title": 'حول التطبيق',
        "icon": 'clipboard-user',
        "onTap": () {
          _closeDrawer();
          Get.to(() => const AboutPage(isDrawer: true));
        },
      },
      {
        "title": 'سياسة الخصوصية',
        "icon": 'confidential-discussion',
        "onTap": () {
          _closeDrawer();
          urlLauncher(
            ApiConstants.privacyPolicyUrl,
          );
        },
      },
      {
        "title": 'مشاركة التطبيق',
        "icon": 'share-square',
        "onTap": () {
          _closeDrawer();
          shareApp(context);
        },
      },
    ];

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.82,
      child: SafeArea(
        child: RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.only(
              top: 10,
              bottom: 14,
              right: 12,
              left: 6,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1C1C) : Colors.white,
              borderRadius: BorderRadius.circular(26),
              border: Border.all(
                color: isDark
                    ? Colors.white.withAlpha(22)
                    : brandColor.withAlpha(35),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 80 : 25),
                  blurRadius: 16,
                  offset: const Offset(-2, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                // 1. HEADER
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
                  decoration: BoxDecoration(
                    color: brandColor.withAlpha(isDark ? 25 : 15),
                    border: Border(
                      bottom: BorderSide(
                        color: isDark
                            ? Colors.white.withAlpha(12)
                            : brandColor.withAlpha(18),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(
                                    isDark ? 50 : 20,
                                  ),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              'assets/images/appIcon.png',
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              cacheWidth: 88,
                              cacheHeight: 88,
                            ),
                          ),
                          const Gap(12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تطبيق السراج',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBMPlexSansArabic',
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                'نورٌ وقربٌ وسكينة',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      ZoomTapAnimation(
                        onTap: _closeDrawer,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withAlpha(15)
                                : brandColor.withAlpha(12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: colorScheme.onSurface.withAlpha(180),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. SCROLLABLE MENU (Native 120 FPS Butter-Smooth with ListView.builder)
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    physics: const BouncingScrollPhysics(),
                    itemCount: mainFeatures.length + 1 + extraItems.length,
                    itemBuilder: (context, index) {
                      if (index == mainFeatures.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Divider(
                            height: 1,
                            color: isDark
                                ? Colors.white.withAlpha(16)
                                : brandColor.withAlpha(20),
                          ),
                        );
                      }

                      final isExtra = index > mainFeatures.length;
                      final item = isExtra
                          ? extraItems[index - mainFeatures.length - 1]
                          : mainFeatures[index];

                      return _buildDrawerItemTile(
                        title: item['title'],
                        icon: item['icon'],
                        onTap: item['onTap'],
                        brandColor: brandColor,
                        colorScheme: colorScheme,
                        isDark: isDark,
                      );
                    },
                  ),
                ),

                // 3. COMPACT FOOTER
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.black.withAlpha(25)
                        : brandColor.withAlpha(6),
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? Colors.white.withAlpha(10)
                            : brandColor.withAlpha(15),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'الإصدار ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                              TextSpan(
                                text: appVersionController
                                        .version.value.isNotEmpty
                                    ? appVersionController.version.value
                                    : '1.0.0',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: brandColor,
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      ZoomTapAnimation(
                        onTap: () => urlLauncher('https://dijlah.org'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withAlpha(10)
                                : brandColor.withAlpha(12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Dijlah IT',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: brandColor,
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                              const Gap(4),
                              Icon(
                                Icons.open_in_new_rounded,
                                size: 11,
                                color: brandColor,
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
        ),
      ),
    );
  }

  Widget _buildDrawerItemTile({
    required String title,
    required String icon,
    required VoidCallback onTap,
    required Color brandColor,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          splashColor: brandColor.withAlpha(20),
          highlightColor: brandColor.withAlpha(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.5),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha(10)
                        : brandColor.withAlpha(12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: SvgPicture.asset(
                    'assets/svgs/$icon.svg',
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(brandColor, BlendMode.srcIn),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'IBMPlexSansArabic',
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 11,
                  color: isDark
                      ? Colors.white.withAlpha(50)
                      : brandColor.withAlpha(80),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
