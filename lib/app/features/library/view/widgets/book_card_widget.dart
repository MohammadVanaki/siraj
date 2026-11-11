import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mawsueat/app/features/library/controller/library_controller.dart';
import 'package:mawsueat/app/features/library/data/models/book_model.dart';
import 'package:mawsueat/app/features/library/view/screens/book_detail_page.dart';
import 'package:mawsueat/app/features/library/view/widgets/book_cover_3d.dart';
import 'package:mawsueat/app/features/library/view/widgets/book_rating_bar_widget.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class BookCardWidget extends StatelessWidget {
  final BookModel book;

  const BookCardWidget({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.onPrimary;

    return ZoomTapAnimation(
      onTap: () {
        Get.to(() => BookDetailPage(book: book));
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 3D Book Cover with Spine, Page Thickness & Badges
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 4, 6, 6),
                child: BookCover3D(
                  coverUrl: book.coverUrl,
                  heroTag: 'book_cover_${book.id}',
                  categoryBadge: Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        book.categoryName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  favoriteBadge: Positioned(
                    top: 8,
                    right: 8,
                    child: Obx(() {
                      final isFav = Get.isRegistered<LibraryController>()
                          ? Get.find<LibraryController>().isBookFavorite(book.id)
                          : book.isFavorite;

                      return ZoomTapAnimation(
                        onTap: () {
                          if (Get.isRegistered<LibraryController>()) {
                            Get.find<LibraryController>().toggleBookFavorite(book.id);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_outline_rounded,
                            color: isFav ? Colors.redAccent : Colors.white,
                            size: 16,
                          ),
                        ),
                      );
                    }),
                  ),
                  progressBadge: (book.isDownloaded || book.hasStartedReading)
                      ? Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: book.hasStartedReading ? 6 : 4,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                                width: 0.7,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 17,
                                  height: 17,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (book.hasStartedReading)
                                        CircularProgressIndicator(
                                          value: book.readProgress,
                                          strokeWidth: 1.8,
                                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            book.readProgressPercent >= 100
                                                ? Colors.greenAccent
                                                : primaryColor,
                                          ),
                                        ),
                                      Container(
                                        width: book.hasStartedReading ? 11 : 13,
                                        height: book.hasStartedReading ? 11 : 13,
                                        decoration: BoxDecoration(
                                          color: book.isDownloaded
                                              ? const Color(0xFF10B981)
                                              : primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          book.isDownloaded
                                              ? Icons.check_rounded
                                              : Icons.auto_stories_rounded,
                                          size: book.hasStartedReading ? 7.5 : 9,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (book.hasStartedReading) ...[
                                  const Gap(4),
                                  Text(
                                    '${book.lastReadPage}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      height: 1.1,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        )
                      : null,
                  progressBar: book.hasStartedReading
                      ? Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(0)),
                            child: LinearProgressIndicator(
                              value: book.readProgress,
                              backgroundColor: Colors.white.withValues(alpha: 0.3),
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                              minHeight: 3.5,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),

            // Book Details (Title, Author, Rating)
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 6, 4, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Gap(3),
                  Text(
                    book.entriesCount > 0
                        ? '${book.entriesCount} مدخل'
                        : (book.author.isNotEmpty ? book.author : 'موسوعة أهل البيت (ع)'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const Gap(6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BookRatingBarWidget(
                        rating: book.rating,
                        size: 13,
                      ),
                      Text(
                        book.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
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
    );
  }
}
