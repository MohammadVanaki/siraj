import 'package:flutter/material.dart';

class BookRatingBarWidget extends StatelessWidget {
  final double rating;
  final int maxRating;
  final double size;
  final Color activeColor;
  final Color inactiveColor;
  final bool isInteractive;
  final ValueChanged<double>? onRatingChanged;

  const BookRatingBarWidget({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 18,
    this.activeColor = const Color(0xFFFFB800),
    this.inactiveColor = const Color(0xFFD1D5DB),
    this.isInteractive = false,
    this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (index) {
        final starValue = index + 1;
        final isFilled = rating >= starValue;
        final isHalf = !isFilled && rating >= (starValue - 0.5);

        IconData icon;
        Color color;

        if (isFilled) {
          icon = Icons.star_rounded;
          color = activeColor;
        } else if (isHalf) {
          icon = Icons.star_half_rounded;
          color = activeColor;
        } else {
          icon = Icons.star_outline_rounded;
          color = inactiveColor;
        }

        final starIcon = Icon(
          icon,
          size: size,
          color: color,
        );

        if (!isInteractive) {
          return starIcon;
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            onRatingChanged?.call(starValue.toDouble());
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: starIcon,
          ),
        );
      }),
    );
  }
}
