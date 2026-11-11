import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

/// ویجت نمایش جلد کتاب با افکت سه‌بعدی واقعی (3D Book Cover)
/// با پشتیبانی کامل از راست‌چین (RTL برای کتاب‌های فارسی/عربی):
/// ۱. عطف کتاب در سمت راست با سایه، هایلایت استوانه‌ای و خط تاخوردگی عطف (Spine & Hinge Crease)
/// ۲. ضخامت صفحات کتاب در سمت چپ با رنگ و خطوط کاغذ (Paper Page Stack Thickness)
/// ۳. لبه جلد پشتی کتاب (Back Cover Rim)
/// ۴. انعکاس نور و براق بودن سلفون جلد (Glossy Sheen)
/// ۵. سایه چندلایه سه‌بعدی واقعی (Multi-layered 3D Drop Shadow)
class BookCover3D extends StatelessWidget {
  final String coverUrl;
  final String? heroTag;
  final double? width;
  final double? height;
  final double pageThickness;
  final Widget? categoryBadge;
  final Widget? favoriteBadge;
  final Widget? progressBadge;
  final Widget? progressBar;
  final VoidCallback? onTap;
  final bool showShadow;
  final double cornerRadius;
  final bool isRtl;

  const BookCover3D({
    super.key,
    required this.coverUrl,
    this.heroTag,
    this.width,
    this.height,
    this.pageThickness = 7.0,
    this.categoryBadge,
    this.favoriteBadge,
    this.progressBadge,
    this.progressBar,
    this.onTap,
    this.showShadow = true,
    this.cornerRadius = 6.0,
    this.isRtl = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.onPrimary;

    Widget bookBody = LayoutBuilder(
      builder: (context, constraints) {
        final actualWidth = width ?? constraints.maxWidth;

        // محاسبه ضخامت متناسب در صورت ابعاد کوچک
        final effectiveThickness = (actualWidth * 0.045).clamp(4.0, pageThickness);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // ۱. لایه سایه سه‌بعدی و لبه جلد پشتی کتاب (Rear Cover & 3D Shadow)
            Positioned(
              left: isRtl ? 0 : 2,
              top: 3,
              right: isRtl ? 2 : 0,
              bottom: 1,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: isRtl ? Radius.circular(cornerRadius + 1) : const Radius.circular(2),
                    bottomLeft: isRtl ? Radius.circular(cornerRadius + 1) : const Radius.circular(2),
                    topRight: isRtl ? const Radius.circular(2) : Radius.circular(cornerRadius + 1),
                    bottomRight: isRtl ? const Radius.circular(2) : Radius.circular(cornerRadius + 1),
                  ),
                  color: const Color(0xFF1E2024),
                  boxShadow: showShadow
                      ? [
                          // سایه ملایم و عمیق کف (جهت دار بر اساس RTL/LTR)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.28),
                            offset: Offset(isRtl ? -4 : 4, 9),
                            blurRadius: 12,
                            spreadRadius: -2,
                          ),
                          // سایه محو دورتر برای ایجاد ارتفاع و عمق
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.16),
                            offset: Offset(isRtl ? -7 : 7, 15),
                            blurRadius: 20,
                            spreadRadius: -3,
                          ),
                        ]
                      : null,
                ),
              ),
            ),

            // ۲. ضخامت صفحات کتاب (Pages Stack Thickness)
            // در حالت راست‌چین (کتاب‌های فارسی/عربی) صفحات سمت چپ قرار دارند
            Positioned(
              top: 3,
              bottom: 3,
              left: isRtl ? 1.5 : null,
              right: isRtl ? null : 1.5,
              width: effectiveThickness,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: isRtl ? const Radius.circular(2.5) : Radius.zero,
                    bottomLeft: isRtl ? const Radius.circular(2.5) : Radius.zero,
                    topRight: isRtl ? Radius.zero : const Radius.circular(2.5),
                    bottomRight: isRtl ? Radius.zero : const Radius.circular(2.5),
                  ),
                  gradient: LinearGradient(
                    begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                    end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                    colors: const [
                      Color(0xFF9E9A8E), // سایه عمیق زیر لبه جلد
                      Color(0xFFFAF7F0), // روشنی لبه کاغذ
                      Color(0xFFECE7DB), // رنگ طبیعی کاغذ
                      Color(0xFFD6CFC1), // لبه بیرونی صفحات
                    ],
                    stops: const [0.0, 0.25, 0.65, 1.0],
                  ),
                ),
                child: CustomPaint(
                  painter: _PageLinesPainter(),
                ),
              ),
            ),

            // ۳. جلد رویی کتاب (Front Cover)
            Positioned(
              left: isRtl ? (effectiveThickness - 0.5) : 0,
              top: 0,
              right: isRtl ? 0 : (effectiveThickness - 0.5),
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: isRtl ? Radius.circular(cornerRadius) : const Radius.circular(3),
                    bottomLeft: isRtl ? Radius.circular(cornerRadius) : const Radius.circular(3),
                    topRight: isRtl ? const Radius.circular(3) : Radius.circular(cornerRadius),
                    bottomRight: isRtl ? const Radius.circular(3) : Radius.circular(cornerRadius),
                  ),
                  boxShadow: [
                    // سایه بسیار ظریف لبه جلد روی صفحات
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      offset: Offset(isRtl ? -2 : 2, 0),
                      blurRadius: 2,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // تصویر اصلی جلد کتاب
                    _buildCoverImage(primaryColor),

                    // شیار و انحنای عطف کتاب (Spine Curvature & Hinge Crease)
                    // در حالت راست‌چین، عطف در سمت راست کتاب قرار دارد
                    Positioned(
                      left: isRtl ? null : 0,
                      right: isRtl ? 0 : null,
                      top: 0,
                      bottom: 0,
                      width: 24,
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                              end: isRtl ? Alignment.centerLeft : Alignment.centerRight,
                              stops: const [
                                0.0,
                                0.14,
                                0.28,
                                0.48,
                                0.65,
                                1.0,
                              ],
                              colors: [
                                Colors.black.withValues(alpha: 0.42), // لبه بیرونی عطف
                                Colors.white.withValues(alpha: 0.32), // خط نور بازتابی عطف
                                Colors.black.withValues(alpha: 0.08), // سایه ملایم
                                Colors.black.withValues(alpha: 0.35), // شیار تاخوردگی جلد
                                Colors.black.withValues(alpha: 0.12), // پخش سایه
                                Colors.transparent,                   // محو در سطح جلد
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // براق بودن و بازتاب نور مورب روی جلد سلفون (Glossy Cover Sheen)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: isRtl
                                  ? const Alignment(0.85, -1.0)
                                  : const Alignment(-0.85, -1.0),
                              end: isRtl
                                  ? const Alignment(-0.85, 1.0)
                                  : const Alignment(0.85, 1.0),
                              stops: const [0.0, 0.32, 0.55, 1.0],
                              colors: [
                                Colors.white.withValues(alpha: 0.18),
                                Colors.transparent,
                                Colors.white.withValues(alpha: 0.06),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // حاشیه بسیار ظریف لبه لمینیت
                    Positioned.fill(
                      child: IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: isRtl ? Radius.circular(cornerRadius) : const Radius.circular(3),
                              bottomLeft: isRtl ? Radius.circular(cornerRadius) : const Radius.circular(3),
                              topRight: isRtl ? const Radius.circular(3) : Radius.circular(cornerRadius),
                              bottomRight: isRtl ? const Radius.circular(3) : Radius.circular(cornerRadius),
                            ),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // بج دسته‌بندی
                    if (categoryBadge != null) categoryBadge!,

                    // دکمه لایک / نشانه‌گذاری
                    if (favoriteBadge != null) favoriteBadge!,

                    // وضعیت دانلود و پیشرفت مطالعه
                    if (progressBadge != null) progressBadge!,

                    // نوار پیشرفت مطالعه در لبه پایین جلد
                    if (progressBar != null) progressBar!,
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );

    if (heroTag != null && heroTag!.isNotEmpty) {
      bookBody = Hero(
        tag: heroTag!,
        child: bookBody,
      );
    }

    if (onTap != null) {
      bookBody = GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: bookBody,
      );
    }

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: bookBody,
      );
    }

    return bookBody;
  }

  Widget _buildCoverImage(Color primaryColor) {
    if (coverUrl.trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: coverUrl.trim(),
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: primaryColor.withValues(alpha: 0.12),
          child: Center(
            child: LoadingAnimationWidget.waveDots(
              color: primaryColor,
              size: 26,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildFallbackCover(primaryColor),
      );
    }
    return _buildFallbackCover(primaryColor);
  }

  Widget _buildFallbackCover(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor.withValues(alpha: 0.35),
            primaryColor.withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.menu_book_rounded,
          size: 42,
          color: primaryColor,
        ),
      ),
    );
  }
}

/// ترسیم خطوط ریز لایه‌های کاغذ در عطف صفحات
class _PageLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFC0B9A8).withValues(alpha: 0.45)
      ..strokeWidth = 0.5;

    // خطوط افقی ریز برای شبیه‌سازی لایه‌های برگه
    const step = 4.0;
    for (double y = 4.0; y < size.height - 4.0; y += step) {
      canvas.drawLine(
        Offset(0.5, y),
        Offset(size.width - 0.5, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
