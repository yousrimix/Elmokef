import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/rating_bar.dart';

/// V3 modern reviews screen with Material 3 design.
///
/// Can be opened with or without an [artisanId]. When null the screen shows
/// "تقييماتي" (my reviews); when provided it shows reviews for that artisan.
class ReviewsScreen extends ConsumerWidget {
  final String? artisanId;
  const ReviewsScreen({super.key, this.artisanId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ── Placeholder data — replace with real provider watch ──────────────
    //   final reviewsAsync = ref.watch(reviewsProvider(artisanId));
    const averageRating = 4.8;
    const totalReviews = 32;
    const distribution = {5: 0.70, 4: 0.20, 3: 0.06, 2: 0.03, 1: 0.01};
    final reviews = <_ReviewData>[
      _ReviewData(
        'عميد',
        5.0,
        DateTime.now().subtract(const Duration(days: 3)),
        'خدمة ممتازة وصل فالوقت، سعر معقول ونظيف. أنصح بالتعامل معه.',
      ),
      _ReviewData(
        'سعيد',
        4.0,
        DateTime.now().subtract(const Duration(days: 7)),
        'خدمة جيدة لكن تأخر شويا فالميعاد. الشغل نظيف والحمد لله.',
      ),
    ];

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Gradient SliverAppBar ────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            floating: false,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsetsDirectional.only(
                start: AppSpacing.lg,
                bottom: AppSpacing.lg,
              ),
              title: Text(
                artisanId != null ? 'التقييمات' : 'تقييماتي',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
              ),
            ),
          ),

          // ── Rating Summary Card ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: _RatingSummaryCard(
                averageRating: averageRating,
                totalReviews: totalReviews,
                distribution: distribution,
              ),
            ),
          ),

          // ── Section Title ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Text(
                artisanId != null ? 'التقييمات' : 'أحدث التقييمات',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),

          // ── Reviews or Empty State ───────────────────────────────────
          if (reviews.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyReviewsState(),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    index == reviews.length - 1 ? AppSpacing.xxxl : AppSpacing.md,
                  ),
                  child: _ReviewCard(review: reviews[index]),
                ),
                childCount: reviews.length,
              ),
            ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Data model
// ═════════════════════════════════════════════════════════════════════════════

class _ReviewData {
  final String name;
  final double rating;
  final DateTime date;
  final String comment;
  const _ReviewData(this.name, this.rating, this.date, this.comment);
}

// ═════════════════════════════════════════════════════════════════════════════
// Rating Summary Card
// ═════════════════════════════════════════════════════════════════════════════

class _RatingSummaryCard extends StatelessWidget {
  final double averageRating;
  final int totalReviews;
  final Map<int, double> distribution;

  const _RatingSummaryCard({
    required this.averageRating,
    required this.totalReviews,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // ── Big rating number ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text(
                  '/5',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Stars ──────────────────────────────────────────────────
          const AppRatingBar(rating: 4.8, size: 28),

          const SizedBox(height: AppSpacing.sm),

          // ── Total reviews count ────────────────────────────────────
          Text(
            'من $totalReviews تقييماً',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // ── Rating distribution bars ───────────────────────────────
          ...distribution.entries.map(
            (entry) => _RatingDistributionRow(
              stars: entry.key,
              percentage: entry.value,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Distribution Row (single star-level bar)
// ═════════════════════════════════════════════════════════════════════════════

class _RatingDistributionRow extends StatelessWidget {
  final int stars;
  final double percentage;

  const _RatingDistributionRow({
    required this.stars,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          // Star-level label
          SizedBox(
            width: 36,
            child: Text(
              stars.toString(),
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Progress bar
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percentage,
                minHeight: 10,
                backgroundColor: AppColors.bgMuted,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.starActive),
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.sm),

          // Percentage label
          SizedBox(
            width: 36,
            child: Text(
              '${(percentage * 100).toInt()}%',
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Individual Review Card
// ═════════════════════════════════════════════════════════════════════════════

class _ReviewCard extends StatelessWidget {
  final _ReviewData review;

  const _ReviewCard({required this.review});

  // ── Relative time helper ──────────────────────────────────────────────
  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) {
      return 'منذ ${(diff.inDays / 365).floor()} سنة';
    } else if (diff.inDays > 30) {
      return 'منذ ${(diff.inDays / 30).floor()} شهر';
    } else if (diff.inDays > 0) {
      return 'منذ ${diff.inDays} ${diff.inDays == 1 ? 'يوم' : 'أيام'}';
    } else if (diff.inHours > 0) {
      return 'منذ ${diff.inHours} ${diff.inHours == 1 ? 'ساعة' : 'ساعات'}';
    } else if (diff.inMinutes > 0) {
      return 'منذ ${diff.inMinutes} ${diff.inMinutes == 1 ? 'دقيقة' : 'دقائق'}';
    } else {
      return 'الآن';
    }
  }

  // ── Deterministic avatar colour from name ────────────────────────────
  Color _avatarColor(String name) {
    const colors = <Color>[
      AppColors.primary,
      AppColors.accentDark,
      AppColors.info,
      AppColors.danger,
      AppColors.primaryLight,
    ];
    return colors[name.codeUnits.first % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: avatar + name + time ──────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: _avatarColor(review.name).withValues(alpha: 0.15),
                child: Text(
                  review.name[0],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _avatarColor(review.name),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  review.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                _timeAgo(review.date),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Stars ─────────────────────────────────────────────────
          AppRatingBar(rating: review.rating, size: 16),

          const SizedBox(height: AppSpacing.sm),

          // ── Comment ───────────────────────────────────────────────
          Text(
            review.comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// Empty State
// ═════════════════════════════════════════════════════════════════════════════

class _EmptyReviewsState extends StatelessWidget {
  const _EmptyReviewsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLighter,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.rate_review_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const Text(
              'لا توجد تقييمات بعد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'كن أول من يقيم هذه الخدمة',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
