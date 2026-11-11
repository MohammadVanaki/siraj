import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({
    super.key,
    required this.title,
  });
  final String title;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(
              width: Get.width * .6,
              height: Get.height * .5,
              child: SvgPicture.asset(
                'assets/svgs/Reading glasses-bro.svg',
                width: Get.width * .6,
                height: Get.height * .5,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'IBMPlexSansArabic',
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
              ),
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }
}
