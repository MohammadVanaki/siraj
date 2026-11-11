import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/home/view/controller/daily_hadith_controller.dart';
import 'package:mawsueat/app/features/home/data/models/daily_hadith_model.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class DailyHadithMarquee extends StatelessWidget {
  const DailyHadithMarquee({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DailyHadithController());
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final brandColor = colorScheme.onPrimary;

    return Obx(() {
      final hadith = controller.currentHadith.value;
      final fullDisplayText = '${hadith.speaker} «${hadith.text}»';

      return ZoomTapAnimation(
        onTap: () => _showHadithDetailDialog(
          context,
          controller,
          hadith,
          brandColor,
          isDark,
        ),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1C1C)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withAlpha(28)
                  : brandColor.withAlpha(32),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 25 : 8),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. Right Badge: "حديث اليوم"
              Container(
                height: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      brandColor,
                      brandColor.withAlpha(210),
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(11),
                    bottomRight: Radius.circular(11),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      'assets/svgs/book-open-cover.svg',
                      width: 13,
                      height: 13,
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                    ),
                    const Gap(6),
                    const Text(
                      'حديث اليوم',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'IBMPlexSansArabic',
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(8),

              // 2. Scrolling Ticker Marquee Area
              Expanded(
                child: ClipRect(
                  child: ShaderMask(
                    shaderCallback: (Rect bounds) {
                      return const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Colors.transparent,
                          Colors.black,
                          Colors.black,
                          Colors.transparent,
                        ],
                        stops: [0.0, 0.04, 0.96, 1.0],
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.dstIn,
                    child: _MarqueeTextTicker(
                      text: fullDisplayText,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colorScheme.onSurface.withAlpha(220),
                        fontFamily: 'IBMPlexSansArabic',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),

              // 3. Left indicator icon (rotated 180 degrees)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: RotatedBox(
                  quarterTurns: 2,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 13,
                    color: brandColor.withAlpha(160),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _showHadithDetailDialog(
    BuildContext context,
    DailyHadithController controller,
    DailyHadithModel hadith,
    Color brandColor,
    bool isDark,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(ctx).padding.bottom + 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withAlpha(90),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const Gap(16),

              // Header with Title & Close button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: brandColor.withAlpha(25),
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(
                          'assets/svgs/book-open-cover.svg',
                          width: 18,
                          height: 18,
                          colorFilter: ColorFilter.mode(
                            brandColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      const Gap(10),
                      Text(
                        'حديث اليوم المبارك',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: Icon(
                      Icons.close_rounded,
                      color: colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ],
              ),

              const Divider(height: 24),

              // Speaker
              Text(
                hadith.speaker,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: brandColor,
                  fontFamily: 'IBMPlexSansArabic',
                ),
              ),
              const Gap(14),

              // Hadith Card Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withAlpha(16)
                      : brandColor.withAlpha(12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: brandColor.withAlpha(30),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '«${hadith.text}»',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.5,
                        height: 1.85,
                        color: colorScheme.onSurface,
                        fontFamily: 'IBMPlexSansArabic',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (hadith.source != null && hadith.source!.isNotEmpty) ...[
                      const Gap(12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black26
                              : Colors.white.withAlpha(180),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '📚 المصدر: ${hadith.source}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[700],
                            fontFamily: 'IBMPlexSansArabic',
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const Gap(20),

              // Action Buttons (Copy & Share)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: brandColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        controller.shareHadith();
                      },
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text(
                        'مشاركة الحديث',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: brandColor,
                        side: BorderSide(color: brandColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        controller.copyHadithToClipboard(context);
                      },
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text(
                        'نسخ النص',
                        style: TextStyle(
                          fontFamily: 'IBMPlexSansArabic',
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MarqueeTextTicker extends StatefulWidget {
  final String text;
  final TextStyle style;

  const _MarqueeTextTicker({
    required this.text,
    required this.style,
  });

  @override
  State<_MarqueeTextTicker> createState() => _MarqueeTextTickerState();
}

class _MarqueeTextTickerState extends State<_MarqueeTextTicker> {
  late final ScrollController _scrollController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startLoop();
    });
  }

  void _startLoop() async {
    while (!_isDisposed && mounted) {
      if (!_scrollController.hasClients) {
        await Future.delayed(const Duration(milliseconds: 300));
        continue;
      }

      final maxExtent = _scrollController.position.maxScrollExtent;
      if (maxExtent <= 0) {
        await Future.delayed(const Duration(milliseconds: 600));
        continue;
      }

      // Initial pause before scrolling starts
      await Future.delayed(const Duration(milliseconds: 1500));
      if (_isDisposed || !mounted || !_scrollController.hasClients) break;

      final current = _scrollController.offset;
      final target = _scrollController.position.maxScrollExtent;
      final distance = (target - current).abs();

      if (distance > 1) {
        // Scroll speed: ~32ms per pixel
        final durationMs = (distance * 32).round().clamp(1000, 50000);
        try {
          await _scrollController.animateTo(
            target,
            duration: Duration(milliseconds: durationMs),
            curve: Curves.linear,
          );
        } catch (_) {
          break;
        }
      }

      if (_isDisposed || !mounted || !_scrollController.hasClients) break;

      // Pause at the end
      await Future.delayed(const Duration(milliseconds: 2000));
      if (_isDisposed || !mounted || !_scrollController.hasClients) break;

      // Smoothly return or jump to start
      try {
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      } catch (_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      }
    }
  }

  @override
  void didUpdateWidget(covariant _MarqueeTextTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            widget.text,
            style: widget.style,
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}
