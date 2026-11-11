import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../controller/duas_controller.dart';
import '../../data/models/dua_media_item.dart';

class DuaAudioCard extends StatefulWidget {
  final DuaAudioItem item;

  const DuaAudioCard({super.key, required this.item});

  @override
  State<DuaAudioCard> createState() => _DuaAudioCardState();
}

class _DuaAudioCardState extends State<DuaAudioCard> {
  // وضعیت درگ کردن اسلایدر توسط کاربر
  bool _isDragging = false;
  double _dragValueMs = 0.0;

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  int _parseDurationTextToMs(String text) {
    try {
      final parts = text.trim().split(':');
      if (parts.length == 2) {
        final m = int.tryParse(parts[0]) ?? 0;
        final s = int.tryParse(parts[1]) ?? 0;
        return (m * 60 + s) * 1000;
      } else if (parts.length == 3) {
        final h = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 0;
        final s = int.tryParse(parts[2]) ?? 0;
        return (h * 3600 + m * 60 + s) * 1000;
      }
    } catch (_) {}
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final controller = Get.find<DuasController>();
    final item = widget.item;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(10) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withAlpha(15)
              : colorScheme.onPrimary.withAlpha(20),
          width: 1.0,
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(6),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // هدر کارت شامل دکمه پخش، عنوان، مداح/قاری و مدت زمان
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // دکمه پخش / مکث صوت (ایزوله در Obx اختصاصی)
                Obx(() {
                  final isActive = controller.activePlayingId.value == item.id;
                  final isPlaying = isActive && controller.isPlaying.value;
                  final isLoading = isActive && controller.isLoadingAudio.value;

                  return ZoomTapAnimation(
                    onTap: () => controller.togglePlayAudio(item),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? colorScheme.onPrimary
                            : colorScheme.onPrimary.withAlpha(20),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: colorScheme.onPrimary.withAlpha(60),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isPlaying ? Colors.white : colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                size: 26,
                                color: isPlaying ? Colors.white : colorScheme.onPrimary,
                              ),
                      ),
                    ),
                  );
                }),

                const Gap(12),

                // عنوان و نام قاری
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'IBMPlexSansArabic',
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (item.reciter.trim().isNotEmpty) ...[
                        const Gap(3),
                        Row(
                          children: [
                            Icon(
                              Icons.mic_none_rounded,
                              size: 13,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                            const Gap(4),
                            Expanded(
                              child: Text(
                                item.reciter,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // نشان مدت زمان
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                      const Gap(4),
                      Text(
                        item.durationText,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'IBMPlexSansArabic',
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // نوار پیشرفت صوت با لایه بافر دانلود شده + اسلایدر تعاملی مستقل از رفرش
          Obx(() {
            final isActive = controller.activePlayingId.value == item.id;
            if (!isActive) return const SizedBox.shrink();

            final position = controller.position.value;
            final duration = controller.duration.value;
            final buffered = controller.bufferedPosition.value;

            final posMs = position.inMilliseconds;
            int totalMs = duration.inMilliseconds;

            if (totalMs <= 0 && item.estimatedDuration != null) {
              totalMs = item.estimatedDuration!.inMilliseconds;
            }

            if (totalMs <= 0) {
              totalMs = _parseDurationTextToMs(item.durationText);
            }

            final double maxMs = (totalMs > 0)
                ? (posMs > totalMs ? posMs.toDouble() : totalMs.toDouble())
                : (posMs > 0 ? (posMs + 2000).toDouble() : 1000.0);

            // در صورتی که کاربر در حال درگ کردن است، مقدار لحظه‌ای درگ استفاده می‌شود
            final double currentMs = _isDragging
                ? _dragValueMs.clamp(0.0, maxMs)
                : posMs.clamp(0, maxMs.toInt()).toDouble();

            // نسبت بافر / دانلود شده واقعی بر اساس فایل کش یا دانلود لحظه‌ای
            final bool isCached = controller.isItemCached(item.id);
            final double dlProgress = controller.downloadProgress[item.id] ?? 0.0;
            final double bufferRatio = isCached
                ? 1.0
                : (dlProgress > 0
                    ? dlProgress
                    : (maxMs > 0 ? (buffered.inMilliseconds / maxMs).clamp(0.0, 1.0) : 0.0));
            final int bufferPercent = (bufferRatio * 100).toInt().clamp(0, 100);

            // زمانی که در لیبل چپ نشان داده می‌شود
            final displayPosition = _isDragging
                ? Duration(milliseconds: _dragValueMs.toInt())
                : position;

            return Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 6),
              child: Column(
                children: [
                  // لایه‌بندی ترکیبی: نوار بافر دانلود شده در زیر + اسلایدر با ترک ترنسپرنت روی آن
                  SizedBox(
                    height: 28,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // ۱. لایه زیرین: ترک پس‌زمینه + پیشرفت بافر دانلود
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2.5),
                            child: SizedBox(
                              height: 3.5,
                              child: LayoutBuilder(
                                builder: (context, trackConstraints) {
                                  final trackWidth = trackConstraints.maxWidth;
                                  return Stack(
                                    children: [
                                      // پس‌زمینه کل مسیر
                                      Container(
                                        width: trackWidth,
                                        color: isDark
                                            ? Colors.white.withAlpha(20)
                                            : colorScheme.onPrimary.withAlpha(25),
                                      ),
                                      // نوار دانلود شده / بافر
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        width: trackWidth * bufferRatio,
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? colorScheme.onPrimary.withAlpha(100)
                                              : colorScheme.onPrimary.withAlpha(65),
                                          borderRadius: BorderRadius.circular(2.5),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // ۲. لایه رویی: اسلایدر تعاملی فلاتر
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.5,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 13),
                            activeTrackColor: colorScheme.onPrimary,
                            inactiveTrackColor: Colors.transparent, // شفاف تا نوار بافر زیرین دیده شود
                            thumbColor: colorScheme.onPrimary,
                          ),
                          child: Slider(
                            min: 0.0,
                            max: maxMs > 0 ? maxMs : 1000.0,
                            value: currentMs.clamp(0.0, maxMs > 0 ? maxMs : 1000.0),
                            onChangeStart: (val) {
                              setState(() {
                                _isDragging = true;
                                _dragValueMs = val;
                              });
                            },
                            onChanged: (val) {
                              setState(() {
                                _dragValueMs = val;
                              });
                            },
                            onChangeEnd: (val) {
                              final targetMs = val.toInt();
                              final maxBufferedMs = controller.bufferedPosition.value.inMilliseconds;

                              // اگر فایل کامل دانلود شده یا نقطه انتخابی تا سقف دانلود شده است، در لحظه پلی می‌شود
                              if (isCached || maxBufferedMs <= 0 || targetMs <= maxBufferedMs) {
                                controller.seekAudio(Duration(milliseconds: targetMs));
                              } else {
                                // در صورتی که کاربر به بعد از بخش دانلود شده کشید، تا سقف بافر دانلود شده هدایت می‌شود
                                controller.seekAudio(Duration(milliseconds: maxBufferedMs));
                              }
                              setState(() {
                                _isDragging = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ردیف اطلاعات: زمان پخش فعلی | درصد دانلود بافر | کل زمان
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زمان پخش فعلی (در حین درگ، زمان انتخابی را پررنگ نشان می‌دهد)
                        Text(
                          _formatDuration(displayPosition),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontFamily: 'IBMPlexSansArabic',
                            fontWeight: _isDragging ? FontWeight.bold : FontWeight.w500,
                            color: _isDragging
                                ? colorScheme.onPrimary
                                : (isDark ? Colors.grey[400] : Colors.grey[600]),
                          ),
                        ),

                        // نشانگر درصد بافر دانلود شده
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              (isCached || bufferPercent >= 100)
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.cloud_download_rounded,
                              size: 11,
                              color: (isCached || bufferPercent >= 100)
                                  ? colorScheme.onPrimary
                                  : (isDark ? Colors.grey[500] : Colors.grey[600]),
                            ),
                            const Gap(3),
                            Text(
                              (isCached || bufferPercent >= 100)
                                  ? 'محمّل بالكامل'
                                  : 'تم التحميل: $bufferPercent%',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontFamily: 'IBMPlexSansArabic',
                                color: (isCached || bufferPercent >= 100)
                                    ? colorScheme.onPrimary
                                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),

                        // کل زمان صوت
                        Text(
                          totalMs > 0
                              ? _formatDuration(Duration(milliseconds: totalMs))
                              : (item.durationText.isNotEmpty ? item.durationText : '--:--'),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontFamily: 'IBMPlexSansArabic',
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          // دکمه باز و بسته کردن متن و محتوای متن دعا
          if (item.hasText)
            Column(
              children: [
                const Divider(height: 1, thickness: 0.5),

                // دکمه باز/بستن (در Obx اختصاصی)
                Obx(() {
                  final isExpanded = controller.isTextExpanded(item.id);

                  return ZoomTapAnimation(
                    onTap: () => controller.toggleExpandText(item.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      color: isExpanded
                          ? colorScheme.onPrimary.withAlpha(12)
                          : Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isExpanded
                                ? Icons.menu_book_rounded
                                : Icons.auto_stories_outlined,
                            size: 15,
                            color: colorScheme.onPrimary,
                          ),
                          const Gap(6),
                          Text(
                            isExpanded ? 'إخفاء نص الدعاء' : 'عرض نص الدعاء للقراءة مع الاستماع',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBMPlexSansArabic',
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          const Gap(4),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: colorScheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                // بدنه متن باز شونده (در Obx اختصاصی)
                Obx(() {
                  final isExpanded = controller.isTextExpanded(item.id);
                  if (!isExpanded) return const SizedBox.shrink();

                  return Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withAlpha(30)
                          : colorScheme.onPrimary.withAlpha(8),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.onPrimary.withAlpha(20),
                        width: 0.8,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // نوار ابزار بالای متن (عنوان، کنترل سایز فونت و دکمه کپی)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 13,
                                  color: colorScheme.onPrimary,
                                ),
                                const Gap(5),
                                Text(
                                  'نص ${item.title}:',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'IBMPlexSansArabic',
                                    color: colorScheme.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // کنترل اندازه قلم
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.white.withAlpha(12)
                                        : colorScheme.onPrimary.withAlpha(14),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: colorScheme.onPrimary.withAlpha(25),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          canRequestFocus: false,
                                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(7)),
                                          onTap: controller.decreaseDuaFontSize,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                            child: Icon(
                                              Icons.remove_rounded,
                                              size: 16,
                                              color: colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        child: Obx(
                                          () => Text(
                                            '${controller.duaFontSize.value.toInt()}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontFamily: 'IBMPlexSansArabic',
                                              fontWeight: FontWeight.bold,
                                              color: colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          canRequestFocus: false,
                                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
                                          onTap: controller.increaseDuaFontSize,
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                                            child: Icon(
                                              Icons.add_rounded,
                                              size: 16,
                                              color: colorScheme.onPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const Gap(8),

                                // دکمه کپی متن
                                ZoomTapAnimation(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                      text: '【${item.title}】\n\n${item.text}\n\nعبر تطبيق السراج',
                                    ));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'تم نسخ نص الدعاء إلى الحافظة',
                                          style: TextStyle(fontFamily: 'IBMPlexSansArabic'),
                                        ),
                                        duration: Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.copy_rounded,
                                        size: 13,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                      const Gap(4),
                                      Text(
                                        'نسخ',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontFamily: 'IBMPlexSansArabic',
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const Gap(10),

                        // متن دعا
                        Obx(
                          () => Text(
                            item.text!,
                            textAlign: TextAlign.start,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: controller.duaFontSize.value,
                              height: 2.0,
                              fontFamily: 'IBMPlexSansArabic',
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
        ],
      ),
    );
  }
}
