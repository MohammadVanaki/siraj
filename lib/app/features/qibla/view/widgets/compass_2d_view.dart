import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../controller/qibla_controller.dart';

class Compass2dView extends StatelessWidget {
  final QiblaController controller;

  const Compass2dView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final double heading = controller.smoothedHeading.value;
      final double qiblaBearing = controller.qiblaBearing.value;
      final double diff = controller.angleDiff.value;
      final bool isAligned = controller.isAligned.value;
      final double distanceKm = controller.distanceToKaabaKm.value;

      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // بطاقة المسافة والدرجة العلوية
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 40 : 15),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isAligned
                        ? const Color(0xFF00E676)
                        : colorScheme.onPrimary.withAlpha(30),
                    width: isAligned ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _infoColumn(
                      'اتجاه القبلة',
                      '${qiblaBearing.toStringAsFixed(1)}°',
                      colorScheme.onPrimary,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.withAlpha(50),
                    ),
                    _infoColumn(
                      'المسافة إلى مكة',
                      '${distanceKm.toStringAsFixed(0)} كم',
                      colorScheme.onSurface,
                    ),
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.grey.withAlpha(50),
                    ),
                    _infoColumn(
                      'الاتجاه الحالي',
                      '${heading.toStringAsFixed(0)}°',
                      isAligned ? const Color(0xFF00E676) : Colors.amber[700]!,
                    ),
                  ],
                ),
              ),

              const Gap(32),

              // قرص البوصلة
              SizedBox(
                width: 310,
                height: 310,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. هالة خارجية تنبض بالأخضر عند الانطباق
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: isAligned
                            ? [
                                const BoxShadow(
                                  color: Color(0xFF00E676),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withAlpha(isDark ? 50 : 20),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                      ),
                    ),

                    // 2. قرص البوصلة الذي يدور مع اتجاه الهاتف
                    Transform.rotate(
                      angle: -heading * (math.pi / 180.0),
                      child: Container(
                        width: 290,
                        height: 290,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? const Color(0xFF181818) : Colors.white,
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withAlpha(20)
                                : Colors.black.withAlpha(15),
                            width: 2,
                          ),
                        ),
                        child: CustomPaint(
                          painter: _CompassDialPainter(
                            isDark: isDark,
                            primaryColor: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),

                    // 3. مؤشر اتجاه القبلة (سهم ومجسم الكعبة يدور نحو زاوية القبلة)
                    Transform.rotate(
                      angle: (qiblaBearing - heading) * (math.pi / 180.0),
                      child: SizedBox(
                        width: 270,
                        height: 270,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // خط السهم نحو القبلة
                            Positioned(
                              top: 25,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // مجسم الكعبة المشرفة في رأس السهم
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: isAligned
                                              ? const Color(0xFF00E676).withAlpha(180)
                                              : Colors.amber.withAlpha(140),
                                          blurRadius: 14,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: SvgPicture.asset(
                                      'assets/svgs/kaaba.svg',
                                    ),
                                  ),
                                  const Gap(4),
                                  // رأس السهم
                                  Icon(
                                    Icons.arrow_drop_up_rounded,
                                    size: 32,
                                    color: isAligned
                                        ? const Color(0xFF00E676)
                                        : Colors.amber[700],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // 4. مركز البوصلة الثابت
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isAligned
                            ? const Color(0xFF00E676)
                            : colorScheme.onPrimary,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(60),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(32),

              // رسالة الحالة السفلية
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: isAligned
                      ? const Color(0xFF00E676).withAlpha(isDark ? 40 : 25)
                      : (isDark ? const Color(0xFF1E1E1E) : Colors.white),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isAligned
                        ? const Color(0xFF00E676)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAligned ? Icons.check_circle_rounded : Icons.explore_rounded,
                      color: isAligned ? const Color(0xFF00E676) : colorScheme.onPrimary,
                      size: 20,
                    ),
                    const Gap(10),
                    Text(
                      isAligned
                          ? 'أنت الآن تواجه القبلة المشرفة بدقة'
                          : (diff > 0
                              ? 'أدر الهاتف يميناً بمقدار ${diff.toStringAsFixed(0)}°'
                              : 'أدر الهاتف يساراً بمقدار ${diff.abs().toStringAsFixed(0)}°'),
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isAligned
                            ? (isDark ? const Color(0xFF69F0AE) : const Color(0xFF00A352))
                            : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _infoColumn(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 11,
            color: Colors.grey,
          ),
        ),
        const Gap(4),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  final bool isDark;
  final Color primaryColor;

  _CompassDialPainter({required this.isDark, required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paintTick = Paint()
      ..color = isDark ? Colors.white.withAlpha(70) : Colors.black.withAlpha(60)
      ..strokeCap = StrokeCap.round;

    final paintMajorTick = Paint()
      ..color = isDark ? Colors.white.withAlpha(180) : Colors.black.withAlpha(160)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    // رسم علامات وتدريجات البوصلة (كل 5 درجات)
    for (int i = 0; i < 360; i += 5) {
      final angle = i * (math.pi / 180.0);
      final bool isMajor = (i % 30 == 0);
      final double tickLength = isMajor ? 12.0 : 6.0;

      final startX = center.dx + (radius - 12) * math.sin(angle);
      final startY = center.dy - (radius - 12) * math.cos(angle);
      final endX = center.dx + (radius - 12 - tickLength) * math.sin(angle);
      final endY = center.dy - (radius - 12 - tickLength) * math.cos(angle);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        isMajor ? paintMajorTick : paintTick,
      );
    }

    // رسم الحروف الرئيسية (N, S, E, W)
    _drawDirectionText(canvas, center, radius - 36, 'N', Colors.red, isBold: true);
    _drawDirectionText(canvas, center, radius - 36, 'S', isDark ? Colors.white70 : Colors.black87, angle: 180);
    _drawDirectionText(canvas, center, radius - 36, 'E', isDark ? Colors.white70 : Colors.black87, angle: 90);
    _drawDirectionText(canvas, center, radius - 36, 'W', isDark ? Colors.white70 : Colors.black87, angle: 270);
  }

  void _drawDirectionText(
    Canvas canvas,
    Offset center,
    double r,
    String text,
    Color color, {
    double angle = 0,
    bool isBold = false,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: isBold ? 15 : 13,
          fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
          fontFamily: 'IBMPlexSansArabic',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final rad = angle * (math.pi / 180.0);
    final x = center.dx + r * math.sin(rad) - (textPainter.width / 2);
    final y = center.dy - r * math.cos(rad) - (textPainter.height / 2);

    textPainter.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
