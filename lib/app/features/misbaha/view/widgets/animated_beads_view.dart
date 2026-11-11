import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/misbaha/controller/misbaha_controller.dart';
import 'package:mawsueat/app/features/misbaha/model/bead_theme.dart';

class AnimatedBeadsView extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedBeadsView({super.key, required this.onTap});

  @override
  State<AnimatedBeadsView> createState() => _AnimatedBeadsViewState();
}

class _AnimatedBeadsViewState extends State<AnimatedBeadsView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _animation;
  final MisbahaController controller = Get.find<MisbahaController>();

  double _dragAccumulator = 0.0;
  Worker? _beadWorker;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 170),
      value: 1.0,
    );

    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );

    // Listen to bead step notifications from controller
    _beadWorker = ever(controller.beadStepNotifier, (_) {
      _triggerBeadStep();
    });
  }

  void _triggerBeadStep() {
    if (!mounted) return;
    _animController.stop();
    _animController.reset();
    _animController.forward();
  }

  @override
  void dispose() {
    _beadWorker?.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    _dragAccumulator += details.primaryDelta ?? 0;
    // Dragging right to left (negative delta) advances the bead from right to left
    if (_dragAccumulator < -24.0 || _dragAccumulator > 36.0) {
      _dragAccumulator = 0.0;
      widget.onTap();
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    _dragAccumulator = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
      onHorizontalDragEnd: _handleHorizontalDragEnd,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final animProgress = _animation.value;
          return Obx(() {
            final count = controller.currentCount.value;
            final beadTheme = controller.selectedTheme.value;
            return CustomPaint(
              painter: HorizontalBeadsPainter(
                count: count,
                animProgress: animProgress,
                isDark: isDark,
                beadTheme: beadTheme,
              ),
              child: const SizedBox.expand(),
            );
          });
        },
      ),
    );
  }
}

class HorizontalBeadsPainter extends CustomPainter {
  final int count;
  final double animProgress;
  final bool isDark;
  final BeadTheme beadTheme;

  HorizontalBeadsPainter({
    required this.count,
    required this.animProgress,
    required this.isDark,
    required this.beadTheme,
  });

  /// Mathematical curve for the thread:
  /// y(x) = centerY + sag * (1 - u^2) where u = (x - centerX) / (width / 2)
  double _getCurveY(
    double x,
    double centerX,
    double centerY,
    double width,
    double sag,
  ) {
    final double u = ((x - centerX) / (width / 2)).clamp(-1.0, 1.0);
    return centerY + sag * (1.0 - (u * u));
  }

  /// Tangent angle theta of the thread at position x
  double _getCurveAngle(double x, double centerX, double width, double sag) {
    final double halfW = width / 2;
    final double u = ((x - centerX) / halfW).clamp(-1.0, 1.0);
    final double slope = -2.0 * sag * u / halfW;
    return math.atan(slope);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double centerX = width / 2;
    final double centerY = height / 2;

    const double beadRadius = 26.0;
    const double beadSpacing = 66.0;

    // Natural catenary sag of the string in the center
    const double sag = 18.0;

    // 1. Center Counting Focal Glow (Static in the center)
    final double centerThreadY = _getCurveY(
      centerX,
      centerX,
      centerY,
      width,
      sag,
    );
    final glowPaint = Paint()
      ..color = beadTheme.glowColor.withAlpha(isDark ? 38 : 22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    canvas.drawCircle(
      Offset(centerX, centerThreadY),
      beadRadius * 2.2,
      glowPaint,
    );

    final centerRingPaint = Paint()
      ..color = beadTheme.threadColor.withAlpha(isDark ? 55 : 35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(
      Offset(centerX, centerThreadY),
      beadRadius * 1.7,
      centerRingPaint,
    );

    // Subtle pointer indicators top and bottom of center focus
    final pointerPaint = Paint()
      ..color = beadTheme.threadColor.withAlpha(isDark ? 160 : 130)
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(centerX, centerThreadY - beadRadius * 1.6),
      Offset(centerX, centerThreadY - beadRadius * 1.15),
      pointerPaint,
    );
    canvas.drawLine(
      Offset(centerX, centerThreadY + beadRadius * 1.6),
      Offset(centerX, centerThreadY + beadRadius * 1.15),
      pointerPaint,
    );

    // 2. Continuous STATIC Thread (خيط المسبحة الثابت بالكامل)
    // This thread is 100% static; only the beads slide along it!
    final Path threadPath = Path();
    threadPath.moveTo(0, centerY);
    threadPath.quadraticBezierTo(
      centerX,
      centerY + (2.0 * sag),
      width,
      centerY,
    );

    // Thread shadow (Static)
    final threadShadowPaint = Paint()
      ..color = Colors.black.withAlpha(isDark ? 80 : 35)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.translate(0, 3.5);
    canvas.drawPath(threadPath, threadShadowPaint);
    canvas.restore();

    // Main thread cord (Static)
    final threadPaint = Paint()
      ..color = beadTheme.threadColor.withAlpha(isDark ? 170 : 210)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(threadPath, threadPaint);

    // Static end anchors at screen borders (محابس الخيط الثابتة على الحواف)
    final anchorPaint = Paint()
      ..color = beadTheme.threadColor.withAlpha(isDark ? 190 : 230)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(6, centerY), 4.5, anchorPaint);
    canvas.drawCircle(Offset(width - 6, centerY), 4.5, anchorPaint);

    // 3. Draw Moving Beads along the static thread
    // Beads move strictly from RIGHT to LEFT into the central focal point
    const int visibleSlots = 8;
    final double slideShift = (1.0 - animProgress) * beadSpacing;

    for (int j = -visibleSlots; j <= visibleSlots; j++) {
      final int beadNumber = count + j;
      final double xPos = centerX + (j * beadSpacing) + slideShift;

      // Skip beads outside horizontal bounds
      if (xPos < -beadRadius * 2 || xPos > width + beadRadius * 2) {
        continue;
      }

      // Compute exact Y along the thread using identical function
      final double yPos = _getCurveY(xPos, centerX, centerY, width, sag);

      // Compute exact tangent angle of thread at this position
      final double angle = _getCurveAngle(xPos, centerX, width, sag);

      // Perspective scale: beads in center are larger, edge beads are smaller
      final double distFromCenterX = (xPos - centerX).abs();
      final double maxDistX = width / 2;
      final double normalizedDistX = (distFromCenterX / maxDistX).clamp(
        0.0,
        1.0,
      );
      final double scale = 1.0 - (normalizedDistX * 0.3);
      final double currentRadius = beadRadius * scale;
      final double opacity = (1.0 - (normalizedDistX * 0.7)).clamp(0.15, 1.0);

      // Separator bead (شاهد / فاصلة) every 33 beads
      final bool isSeparator = (beadNumber > 0 && beadNumber % 33 == 0);

      _drawHorizontalBead(
        canvas: canvas,
        center: Offset(xPos, yPos),
        angle: angle,
        radius: currentRadius,
        opacity: opacity,
        isSeparator: isSeparator,
      );
    }
  }

  void _drawHorizontalBead({
    required Canvas canvas,
    required Offset center,
    required double angle,
    required double radius,
    required double opacity,
    required bool isSeparator,
  }) {
    canvas.save();

    // 1. Determine effective bead radius (separator beads are dainty and smaller)
    final double effectiveRadius = isSeparator ? radius * 0.58 : radius;

    // Soft drop shadow under the bead (drawn in global space)
    final shadowPaint = Paint()
      ..color = Colors.black.withAlpha((isDark ? 85 : 45 * opacity).toInt())
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, effectiveRadius * 0.4);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + effectiveRadius * 0.42),
        width: effectiveRadius * 2.3,
        height: effectiveRadius * 1.5,
      ),
      shadowPaint,
    );

    // 2. Rotate canvas around the bead center to match the exact tangent angle of the thread
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    final List<Color> colors = isSeparator
        ? beadTheme.separatorColors
        : beadTheme.beadColors;

    // 3. Draw 3D Spherical Gradient Bead Body
    final sphereGradient = RadialGradient(
      center: const Alignment(-0.35, -0.45),
      radius: 0.88,
      colors: colors
          .map((c) => c.withAlpha((c.alpha * opacity).toInt()))
          .toList(),
      stops: const [0.0, 0.4, 0.82, 1.0],
    );

    final beadPaint = Paint()
      ..shader = sphereGradient.createShader(
        Rect.fromCircle(center: Offset.zero, radius: effectiveRadius),
      )
      ..style = PaintingStyle.fill;

    // Draw bead sphere
    canvas.drawCircle(Offset.zero, effectiveRadius, beadPaint);

    if (isSeparator) {
      // Dainty golden ornamental center ring on the separator bead
      final ringPaint = Paint()
        ..color = const Color(0xFFFFDF79).withAlpha((220 * opacity).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1;
      canvas.drawCircle(Offset.zero, effectiveRadius * 0.55, ringPaint);
    }

    // 4. Thread Hole Rings (حلقات ثقوب الخرز)
    final double holeX = effectiveRadius * 0.95;
    final double collarWidth = effectiveRadius * 0.18;
    final double collarHeight = effectiveRadius * 0.42;

    final collarPaint = Paint()
      ..color = (isSeparator ? const Color(0xFFFFDF79) : beadTheme.threadColor)
          .withAlpha((220 * opacity).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSeparator ? 1.1 : 1.5;

    // Left hole collar
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-holeX, 0),
        width: collarWidth,
        height: collarHeight,
      ),
      collarPaint,
    );

    // Right hole collar
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(holeX, 0),
        width: collarWidth,
        height: collarHeight,
      ),
      collarPaint,
    );

    // 5. Specular glossy highlight (بريق الحبة اللامع)
    final highlightPaint = Paint()
      ..color = Colors.white.withAlpha((210 * opacity).toInt())
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-effectiveRadius * 0.30, -effectiveRadius * 0.32),
        width: effectiveRadius * 0.46,
        height: effectiveRadius * 0.26,
      ),
      highlightPaint,
    );

    // 6. Subtle bottom rim light
    final rimPaint = Paint()
      ..color = colors[0].withAlpha((70 * opacity).toInt())
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSeparator ? 1.0 : 1.5;
    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: effectiveRadius * 0.9),
      0.5,
      2.0,
      false,
      rimPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant HorizontalBeadsPainter oldDelegate) {
    return oldDelegate.animProgress != animProgress ||
        oldDelegate.count != count ||
        oldDelegate.isDark != isDark ||
        oldDelegate.beadTheme.id != beadTheme.id;
  }
}
