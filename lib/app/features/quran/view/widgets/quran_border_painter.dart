import 'package:flutter/material.dart';

class QuranBorderPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final bool isDark;

  const QuranBorderPainter({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // 1. Draw Page Background
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final primaryPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final primaryFillPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final secondaryPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final secondaryFillPaint = Paint()
      ..color = secondaryColor
      ..style = PaintingStyle.fill;

    // Margins and measurements
    const margin = 2.0;
    const bandWidth = 13.0; // The ornate ribbon band width

    final outerRect = Rect.fromLTWH(
      margin,
      margin,
      size.width - 2 * margin,
      size.height - 2 * margin,
    );
    // Draw outer boundary line
    canvas.drawRect(outerRect, primaryPaint);

    // Inner boundary line of the band
    final innerBandRect = Rect.fromLTWH(
      outerRect.left + bandWidth,
      outerRect.top + bandWidth,
      outerRect.width - 2 * bandWidth,
      outerRect.height - 2 * bandWidth,
    );
    canvas.drawRect(innerBandRect, primaryPaint);

    // Subtle tint background for the band itself
    final bandBgPaint = Paint()
      ..color = isDark
          ? primaryColor.withAlpha(25)
          : primaryColor.withAlpha(15)
      ..style = PaintingStyle.fill;

    // Paint band background paths (4 strips)
    canvas.drawRect(
      Rect.fromLTWH(outerRect.left, outerRect.top, outerRect.width, bandWidth),
      bandBgPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        outerRect.left,
        outerRect.bottom - bandWidth,
        outerRect.width,
        bandWidth,
      ),
      bandBgPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        outerRect.left,
        outerRect.top + bandWidth,
        bandWidth,
        outerRect.height - 2 * bandWidth,
      ),
      bandBgPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        outerRect.right - bandWidth,
        outerRect.top + bandWidth,
        bandWidth,
        outerRect.height - 2 * bandWidth,
      ),
      bandBgPaint,
    );

    // Paint the interlocking geometric pattern inside the 4 strips
    _paintPatternBand(
      canvas,
      outerRect,
      bandWidth,
      primaryPaint,
      primaryFillPaint,
      secondaryPaint,
      secondaryFillPaint,
    );

    // Inner double decorative frame (with 3.5px spacing)
    const innerGap = 3.5;
    final innerThinRect = Rect.fromLTWH(
      innerBandRect.left + innerGap,
      innerBandRect.top + innerGap,
      innerBandRect.width - 2 * innerGap,
      innerBandRect.height - 2 * innerGap,
    );
    canvas.drawRect(innerThinRect, secondaryPaint);
  }

  void _paintPatternBand(
    Canvas canvas,
    Rect outerRect,
    double bandWidth,
    Paint primaryPaint,
    Paint primaryFill,
    Paint secondaryPaint,
    Paint secondaryFill,
  ) {
    final step = bandWidth;

    // 1. CORNER SQUARES
    final corners = [
      Rect.fromLTWH(outerRect.left, outerRect.top, bandWidth, bandWidth),
      Rect.fromLTWH(
        outerRect.right - bandWidth,
        outerRect.top,
        bandWidth,
        bandWidth,
      ),
      Rect.fromLTWH(
        outerRect.left,
        outerRect.bottom - bandWidth,
        bandWidth,
        bandWidth,
      ),
      Rect.fromLTWH(
        outerRect.right - bandWidth,
        outerRect.bottom - bandWidth,
        bandWidth,
        bandWidth,
      ),
    ];

    for (final corner in corners) {
      _paintCornerRosette(
        canvas,
        corner,
        primaryPaint,
        primaryFill,
        secondaryFill,
      );
    }

    // 2. TOP HORIZONTAL STRIP
    final topStartX = outerRect.left + bandWidth;
    final topEndX = outerRect.right - bandWidth;
    final topY = outerRect.top;
    _paintHorizontalChain(
      canvas,
      topStartX,
      topEndX,
      topY,
      bandWidth,
      step,
      primaryPaint,
      secondaryFill,
    );

    // 3. BOTTOM HORIZONTAL STRIP
    final bottomY = outerRect.bottom - bandWidth;
    _paintHorizontalChain(
      canvas,
      topStartX,
      topEndX,
      bottomY,
      bandWidth,
      step,
      primaryPaint,
      secondaryFill,
    );

    // 4. LEFT VERTICAL STRIP
    final leftStartY = outerRect.top + bandWidth;
    final leftEndY = outerRect.bottom - bandWidth;
    final leftX = outerRect.left;
    _paintVerticalChain(
      canvas,
      leftStartY,
      leftEndY,
      leftX,
      bandWidth,
      step,
      primaryPaint,
      secondaryFill,
    );

    // 5. RIGHT VERTICAL STRIP
    final rightX = outerRect.right - bandWidth;
    _paintVerticalChain(
      canvas,
      leftStartY,
      leftEndY,
      rightX,
      bandWidth,
      step,
      primaryPaint,
      secondaryFill,
    );
  }

  void _paintCornerRosette(
    Canvas canvas,
    Rect corner,
    Paint primaryPaint,
    Paint primaryFill,
    Paint secondaryFill,
  ) {
    final cx = corner.center.dx;
    final cy = corner.center.dy;
    final half = corner.width / 2;

    // Corner diagonal cross lines
    canvas.drawLine(
      Offset(corner.left, corner.top),
      Offset(corner.right, corner.bottom),
      primaryPaint,
    );
    canvas.drawLine(
      Offset(corner.left, corner.bottom),
      Offset(corner.right, corner.top),
      primaryPaint,
    );

    // Rotated diamond
    final diamondPath = Path()
      ..moveTo(cx, cy - half * 0.75)
      ..lineTo(cx + half * 0.75, cy)
      ..lineTo(cx, cy + half * 0.75)
      ..lineTo(cx - half * 0.75, cy)
      ..close();
    canvas.drawPath(diamondPath, primaryPaint);

    // Center rosette dot
    canvas.drawCircle(Offset(cx, cy), 1.8, secondaryFill);
  }

  void _paintHorizontalChain(
    Canvas canvas,
    double startX,
    double endX,
    double topY,
    double bandWidth,
    double step,
    Paint primaryPaint,
    Paint secondaryFill,
  ) {
    final totalWidth = endX - startX;
    if (totalWidth <= 0) return;
    final count = (totalWidth / step).floor();
    if (count <= 0) return;
    final adjustedStep = totalWidth / count;
    final midY = topY + bandWidth / 2;

    for (int i = 0; i < count; i++) {
      final x1 = startX + i * adjustedStep;
      final x2 = x1 + adjustedStep;
      final xm = (x1 + x2) / 2;

      // Interlocking Diamond Path
      final path = Path()
        ..moveTo(xm, topY)
        ..lineTo(x2, midY)
        ..lineTo(xm, topY + bandWidth)
        ..lineTo(x1, midY)
        ..close();
      canvas.drawPath(path, primaryPaint);

      // Center decorative dot
      canvas.drawCircle(Offset(xm, midY), 1.4, secondaryFill);
    }
  }

  void _paintVerticalChain(
    Canvas canvas,
    double startY,
    double endY,
    double leftX,
    double bandWidth,
    double step,
    Paint primaryPaint,
    Paint secondaryFill,
  ) {
    final totalHeight = endY - startY;
    if (totalHeight <= 0) return;
    final count = (totalHeight / step).floor();
    if (count <= 0) return;
    final adjustedStep = totalHeight / count;
    final midX = leftX + bandWidth / 2;

    for (int i = 0; i < count; i++) {
      final y1 = startY + i * adjustedStep;
      final y2 = y1 + adjustedStep;
      final ym = (y1 + y2) / 2;

      // Interlocking Diamond Path
      final path = Path()
        ..moveTo(midX, y1)
        ..lineTo(leftX + bandWidth, ym)
        ..lineTo(midX, y2)
        ..lineTo(leftX, ym)
        ..close();
      canvas.drawPath(path, primaryPaint);

      // Center decorative dot
      canvas.drawCircle(Offset(midX, ym), 1.4, secondaryFill);
    }
  }

  @override
  bool shouldRepaint(covariant QuranBorderPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.isDark != isDark;
  }
}

