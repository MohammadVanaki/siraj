import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/library/controller/library_controller.dart';
import 'package:mawsueat/app/features/library/data/models/bookmarked_page_model.dart';
import 'package:mawsueat/app/features/library/view/widgets/book_cover_3d.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class BookmarkedPageCardWidget extends StatelessWidget {
  final BookmarkedPageModel bookmark;

  const BookmarkedPageCardWidget({
    super.key,
    required this.bookmark,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.onPrimary;
    final controller = Get.find<LibraryController>();

    return ZoomTapAnimation(
      onTap: () => controller.openBookmarkedPage(bookmark),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.dividerTheme.color ?? Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row: Book cover thumbnail + Title & Chapter + Bookmark remove button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mini 3D Cover
                BookCover3D(
                  coverUrl: bookmark.bookCoverUrl,
                  width: 44,
                  height: 60,
                  pageThickness: 3.5,
                  cornerRadius: 4.0,
                ),
                const Gap(12),

                // Info: Book Title, Chapter, Page Chip
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bookmark.bookTitle,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Gap(4),
                      if (bookmark.chapterTitle.isNotEmpty) ...[
                        Text(
                          bookmark.chapterTitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Gap(4),
                      ],
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.bookmark_rounded,
                                  size: 13,
                                  color: primaryColor,
                                ),
                                const Gap(4),
                                Text(
                                  'صفحة ${bookmark.pageNumber}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (bookmark.bookAuthor.isNotEmpty) ...[
                            const Gap(8),
                            Expanded(
                              child: Text(
                                bookmark.bookAuthor,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: theme.colorScheme.secondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Delete Bookmark Button
                ZoomTapAnimation(
                  onTap: () {
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: const Text(
                          'إزالة العلامة المرجعية',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'هل أنت متأكد من حذف الإشارة المرجعية لصفحة ${bookmark.pageNumber} من كتاب "${bookmark.bookTitle}"؟',
                          style: const TextStyle(fontSize: 13.5),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: const Text('إلغاء'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              Get.back();
                              controller.removeBookmark(
                                bookmark.bookId,
                                bookmark.pageNumber,
                              );
                            },
                            child: const Text('حذف'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_remove_rounded,
                      size: 18,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),

            // Text Snippet Preview (if available)
            if (bookmark.snippet.isNotEmpty) ...[
              const Gap(10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.dividerTheme.color?.withValues(alpha: 0.5) ??
                        Colors.grey.shade100,
                  ),
                ),
                child: Text(
                  '« ${bookmark.snippet} »',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
