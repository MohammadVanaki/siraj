import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/confirm_action_dialog.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import 'package:mawsueat/app/features/favorite%20&%20comment/view/controller/favorite_controller.dart';
import 'package:mawsueat/app/features/home/view/controller/content_controller.dart';
import 'package:mawsueat/app/features/home/view/controller/navigation_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class FavorityContainer extends StatelessWidget {
  final String bookName;
  final int bookId;
  final String pageNumber;
  final int index;

  const FavorityContainer({
    super.key,
    required this.bookName,
    required this.bookId,
    required this.pageNumber,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final favoriteController = Get.find<FavoriteController>();

    return ZoomTapAnimation(
      onTap: () {
        final ContentController contentController =
            Get.find<ContentController>();
        final int targetPageIndex =
            (int.tryParse(pageNumber) ?? 1) - 1;

        int targetTextId = 0;
        int targetBookId = bookId;

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

        // ۱. باز کردن گروه اصلی و اکاردئون سرفصل بوک‌مارک شده
        if (targetTextId != 0) {
          contentController.expandTopic(
            bookId: targetBookId,
            textId: targetTextId,
          );
        } else {
          contentController.toggleGroupExpansion(targetBookId);
        }

        // ۲. بازنشانی جستجو تا فهرست کامل باشد
        contentController.searchQuery.value = '';

        // ۳. اگر صفحه روی استک باز شده، برگردد
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
        padding: const EdgeInsets.all(10),
        decoration: Constants.containerBoxDecoration(context).copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
        child: Row(
          children: [
            Icon(
              Icons.auto_stories_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const Gap(10),
            Expanded(
              child: Text(
                bookName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBMPlexSansArabic',
                ),
              ),
            ),
            const Gap(10),
            ZoomTapAnimation(
              onTap: () {
                showConfirmationDialog(
                  title: 'حذف الإشارة المرجعية',
                  message: 'هل انت متأكد من حذف الاشارة المرجعية؟',
                  onConfirm: () {
                    favoriteController.removeBookmarkAt(
                        bookId, int.parse(pageNumber) - 1);
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
          ],
        ),
      ),
    );
  }
}
