import 'package:flutter/material.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class FortyDaysMatrix extends StatelessWidget {
  final List<int> completedDays;
  final int activeDay;
  final int totalDays;
  final List<int> missedDays;
  final Function(int dayNumber) onDayTap;

  const FortyDaysMatrix({
    super.key,
    required this.completedDays,
    required this.activeDay,
    this.totalDays = 40,
    this.missedDays = const [],
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final effectiveTotalDays = totalDays > 0 ? totalDays : 40;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2226) : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.onPrimary.withAlpha(isDark ? 40 : 25),
          width: 1.2,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: colorScheme.onPrimary.withAlpha(8),
                  blurRadius: 10,
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
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.teal.withAlpha(isDark ? 50 : 30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.grid_view_rounded,
                      size: 16,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    effectiveTotalDays == 40
                        ? 'مسار الأربعين يوماً'
                        : 'مسار العهد ($effectiveTotalDays يوماً)',
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${completedDays.length} / $effectiveTotalDays يوم',
                  style: const TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: effectiveTotalDays,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index + 1;
              final isCompleted = completedDays.contains(dayNumber);
              final isCurrentActive = dayNumber == activeDay;
              final isLocked = dayNumber > activeDay;
              final isMissed = missedDays.contains(dayNumber);

              Color bgColor;
              Color textColor;
              Border? border;

              if (isCompleted) {
                bgColor = Colors.teal;
                textColor = Colors.white;
              } else if (isCurrentActive) {
                bgColor = colorScheme.onPrimary.withAlpha(isDark ? 50 : 30);
                textColor = colorScheme.onPrimary;
                border = Border.all(
                  color: colorScheme.onPrimary,
                  width: 2,
                );
              } else if (isMissed) {
                bgColor = isDark
                    ? Colors.amber.withAlpha(20)
                    : Colors.amber.withAlpha(25);
                textColor = isDark ? Colors.amber[300]! : Colors.amber[900]!;
                border = Border.all(
                  color: Colors.amber.shade700,
                  width: 1.2,
                );
              } else if (isLocked) {
                bgColor = isDark
                    ? Colors.white.withAlpha(5)
                    : Colors.grey.withAlpha(20);
                textColor = isDark ? Colors.white24 : Colors.grey.shade400;
              } else {
                bgColor = isDark
                    ? Colors.white.withAlpha(10)
                    : colorScheme.onPrimary.withAlpha(15);
                textColor = isDark ? Colors.grey[400]! : Colors.grey[700]!;
              }

              return ZoomTapAnimation(
                onTap: () => onDayTap(dayNumber),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: border,
                    boxShadow: isCompleted
                        ? [
                            BoxShadow(
                              color: Colors.teal.withAlpha(70),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                          )
                        : isLocked
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    size: 13,
                                    color: isDark
                                        ? Colors.white24
                                        : Colors.grey.shade400,
                                  ),
                                  Text(
                                    '$dayNumber',
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexSansArabic',
                                      fontSize: 11,
                                      color: isDark
                                        ? Colors.white24
                                        : Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              )
                            : isMissed
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '$dayNumber',
                                        style: TextStyle(
                                          fontFamily: 'IBMPlexSansArabic',
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                        ),
                                      ),
                                      Icon(
                                        Icons.priority_high_rounded,
                                        size: 11,
                                        color: textColor,
                                      ),
                                    ],
                                  )
                                : Text(
                                    '$dayNumber',
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexSansArabic',
                                      fontSize: 14,
                                      fontWeight: isCurrentActive
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: textColor,
                                    ),
                                  ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          // Legend
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              _legendItem(
                color: Colors.teal,
                label: 'تم الإنجاز',
                isDark: isDark,
              ),
              _legendItem(
                color: colorScheme.onPrimary,
                label: 'اليوم الحالي',
                isDark: isDark,
                hasBorder: true,
              ),
              if (missedDays.isNotEmpty)
                _legendItem(
                  color: Colors.amber,
                  label: 'يوم فائت',
                  isDark: isDark,
                  hasBorder: true,
                ),
              _legendItem(
                color: isDark ? Colors.white24 : Colors.grey[400]!,
                label: 'مقفل 🔒',
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem({
    required Color color,
    required String label,
    required bool isDark,
    bool hasBorder = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: hasBorder ? color.withAlpha(50) : color,
            borderRadius: BorderRadius.circular(3),
            border: hasBorder ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 11,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

