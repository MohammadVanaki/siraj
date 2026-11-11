import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/misbaha/controller/misbaha_controller.dart';
import 'package:mawsueat/app/features/misbaha/model/dhikr_item.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class DhikrSelectionSheet extends StatelessWidget {
  const DhikrSelectionSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const DhikrSelectionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = MisbahaController.to;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 90 : 40),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(12),
            // Handle bar
            Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const Gap(16),

            // Header title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.format_list_bulleted_rounded,
                    color: colorScheme.onPrimary,
                    size: 22,
                  ),
                  const Gap(10),
                  Text(
                    'اختر الذكر أو الورد',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            const Divider(height: 16),

            // Quick target options (33, 99, 100, Free)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Obx(() {
                final currentTarget = controller.effectiveTarget;
                return Row(
                  children: [
                    _buildTargetChip(context, label: '٣٣', value: 33, selected: currentTarget == 33),
                    const Gap(8),
                    _buildTargetChip(context, label: '٩٩', value: 99, selected: currentTarget == 99),
                    const Gap(8),
                    _buildTargetChip(context, label: '١٠٠', value: 100, selected: currentTarget == 100),
                    const Gap(8),
                    _buildTargetChip(context, label: 'مفتوح', value: 0, selected: currentTarget == 0),
                  ],
                );
              }),
            ),

            const Gap(8),

            // Dhikr items list
            Flexible(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: DhikrItem.defaultList.length,
                separatorBuilder: (context, index) => const Gap(8),
                itemBuilder: (context, index) {
                  final item = DhikrItem.defaultList[index];
                  return Obx(() {
                    final isSelected = controller.selectedDhikr.value.id == item.id;
                    return ZoomTapAnimation(
                      onTap: () {
                        controller.selectDhikr(item);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colorScheme.onPrimary.withAlpha(isDark ? 40 : 25)
                              : (isDark ? Colors.white.withAlpha(8) : Colors.grey[100]),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.onPrimary
                                : (isDark ? Colors.white10 : Colors.grey[300]!),
                            width: isSelected ? 1.5 : 0.8,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? colorScheme.onPrimary
                                    : (isDark ? Colors.white12 : Colors.grey[200]),
                              ),
                              child: Icon(
                                isSelected ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                                size: 16,
                                color: isSelected ? Colors.white : Colors.grey,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexSansArabic',
                                      fontSize: 15,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                  if (item.subtitle != null) ...[
                                    const Gap(2),
                                    Text(
                                      item.subtitle!,
                                      style: TextStyle(
                                        fontFamily: 'IBMPlexSansArabic',
                                        fontSize: 11,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (item.target > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white12 : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${item.target}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'IBMPlexSansArabic',
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
            const Gap(12),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetChip(
    BuildContext context, {
    required String label,
    required int value,
    required bool selected,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = MisbahaController.to;

    return Expanded(
      child: ZoomTapAnimation(
        onTap: () {
          controller.setCustomTarget(value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.onPrimary
                : (isDark ? Colors.white.withAlpha(12) : Colors.grey[200]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: selected
                  ? Colors.white
                  : (isDark ? Colors.grey[300] : Colors.grey[800]),
            ),
          ),
        ),
      ),
    );
  }
}
