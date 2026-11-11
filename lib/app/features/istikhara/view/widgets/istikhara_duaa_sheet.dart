import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/istikhara/controller/istikhara_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class IstikharaDuaaSheet extends StatelessWidget {
  const IstikharaDuaaSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const IstikharaDuaaSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IstikharaController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 90 : 30),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black12,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withAlpha(isDark ? 40 : 20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      'آداب ودعاء الاستخارة',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                ZoomTapAnimation(
                  onTap: () => Get.back(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white10 : Colors.black.withAlpha(10),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Duaa Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF232020)
                          : colorScheme.onPrimary.withAlpha(12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: colorScheme.onPrimary.withAlpha(isDark ? 50 : 30),
                      ),
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
                                  Icons.menu_book_rounded,
                                  size: 17,
                                  color: colorScheme.onPrimary,
                                ),
                                const Gap(8),
                                Text(
                                  'دعاء الاستخارة المأثور',
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSansArabic',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                            ZoomTapAnimation(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: controller.duaaText.value));
                                Get.rawSnackbar(
                                  message: 'تم نسخ الدعاء إلى الحافظة',
                                  snackPosition: SnackPosition.BOTTOM,
                                  margin: const EdgeInsets.all(16),
                                  borderRadius: 12,
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.onPrimary.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.copy_rounded,
                                      size: 13,
                                      color: colorScheme.onPrimary,
                                    ),
                                    const Gap(4),
                                    Text(
                                      'نسخ',
                                      style: TextStyle(
                                        fontFamily: 'IBMPlexSansArabic',
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(12),
                        Obx(
                          () => Text(
                            controller.duaaText.value.isNotEmpty
                                ? controller.duaaText.value
                                : '«اللَّهُمَّ إِنِّي تَفَأَّلْتُ بِكِتَابِكَ، وَتَوَكَّلْتُ عَلَيْكَ، فَأَرِنِي مِنْ كِتَابِكَ مَا هُوَ مَكْتُومٌ مِنْ سِرِّكَ الْمَكْنُونِ فِي غَيْبِكَ، بِرَحْمَتِكَ يَا أَرْحَمَ الرَّاحِمِينَ»',
                            textAlign: TextAlign.justify,
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 15,
                              height: 1.8,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(20),

                  // 2. Etiquettes Title
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 18,
                        color: colorScheme.onPrimary,
                      ),
                      const Gap(8),
                      Text(
                        'شروط وآداب الاستخارة',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),

                  const Gap(12),

                  // List of etiquettes
                  Obx(() {
                    final items = controller.etiquettes;
                    return Column(
                      children: List.generate(items.length, (index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white10 : Colors.black.withAlpha(6),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: colorScheme.onPrimary.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSansArabic',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Text(
                                  items[index],
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSansArabic',
                                    fontSize: 13.5,
                                    height: 1.5,
                                    color: colorScheme.onSurface.withAlpha(220),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }
}
