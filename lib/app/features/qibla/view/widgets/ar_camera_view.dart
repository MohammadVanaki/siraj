import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../controller/qibla_controller.dart';

class ArCameraView extends StatefulWidget {
  final QiblaController controller;

  const ArCameraView({super.key, required this.controller});

  @override
  State<ArCameraView> createState() => _ArCameraViewState();
}

class _ArCameraViewState extends State<ArCameraView>
    with SingleTickerProviderStateMixin {
  late AnimationController _arrowAnimationController;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _arrowAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _arrowAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _arrowAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _arrowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        return Obx(() {
          final isCamReady = widget.controller.isCameraInitialized.value;
          final cameraCtrl = widget.controller.cameraController;

          if (!isCamReady || cameraCtrl == null || !cameraCtrl.value.isInitialized) {
            return Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.amber),
                    Gap(16),
                    Text(
                      'جاري تشغيل الكاميرا...',
                      style: TextStyle(color: Colors.white, fontFamily: 'IBMPlexSansArabic'),
                    ),
                  ],
                ),
              ),
            );
          }

          final double diff = widget.controller.angleDiff.value;
          final bool isAligned = widget.controller.isAligned.value;
          final double diffAbs = diff.abs();

          // زاوية الرؤية الأفقية للكاميرا (حوالي 60 درجة = +-30 من المنتصف)
          const double cameraHFOV = 60.0;
          const double halfFOV = cameraHFOV / 2.0;

          // هل الكعبة داخل نطاق كادر الكاميرا حالياً؟
          final bool isKaabaInView = diffAbs <= halfFOV;

          // حساب الإزاحة الأفقية للكعبة على الشاشة
          // إذا كان diff = 0 تكون في المنتصف تماماً
          // إذا كان diff > 0 (القبلة يمين) تزاح لليمين
          // إذا كان diff < 0 (القبلة يسار) تزاح لليسار
          const double kaabaSize = 130.0;
          final double normalizedOffset = (diff / halfFOV); // -1.0 إلى +1.0
          final double kaabaX = (screenWidth / 2.0) +
              (normalizedOffset * (screenWidth / 2.0)) -
              (kaabaSize / 2.0);
          final double kaabaY = (screenHeight / 2.0) - (kaabaSize / 2.0) - 20;

          return Stack(
            fit: StackFit.expand,
            children: [
              // 1. معاينة الكاميرا بالملء التام
              ClipRect(
                child: SizedBox(
                  width: screenWidth,
                  height: screenHeight,
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width: cameraCtrl.value.previewSize?.height ?? screenWidth,
                      height: cameraCtrl.value.previewSize?.width ?? screenHeight,
                      child: CameraPreview(cameraCtrl),
                    ),
                  ),
                ),
              ),

              // 2. طبقة تعتيم خفيفة جمالية للـ AR
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.1,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(isAligned ? 60 : 120),
                    ],
                  ),
                ),
              ),

              // 3. شبكة وهدف استهداف منتصف الكادر (Center Crosshair / Reticle)
              Center(
                child: _buildCenterCrosshair(isAligned, diffAbs),
              ),

              // 4. صورة/أيقونة الكعبة المشرفة في الواقع المعزز (AR Kaaba)
              if (isKaabaInView)
                Positioned(
                  left: kaabaX,
                  top: kaabaY,
                  child: _buildKaabaARObject(isAligned, kaabaSize, diffAbs),
                ),

              // 5. أسهم التوجيه الحركية (>>> لليمين أو <<< لليسار)
              if (!isAligned) ...[
                // سهم التدوير لليمين >>>
                if (diff > 3.0)
                  Positioned(
                    right: 16,
                    top: screenHeight / 2 - 80,
                    child: _buildTurnRightGuide(diff),
                  ),

                // سهم التدوير لليسار <<<
                if (diff < -3.0)
                  Positioned(
                    left: 16,
                    top: screenHeight / 2 - 80,
                    child: _buildTurnLeftGuide(diffAbs),
                  ),
              ],

              // 6. شارة الحالة عند انطباق القبلة
              if (isAligned)
                Positioned(
                  top: 90,
                  left: 20,
                  right: 20,
                  child: _buildAlignedSuccessBanner(),
                ),

              // 7. بوصلة ورادار مصغر أسفل الشاشة
              Positioned(
                bottom: 24,
                left: 20,
                right: 20,
                child: _buildBottomHudBar(diff, isAligned),
              ),
            ],
          );
        });
      },
    );
  }

  /// مجسم الكعبة المشرفة العائم في الكادر
  Widget _buildKaabaARObject(bool isAligned, double size, double diffAbs) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: isAligned ? 1.15 : (1.0 - (diffAbs / 60.0) * 0.25).clamp(0.7, 1.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // مؤشر فوق الكعبة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAligned
                  ? const Color(0xFF00E676).withAlpha(220)
                  : Colors.black.withAlpha(180),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isAligned ? Colors.white : Colors.amber,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isAligned ? const Color(0xFF00E676) : Colors.amber)
                      .withAlpha(120),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAligned ? Icons.check_circle : Icons.location_on,
                  color: Colors.white,
                  size: 14,
                ),
                const Gap(4),
                Text(
                  isAligned ? 'الكعبة المشرفة' : 'القبلة',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Gap(6),

          // مجسم الكعبة مع تأثير الهالة والنبض
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: isAligned
                  ? [
                      BoxShadow(
                        color: const Color(0xFF00E676).withAlpha(180),
                        blurRadius: 30,
                        spreadRadius: 8,
                      ),
                      BoxShadow(
                        color: Colors.amber.withAlpha(120),
                        blurRadius: 40,
                        spreadRadius: 4,
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(100),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: SvgPicture.asset(
              'assets/svgs/kaaba.svg',
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  /// علامة التقاطع والهدف في منتصف الشاشة
  Widget _buildCenterCrosshair(bool isAligned, double diffAbs) {
    final Color crossColor = isAligned
        ? const Color(0xFF00E676)
        : Colors.white.withAlpha((180 - (diffAbs * 2).clamp(0, 120)).toInt());

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: isAligned ? 200 : 160,
      height: isAligned ? 200 : 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: crossColor,
          width: isAligned ? 3 : 1.5,
        ),
        boxShadow: isAligned
            ? [
                BoxShadow(
                  color: const Color(0xFF00E676).withAlpha(120),
                  blurRadius: 25,
                  spreadRadius: 3,
                )
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // الخطوط العرضية والطولية
          Container(
            width: 1.5,
            height: 24,
            color: crossColor,
          ),
          Container(
            width: 24,
            height: 1.5,
            color: crossColor,
          ),

          // دائرة المركز الصغيرة
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: crossColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  /// إرشاد التدوير لليمين >>>
  Widget _buildTurnRightGuide(double diff) {
    return AnimatedBuilder(
      animation: _arrowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(190),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.amber.withAlpha((_arrowAnimation.value * 255).toInt()),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withAlpha(60),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _chevronIcon(Icons.chevron_right_rounded, 0.4),
                  _chevronIcon(Icons.chevron_right_rounded, 0.7),
                  _chevronIcon(Icons.chevron_right_rounded, 1.0),
                ],
              ),
              const Gap(4),
              const Text(
                'أدر لليمين',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${diff.toStringAsFixed(0)}°',
                style: const TextStyle(
                  color: Colors.amber,
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// إرشاد التدوير لليسار <<<
  Widget _buildTurnLeftGuide(double diffAbs) {
    return AnimatedBuilder(
      animation: _arrowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(190),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.amber.withAlpha((_arrowAnimation.value * 255).toInt()),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withAlpha(60),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _chevronIcon(Icons.chevron_left_rounded, 1.0),
                  _chevronIcon(Icons.chevron_left_rounded, 0.7),
                  _chevronIcon(Icons.chevron_left_rounded, 0.4),
                ],
              ),
              const Gap(4),
              const Text(
                'أدر لليسار',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${diffAbs.toStringAsFixed(0)}°',
                style: const TextStyle(
                  color: Colors.amber,
                  fontFamily: 'IBMPlexSansArabic',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chevronIcon(IconData icon, double opacityMultiplier) {
    final double op = (_arrowAnimation.value * opacityMultiplier).clamp(0.2, 1.0);
    return Icon(
      icon,
      color: Colors.amber.withAlpha((op * 255).toInt()),
      size: 26,
    );
  }

  /// شارة النجاح والانطباق التام
  Widget _buildAlignedSuccessBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF00E676).withAlpha(230),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withAlpha(150),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
          Gap(10),
          Text(
            'أنت الآن تواجه القبلة المشرفة بدقة',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'IBMPlexSansArabic',
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// شريط المعلومات السفلي
  Widget _buildBottomHudBar(double diff, bool isAligned) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isAligned
              ? const Color(0xFF00E676).withAlpha(180)
              : Colors.white.withAlpha(40),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // زاوية القبلة
          _hudItem(
            title: 'زاوية القبلة',
            value: '${widget.controller.qiblaBearing.value.toStringAsFixed(1)}°',
            icon: Icons.explore_rounded,
          ),

          // خط فاصل
          Container(width: 1, height: 28, color: Colors.white24),

          // المسافة إلى الكعبة
          _hudItem(
            title: 'المسافة لمكة',
            value: '${widget.controller.distanceToKaabaKm.value.toStringAsFixed(0)} كم',
            icon: Icons.near_me_rounded,
          ),

          // خط فاصل
          Container(width: 1, height: 28, color: Colors.white24),

          // حالة الاتجاه
          _hudItem(
            title: 'الحالة',
            value: isAligned
                ? 'مضبوط ✓'
                : (diff > 0 ? 'يمين +${diff.toStringAsFixed(0)}°' : 'يسار -${diff.abs().toStringAsFixed(0)}°'),
            icon: isAligned ? Icons.verified_rounded : Icons.sync_rounded,
            valueColor: isAligned ? const Color(0xFF00E676) : Colors.amber,
          ),
        ],
      ),
    );
  }

  Widget _hudItem({
    required String title,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.grey[400]),
            const Gap(4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[400],
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 10,
              ),
            ),
          ],
        ),
        const Gap(2),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontFamily: 'IBMPlexSansArabic',
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
