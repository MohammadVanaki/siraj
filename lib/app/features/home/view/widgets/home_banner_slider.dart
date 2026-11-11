import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/routes/routes.dart';
import 'package:mawsueat/app/features/home/view/screens/feature_placeholder_page.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomeBannerSlider extends StatefulWidget {
  const HomeBannerSlider({super.key});

  @override
  State<HomeBannerSlider> createState() => _HomeBannerSliderState();
}

class _HomeBannerSliderState extends State<HomeBannerSlider> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoPlayTimer;

  final List<Map<String, dynamic>> _sliderItems = [
    {
      'tag': 'القسم التخصصي',
      'title': 'موسوعة أهل البيت',
      'subtitle': 'المكتبة الشاملة والبحوث والموضوعات التخصصية',
      'buttonText': 'دخول الموسوعة',
      'icon': 'assets/icons/Ahlul-Bayt-Encyclopedia.png',
      'gradientLight': [
        const Color(0xFF6B1426),
        const Color(0xFF9E2A40),
      ],
      'gradientDark': [
        const Color(0xFF4A0E1A),
        const Color(0xFF2A0910),
      ],
      'onTap': () => Get.toNamed(Routes.mawsueat),
    },
    {
      'tag': 'المصحف المبارك',
      'title': 'القرآن الكريم',
      'subtitle': 'تصفح السور والآيات الكريمة والتلاوات العطرة',
      'buttonText': 'تصفح المصحف',
      'icon': 'assets/icons/Quran.png',
      'gradientLight': [
        const Color(0xFF0F5A47),
        const Color(0xFF1E8267),
      ],
      'gradientDark': [
        const Color(0xFF0A3D30),
        const Color(0xFF05241C),
      ],
      'onTap': () => Get.toNamed(Routes.quran),
    },
    {
      'tag': 'تراث أمير المؤمنين',
      'title': 'نهج البلاغة الشريف',
      'subtitle': 'خطب ورسائل ومواعظ وحكم الإمام علي (ع)',
      'buttonText': 'استكشاف الحِكَم',
      'icon': 'assets/icons/Nahj-al-Balagha.png',
      'gradientLight': [
        const Color(0xFF8B5E14),
        const Color(0xFFB88228),
      ],
      'gradientDark': [
        const Color(0xFF5A3C0B),
        const Color(0xFF332104),
      ],
      'onTap': () => Get.toNamed(Routes.nahj),
    },
    {
      'tag': 'الأدعية والزيارات',
      'title': 'مفاتيح الجنان',
      'subtitle': 'الأدعية اليومية، المناجاة وزيارات العتبات المقدسة',
      'buttonText': 'قراءة الأدعية',
      'icon': 'assets/icons/Mafatih-al-Jinan.png',
      'gradientLight': [
        const Color(0xFF1B4965),
        const Color(0xFF2B6E94),
      ],
      'gradientDark': [
        const Color(0xFF113247),
        const Color(0xFF091C28),
      ],
      'onTap': () => Get.toNamed(Routes.mafatihAlJinan),
    },
    {
      'tag': 'المشاريع الولائية',
      'title': 'مشروع عهد الأربعين',
      'subtitle': 'برنامج ختم الصلوات ومتابعة الأوراد اليومية المباركة',
      'buttonText': 'متابعة العهد',
      'icon': 'assets/icons/Arbaeen.png',
      'gradientLight': [
        const Color(0xFF7A1C30),
        const Color(0xFFA52843),
      ],
      'gradientDark': [
        const Color(0xFF501220),
        const Color(0xFF2E0912),
      ],
      'onTap': () => Get.toNamed(Routes.chelleh),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _sliderItems.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = theme.colorScheme.onPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 152,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            itemCount: _sliderItems.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final item = _sliderItems[index];
              final gradientColors = isDark
                  ? item['gradientDark'] as List<Color>
                  : item['gradientLight'] as List<Color>;

              return ZoomTapAnimation(
                onTap: item['onTap'] as VoidCallback,
                begin: 1.0,
                end: 0.98,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: gradientColors,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark ? Colors.black : gradientColors.first)
                            .withAlpha(isDark ? 80 : 50),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Decorative glowing background circles
                        Positioned(
                          left: -25,
                          top: -25,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withAlpha(isDark ? 10 : 22),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 60,
                          bottom: -35,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withAlpha(isDark ? 8 : 16),
                            ),
                          ),
                        ),

                        // Card Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                          child: Row(
                            children: [
                              // Text & Action details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Tag pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(isDark ? 28 : 40),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.star_rounded,
                                            size: 13,
                                            color: Colors.amberAccent,
                                          ),
                                          const Gap(4),
                                          Text(
                                            item['tag'] as String,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'IBMPlexSansArabic',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Title & Subtitle
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          item['title'] as String,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 17.5,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'IBMPlexSansArabic',
                                            letterSpacing: 0.2,
                                          ),
                                        ),
                                        const Gap(2),
                                        Text(
                                          item['subtitle'] as String,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white.withAlpha(225),
                                            fontSize: 11,
                                            fontFamily: 'IBMPlexSansArabic',
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Action button pill
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            item['buttonText'] as String,
                                            style: TextStyle(
                                              color: gradientColors.first,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'IBMPlexSansArabic',
                                            ),
                                          ),
                                          const Gap(4),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            size: 13,
                                            color: gradientColors.first,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Gap(12),

                              // High-res Icon Avatar
                              Container(
                                width: 78,
                                height: 78,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(isDark ? 22 : 35),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(50),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(isDark ? 50 : 25),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Image.asset(
                                  item['icon'] as String,
                                  fit: BoxFit.contain,
                                  cacheWidth: 156,
                                  cacheHeight: 156,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const Gap(10),

        // Indicator Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_sliderItems.length, (index) {
            final isSelected = _currentPage == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isSelected ? 20 : 6,
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: isSelected
                    ? brandColor
                    : (isDark
                        ? Colors.white.withAlpha(40)
                        : brandColor.withAlpha(35)),
              ),
            );
          }),
        ),
      ],
    );
  }
}
