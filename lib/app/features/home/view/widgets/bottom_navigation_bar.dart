import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mawsueat/app/features/home/view/controller/navigation_controller.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CostumBottomNavigationBar extends StatelessWidget {
  const CostumBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final BottmNavigationController navigationController =
        Get.find<BottmNavigationController>();

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _bottomAppBarItem(
            context: context,
            controller: navigationController,
            page: 0,
            title: 'الرئيسية',
            selectedIcon: Icons.menu_book_rounded,
            unselectedIcon: Icons.menu_book_outlined,
          ),
          _bottomAppBarItem(
            context: context,
            controller: navigationController,
            page: 1,
            title: 'الإعدادات',
            selectedIcon: Icons.settings_rounded,
            unselectedIcon: Icons.settings_outlined,
          ),
          _bottomAppBarItem(
            context: context,
            controller: navigationController,
            page: 2,
            title: 'حول التطبيق',
            selectedIcon: Icons.info_rounded,
            unselectedIcon: Icons.info_outline_rounded,
          ),
          _bottomAppBarItem(
            context: context,
            controller: navigationController,
            page: 3,
            title: 'الإشارات',
            selectedIcon: Icons.bookmarks_rounded,
            unselectedIcon: Icons.bookmarks_outlined,
          ),
        ],
      ),
    );
  }

  Widget _bottomAppBarItem({
    required BuildContext context,
    required BottmNavigationController controller,
    required int page,
    required String title,
    required IconData selectedIcon,
    required IconData unselectedIcon,
  }) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.onPrimary;
    final inactiveColor = theme.colorScheme.onPrimary.withOpacity(0.45);

    return Expanded(
      child: ZoomTapAnimation(
        onTap: () {
          controller.goToPage(page);
        },
        child: Obx(() {
          final isSelected = controller.currentPage.value == page;

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeColor.withOpacity(0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? selectedIcon : unselectedIcon,
                  size: 21,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9.5,
                  fontFamily: 'IBMPlexSansArabic',
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
