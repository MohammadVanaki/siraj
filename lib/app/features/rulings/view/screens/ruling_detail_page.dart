import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/widgets/custom_app_bar.dart';
import 'package:mawsueat/app/features/rulings/controller/rulings_controller.dart';
import 'package:mawsueat/app/features/rulings/data/models/ruling_model.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class RulingDetailPage extends StatefulWidget {
  final RulingModel ruling;

  const RulingDetailPage({super.key, required this.ruling});

  @override
  State<RulingDetailPage> createState() => _RulingDetailPageState();
}

class _RulingDetailPageState extends State<RulingDetailPage> {
  double _fontSize = 15.0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RulingsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final ruling = widget.ruling;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'تفاصيل الاستفتاء',
        actions: [
          // Font size decrease
          ZoomTapAnimation(
            onTap: () {
              if (_fontSize > 12) setState(() => _fontSize -= 1.5);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : colorScheme.onPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.text_decrease_rounded, size: 18, color: colorScheme.onPrimary),
            ),
          ),
          // Font size increase
          ZoomTapAnimation(
            onTap: () {
              if (_fontSize < 24) setState(() => _fontSize += 1.5);
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : colorScheme.onPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.text_increase_rounded, size: 18, color: colorScheme.onPrimary),
            ),
          ),
          // Share
          ZoomTapAnimation(
            onTap: () => controller.shareRuling(ruling),
            child: Container(
              margin: const EdgeInsets.only(left: 12, right: 4),
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : colorScheme.onPrimary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.share_rounded, size: 18, color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Marja & Category Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.onPrimary.withAlpha(isDark ? 45 : 25),
                      colorScheme.onPrimary.withAlpha(isDark ? 20 : 10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.onPrimary.withAlpha(isDark ? 60 : 35),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_rounded,
                        color: colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'وفقاً لفتوى سماحة:',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const Gap(2),
                          Text(
                            ruling.marjaName,
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          const Gap(2),
                          Text(
                            'الباب: ${ruling.categoryTitle} ${ruling.rulingNumber != null ? '(${ruling.rulingNumber})' : ''}',
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 11.5,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(16),

              // 2. Question Title & Content
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242020) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black.withAlpha(10),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 40 : 8),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                        const Gap(8),
                        Text(
                          'نص السؤال والاستفتاء',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    Text(
                      ruling.title,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: _fontSize + 1,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                        height: 1.5,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      ruling.question,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: _fontSize,
                        color: isDark ? Colors.grey[300] : Colors.grey[800],
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(16),

              // 3. Answer / Fatwa Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF242020) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colorScheme.onPrimary.withAlpha(isDark ? 60 : 40),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.onPrimary.withAlpha(isDark ? 30 : 15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: colorScheme.onPrimary,
                        ),
                        const Gap(8),
                        Text(
                          'الجواب والفتوى الشرعية',
                          style: TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    Text(
                      ruling.answer,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: _fontSize + 0.5,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(24),

              // Bottom Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ZoomTapAnimation(
                      onTap: () => controller.copyRuling(ruling),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                            Icon(Icons.copy_rounded, color: Colors.white, size: 18),
                            Gap(8),
                            Text(
                              'نسخ المسألة والجواب',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 14,
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
                  // Bookmark
                  ZoomTapAnimation(
                    onTap: () => controller.toggleBookmark(ruling),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white12 : Colors.grey[200],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        ruling.isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        color: ruling.isFavorite ? Colors.amber[700] : colorScheme.onPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const Gap(24),
            ],
          ),
        ),
      ),
    );
  }
}
