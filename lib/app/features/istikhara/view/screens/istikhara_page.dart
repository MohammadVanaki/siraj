import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/widgets/custom_app_bar.dart';
import 'package:mawsueat/app/core/common/widgets/custom_loading.dart';
import 'package:mawsueat/app/features/istikhara/controller/istikhara_controller.dart';
import 'package:mawsueat/app/features/istikhara/view/widgets/istikhara_duaa_sheet.dart';
import 'package:mawsueat/app/features/istikhara/view/widgets/istikhara_result_card.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class IstikharaPage extends StatelessWidget {
  const IstikharaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IstikharaController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'الاستخارة بالقرآن',
        actions: [
          ZoomTapAnimation(
            onTap: () => IstikharaDuaaSheet.show(context),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withAlpha(20)
                    : colorScheme.onPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 20,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          // 1. Loading state when taking Istikhara
          if (controller.isTakingIstikhara.value) {
            return _buildTakingIstikharaState(context, colorScheme, isDark);
          }

          // 2. Result state
          final result = controller.result.value;
          if (result != null) {
            return IstikharaResultCard(result: result);
          }

          // 3. Initial Niyyah / Start State
          return _buildInitialState(context, controller, colorScheme, isDark);
        }),
      ),
    );
  }

  Widget _buildInitialState(
    BuildContext context,
    IstikharaController controller,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          const Gap(10),

          // Central Icon Artwork
          Center(
            child: Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.onPrimary.withAlpha(isDark ? 30 : 15),
                border: Border.all(
                  color: colorScheme.onPrimary.withAlpha(isDark ? 60 : 40),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onPrimary.withAlpha(isDark ? 50 : 25),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/icons/Istikhara.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.auto_stories_rounded,
                  size: 54,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),

          const Gap(20),

          // Main Title
          Text(
            'طلب الخيرة من الله تعالى',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const Gap(8),

          // Instruction Text
          Text(
            'قال الإمام الصادق (ع): «ما استخار الله عبدٌ مؤمن إلا خار له وإن وقع ما يكره»',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),

          const Gap(24),

          // Steps & Etiquettes Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF242020) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black.withAlpha(10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? 40 : 8),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                        const Gap(8),
                        Text(
                          'خطوات الاستخارة المباركة',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    ZoomTapAnimation(
                      onTap: () => IstikharaDuaaSheet.show(context),
                      child: Text(
                        'الأدعية والآداب الكاملة',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimary,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const Gap(14),
                _buildStepRow(
                  number: '١',
                  text: 'النية الخالصة والتسليم لأمر الله وقضائه.',
                  colorScheme: colorScheme,
                ),
                const Gap(10),
                _buildStepRow(
                  number: '٢',
                  text: 'الصلاة على محمد وآل محمد وقراءة سورة التوحيد.',
                  colorScheme: colorScheme,
                ),
                const Gap(10),
                _buildStepRow(
                  number: '٣',
                  text: 'قراءة دعاء الاستخارة والضغط على زر الاستخارة أدناه.',
                  colorScheme: colorScheme,
                ),
              ],
            ),
          ),

          const Gap(32),

          // Big Call to Action Button
          ZoomTapAnimation(
            onTap: controller.takeIstikhara,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.onPrimary,
                    colorScheme.onPrimary.withAlpha(210),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.onPrimary.withAlpha(90),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  Gap(10),
                  Text(
                    'استخر بالله وتوكل',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Gap(20),
        ],
      ),
    );
  }

  Widget _buildStepRow({
    required String number,
    required String text,
    required ColorScheme colorScheme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.onPrimary.withAlpha(25),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
            ),
          ),
        ),
        const Gap(10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13,
              color: colorScheme.onSurface.withAlpha(210),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTakingIstikharaState(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.onPrimary.withAlpha(isDark ? 35 : 15),
              ),
              child: const CustomLoading(),
            ),
            const Gap(24),
            Text(
              'جارِ الاستخارة بكتاب الله...',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(8),
            Text(
              '«اللَّهُمَّ إِنِّي تَفَأَّلْتُ بِكِتَابِكَ، وَتَوَكَّلْتُ عَلَيْكَ»',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                color: colorScheme.onPrimary,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
