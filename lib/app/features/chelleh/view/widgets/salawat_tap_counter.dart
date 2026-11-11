import 'package:flutter/material.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SalawatTapCounter extends StatelessWidget {
  final int currentCount;
  final int targetCount;
  final bool isCompleted;
  final String? dhikrTitle;
  final String? dhikrText;
  final VoidCallback onTap;
  final VoidCallback onReset;
  final Function(int target) onTargetChange;

  const SalawatTapCounter({
    super.key,
    required this.currentCount,
    required this.targetCount,
    required this.isCompleted,
    this.dhikrTitle,
    this.dhikrText,
    required this.onTap,
    required this.onReset,
    required this.onTargetChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final progress = targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

    final List<int> targetOptions = targetCount <= 10
        ? [1, 3, 5, 10]
        : (targetCount <= 100 ? [33, 70, 100] : [100, 500, 1000]);

    final String displayText = dhikrText != null && dhikrText!.trim().isNotEmpty
        ? (dhikrText!.length > 100
            ? '${dhikrText!.substring(0, 95)}...'
            : dhikrText!)
        : '«اللّهُمَّ صَلِّ عَلی مُحَمَّدٍ وَ آلِ مُحَمَّدٍ»';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2226) : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted
              ? Colors.teal.withAlpha(isDark ? 90 : 60)
              : colorScheme.onPrimary.withAlpha(isDark ? 40 : 25),
          width: isCompleted ? 1.5 : 1.2,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: isCompleted
                      ? Colors.teal.withAlpha(15)
                      : colorScheme.onPrimary.withAlpha(8),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: Column(
        children: [
          // Header of Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dhikrTitle ?? 'ورد اليوم',
                style: TextStyle(
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              // Target Selector Chips
              Row(
                children: targetOptions.map((t) {
                  final isSelected = targetCount == t;
                  return ZoomTapAnimation(
                    onTap: () => onTargetChange(t),
                    child: Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : (isDark ? Colors.white12 : Colors.grey[200]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$t',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Dhikr Arabic Text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withAlpha(8)
                  : colorScheme.onPrimary.withAlpha(12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              displayText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isCompleted ? Colors.teal : colorScheme.onPrimary,
                height: 1.6,
              ),
            ),
          ),


          const SizedBox(height: 22),

          // Big Interactive Tap Disc with Circular Progress
          ZoomTapAnimation(
            onTap: onTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer Progress Indicator
                SizedBox(
                  width: 170,
                  height: 170,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    backgroundColor: isDark
                        ? Colors.white12
                        : colorScheme.onPrimary.withAlpha(20),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCompleted ? Colors.teal : colorScheme.onPrimary,
                    ),
                  ),
                ),

                // Center Disc
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isCompleted
                          ? [
                              Colors.teal.shade700,
                              Colors.teal.shade900,
                            ]
                          : [
                              colorScheme.onPrimary,
                              colorScheme.onPrimary.withAlpha(190),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isCompleted ? Colors.teal : colorScheme.onPrimary)
                            .withAlpha(60),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$currentCount',
                        style: const TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'من $targetCount',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 12,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isCompleted ? 'تم إنجاز اليوم ✓' : 'المس للعد',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? Colors.amberAccent
                              : Colors.white.withAlpha(220),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          if (isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.teal.withAlpha(isDark ? 35 : 20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withAlpha(50)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_top_rounded, size: 16, color: Colors.teal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'أتممت صلوات اليوم! سيتوفر اليوم التالي غداً إن شاء الله',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Bottom Action: Reset Today
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: currentCount > 0 ? onReset : null,
                icon: Icon(
                  Icons.refresh_rounded,
                  size: 16,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
                label: Text(
                  'تصفير عداد اليوم',
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
