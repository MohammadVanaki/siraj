import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/config/get_version.dart';
import 'package:mawsueat/app/config/launch_url.dart';
import 'package:mawsueat/app/config/share_app.dart';
import 'package:mawsueat/app/core/common/constants/api_constants.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key, this.isDrawer = true});

  final bool isDrawer;

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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: isDrawer
          ? AppBar(
              backgroundColor: colorScheme.surface,
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: colorScheme.onSurface,
                ),
                onPressed: () => Get.back(),
              ),
              title: Text(
                'حول التطبيق',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                  color: colorScheme.onSurface,
                ),
              ),
              actions: [
                IconButton(
                  tooltip: 'مشاركة التطبيق',
                  icon: Icon(
                    Icons.share_rounded,
                    size: 20,
                    color: brandColor,
                  ),
                  onPressed: () => shareApp(context),
                ),
                const Gap(4),
              ],
            )
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(10),

              // 1. APP LOGO & BRANDING HEADER
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: brandColor.withAlpha(isDark ? 60 : 35),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 70 : 15),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withAlpha(35)
                              : brandColor.withAlpha(60),
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/images/appIcon.png',
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        cacheWidth: 192,
                        cacheHeight: 192,
                      ),
                    ),
                    const Gap(16),
                    Text(
                      'تطبيق السراج',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBMPlexSansArabic',
                        color: colorScheme.onSurface,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Gap(8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: brandColor.withAlpha(isDark ? 28 : 18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: brandColor.withAlpha(45),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        'رفيقك في رحاب القرآن والدعاء',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          color: brandColor,
                        ),
                      ),
                    ),
                    const Gap(8),
                    Obx(() {
                      final version = appVersionController.version.value;
                      return Text(
                        version.isNotEmpty ? 'الإصدار $version' : 'الإصدار 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontFamily: 'IBMPlexSansArabic',
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const Gap(24),

              // 2. CARD 1: OVERVIEW
              _buildInfoCard(
                context: context,
                icon: Icons.info_outline_rounded,
                title: 'عن التطبيق',
                content:
                    'تطبيق السراج هو تطبيق إسلامي شامل، يجمع بين القرآن الكريم والأدعية والزيارات والأذكار والأعمال العبادية في منصة واحدة، ليكون رفيقك اليومي في رحلتك الإيمانية، ويعينك على التواصل الدائم مع الله تعالى وتعزيز ارتباطك بالقيم الروحية والتعاليم الإسلامية الأصيلة.',
              ),

              const Gap(16),

              // 3. CARD 2: CONTENT & FEATURES
              _buildInfoCard(
                context: context,
                icon: Icons.auto_stories_rounded,
                title: 'المحتوى والخدمات',
                content:
                    'يقدّم التطبيق محتوى دينيًا متنوعًا ومنظمًا، يشمل تلاوة القرآن الكريم، والأدعية المأثورة، وزيارات المعصومين (عليهم السلام)، والأذكار اليومية، والتعقيبات، وأعمال الأيام والليالي والمناسبات الدينية، إلى جانب المواقيت الشرعية، ضمن واجهة سهلة الاستخدام وتصميم مريح يتيح الوصول إلى المحتوى بكل يسر وسلاسة.',
                extraWidget: Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureTag(context, 'القرآن الكريم'),
                      _buildFeatureTag(context, 'الأدعية والزيارات'),
                      _buildFeatureTag(context, 'مفاتيح الجنان'),
                      _buildFeatureTag(context, 'الصحيفة السجادية'),
                      _buildFeatureTag(context, 'نهج البلاغة'),
                      _buildFeatureTag(context, 'الأوقات الشرعية'),
                      _buildFeatureTag(context, 'المسبحة الإلكترونية'),
                      _buildFeatureTag(context, 'الاستخارة'),
                    ],
                  ),
                ),
              ),

              const Gap(16),

              // 4. CARD 3: VISION
              _buildInfoCard(
                context: context,
                icon: Icons.lightbulb_outline_rounded,
                title: 'رؤيتنا ورسالتنا',
                content:
                    'يسعى السراج إلى أن يكون مكتبتك العبادية المتكاملة، ومصدرًا موثوقًا للمحتوى الروحي، يجمع بين أصالة الموروث الإسلامي وسهولة التقنيات الحديثة، ليبقى نورًا يرافقك في كل وقت ومكان.',
              ),

              const Gap(20),

              // 5. SLOGAN BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      brandColor.withAlpha(isDark ? 30 : 20),
                      brandColor.withAlpha(isDark ? 15 : 10),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: brandColor.withAlpha(isDark ? 45 : 35),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: brandColor.withAlpha(isDark ? 20 : 10),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: brandColor.withAlpha(isDark ? 40 : 25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.format_quote_rounded,
                        color: brandColor,
                        size: 22,
                      ),
                    ),
                    const Gap(14),
                    Expanded(
                      child: Text(
                        'السراج… نورٌ يهديك، وذِكرٌ يرافقك.',
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          color: isDark ? Colors.white : brandColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(20),

              // 6. DEVELOPER & COPYRIGHT CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF221F20) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(24)
                        : brandColor.withAlpha(35),
                    width: 1.3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 60 : 12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'برمجة وتصميم',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'دجلة لتقنية المعلومات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBMPlexSansArabic',
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Gap(2),
                    Text(
                      'Dijlah IT',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'IBMPlexSansArabic',
                        color: brandColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Gap(16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ZoomTapAnimation(
                          onTap: () => urlLauncher('https://dijlah.org'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: brandColor.withAlpha(isDark ? 28 : 18),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: brandColor.withAlpha(45),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.language_rounded,
                                  size: 16,
                                  color: brandColor,
                                ),
                                const Gap(6),
                                Text(
                                  'الموقع الرسمي',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'IBMPlexSansArabic',
                                    color: brandColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Gap(10),
                        ZoomTapAnimation(
                          onTap: () => urlLauncher(ApiConstants.privacyPolicyUrl),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withAlpha(12)
                                  : Colors.grey.withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withAlpha(20)
                                    : Colors.grey.withAlpha(40),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.privacy_tip_outlined,
                                  size: 16,
                                  color: colorScheme.onSurface.withAlpha(180),
                                ),
                                const Gap(6),
                                Text(
                                  'سياسة الخصوصية',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'IBMPlexSansArabic',
                                    color: colorScheme.onSurface.withAlpha(180),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(14),
                    Text(
                      'جميع الحقوق محفوظة © 2026',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    Widget? extraWidget,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF221F20) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(24)
              : brandColor.withAlpha(35),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 60 : 12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          if (!isDark)
            BoxShadow(
              color: brandColor.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      brandColor,
                      brandColor.withAlpha(200),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: brandColor.withAlpha(60),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
              ),
              const Gap(12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            content,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.85,
              letterSpacing: 0.2,
              fontFamily: 'IBMPlexSansArabic',
              color: colorScheme.onSurface.withAlpha(isDark ? 220 : 200),
            ),
          ),
          if (extraWidget != null) extraWidget,
        ],
      ),
    );
  }

  Widget _buildFeatureTag(BuildContext context, String title) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = theme.colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(10)
            : brandColor.withAlpha(10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(18)
              : brandColor.withAlpha(25),
          width: 0.9,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: brandColor,
            ),
          ),
          const Gap(6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              fontFamily: 'IBMPlexSansArabic',
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
