import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import 'package:mawsueat/app/core/common/widgets/empty_widget.dart';
import 'package:mawsueat/app/features/favorite%20&%20comment/view/controller/favorite_controller.dart';
import 'package:mawsueat/app/features/favorite%20&%20comment/view/widgets/comment_widget.dart';
import 'package:mawsueat/app/features/favorite%20&%20comment/view/widgets/favority_widget.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key, required this.isDrawer});
  final bool isDrawer;
  @override
  Widget build(BuildContext context) {
    final FavoriteController favoriteController = Get.put(FavoriteController());
    double containerWidth = MediaQuery.of(context).size.width - 40;
    double itemWidth = (containerWidth / 2) - 5;

    return Scaffold(
      appBar: isDrawer ? AppBar(title: Text(Constants.appTitle)) : null,
      body: Column(
        children: [
          // TABS
          Container(
            width: containerWidth,
            height: 50,
            margin: EdgeInsets.all(20).copyWith(top: 5),
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              borderRadius: BorderRadius.circular(10),
              color: Theme.of(context).colorScheme.onPrimary.withAlpha(100),
            ),
            child: Obx(
              () => Stack(
                children: [
                  AnimatedPositioned(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    left:
                        (favoriteController.selectedTabIndex.value * itemWidth),
                    top: 0,
                    child: Container(
                      width: itemWidth,
                      height: 40,
                      decoration: Constants.containerBoxDecoration(
                        context,
                      ).copyWith(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ZoomTapAnimation(
                          onTap: () => favoriteController.changeTab(1),
                          child: Center(
                            child: Text(
                              'اشارات مرجعية',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 13.5,
                                fontWeight:
                                    favoriteController.selectedTabIndex.value == 1
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                color:
                                    favoriteController.selectedTabIndex.value == 1
                                        ? Colors.white
                                        : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: ZoomTapAnimation(
                          onTap: () => favoriteController.changeTab(0),
                          child: Center(
                            child: Text(
                              'تعليقات',
                              style: TextStyle(
                                fontFamily: 'IBMPlexSansArabic',
                                fontSize: 13.5,
                                fontWeight:
                                    favoriteController.selectedTabIndex.value == 0
                                        ? FontWeight.bold
                                        : FontWeight.w500,
                                color:
                                    favoriteController.selectedTabIndex.value == 0
                                        ? Colors.white
                                        : Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (favoriteController.selectedTabIndex.value == 0) {
                return favoriteController.commentsList.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 115),
                        itemCount: favoriteController.commentsList.length,
                        itemBuilder: (context, index) {
                          return CommentContainer(
                            comment: favoriteController.commentsList[index],
                          );
                        },
                      )
                    : EmptyWidget(title: 'لم تتم اضافة عناصر');
              } else {
                return favoriteController.bookmarksList.isNotEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 115),
                        itemCount: favoriteController.bookmarksList.length,
                        itemBuilder: (context, index) {
                          final bookmark =
                              favoriteController.bookmarksList[index];
                          final int bookId = bookmark['bookId'] is int
                              ? bookmark['bookId']
                              : (int.tryParse(bookmark['bookId']?.toString() ?? '1') ?? 1);
                          final int pageNum = bookmark['pageNumber'] is int
                              ? bookmark['pageNumber']
                              : (int.tryParse(bookmark['pageNumber']?.toString() ?? '0') ?? 0);
                          return FavorityContainer(
                            bookId: bookId,
                            bookName: (bookmark['bookName'] ?? '').toString(),
                            pageNumber: (pageNum + 1).toString(),
                            index: index,
                          );
                        },
                      )
                    : EmptyWidget(title: 'لم تتم اضافة عناصر');
              }
            }),
          ),
        ],
      ),
    );
  }
}
