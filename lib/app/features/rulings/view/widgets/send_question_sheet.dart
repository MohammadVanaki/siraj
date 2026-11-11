import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/rulings/controller/rulings_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SendQuestionSheet extends StatefulWidget {
  const SendQuestionSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SendQuestionSheet(),
    );
  }

  @override
  State<SendQuestionSheet> createState() => _SendQuestionSheetState();
}

class _SendQuestionSheetState extends State<SendQuestionSheet> {
  final _questionController = TextEditingController();
  final _contactController = TextEditingController();
  int _selectedMarja = 1;
  int _selectedCategory = 1;

  @override
  void dispose() {
    _questionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RulingsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const Gap(14),

            // Header
            Row(
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
                        Icons.edit_note_rounded,
                        color: colorScheme.onPrimary,
                        size: 22,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      'إرسال استفتاء شرعي',
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
                  onTap: () => Navigator.of(context).pop(),
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

            const Gap(18),

            // Select Marja Dropdown / Selector
            Text(
              'اختر المرجع:',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withAlpha(6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedMarja,
                  isExpanded: true,
                  dropdownColor: theme.scaffoldBackgroundColor,
                  items: controller.maraji
                      .where((m) => m.id != 0)
                      .map((m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(
                              m.name,
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 13.5,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedMarja = val);
                  },
                ),
              ),
            ),

            const Gap(14),

            // Question text
            Text(
              'نص السؤال / الاستفتاء:',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withAlpha(6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: TextField(
                controller: _questionController,
                maxLines: 4,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 13.5,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'اكتب تفاصيل المسألة الشرعية بوضوح...',
                  hintStyle: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            const Gap(14),

            // Contact info
            Text(
              'وسيلة التواصل للرد (اختياري - بريد إلكتروني أو هاتف):',
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 12,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            const Gap(6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.black.withAlpha(6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? Colors.white12 : Colors.black12,
                ),
              ),
              child: TextField(
                controller: _contactController,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 13,
                  color: colorScheme.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'example@email.com / +964...',
                  hintStyle: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[500],
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),

            const Gap(22),

            // Submit Button
            ZoomTapAnimation(
              onTap: () async {
                if (_questionController.text.trim().isEmpty) {
                  Get.rawSnackbar(
                    message: 'يرجى كتابة نص الاستفتاء أولاً',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                  );
                  return;
                }

                final success = await controller.sendQuestion(
                  marjaId: _selectedMarja,
                  categoryId: _selectedCategory,
                  question: _questionController.text.trim(),
                  contact: _contactController.text.trim(),
                );

                if (success) {
                  if (context.mounted) Navigator.of(context).pop();
                  Get.rawSnackbar(
                    message: 'تم إرسال الاستفتاء بنجاح، ستتم الإجابة قريباً إن شاء الله',
                    snackPosition: SnackPosition.BOTTOM,
                    margin: const EdgeInsets.all(16),
                    borderRadius: 12,
                    duration: const Duration(seconds: 3),
                  );
                }
              },
              child: Container(
                width: double.infinity,
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
                    Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    Gap(8),
                    Text(
                      'إرسال السؤال',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }
}
