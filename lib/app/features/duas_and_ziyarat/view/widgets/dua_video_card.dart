import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import '../../data/models/dua_media_item.dart';

class DuaVideoCard extends StatelessWidget {
  final DuaVideoItem item;
  final EdgeInsetsGeometry? margin;

  const DuaVideoCard({
    super.key,
    required this.item,
    this.margin,
  });

  Future<void> _handleTap(BuildContext context) async {
    if (item.videoUrl.trim().isNotEmpty) {
      final uri = Uri.tryParse(item.videoUrl.trim());
      if (uri != null) {
        try {
          final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
          if (launched) return;
        } catch (_) {
          final fallbackLaunched = await launchUrl(uri);
          if (fallbackLaunched) return;
        }
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${item.title}: لا يوجد رابط تشغيل متاح حالياً',
            style: const TextStyle(fontFamily: 'IBMPlexSansArabic'),
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final hasThumbnail = item.thumbnailUrl != null && item.thumbnailUrl!.trim().isNotEmpty;

    return ZoomTapAnimation(
      onTap: () => _handleTap(context),
      child: Container(
        margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // قاب ویدیویی استاندارد ۱۶:۹ با نشان پخش
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.onPrimary.withAlpha(170),
                      colorScheme.onPrimary.withAlpha(245),
                    ],
                  ),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // تصویر بندانگشتی در صورت وجود
                    if (hasThumbnail)
                      CachedNetworkImage(
                        imageUrl: item.thumbnailUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const SizedBox(),
                      ),

                    // لایه تیره یا گرادیانت برای وضوح آیکون و نوشته‌ها
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(hasThumbnail ? 60 : 20),
                            Colors.black.withAlpha(hasThumbnail ? 130 : 60),
                          ],
                        ),
                      ),
                    ),

                    // دکمه وسط پخش ویدیو
                    Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(hasThumbnail ? 65 : 45),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withAlpha(150),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 32,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    // نشان یوتوب در صورت ویدیو یوتیوب
                    if (item.isYouTube)
                      Positioned(
                        top: 8,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF0000).withAlpha(220),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_arrow_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              Gap(3),
                              Text(
                                'YouTube',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'IBMPlexSansArabic',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // نشان مدت زمان ویدیو در گوشه
                    if (item.durationText.isNotEmpty && item.durationText != '--:--')
                      Positioned(
                        bottom: 8,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(160),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 11,
                                color: Colors.white,
                              ),
                              const Gap(4),
                              Text(
                                item.durationText,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontFamily: 'IBMPlexSansArabic',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // اطلاعات زیرین ویدیو (عنوان و راوی/قاری)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'IBMPlexSansArabic',
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.reciter.isNotEmpty || (item.categoryNameArabic != null && item.categoryNameArabic!.isNotEmpty)) ...[
                          const Gap(4),
                          Row(
                            children: [
                              Icon(
                                item.reciter.isNotEmpty ? Icons.person_outline_rounded : Icons.label_outline_rounded,
                                size: 13,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              const Gap(4),
                              Expanded(
                                child: Text(
                                  item.reciter.isNotEmpty ? item.reciter : (item.categoryNameArabic ?? ''),
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
                  const Gap(8),
                  Icon(
                    item.isYouTube ? Icons.smart_display_rounded : Icons.play_circle_outline_rounded,
                    size: 24,
                    color: item.isYouTube ? const Color(0xFFE53935) : colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
