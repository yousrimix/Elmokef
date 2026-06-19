import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

// Vibrant shimmer with gradient-style colors
class _ShimmerStyle {
  static const baseColor = Color(0xFFE4E7EB);
  static const highlightColor = Color(0xFFF2F4F7);
  static const primaryBase = Color(0xFFD1FAE5);
  static const primaryHighlight = Color(0xFFECFDF5);
}

/// Fancy shimmer card that mimics actual card layout with avatar + lines
class ShimmerCard extends StatelessWidget {
  final double height;
  final bool showAvatar;
  final int lines;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.showAvatar = true,
    this.lines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _ShimmerStyle.baseColor,
      highlightColor: _ShimmerStyle.highlightColor,
      period: const Duration(milliseconds: 1500),
      child: Container(
        height: height,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (showAvatar)
              Container(
                width: 48, height: 48,
                decoration: const BoxDecoration(
                  color: _ShimmerStyle.baseColor,
                  borderRadius: BorderRadius.all(Radius.circular(14)),
                ),
              ),
            if (showAvatar) const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(lines, (i) => Padding(
                  padding: EdgeInsets.only(bottom: i < lines - 1 ? 10 : 0),
                  child: Container(
                    height: 12,
                    width: i == lines - 1 ? 0.45 : 1.0,
                    decoration: BoxDecoration(
                      color: _ShimmerStyle.baseColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final bool showAvatar;
  final int lines;

  const ShimmerList({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 120,
    this.showAvatar = true,
    this.lines = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        itemCount,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: ShimmerCard(
            height: itemHeight,
            showAvatar: showAvatar,
            lines: lines,
          ),
        ),
      ),
    );
  }
}

class ShimmerGrid extends StatelessWidget {
  final int itemCount;
  final double aspectRatio;

  const ShimmerGrid({
    super.key,
    this.itemCount = 6,
    this.aspectRatio = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _ShimmerStyle.primaryBase,
      highlightColor: _ShimmerStyle.primaryHighlight,
      period: const Duration(milliseconds: 1200),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: aspectRatio,
        ),
        itemCount: itemCount,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgCard.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.primary.withValues(alpha: 0.7),
                ),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                message!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
