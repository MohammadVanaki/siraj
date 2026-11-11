import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mawsueat/app/features/quran/data/models/reciter_model.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ReciterSelectorSheet extends StatelessWidget {
  final List<ReciterModel> reciters;
  final ReciterModel currentReciter;
  final ValueChanged<ReciterModel> onSelect;

  const ReciterSelectorSheet({
    super.key,
    required this.reciters,
    required this.currentReciter,
    required this.onSelect,
  });

  static Future<ReciterModel?> show(
    BuildContext context, {
    required List<ReciterModel> reciters,
    required ReciterModel currentReciter,
    required ValueChanged<ReciterModel> onSelect,
  }) {
    return showModalBottomSheet<ReciterModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReciterSelectorSheet(
        reciters: reciters,
        currentReciter: currentReciter,
        onSelect: onSelect,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary.withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.record_voice_over_rounded,
                      color: colorScheme.onPrimary,
                      size: 22,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اختيار القارئ',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'اختر القارئ المفضل لتلاوة السور والآيات المباركة',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // List of reciters
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                itemCount: reciters.length,
                separatorBuilder: (_, __) => const Gap(8),
                itemBuilder: (context, index) {
                  final item = reciters[index];
                  final isSelected = item.id == currentReciter.id;

                  return ZoomTapAnimation(
                    onTap: () {
                      onSelect(item);
                      Navigator.pop(context, item);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.onPrimary.withAlpha(20)
                            : (isDark
                                  ? Colors.white.withAlpha(8)
                                  : Colors.black.withAlpha(4)),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isSelected
                                ? colorScheme.onPrimary
                                : (isDark
                                      ? Colors.grey[600]
                                      : Colors.grey[400]),
                          ),
                          const Gap(14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.w600,
                                          fontFamily: 'IBMPlexSansArabic',
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    if (item.isAvailable)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withAlpha(25),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: Colors.green.withAlpha(60),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: Text(
                                          '${item.bitrateKbps} kbps',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                            fontFamily: 'IBMPlexSansArabic',
                                          ),
                                        ),
                                      )
                                    else
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withAlpha(25),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: Colors.amber.withAlpha(70),
                                            width: 0.8,
                                          ),
                                        ),
                                        child: const Text(
                                          'قريباً',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.amber,
                                            fontFamily: 'IBMPlexSansArabic',
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const Gap(3),
                                Text(
                                  item.subName,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colorScheme.onPrimary.withAlpha(200),
                                    fontFamily: 'IBMPlexSansArabic',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
