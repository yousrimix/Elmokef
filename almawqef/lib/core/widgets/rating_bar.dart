import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AppRatingBar extends StatelessWidget {
  final double rating;
  final double size;
  final int starCount;

  const AppRatingBar({
    super.key,
    required this.rating,
    this.size = 16,
    this.starCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        final filled = index < rating.floor();
        final half = !filled && index < rating;
        return Icon(
          half ? Icons.star_half_rounded : Icons.star_rounded,
          size: size,
          color: filled || half ? AppColors.starActive : AppColors.starInactive,
        );
      }),
    );
  }
}
