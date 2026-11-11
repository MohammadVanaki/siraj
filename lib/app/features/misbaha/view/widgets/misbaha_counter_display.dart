import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/misbaha/controller/misbaha_controller.dart';

class MisbahaCounterDisplay extends StatelessWidget {
  const MisbahaCounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = MisbahaController.to;

    return Obx(() {
      final current = controller.currentCount.value;
      final target = controller.effectiveTarget;
      final rounds = controller.roundCount.value;
      final total = controller.totalCount.value;
      final displayedDhikr = controller.displayedDhikrText;
      final zahraPhase = controller.currentZahraPhase;
      final beadTheme = controller.selectedTheme.value;

      final double progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withAlpha(10)
              : colorScheme.onPrimary.withAlpha(12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? Colors.white.withAlpha(16)
                : colorScheme.onPrimary.withAlpha(25),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: beadTheme.glowColor.withAlpha(isDark ? 20 : 12),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dhikr Title
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                displayedDhikr,
                key: ValueKey<String>(displayedDhikr),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                  height: 1.25,
                ),
              ),
            ),

            if (zahraPhase.isNotEmpty) ...[
              const Gap(4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: beadTheme.glowColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  zahraPhase,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : colorScheme.onPrimary,
                  ),
                ),
              ),
            ],

            const Gap(6),

            // Big Count Number with animated scale
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    '$current',
                    key: ValueKey<int>(current),
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'IBMPlexSansArabic',
                      color: colorScheme.onPrimary,
                      letterSpacing: -1.0,
                      shadows: [
                        Shadow(
                          color: beadTheme.glowColor.withAlpha(70),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                  ),
                ),
                if (target > 0) ...[
                  const Gap(6),
                  Text(
                    '/ $target',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ],
              ],
            ),

            // Progress bar if target is set
            if (target > 0) ...[
              const Gap(6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 5,
                  backgroundColor: isDark
                      ? Colors.white.withAlpha(18)
                      : colorScheme.onPrimary.withAlpha(20),
                  valueColor: AlwaysStoppedAnimation<Color>(beadTheme.glowColor),
                ),
              ),
            ],

            const Gap(10),

            // Statistics badges: Rounds & Total
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBadge(
                  context: context,
                  label: 'الدورات',
                  value: '$rounds',
                  icon: Icons.repeat_rounded,
                ),
                const Gap(10),
                _buildBadge(
                  context: context,
                  label: 'المجموع الكلي',
                  value: '$total',
                  icon: Icons.all_inclusive_rounded,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBadge({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(12) : Colors.black.withAlpha(6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: theme.colorScheme.onPrimary,
          ),
          const Gap(5),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'IBMPlexSansArabic',
              color: theme.colorScheme.onSurface.withAlpha(190),
            ),
          ),
        ],
      ),
    );
  }
}
