import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/confirm_action_dialog.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import 'package:mawsueat/app/features/favorite%20&%20comment/view/controller/favorite_controller.dart';
import 'package:mawsueat/app/features/home/repository/modal_comment.dart';
import 'package:mawsueat/app/features/home/view/controller/content_controller.dart';
import 'package:mawsueat/app/features/home/view/controller/navigation_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';
import 'package:intl/intl.dart';

class CommentContainer extends StatelessWidget {
  const CommentContainer({super.key, required this.comment});

  final Map<String, dynamic> comment;

  @override
  Widget build(BuildContext context) {
    DateTime createdAt = DateTime.tryParse(comment['createdAt']?.toString() ?? '') ??
        DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(createdAt);
    final FavoriteController favoriteController =
        Get.find<FavoriteController>();

    final int idPage = comment['idPage'] is int
        ? comment['idPage']
        : (int.tryParse(comment['idPage']?.toString() ?? '1') ?? 1);
    final int idBook = comment['idBook'] is int
        ? comment['idBook']
        : (int.tryParse(comment['idBook']?.toString() ?? '1') ?? 1);

    return ZoomTapAnimation(
      onTap: () {
        final ContentController contentController =
            Get.find<ContentController>();

        final int targetPageIndex = idPage - 1;
        int targetTextId = 0;
        int targetBookId = idBook;

        if (targetPageIndex >= 0 &&
            targetPageIndex < contentController.pages.length) {
          final p = contentController.pages[targetPageIndex];
          targetTextId = p['id'] is int
              ? p['id']
              : (int.tryParse(p['id']?.toString() ?? '0') ?? 0);
          final bid = p['bid'] is int
              ? p['bid']
              : (int.tryParse(p['bid']?.toString() ?? '0') ?? 0);
          if (bid != 0) targetBookId = bid;
        }

        // ۱. باز کردن گروه اصلی و سرفصل مربوطه در صفحه موضوعات
        if (targetTextId != 0) {
          contentController.expandTopic(
            bookId: targetBookId,
            textId: targetTextId,
          );
        } else {
          contentController.toggleGroupExpansion(targetBookId);
        }

        // ۲. پاک کردن سرچ احتمالی
        contentController.searchQuery.value = '';

        // ۳. بازگشت در صورت باز بودن دراور/استک
        if (Get.key.currentState?.canPop() ?? false) {
          Get.back();
        }

        // ۴. رفتن به تب اول (صفحه موضوعات / خانه)
        if (Get.isRegistered<BottmNavigationController>()) {
          Get.find<BottmNavigationController>().goToPage(0);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: Constants.containerBoxDecoration(context).copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.comment_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const Gap(8),
                Expanded(
                  child: Text(
                    comment['bookName'] ?? 'بدون عنوان',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onPrimary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'ص $idPage',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onPrimary.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((comment['title'] ?? '').toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(
                        'العنوان: ${comment['title']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          fontFamily: 'IBMPlexSansArabic',
                        ),
                      ),
                    ),
                  Text(
                    '${comment['comment'] ?? ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontFamily: 'IBMPlexSansArabic',
                    ),
                  ),
                ),
                ZoomTapAnimation(
                  onTap: () {
                    showConfirmationDialog(
                      title: 'حذف التعليق',
                      message: 'هل أنت متأكد من أنك تريد حذف هذا التعليق؟',
                      onConfirm: () {
                        favoriteController.deleteComment(comment['id']);
                      },
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/svgs/trash-empty.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onPrimary,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                  ),
                ),
                const Gap(12),
                ZoomTapAnimation(
                  onTap: () {
                    ModalComment.show(
                      context,
                      updateMode: true,
                      id: comment['id'] is int
                          ? comment['id']
                          : (int.tryParse(comment['id']?.toString() ?? '0') ?? 0),
                      idPage: idPage,
                      idBook: idBook,
                      bookname: comment['bookName'] ?? '',
                      oldTitle: comment['title'],
                      oldComment: comment['comment'],
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/svgs/file-edit.svg',
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.onPrimary,
                      BlendMode.srcIn,
                    ),
                    width: 20,
                    height: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
