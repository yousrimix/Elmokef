import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? elevation;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.elevation,
    this.onTap,
    this.color,
    this.margin,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        color: color ?? AppColors.bgCard,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        boxShadow: elevation == null
            ? AppColors.cardShadow
            : [BoxShadow(
                color: Colors.black.withValues(alpha: 0.06 * elevation!),
                blurRadius: 8 + elevation! * 4,
                offset: const Offset(0, 2),
              )],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          splashColor: AppColors.overlay,
          highlightColor: AppColors.overlay,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// A shimmer card placeholder for loading states
class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.border,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
