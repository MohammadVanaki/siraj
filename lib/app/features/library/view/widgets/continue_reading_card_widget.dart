import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/library/controller/library_controller.dart';
import 'package:mawsueat/app/features/library/data/models/book_model.dart';
import 'package:mawsueat/app/features/library/view/screens/book_detail_page.dart';
import 'package:mawsueat/app/features/library/view/widgets/book_cover_3d.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class ContinueReadingCardWidget extends StatelessWidget {
  final BookModel book;

  const ContinueReadingCardWidget({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.onPrimary;

    return ZoomTapAnimation(
      onTap: () {
        if (Get.isRegistered<LibraryController>()) {
          Get.find<LibraryController>().openBookForReading(book);
        } else {
          Get.to(() => BookDetailPage(book: book));
        }
      },
      child: Container(
        width: 290,
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            // 3D Cover Image
            BookCover3D(
              coverUrl: book.coverUrl,
              width: 58,
              height: 82,
              pageThickness: 4.5,
              cornerRadius: 4.0,
            ),
            const Gap(12),

            // Info & Progress
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Gap(3),
                  Text(
                    'صفحة ${book.lastReadPage} من ${book.totalPages}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  const Gap(8),

                  // Progress Bar & Percentage
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: book.readProgress,
                            backgroundColor: theme.colorScheme.surface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              primaryColor,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const Gap(8),
                      Text(
                        '${book.readProgressPercent}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const Gap(6),

                  // Resume button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        'متابعة القراءة',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const Gap(2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 11,
                        color: primaryColor,
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
