import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mawsueat/app/features/gallery/controller/gallery_controller.dart';
import 'package:mawsueat/app/features/gallery/data/models/gallery_item_model.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class PhotoDetailPage extends StatefulWidget {
  final GalleryItemModel item;

  const PhotoDetailPage({super.key, required this.item});

  @override
  State<PhotoDetailPage> createState() => _PhotoDetailPageState();
}

class _PhotoDetailPageState extends State<PhotoDetailPage> {
  late GalleryItemModel _item;
  late PageController _pageController;
  int _currentIndex = 0;
  bool _isLoadingDetails = false;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _pageController = PageController();

    if (_item.images.isEmpty && _item.id.isNotEmpty) {
      _loadDetails();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoadingDetails = true);
    final controller = Get.find<GalleryController>();
    final detailed = await controller.loadAlbumDetail(_item.id);
    if (mounted && detailed != null) {
      setState(() {
        _item = detailed;
        _isLoadingDetails = false;
      });
    } else if (mounted) {
      setState(() => _isLoadingDetails = false);
    }
  }

  List<String> get _imageUrls {
    if (_item.images.isNotEmpty) {
      return _item.images.map((img) => img.imageUrl).toList();
    }
    if (_item.imageUrl.isNotEmpty) {
      return [_item.imageUrl];
    }
    return [];
  }

  String get _currentImageUrl {
    final urls = _imageUrls;
    if (urls.isEmpty) return '';
    if (_currentIndex < urls.length) return urls[_currentIndex];
    return urls.first;
  }

  String? get _currentCaption {
    if (_item.images.isNotEmpty && _currentIndex < _item.images.length) {
      final caption = _item.images[_currentIndex].captionArabic;
      if (caption != null && caption.trim().isNotEmpty) {
        return caption.trim();
      }
    }
    return _item.subtitle;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GalleryController>();
    final urls = _imageUrls;
    final totalCount = urls.length;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image / PageView
          if (urls.isEmpty)
            Center(
              child: _isLoadingDetails
                  ? LoadingAnimationWidget.threeArchedCircle(
                      size: 32,
                      color: Colors.white,
                    )
                  : const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_rounded, color: Colors.white54, size: 48),
                        Gap(10),
                        Text('لا توجد صور متاحة', style: TextStyle(color: Colors.white70)),
                      ],
                    ),
            )
          else
            PageView.builder(
              controller: _pageController,
              itemCount: totalCount,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentIndex = index);
              },
              itemBuilder: (context, index) {
                final url = urls[index];
                return Center(
                  child: InteractiveViewer(
                    minScale: 0.8,
                    maxScale: 4.0,
                    clipBehavior: Clip.none,
                    child: url.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Center(
                              child: LoadingAnimationWidget.threeArchedCircle(
                                size: 28,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) => Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.broken_image_rounded, color: Colors.white54, size: 48),
                                  const Gap(10),
                                  Text(
                                    _item.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'IBMPlexSansArabic',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Gap(4),
                                  const Text(
                                    'تعذر تحميل الصورة عبر الإنترنت',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontFamily: 'IBMPlexSansArabic',
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Image.asset(
                            url,
                            fit: BoxFit.contain,
                          ),
                  ),
                );
              },
            ),

          // Top Floating Navigation Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                bottom: 16,
                left: 16,
                right: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(200),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  ZoomTapAnimation(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Get.back();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 0.5),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Row(
                    children: [
                      // Photo counter (e.g., 2 / 5)
                      if (totalCount > 1)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(160),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24, width: 0.5),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / $totalCount',
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                      // Category tag
                      if (_item.categoryTitle != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(30),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24, width: 0.5),
                          ),
                          child: Text(
                            _item.categoryTitle!,
                            style: const TextStyle(
                              fontFamily: 'IBMPlexSansArabic',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Floating Info & Action Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                top: 20,
                left: 20,
                right: 20,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withAlpha(230),
                    Colors.black.withAlpha(160),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _item.title,
                    style: const TextStyle(
                      fontFamily: 'IBMPlexSansArabic',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (_currentCaption != null) ...[
                    const Gap(6),
                    Text(
                      _currentCaption!,
                      style: const TextStyle(
                        fontFamily: 'IBMPlexSansArabic',
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const Gap(16),

                  // Action Buttons Row
                  Row(
                    children: [
                      // Like Action
                      Obx(() {
                        final currentItem = controller.images.firstWhereOrNull(
                          (element) => element.id == _item.id,
                        );
                        final isFav = currentItem?.isFavorite ?? _item.isFavorite;
                        final likesCount = currentItem?.likesCount ?? _item.likesCount;

                        return ZoomTapAnimation(
                          onTap: () => controller.toggleFavorite(currentItem ?? _item),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isFav ? Colors.redAccent.withAlpha(50) : Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isFav ? Colors.redAccent : Colors.white24,
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isFav ? Colors.redAccent : Colors.white,
                                  size: 18,
                                ),
                                if (likesCount > 0) ...[
                                  const Gap(6),
                                  Text(
                                    '$likesCount',
                                    style: TextStyle(
                                      fontFamily: 'IBMPlexSansArabic',
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isFav ? Colors.redAccent : Colors.white,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),

                      const Gap(10),

                      // Share Button
                      Expanded(
                        child: ZoomTapAnimation(
                          onTap: () {
                            final currentModel = _item.copyWith(imageUrl: _currentImageUrl);
                            controller.shareImage(currentModel);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(25),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white24, width: 0.8),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.share_rounded, color: Colors.white, size: 18),
                                Gap(6),
                                Text(
                                  'مشاركة',
                                  style: TextStyle(
                                    fontFamily: 'IBMPlexSansArabic',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const Gap(10),

                      // Copy Link Button
                      ZoomTapAnimation(
                        onTap: () {
                          final currentModel = _item.copyWith(imageUrl: _currentImageUrl);
                          controller.copyImageUrl(currentModel);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: const Icon(
                            Icons.link_rounded,
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
          ),
        ],
      ),
    );
  }
}
