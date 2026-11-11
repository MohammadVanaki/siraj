import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// ویجت اختصاصی جداکننده و کتیبه بخش‌های صفحه هوم (طرح کپسولی اسلیمی با امواج طلایی/رنگ تم)
class OrnateSectionDivider extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final Color? tintColor;
  final VoidCallback? onTap;

  const OrnateSectionDivider({
    super.key,
    required this.title,
    this.icon = Icons.music_note_rounded,
    this.trailing,
    this.tintColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    // رنگ تم دینامیک برنامه (بر اساس پالت رنگ انتخابی کاربر)
    final brandColor = tintColor ?? colorScheme.onPrimary;

    // رنگ پس‌زمینه کپسول میانی
    final capsuleBg = isDark
        ? const Color(0xFF1E211E)
        : const Color(0xFFFDFBF7);

    final capsuleBorder = brandColor.withAlpha(isDark ? 160 : 130);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          // عرض کپسول میانی با توجه به عرض صفحه‌نمایش
          final capsuleWidth = math.min(totalWidth * 0.82, 310.0);
          const capsuleHeight = 48.0;
          const borderWidth = 1.25;

          return SizedBox(
            width: totalWidth,
            height: 56,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // ۱. پس‌زمینه: امواج خطی شناور و تذهیب‌های بالا و پایین
                Positioned.fill(
                  child: CustomPaint(
                    painter: _OrnateWavesAndCrestPainter(
                      color: brandColor,
                      capsuleWidth: capsuleWidth,
                      isDark: isDark,
                    ),
                  ),
                ),

                // ۲. کتیبه کپسولی میانی (Center Stadium Capsule)
                Center(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(capsuleHeight / 2),
                      child: SizedBox(
                        width: capsuleWidth,
                        height: capsuleHeight,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // ۱. پس‌زمینه و کادر کلی کپسول
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: capsuleBg,
                                  borderRadius:
                                      BorderRadius.circular(capsuleHeight / 2),
                                  border: Border.all(
                                    color: capsuleBorder,
                                    width: borderWidth,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: brandColor.withAlpha(isDark ? 28 : 20),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withAlpha(isDark ? 50 : 12),
                                      blurRadius: 5,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // ۲. نشان دایره‌ای آیکون: کاملاً مماس و فیکس روی لبه راست بدون هیچ فاصله داخلی
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              width: capsuleHeight,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark
                                      ? const Color(0xFF282B28)
                                      : Colors.white,
                                  border: Border.all(
                                    color: brandColor.withAlpha(isDark ? 180 : 150),
                                    width: 1.2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: brandColor.withAlpha(isDark ? 25 : 18),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1.5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    icon,
                                    size: 22,
                                    color: brandColor,
                                  ),
                                ),
                              ),
                            ),

                            // ۳. دکمه یا بج انتخابی در سمت چپ
                            if (trailing != null)
                              Positioned(
                                left: 10,
                                child: trailing!,
                              ),

                            // ۴. متن عنوان کتیبه (کاملاً متقارن و در مرکز کتیبه)
                            Positioned(
                              left: trailing != null ? 76.0 : capsuleHeight,
                              right: capsuleHeight,
                              child: Text(
                                title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: 'IBMPlexSansArabic',
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1E211E),
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// نقاش اختصاصی امواج خطی ظریف (Harmonic Silk Waves) و نشان تذهیب اسلیمی بالا و پایین
class _OrnateWavesAndCrestPainter extends CustomPainter {
  final Color color;
  final double capsuleWidth;
  final bool isDark;

  const _OrnateWavesAndCrestPainter({
    required this.color,
    required this.capsuleWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final centerY = size.height / 2;
    final centerX = size.width / 2;

    // نقاط شروع امواج از لبه‌های کپسول
    final capsuleHalf = capsuleWidth / 2;
    final leftOrigin = centerX - capsuleHalf + 16;
    final rightOrigin = centerX + capsuleHalf - 16;

    // ۱. رسم امواج ظریف خطی با محوشدگی نرم گرادینت و همگرایی نوک (Harmonic Waves)
    _drawFlowingWaves(
      canvas: canvas,
      startX: leftOrigin,
      endX: 8.0,
      centerY: centerY,
      isLeft: true,
    );

    _drawFlowingWaves(
      canvas: canvas,
      startX: rightOrigin,
      endX: size.width - 8.0,
      centerY: centerY,
      isLeft: false,
    );

    // ۲. رسم نشان تذهیب/تاج اسلیمی در بالا و پایین مرکز کتیبه (Top & Bottom Crests)
    _drawIslamicCrest(
      canvas: canvas,
      center: Offset(centerX, centerY - 24),
      isTop: true,
    );

    _drawIslamicCrest(
      canvas: canvas,
      center: Offset(centerX, centerY + 24),
      isTop: false,
    );
  }

  /// رسم باند خطوط موج‌گونه متحرک و ابریشمی با محو شدن تدریجی (Gradient Fade-out) و همگرایی نوک
  void _drawFlowingWaves({
    required Canvas canvas,
    required double startX,
    required double endX,
    required double centerY,
    required bool isLeft,
  }) {
    final distance = (endX - startX).abs();
    if (distance < 15) return;

    const lineCount = 13;
    final baseAlpha = isDark ? 130 : 110;

    for (int i = 0; i < lineCount; i++) {
      final normalized = (i - (lineCount / 2)) / (lineCount / 2);
      final spread = normalized * 7.5;
      final opacityRatio = (1.0 - (normalized.abs() * 0.45)).clamp(0.2, 1.0);

      // گرادینت خطی در طول مسیر موج:
      // از زیر کپسول (0%) به صورت نرم آغاز شده، در میانه اوج گرفته و قبل از رسیدن به انتها کاملاً محو (0%) می‌شود
      final lineShader = ui.Gradient.linear(
        Offset(startX, centerY),
        Offset(endX, centerY),
        [
          color.withAlpha(0),
          color.withAlpha((baseAlpha * opacityRatio * 0.75).round()),
          color.withAlpha((baseAlpha * opacityRatio).round()),
          color.withAlpha((baseAlpha * opacityRatio * 0.35).round()),
          color.withAlpha(0), // در انتها شفافیت ۱۰۰٪ و بدون برش تیز
        ],
        const [0.0, 0.18, 0.45, 0.78, 1.0],
      );

      final paint = Paint()
        ..shader = lineShader
        ..style = PaintingStyle.stroke
        ..strokeWidth = (0.75 + (1.0 - normalized.abs()) * 0.25).clamp(0.65, 1.0);

      final path = Path();
      // نقطه شروع از زیر کپسول با فاصله متناسب
      path.moveTo(startX, centerY + spread * 0.30);

      // انحنای ملایم و ابریشمی (Harmonic Bezier)
      final dir = isLeft ? 1.0 : -1.0;
      final cp1x = startX + (endX - startX) * 0.32;
      final cp1y = centerY - (10.5 * dir) + spread * 1.4;

      final cp2x = startX + (endX - startX) * 0.68;
      final cp2y = centerY + (9.5 * dir) + spread * 0.5;

      // همگرایی خطوط به سمت نقطه مرکزی در انتها (Tapered convergence) تا خطوط مثل قلم مو یا تار ابریشم جمع شوند
      final targetY = centerY + spread * 0.08;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, endX, targetY);
      canvas.drawPath(path, paint);
    }
  }

  /// رسم ترنج/تاج اسلیمی ظریف در بالا و پایین کپسول
  void _drawIslamicCrest({
    required Canvas canvas,
    required Offset center,
    required bool isTop,
  }) {
    final dir = isTop ? -1.0 : 1.0;

    final fillPaint = Paint()
      ..color = color.withAlpha(isDark ? 95 : 75)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = color.withAlpha(isDark ? 190 : 170)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    // گلبرگ سه شاخه اسلیمی
    final path = Path();
    path.moveTo(center.dx - 13, center.dy);

    // بال چپ
    path.quadraticBezierTo(
      center.dx - 9,
      center.dy + dir * 3.5,
      center.dx - 4,
      center.dy + dir * 2,
    );

    // قله مرکزی
    path.quadraticBezierTo(
      center.dx - 1.5,
      center.dy + dir * 7.5,
      center.dx,
      center.dy + dir * 8.5,
    );

    // بال راست
    path.quadraticBezierTo(
      center.dx + 1.5,
      center.dy + dir * 7.5,
      center.dx + 4,
      center.dy + dir * 2,
    );

    path.quadraticBezierTo(
      center.dx + 9,
      center.dy + dir * 3.5,
      center.dx + 13,
      center.dy,
    );

    // بازگشت به لبه کپسول
    path.quadraticBezierTo(
      center.dx,
      center.dy - dir * 1.5,
      center.dx - 13,
      center.dy,
    );

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // نگین یا نقطه نوک تاج اسلیمی
    final dotPaint = Paint()
      ..color = color.withAlpha(isDark ? 220 : 200)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(center.dx, center.dy + dir * 11),
      1.5,
      dotPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrnateWavesAndCrestPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.capsuleWidth != capsuleWidth ||
        oldDelegate.isDark != isDark;
  }
}
