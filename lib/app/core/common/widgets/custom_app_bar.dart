import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zoom_tap_animation/zoom_tap_animation.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final VoidCallback? onBackTap;
  final bool centerTitle;
  final Color? backgroundColor;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.onBackTap,
    this.centerTitle = true,
    this.backgroundColor,
    this.elevation = 0,
    this.bottom,
  });

  Widget _buildBackButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ZoomTapAnimation(
      onTap: onBackTap ??
          () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else if (Get.key.currentState?.canPop() == true) {
              Get.key.currentState?.pop();
            }
          },
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withAlpha(20)
              : colorScheme.onPrimary.withAlpha(20),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: colorScheme.onPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Widget? leadingWidget = leading;
    if (leadingWidget == null && showBackButton) {
      if (Navigator.of(context).canPop() || onBackTap != null) {
        leadingWidget = _buildBackButton(context);
      }
    }

    return AppBar(
      backgroundColor: backgroundColor ?? colorScheme.surface,
      elevation: elevation,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      automaticallyImplyLeading: false,
      leading: leadingWidget,
      title: titleWidget ??
          (title != null
              ? Text(
                  title!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    fontFamily: 'IBMPlexSansArabic',
                  ),
                )
              : null),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
