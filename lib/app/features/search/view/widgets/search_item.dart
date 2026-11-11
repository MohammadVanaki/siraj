import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/config/functions.dart';
import 'package:mawsueat/app/core/common/constants/constants.dart';
import 'package:mawsueat/app/features/home/view/screens/content_page.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class SearchItem extends StatelessWidget {
  final String title;
  final String page;
  final String bookName;
  final String bookId;
  final String searchWords;

  const SearchItem({
    super.key,
    required this.title,
    required this.page,
    required this.bookName,
    required this.bookId,
    required this.searchWords,
  });

  @override
  Widget build(BuildContext context) {
    return ZoomTapAnimation(
      onTap: () {
        print(page);
        print(bookId);
        Get.to(
          () => ContentPage(
            bookId: int.tryParse(bookId) ?? 0,
            bookName: bookName,
            scrollPosetion: double.parse(page) - 1,
            searchWord: searchWords,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.symmetric(horizontal: 20).copyWith(bottom: 5),
        decoration: Constants.containerBoxDecoration(
          context,
        ).copyWith(borderRadius: BorderRadius.circular(4), color: Colors.white),
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '•',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 18,
                        ),
                      ),
                      const Gap(5),
                      Expanded(
                        child: Text(
                          removeHtmlTags(title),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 15,
                            fontFamily: 'IBMPlexSansArabic',
                            overflow: TextOverflow.ellipsis,
                          ),
                          softWrap: false,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/svgs/search-alt.svg',
                        colorFilter: ColorFilter.mode(
                          Theme.of(context).colorScheme.onPrimary,
                          BlendMode.srcIn,
                        ),
                        width: 15,
                        height: 15,
                      ),
                      const Gap(5),
                      Expanded(
                        child: Text(
                          bookName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(10),
            Container(
              width: 35,
              height: 35,
              decoration: Constants.containerBoxDecoration(context),
              alignment: Alignment.center,
              child: Text(
                page,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
