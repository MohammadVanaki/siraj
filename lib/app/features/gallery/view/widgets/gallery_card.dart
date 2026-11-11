import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mawsueat/app/features/gallery/controller/gallery_controller.dart';
import 'package:mawsueat/app/features/gallery/data/models/gallery_item_model.dart';
import 'package:mawsueat/app/features/gallery/view/screens/photo_detail_page.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class GalleryCard extends StatelessWidget {
  final GalleryItemModel item;

  const GalleryCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GalleryController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ZoomTapAnimation(
      onTap: () => Get.to(() => PhotoDetailPage(item: item)),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242020) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.black.withAlpha(10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 40 : 10),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image with Overlays
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  item.imageUrl.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: isDark ? Colors.white10 : Colors.black.withAlpha(8),
                            child: Center(
                              child: LoadingAnimationWidget.threeArchedCircle(
                                size: 18,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  colorScheme.onPrimary.withAlpha(isDark ? 80 : 50),
                                  colorScheme.onPrimary.withAlpha(isDark ? 30 : 15),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_stories_rounded,
                                    color: colorScheme.onPrimary,
                                    size: 30,
                                  ),
                                  const Gap(6),
                                  Text(
                                    item.title,
                                    maxLines: 1,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexSansArabic',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : Image.asset(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: colorScheme.onPrimary.withAlpha(30),
                            child: Icon(Icons.image_rounded, color: colorScheme.onPrimary),
                          ),
                        ),

                  // Gradient shade for text readability
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(70),
                            Colors.transparent,
                            Colors.black.withAlpha(140),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Top Category Tag
                  if (item.categoryTitle != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(140),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white24, width: 0.5),
                        ),
                        child: Text(
                          item.categoryTitle!,
                          style: const TextStyle(
                            fontFamily: 'IBMPlexSansArabic',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  // Top Favorite / Like Action Button
                  Positioned(
                    top: 8,
                    left: 8,
                    child: ZoomTapAnimation(
                      onTap: () => controller.toggleFavorite(item),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(140),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 0.5),
                        ),
                        child: Icon(
                          item.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 16,
                          color: item.isFavorite ? Colors.redAccent : Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // Bottom views & likes row inside image
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (item.imageCount > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(150),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.white24, width: 0.5),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.photo_library_rounded,
                                  size: 11,
                                  color: Colors.white,
                                ),
                                const Gap(4),
                                Text(
                                  '${item.imageCount}',
                                  style: const TextStyle(
                                    fontFamily: 'IBMPlexSansArabic',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                        if (item.likesCount > 0)
                          Row(
                            children: [
                              const Icon(
                                Icons.favorite_rounded,
                                size: 12,
                                color: Colors.redAccent,
                              ),
                              const Gap(4),
                              Text(
                                '${item.likesCount}',
                                style: const TextStyle(
                                  fontFamily: 'IBMPlexSansArabic',
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Card Footer Title
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (item.subtitle != null) ...[
                    const Gap(2),
                    Text(
                      item.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 10.5,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
