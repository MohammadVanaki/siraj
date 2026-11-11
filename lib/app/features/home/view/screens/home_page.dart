import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/home/view/screens/subject_page.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ZoomTapAnimation(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  Get.back();
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withAlpha(20)
                      : Theme.of(context).colorScheme.onPrimary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
            const Gap(10),
            Text(
              'موسوعة أهل البيت',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBMPlexSansArabic',
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        titleTextStyle: const TextStyle(
          fontSize: 18,
          color: Colors.black,
          fontFamily: 'IBMPlexSansArabic',
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        shadowColor: Colors.black26,
        leading: null,
      ),
      body: const SafeArea(
        top: false,
        bottom: true,
        child: SubjectPage(),
      ),
    );
  }
}

typedef MawsueatPage = HomePage;


