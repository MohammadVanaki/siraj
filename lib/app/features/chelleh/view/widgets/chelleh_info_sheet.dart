import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ChellehInfoSheet extends StatelessWidget {
  const ChellehInfoSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2226) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Gap(16),

          // Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 22,
                  color: colorScheme.onPrimary,
                ),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ما هي الأربعينيات؟',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'فضيلة المداومة ٤٠ يوماً وأسرارها المباركة',
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const Gap(16),
          const Divider(height: 1),
          const Gap(16),

          // Content Scroll
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.65,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionCard(
                    context: context,
                    icon: Icons.menu_book_rounded,
                    title: 'سرّ الأربعين في القرآن والحديث',
                    content:
                        'في التعاليم القرآنية والروايات الشريفة، يُعتبر الرقم أربعون محطة مباركة لكمال النفس واستجابة الدعاء ورسوخ الأعمال الصالحة.\n'
                        'قال تعالى: ﴿وَوَاعَدْنَا مُوسَىٰ ثَلَاثِينَ لَيْلَةً وَأَتْمَمْنَاهَا بِعَشْرٍ فَتَمَّ مِيقَاتُ رَبِّهِ أَرْبَعِينَ لَيْلَةً﴾.\n'
                        'وقال رسول الله (صلى الله عليه وآله): «مَنْ أَخْلَصَ لِلَّهِ أَرْبَعِينَ صَبَاحاً ظَهَرَتْ يَنَابِيعُ الْحِكْمَةِ مِنْ قَلْبِهِ عَلَى لِسَانِهِ».',
                    colorScheme: colorScheme,
                    isDark: isDark,
                  ),
                  const Gap(12),
                  _buildSectionCard(
                    context: context,
                    icon: Icons.volunteer_activism_rounded,
                    title: 'فضل أربعينية الصلوات المباركة',
                    content:
                        'الصلاة على محمد وآل محمد هي من أعظم الأوراد التي تُثقل الموازين، وتكشف الكروب، وتقضي الحوائج المتعسرة.\n'
                        'المداومة طيلة أربعين يوماً بقلب حاضر ونية صادقة تُحدث أثراً روحياً عميقاً وبركة ملموسة في تيسير الأمور وتطهير الروح.',
                    colorScheme: colorScheme,
                    isDark: isDark,
                  ),
                  const Gap(12),
                  _buildSectionCard(
                    context: context,
                    icon: Icons.checklist_rounded,
                    title: 'كيف تعمل الأربعينيات في التطبيق؟',
                    content:
                        '١. تحديد النية: ادخل على إعدادات الأربعينية (أيقونة الترس) وحدد نيتك الخاصة لقضاء الحاجة أو التوفيق.\n'
                        '٢. الورد اليومي: استخدم السبحة الإلكترونية لإتمام عدد صلوات اليوم المحدد.\n'
                        '٣. جدول الأيام: ستتحول الأيام المنجزة إلى اللون الأخضر تلقائياً لمتابعة تقدمك يوماً بعد يوم.\n'
                        '٤. التنبيه اليومي: يمكنك تفعيل منبه يومي في وقت محدد لتذكيرك بالورد وعدم فوات أي يوم.',
                    colorScheme: colorScheme,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ),

          const Gap(16),

          // Close button
          ZoomTapAnimation(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text(
                  'فهمت، بارك الله فيكم',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String content,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withAlpha(8)
            : colorScheme.onPrimary.withAlpha(10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onPrimary.withAlpha(isDark ? 25 : 30),
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.onPrimary),
              const Gap(8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const Gap(8),
          Text(
            content,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 12.5,
              height: 1.6,
              color: isDark ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
