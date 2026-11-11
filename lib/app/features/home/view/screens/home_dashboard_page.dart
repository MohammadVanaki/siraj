import 'package:mawsueat/app/features/home/view/widgets/ornate_section_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import 'package:mawsueat/app/core/routes/routes.dart';
import 'package:mawsueat/app/features/home/view/widgets/custom_drawer.dart';
import 'package:mawsueat/app/features/home/view/widgets/home_feature_grid_item.dart';
import 'package:mawsueat/app/features/home/view/widgets/daily_hadith_marquee.dart';
import 'package:mawsueat/app/features/prayer_times/view/widgets/home_prayer_banner.dart';
import 'package:mawsueat/app/config/share_app.dart';
import 'package:mawsueat/app/features/about/view/screens/about_page.dart';
import 'package:mawsueat/app/features/favorite%20&%20comment/view/screens/favorite_page.dart';
import 'package:mawsueat/app/features/home/view/controller/bottom_navigation_controller.dart';
import 'package:mawsueat/app/features/home/view/widgets/floating_bottom_navigation_bar.dart';
import 'package:mawsueat/app/features/home/view/widgets/home_banner_slider.dart';
import 'package:mawsueat/app/features/home/view/widgets/home_chelleh_summary_card.dart';
import 'package:mawsueat/app/features/home/view/widgets/home_audio_player_card.dart';
import 'package:mawsueat/app/features/home/view/widgets/home_virtual_ziyarat_widget.dart';
import 'package:mawsueat/app/features/setting/view/screens/setting_page.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomeDashboardPage extends StatelessWidget {
  HomeDashboardPage({super.key});

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final BottomNavigationController navigationController = Get.put(
    BottomNavigationController(),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // List of the 13 defined features with high-resolution icons
    final List<Map<String, dynamic>> featuresList = [
      {
        "title": "القرآن الكريم",
        "subtitle": "المصحف الشريف والتلاوات",
        "icon": "assets/icons/Quran.png",
        "onTap": () => Get.toNamed(Routes.quran),
      },
      {
        "title": "موسوعة أهل البيت",
        "subtitle": "سيرة وتراث المعصومين (ع)",
        "icon": "assets/icons/Ahlul-Bayt-Encyclopedia.png",
        "onTap": () => Get.toNamed(Routes.mawsueat),
      },
      {
        "title": "المكتبة",
        "subtitle": "المكتبة الإسلامية والكتب",
        "icon": "assets/icons/Library.png",
        "onTap": () => Get.toNamed(Routes.library),
      },
      {
        "title": "نهج البلاغة",
        "subtitle": "خطب ورسائل أمير المؤمنين (ع)",
        "icon": "assets/icons/Nahj-al-Balagha.png",
        "onTap": () => Get.toNamed(Routes.nahj),
      },
      {
        "title": "مفاتيح الجنان",
        "subtitle": "الأدعية والزيارات والأعمال",
        "icon": "assets/icons/Mafatih-al-Jinan.png",
        "onTap": () => Get.toNamed(Routes.mafatihAlJinan),
      },
      {
        "title": "الصحيفة السجادية",
        "subtitle": "أدعية الإمام زين العابدين (ع)",
        "icon": "assets/icons/Sahifa-Sajjadiyya.png",
        "onTap": () => Get.toNamed(Routes.sahifaSajjadiyya),
      },
      {
        "title": "الأوقات الشرعية",
        "subtitle": "أوقات الصلاة والأذان",
        "icon": "assets/icons/Prayer-Times.png",
        "onTap": () => Get.toNamed(Routes.prayerTimes),
      },
      {
        "title": "اتجاه القبلة",
        "subtitle": "بوصلة تحديد اتجاه القبلة",
        "icon": "assets/icons/Qibla-Direction.png",
        "onTap": () => Get.toNamed(Routes.qibla),
      },
      {
        "title": "المسبحة",
        "subtitle": "المسبحة الإلكترونية والأذكار",
        "icon": "assets/icons/Tasbih.png",
        "onTap": () => Get.toNamed(Routes.misbaha),
      },
      {
        "title": "المناسبات",
        "subtitle": "التقويم والمناسبات الدينية",
        "icon": "assets/icons/Occasions.png",
        "onTap": () => Get.toNamed(Routes.occasions),
      },
      {
        "title": "الاستخارة",
        "subtitle": "الاستخارة بالقرآن الكريم",
        "icon": "assets/icons/Istikhara.png",
        "onTap": () => Get.toNamed(Routes.istikhara),
      },
      {
        "title": "الاستفتاءات",
        "subtitle": "الأحكام والفتاوى الشرعية",
        "icon": "assets/icons/Religious-Rulings.png",
        "onTap": () => Get.toNamed(Routes.rulings),
      },
      {
        "title": "الأربعين",
        "subtitle": "عهد الأربعين وختم الصلوات",
        "icon": "assets/icons/Arbaeen.png",
        "onTap": () => Get.toNamed(Routes.chelleh),
      },
      {
        "title": "معرض الصور",
        "subtitle": "الصور والخلفيات والمشاهد",
        "icon": "assets/icons/Gallery.png",
        "onTap": () => Get.toNamed(Routes.gallery),
      },
      {
        "title": "الأدعية والزيارات",
        "subtitle": "الأدعية المأثورة والزيارات المباركة",
        "icon": "assets/icons/Duas-and-Ziyarat.png",
        "onTap": () => Get.toNamed(Routes.duasAndZiyarat),
      },
    ];

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: colorScheme.surface,
      extendBody: true,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Obx(() {
          final selectedIndex = navigationController.selectedIndex.value;
          String title = Constants.appTitle;
          String subtitle = 'نورٌ وقربٌ وسكينة';

          if (selectedIndex == 1) {
            title = 'المفضلة';
            subtitle = 'العلامات المرجعية والتعليقات';
          } else if (selectedIndex == 2) {
            title = 'الإعدادات';
            subtitle = 'تخصيص الخطوط والمظهر والتطبيق';
          }

          return Row(
            children: [
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () {
                    scaffoldKey.currentState?.openDrawer();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(20)
                          : colorScheme.onPrimary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      'assets/svgs/menu-burger.svg',
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        colorScheme.onPrimary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Theme(
              data: theme.copyWith(
                popupMenuTheme: PopupMenuThemeData(
                  color: isDark ? const Color(0xFF2C2828) : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDark
                          ? Colors.white.withAlpha(25)
                          : colorScheme.onPrimary.withAlpha(30),
                    ),
                  ),
                  elevation: 6,
                  shadowColor: Colors.black.withAlpha(isDark ? 80 : 30),
                ),
              ),
              child: PopupMenuButton<String>(
                offset: const Offset(0, 48),
                elevation: 6,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 180),
                onSelected: (value) {
                  switch (value) {
                    case 'settings':
                      navigationController.onItemTapped(2);
                      break;
                    case 'favorites':
                      navigationController.onItemTapped(1);
                      break;
                    case 'about':
                      Get.to(() => const AboutPage(isDrawer: true));
                      break;
                    case 'share':
                      shareApp(context);
                      break;
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withAlpha(20)
                        : colorScheme.onPrimary.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.more_vert_rounded,
                    size: 20,
                    color: colorScheme.onPrimary,
                  ),
                ),
                itemBuilder: (context) => [
                  _buildPopupMenuItem(
                    value: 'settings',
                    iconPath: 'assets/svgs/settings.svg',
                    title: 'الإعدادات',
                    brandColor: colorScheme.onPrimary,
                    textColor: colorScheme.onSurface,
                  ),
                  _buildPopupMenuItem(
                    value: 'favorites',
                    iconPath: 'assets/svgs/wishlist-star.svg',
                    title: 'المفضلة',
                    brandColor: colorScheme.onPrimary,
                    textColor: colorScheme.onSurface,
                  ),
                  _buildPopupMenuItem(
                    value: 'about',
                    iconPath: 'assets/svgs/info.svg',
                    title: 'حول التطبيق',
                    brandColor: colorScheme.onPrimary,
                    textColor: colorScheme.onSurface,
                  ),
                  const PopupMenuDivider(),
                  _buildPopupMenuItem(
                    value: 'share',
                    iconPath: 'assets/svgs/share.svg',
                    title: 'مشاركة التطبيق',
                    brandColor: colorScheme.onPrimary,
                    textColor: colorScheme.onSurface,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      drawer: CustomDrawer(sliderDrawerKey: scaffoldKey),
      bottomNavigationBar: FloatingBottomNavigationBar(
        controller: navigationController,
      ),
      body: Obx(
        () => IndexedStack(
          index: navigationController.selectedIndex.value,
          children: [
            // TAB 0: HOME DASHBOARD
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 115),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. DAILY HADITH MARQUEE TICKER
                    const RepaintBoundary(child: DailyHadithMarquee()),

                    const Gap(14),

                    // 2. PRAYER TIMES LIVE QUICK BANNER (Directly under Daily Hadith)
                    const RepaintBoundary(child: HomePrayerBanner()),

                    const Gap(18),

                    // 3. FEATURED BANNER SLIDER (Directly under Prayer Times)
                    const RepaintBoundary(child: HomeBannerSlider()),

                    const Gap(22),

                    // 4. AUDIO PLAYER SECTION (کتیبه و پلیر صوتی تلاوت‌ها)
                    const OrnateSectionDivider(
                      title: 'تلاوات وأدعية مختارة',
                      icon: Icons.music_note_rounded,
                    ),
                    const Gap(10),
                    const RepaintBoundary(child: HomeAudioPlayerCard()),

                    const Gap(22),

                    // 5. APP FEATURES SECTION (کتیبه و بخش‌های ۱۵ گانه)
                    OrnateSectionDivider(
                      title: 'أقسام التطبيق',
                      icon: Icons.grid_view_rounded,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary.withAlpha(isDark ? 30 : 20),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: colorScheme.onPrimary.withAlpha(isDark ? 55 : 40),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          '${featuresList.length} قسماً',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    RepaintBoundary(
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: featuresList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.98,
                            ),
                        itemBuilder: (context, index) {
                          final item = featuresList[index];
                          return HomeFeatureGridItem(
                            title: item['title'],
                            subtitle: item['subtitle'],
                            iconPath: item['icon'],
                            onTap: item['onTap'],
                          );
                        },
                      ),
                    ),

                    const Gap(22),

                    // 6. VIRTUAL ZIYARAT SECTION (کتیبه و زیارت مجازی)
                    const OrnateSectionDivider(
                      title: 'الزيارة الافتراضية',
                      icon: Icons.mosque_rounded,
                    ),
                    const Gap(10),
                    const RepaintBoundary(child: HomeVirtualZiyaratWidget()),

                    const Gap(22),

                    // 7. CHELLEH SECTION (کتیبه و عهد الأربعين)
                    OrnateSectionDivider(
                      title: 'عهد الأربعين (الأربعينيات)',
                      icon: Icons.task_alt_rounded,
                      trailing: ZoomTapAnimation(
                        onTap: () => Get.toNamed(Routes.chelleh),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.onPrimary.withAlpha(isDark ? 30 : 20),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: colorScheme.onPrimary.withAlpha(isDark ? 55 : 40),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'التفاصيل',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBMPlexSansArabic',
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              const Gap(3),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 9,
                                color: colorScheme.onPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    const RepaintBoundary(child: HomeChellehSummaryCard()),

                    const Gap(36),
                  ],
                ),
              ),
            ),

            // TAB 1: FAVORITES
            const FavoritePage(isDrawer: false),

            // TAB 2: SETTINGS
            SettingPage(isDrawer: false),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem({
    required String value,
    required String iconPath,
    required String title,
    required Color brandColor,
    required Color textColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 42,
      child: Row(
        children: [
          SvgPicture.asset(
            iconPath,
            width: 17,
            height: 17,
            colorFilter: ColorFilter.mode(brandColor, BlendMode.srcIn),
          ),
          const Gap(12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'IBMPlexSansArabic',
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
