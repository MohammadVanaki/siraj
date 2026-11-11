import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/rulings/controller/rulings_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class MarjaSelectorBar extends StatelessWidget {
  const MarjaSelectorBar({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RulingsController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final maraji = controller.maraji;
      final selectedId = controller.selectedMarjaId.value;

      if (maraji.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: maraji.length,
          separatorBuilder: (_, __) => const Gap(8),
          itemBuilder: (context, index) {
            final marja = maraji[index];
            final isSelected = selectedId == marja.id;

            return ZoomTapAnimation(
              onTap: () => controller.selectMarja(marja.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : (isDark ? Colors.white10 : Colors.black.withAlpha(8)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : (isDark ? Colors.white12 : Colors.black12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_rounded,
                      size: 14,
                      color: isSelected ? Colors.white : colorScheme.onPrimary,
                    ),
                    const Gap(6),
                    Text(
                      marja.name,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}
