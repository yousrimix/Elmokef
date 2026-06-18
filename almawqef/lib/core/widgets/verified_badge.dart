import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class VerifiedBadge extends StatelessWidget {
  final double fontSize;

  const VerifiedBadge({super.key, this.fontSize = 12});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '✅ موثّق',
        style: TextStyle(
          fontSize: fontSize,
          color: AppColors.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
