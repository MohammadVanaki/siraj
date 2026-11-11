import 'dart:collection';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mawsueat/app/features/home/view/controller/virtual_ziyarat_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomeVirtualZiyaratWidget extends StatelessWidget {
  const HomeVirtualZiyaratWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.onPrimary;
    final isDark = theme.brightness == Brightness.dark;
    final controller = Get.put(VirtualZiyaratController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // چیپ‌های انتخاب بارگاه و دکمه‌های «نافذة كاملة» و «مباشر» در یک ردیف متوازن
        Obx(() {
          final activeShrine = controller.currentShrine.value;

          return Row(
            children: [
              // ۱. چیپ‌های انتخاب بارگاه (شروع از المدينة المنورة به صورت اسکرول افقی)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: controller.shrines.map((shrine) {
                      final isSelected = activeShrine.id == shrine.id;

                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: ZoomTapAnimation(
                          onTap: () => controller.selectShrine(shrine),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? primaryColor
                                  : primaryColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? primaryColor
                                    : primaryColor.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: isSelected ? Colors.white : primaryColor,
                                ),
                                const Gap(4),
                                Text(
                                  shrine.city,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.white
                                        : colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const Gap(8),

              // ۲. گزینه‌های «نافذة كاملة» و «مباشر» روبه‌روی چیپ‌های بارگاه
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // دکمه باز کردن در پنجره کامل
                  ZoomTapAnimation(
                    onTap: controller.openExternalStream,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: 0.2),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.open_in_new_rounded,
                            size: 12,
                            color: primaryColor,
                          ),
                          const Gap(3),
                          Text(
                            'نافذة كاملة',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'IBMPlexSansArabic',
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Gap(6),

                  // نشانگر پخش زنده (مباشر)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const Gap(4),
                        const Text(
                          'مباشر',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        }),

        const Gap(12),

        // ۳. کارت یکپارچه زیارت مجازی (پلیر زنده، جهت‌نما و متن زیارت)
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F2428) : colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(20)
                  : primaryColor.withAlpha(28),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 80 : 14),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الف) پلیر زنده
                Obx(() {
                  final shrine = controller.currentShrine.value;
                  final isPlaying = controller.isStreamActive.value;
                  final isLoading = controller.isStreamLoading.value;
                  final hasError = controller.streamHasError.value;

                  return AspectRatio(
                    aspectRatio: 16 / 9,
                    child: isPlaying
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              // وب‌ویو بهینه‌سازی شده با Hybrid Composition و RepaintBoundary برای اسکرول فوق‌العاده روان
                              RepaintBoundary(
                                child: InAppWebView(
                                  key: ValueKey(shrine.streamUrl),
                                  initialUrlRequest: URLRequest(
                                    url: WebUri(shrine.streamUrl),
                                    headers: {
                                      'Referer': 'https://www.youtube.com/',
                                    },
                                  ),
                                  initialSettings: InAppWebViewSettings(
                                    useHybridComposition: true,
                                    hardwareAcceleration: true,
                                    disableHorizontalScroll: true,
                                    disableVerticalScroll: true,
                                    horizontalScrollBarEnabled: false,
                                    verticalScrollBarEnabled: false,
                                    overScrollMode: OverScrollMode.NEVER,
                                    javaScriptEnabled: true,
                                    domStorageEnabled: true,
                                    databaseEnabled: true,
                                    mediaPlaybackRequiresUserGesture: false,
                                    allowsInlineMediaPlayback: true,
                                    iframeAllow:
                                        "accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share",
                                    iframeAllowFullscreen: true,
                                    mixedContentMode: MixedContentMode
                                        .MIXED_CONTENT_ALWAYS_ALLOW,
                                    useWideViewPort: true,
                                    loadWithOverviewMode: true,
                                    supportZoom: false,
                                    transparentBackground: false,
                                    userAgent:
                                        "Mozilla/5.0 (Linux; Android 13; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
                                  ),
                                  initialUserScripts: UnmodifiableListView([
                                    UserScript(
                                      source: '''
                                    (function() {
                                      var css = `
                                        html, body {
                                          background-color: #000000 !important;
                                          overflow: hidden !important;
                                          margin: 0 !important;
                                          padding: 0 !important;
                                          width: 100% !important;
                                          height: 100% !important;
                                          touch-action: pan-y !important;
                                        }
                                        .ytp-pause-overlay, .ytp-watermark, .ytp-show-cards-title {
                                          display: none !important;
                                        }
                                      `;
                                      var style = document.createElement('style');
                                      style.type = 'text/css';
                                      style.appendChild(document.createTextNode(css));
                                      if (document.head) {
                                        document.head.appendChild(style);
                                      } else {
                                        document.addEventListener('DOMContentLoaded', function() {
                                          document.head.appendChild(style);
                                        });
                                      }
                                    })();
                                  ''',
                                      injectionTime: UserScriptInjectionTime
                                          .AT_DOCUMENT_START,
                                    ),
                                  ]),
                                  onWebViewCreated: (webCtrl) {
                                    controller.webViewController = webCtrl;
                                  },
                                  onLoadStart: (_, __) {
                                    controller.isStreamLoading.value = true;
                                    controller.streamHasError.value = false;
                                  },
                                  onLoadStop: (webCtrl, _) {
                                    controller.isStreamLoading.value = false;
                                    webCtrl.evaluateJavascript(
                                      source: '''
                                  (function() {
                                    var v = document.querySelector('video');
                                    if (v && v.paused) {
                                      v.play().catch(function() {});
                                    }
                                  })();
                                ''',
                                    );
                                  },
                                  onReceivedError: (_, __, ___) {
                                    controller.isStreamLoading.value = false;
                                    controller.streamHasError.value = true;
                                  },
                                  gestureRecognizers:
                                      const <
                                        Factory<OneSequenceGestureRecognizer>
                                      >{},
                                ),
                              ),

                              // نمایش لودینگ زیبا هنگام بافر شدن استریم
                              if (isLoading)
                                Container(
                                  color: Colors.black54,
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        LoadingAnimationWidget.waveDots(
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                        const Gap(10),
                                        const Text(
                                          'جاري الاتصال بالبث المباشر...',
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // خطای اتصال یا فیلتر بودن لینک
                              if (hasError)
                                Container(
                                  color: const Color(0xFF0F172A),
                                  padding: const EdgeInsets.all(16),
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons
                                              .signal_wifi_connected_no_internet_4_rounded,
                                          color: Colors.redAccent,
                                          size: 36,
                                        ),
                                        const Gap(8),
                                        const Text(
                                          'تعذر تحميل البث المباشر داخل التطبيق',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Gap(10),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed:
                                                  controller.reloadStream,
                                              icon: const Icon(
                                                Icons.refresh_rounded,
                                                size: 16,
                                              ),
                                              label: const Text(
                                                'إعادة المحاولة',
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: primaryColor,
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                textStyle: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                            const Gap(8),
                                            OutlinedButton.icon(
                                              onPressed:
                                                  controller.openExternalStream,
                                              icon: const Icon(
                                                Icons.open_in_browser_rounded,
                                                size: 16,
                                              ),
                                              label: const Text(
                                                'فتح في المتصفح',
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                side: const BorderSide(
                                                  color: Colors.white38,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                textStyle: const TextStyle(
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                              // نوار ابزار بالای پلیر (توقف، بارگذاری مجدد، پنجره کامل)
                              Positioned(
                                top: 8,
                                right: 8,
                                left: 8,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ZoomTapAnimation(
                                      onTap: controller.toggleStream,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.65,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        ZoomTapAnimation(
                                          onTap: controller.reloadStream,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.65,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.refresh_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                        const Gap(6),
                                        ZoomTapAnimation(
                                          onTap: controller.openExternalStream,
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withValues(
                                                alpha: 0.65,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.fullscreen_rounded,
                                              color: Colors.white,
                                              size: 18,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Stack(
                            fit: StackFit.expand,
                            children: [
                              // تصویر بنر قبل از پخش (به جای کادر سیاه)
                              Image.asset(
                                'assets/images/appIcon.png',
                                fit: BoxFit.cover,
                                cacheWidth: 600,
                              ),

                              // گرادیان تیره روی پوستر برای خوانایی و عمق
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.25),
                                      Colors.black.withValues(alpha: 0.8),
                                    ],
                                  ),
                                ),
                              ),

                              // نام حرم و شهر روی ویدیو
                              Positioned(
                                top: 12,
                                right: 14,
                                left: 14,
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.mosque_rounded,
                                      color: Colors.amberAccent,
                                      size: 18,
                                    ),
                                    const Gap(6),
                                    Expanded(
                                      child: Text(
                                        shrine.shrineName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'IBMPlexSansArabic',
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // دکمه مرکزی پخش زنده (Play Live Button)
                              Center(
                                child: ZoomTapAnimation(
                                  onTap: controller.toggleStream,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withValues(
                                        alpha: 0.92,
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: primaryColor.withValues(
                                            alpha: 0.45,
                                          ),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                        Gap(6),
                                        Text(
                                          'مشاهدة البث المباشر',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  );
                }),

                // ب) نوار هوشمند جهت‌نما (یکپارچه با دیوایدر و بک‌گراند ظریف)
                Obx(() {
                  final shrine = controller.currentShrine.value;
                  final distance = controller.distanceKm.value;
                  final direction = controller.turnDirection.value;
                  final degrees = controller.turnDegrees;
                  final hasLocation =
                      controller.locationService.hasLocationPermission.value;
                  final isGpsEnabled =
                      controller.locationService.isGpsServiceEnabled.value;

                  final bool isFacing = direction == ShrineTurnDirection.facing;
                  final bool isTurnRight =
                      direction == ShrineTurnDirection.turnRight;
                  final bool isTurnLeft =
                      direction == ShrineTurnDirection.turnLeft;
                  final bool isTurnAround =
                      direction == ShrineTurnDirection.turnAround;


                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isFacing
                          ? const Color(0xFF10B981).withValues(alpha: 0.10)
                          : (isDark
                                ? Colors.white.withAlpha(5)
                                : primaryColor.withAlpha(6)),
                      border: Border(
                        top: BorderSide(
                          color: isFacing
                              ? const Color(0xFF10B981).withValues(alpha: 0.45)
                              : (isDark
                                    ? Colors.white.withAlpha(15)
                                    : primaryColor.withAlpha(20)),
                          width: isFacing ? 1.5 : 1.0,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // عقربه مینیاتوری دقیق ایزوله‌شده در RepaintBoundary برای صفر کردن لگ اسکرول
                            ZoomTapAnimation(
                              onTap: () => _showShrineCompassBottomSheet(
                                context,
                                controller,
                              ),
                              child: _HomeMiniCompassDial(
                                controller: controller,
                                isDark: isDark,
                              ),
                            ),

                            const Gap(12),

                            // راهنمای زنده چرخش و زاویه
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!hasLocation) ...[
                                    ZoomTapAnimation(
                                      onTap: controller.requestLocation,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.my_location_rounded,
                                            size: 15,
                                            color: primaryColor,
                                          ),
                                          const Gap(5),
                                          Expanded(
                                            child: Text(
                                              'اضغط لتحديد الاتجاه بدقة (تفعيل GPS)',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else if (!isGpsEnabled) ...[
                                    ZoomTapAnimation(
                                      onTap: controller.openGpsSettings,
                                      child: Row(
                                        children: const [
                                          Icon(
                                            Icons.location_off_rounded,
                                            size: 15,
                                            color: Colors.redAccent,
                                          ),
                                          Gap(5),
                                          Expanded(
                                            child: Text(
                                              'خدمة GPS متوقفة - اضغط للتشغيل',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ] else if (isFacing) ...[
                                    Row(
                                      children: const [
                                        Icon(
                                          Icons.verified_rounded,
                                          size: 16,
                                          color: Color(0xFF10B981),
                                        ),
                                        Gap(5),
                                        Expanded(
                                          child: Text(
                                            'أنت الآن موجه نحو الحرم المطهر ✦',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(2),
                                    Text(
                                      'بارگاه ${shrine.city} مباشرة أمامك',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                  ] else if (isTurnAround) ...[
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.u_turn_right_rounded,
                                          size: 19,
                                          color: Color(0xFFEF4444),
                                        ),
                                        const Gap(4),
                                        Expanded(
                                          child: Text(
                                            'أدر للخلف $degrees° (الحرم خلفك)',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFEF4444),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(2),
                                    Text(
                                      'استدر للخلف لمواجهة بارگاه ${shrine.city}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                  ] else if (isTurnRight) ...[
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.turn_right_rounded,
                                          size: 19,
                                          color: Color(0xFFF59E0B),
                                        ),
                                        const Gap(4),
                                        Expanded(
                                          child: Text(
                                            'أدر $degrees° إلى اليمين ↻',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFF59E0B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(2),
                                    Text(
                                      'لتوجيه هاتفك نحو ${shrine.city}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                  ] else if (isTurnLeft) ...[
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.turn_left_rounded,
                                          size: 19,
                                          color: Color(0xFFF59E0B),
                                        ),
                                        const Gap(4),
                                        Expanded(
                                          child: Text(
                                            'أدر $degrees° إلى اليسار ↺',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFFF59E0B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Gap(2),
                                    Text(
                                      'لتوجيه هاتفك نحو ${shrine.city}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: colorScheme.secondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),

                            // فاصله مستقیم بر حسب کیلومتر
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: primaryColor.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${distance.toStringAsFixed(0)} كم',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                  Text(
                                    'المسافة',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      color: colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Gap(8),

                        // راهنمای در دست گرفتن افقی گوشی مانند قطب‌نما
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.screen_rotation_rounded,
                                size: 12,
                                color: primaryColor.withValues(alpha: 0.7),
                              ),
                              const Gap(6),
                              Expanded(
                                child: Text(
                                  'امسك الهاتف أفقياً كالبوصلة (موازياً للأرض) للحصول على أعلى دقة',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // ج) متن زیارت‌نامه (یکپارچه با دیوایدر بالا)
                Obx(() {
                  final shrine = controller.currentShrine.value;
                  final isExpanded = controller.isTextExpanded.value;
                  final currentReading = controller.currentReading;
                  final title =
                      currentReading?.titleArabic ?? shrine.ziyaratTitle;
                  final body =
                      currentReading?.bodyArabic ?? shrine.ziyaratArabicText;
                  final readings = shrine.readings;
                  final isLoading =
                      controller.isLoadingReadings.value && readings.isEmpty;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? Colors.white.withAlpha(15)
                              : primaryColor.withAlpha(20),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 17,
                                  color: primaryColor,
                                ),
                                const Gap(6),
                                Text(
                                  title,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'IBMPlexSansArabic',
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            ZoomTapAnimation(
                              onTap: controller.toggleTextExpansion,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isExpanded ? 'طي النص' : 'قراءة المزيد',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    const Gap(2),
                                    Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up_rounded
                                          : Icons.keyboard_arrow_down_rounded,
                                      size: 16,
                                      color: primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // چیپ‌های انتخاب زیارت در صورت وجود بیش از یک متن برای یک بارگاه
                        if (readings.length > 1) ...[
                          const Gap(8),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(readings.length, (idx) {
                                final r = readings[idx];
                                final isSel =
                                    controller.selectedReadingIndex.value ==
                                    idx;
                                return Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: ZoomTapAnimation(
                                    onTap: () => controller.selectReading(idx),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSel
                                            ? primaryColor
                                            : primaryColor.withValues(
                                                alpha: 0.08,
                                              ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        r.titleArabic,
                                        style: TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: isSel
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSel
                                              ? Colors.white
                                              : colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ],

                        const Gap(8),

                        if (isLoading)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: LoadingAnimationWidget.waveDots(
                                color: primaryColor,
                                size: 24,
                              ),
                            ),
                          )
                        else
                          Text(
                            body.isNotEmpty ? body : 'جاري تحميل نص الزيارة...',
                            maxLines: isExpanded ? null : 3,
                            overflow: isExpanded
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            textAlign: TextAlign.justify,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 14,
                              height: 1.9,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// نمایش دیالوگ/شیت بوصلة و جهت‌نمای بزرگ همراه با راهنمای کالیبراسیون
  void _showShrineCompassBottomSheet(
    BuildContext context,
    VirtualZiyaratController controller,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.onPrimary;
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Obx(() {
          final shrine = controller.currentShrine.value;
          final heading = controller.locationService.smoothedHeading.value;
          final needleAngle = controller.needleRotationRadians;
          final distance = controller.distanceKm.value;
          final bearing = controller.shrineBearing.value;
          final isFacing = controller.isFacingShrine.value;
          final degrees = controller.turnDegrees;
          final direction = controller.turnDirection.value;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // نوار بالایی کوچک برای کشیدن به پایین
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Gap(16),

              // عنوان
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.explore_rounded,
                        color: primaryColor,
                        size: 22,
                      ),
                      const Gap(8),
                      Text(
                        'بوصلة اتجاه بارگاه ${shrine.city}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),

              const Gap(16),

              // قرص بزرگ قطب‌نما
              Center(
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isFacing
                            ? const Color(0xFF10B981).withValues(alpha: 0.45)
                            : Colors.black.withValues(
                                alpha: isDark ? 0.3 : 0.08,
                              ),
                        blurRadius: isFacing ? 24 : 14,
                        spreadRadius: isFacing ? 4 : 1,
                      ),
                    ],
                  ),
                  child: CustomPaint(
                    painter: _MiniCompassPainter(
                      heading: heading,
                      needleAngle: needleAngle,
                      isFacing: isFacing,
                      statusColor: isFacing
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                      isDark: isDark,
                      scale: 1.8,
                    ),
                  ),
                ),
              ),

              const Gap(16),

              // پیام وضعیت چرخش
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isFacing
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isFacing
                        ? const Color(0xFF10B981).withValues(alpha: 0.5)
                        : primaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  isFacing
                      ? '✦ أنت الآن موجه نحو الحرم المطهر بدقة ✦'
                      : (direction == ShrineTurnDirection.turnAround
                            ? 'أدر للخلف $degrees° (الحرم خلفك تماماً)'
                            : (direction == ShrineTurnDirection.turnRight
                                  ? 'أدر الهاتف يميناً بمقدار $degrees° ↻'
                                  : 'أدر الهاتف يساراً بمقدار $degrees° ↺')),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBMPlexSansArabic',
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: isFacing
                        ? const Color(0xFF10B981)
                        : colorScheme.onSurface,
                  ),
                ),
              ),

              const Gap(16),

              // کارت اطلاعات تکمیلی: زاویه قطب‌نما، زاویه حرم، فاصله
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoItem(
                    'اتجاه الحرم',
                    '${bearing.toStringAsFixed(0)}°',
                    primaryColor,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  _infoItem(
                    'المسافة',
                    '${distance.toStringAsFixed(0)} كم',
                    colorScheme.onSurface,
                  ),
                  Container(
                    width: 1,
                    height: 28,
                    color: Colors.grey.withValues(alpha: 0.3),
                  ),
                  _infoItem(
                    'الاتجاه الحالي',
                    '${heading.toStringAsFixed(0)}°',
                    isFacing ? const Color(0xFF10B981) : Colors.amber[700]!,
                  ),
                ],
              ),

              const Gap(16),

              // راهنمای کالیبراسیون سنسور گوشی
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.tune_rounded, size: 16, color: Colors.amber),
                    Gap(8),
                    Expanded(
                      child: Text(
                        'للحصول على أعلى دقة: ضع الهاتف أفقياً في راحة يدك وابتعد عن المعادن والأجهزة الإلكترونية، وقم بتحريك الهاتف في الهواء على شكل الرقم (8) الإنجليزي لمعايرة الحساس.',
                        style: TextStyle(
                          fontSize: 10.5,
                          height: 1.5,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(10),
            ],
          );
        }),
      ),
    );
  }

  static Widget _infoItem(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, color: Colors.grey)),
        const Gap(2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
            fontFamily: 'IBMPlexSansArabic',
          ),
        ),
      ],
    );
  }
}

/// ویجت ایزوله‌شده عقربه قطب‌نما با RepaintBoundary برای جلوگیری از ری‌بیلد کل بخش هنگام حرکت گوشی
class _HomeMiniCompassDial extends StatelessWidget {
  final VirtualZiyaratController controller;
  final bool isDark;

  const _HomeMiniCompassDial({required this.controller, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Obx(() {
        final isFacing = controller.isFacingShrine.value;
        final direction = controller.turnDirection.value;
        final Color statusColor = isFacing
            ? const Color(0xFF10B981)
            : (direction == ShrineTurnDirection.turnAround
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFF59E0B));

        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              if (isFacing)
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: CustomPaint(
            painter: _MiniCompassPainter(
              heading: controller.locationService.smoothedHeading.value,
              needleAngle: controller.needleRotationRadians,
              isFacing: isFacing,
              statusColor: statusColor,
              isDark: isDark,
            ),
          ),
        );
      }),
    );
  }
}

/// نقاش عقربه و قرص قطب‌نما با دقت هندسی زیرپیکسلی بدون پرش و لرزش
class _MiniCompassPainter extends CustomPainter {
  final double heading;
  final double needleAngle;
  final bool isFacing;
  final Color statusColor;
  final bool isDark;
  final double scale;

  _MiniCompassPainter({
    required this.heading,
    required this.needleAngle,
    required this.isFacing,
    required this.statusColor,
    required this.isDark,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // ۱. صفحه پس‌زمینه قرص قطب‌نما
    final bgPaint = Paint()
      ..color = isDark ? const Color(0xFF1E1E1E) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 1.5, bgPaint);

    final borderPaint = Paint()
      ..color = isFacing
          ? const Color(0xFF10B981)
          : (isDark ? Colors.white24 : Colors.black12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isFacing ? (2.2 * scale) : (1.2 * scale);
    canvas.drawCircle(center, radius - 1.5, borderPaint);

    // ۲. چرخش صفحه مدرج با -heading جهت نشان دادن جهت شمال (N)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * (math.pi / 180.0));

    // خطوط جهت‌های اصلی چهارگانه
    final tickPaint = Paint()
      ..color = isDark ? Colors.white30 : Colors.black26
      ..strokeWidth = 1.2 * scale
      ..strokeCap = StrokeCap.round;

    final tickLen = 4.0 * scale;
    for (int i = 0; i < 4; i++) {
      canvas.drawLine(
        Offset(0, -(radius - (3 * scale))),
        Offset(0, -(radius - (3 * scale) - tickLen)),
        tickPaint,
      );
      canvas.rotate(math.pi / 2);
    }

    // حرف N به رنگ قرمز در بالای صفحه
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          fontSize: 8.5 * scale,
          fontWeight: FontWeight.w900,
          fontFamily: 'IBMPlexSansArabic',
          color: const Color(0xFFEF4444),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -(radius - (5 * scale))),
    );

    canvas.restore();

    // ۳. نقاشی عقربه دو رنگ چرخان به سمت بارگاه مطهر (دقیقاً بر اساس needleAngle)
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(needleAngle);

    final double needleLength = radius - (6.0 * scale);
    final double needleWidth = 3.6 * scale;

    // نیمه جلویی عقربه (رو به حرم مطهر)
    final frontNeedlePath = Path()
      ..moveTo(0, -needleLength)
      ..lineTo(needleWidth, 0)
      ..lineTo(0, -2 * scale)
      ..lineTo(-needleWidth, 0)
      ..close();

    final frontPaint = Paint()
      ..color = isFacing ? const Color(0xFF10B981) : const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawPath(frontNeedlePath, frontPaint);

    // نیمه عقبی عقربه (مخالف جهت حرم)
    final backNeedlePath = Path()
      ..moveTo(0, needleLength * 0.6)
      ..lineTo(needleWidth * 0.75, 0)
      ..lineTo(0, 1.5 * scale)
      ..lineTo(-needleWidth * 0.75, 0)
      ..close();

    final backPaint = Paint()
      ..color = isDark ? Colors.white38 : Colors.black26
      ..style = PaintingStyle.fill;
    canvas.drawPath(backNeedlePath, backPaint);

    // پین مرکز عقربه (Pivot Dot)
    final centerPinOuter = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 3.2 * scale, centerPinOuter);

    final centerPinInner = Paint()
      ..color = isFacing ? const Color(0xFF10B981) : statusColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, 2.0 * scale, centerPinInner);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MiniCompassPainter oldDelegate) {
    return oldDelegate.heading != heading ||
        oldDelegate.needleAngle != needleAngle ||
        oldDelegate.isFacing != isFacing ||
        oldDelegate.statusColor != statusColor ||
        oldDelegate.scale != scale;
  }
}
