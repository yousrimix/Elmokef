import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/rating_bar.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../home/presentation/providers/services_provider.dart';
import '../../../home/data/models/category_model.dart';

class ArtisanListScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String? serviceName;
  const ArtisanListScreen({super.key, required this.serviceId, this.serviceName});

  @override
  ConsumerState<ArtisanListScreen> createState() => _ArtisanListScreenState();
}

class _ArtisanListScreenState extends ConsumerState<ArtisanListScreen> {
  String _activeSort = 'rank';
  final ScrollController _scrollController = ScrollController();
  List<ArtisanModel>? _cachedSorted;
  List<ArtisanModel>? _cachedSource;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<ArtisanModel> _sortedArtisans(List<ArtisanModel> artisans) {
    if (_cachedSource == artisans) return _cachedSorted ?? artisans;
    final sorted = List<ArtisanModel>.from(artisans);
    switch (_activeSort) {
      case 'rank':
        sorted.sort((a, b) => b.rankScore.compareTo(a.rankScore));
        break;
      case 'distance':
        sorted.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
        break;
      case 'rating':
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price':
        sorted.sort((a, b) => a.priceRange.compareTo(b.priceRange));
        break;
    }
    _cachedSource = artisans;
    _cachedSorted = sorted;
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final artisansAsync = ref.watch(artisansProvider(widget.serviceId));

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(widget.serviceName ?? 'الخدمة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            onPressed: () => context.go('/map/${widget.serviceId}', extra: widget.serviceName),
          ),
        ],
      ),
      body: artisansAsync.when(
        data: (artisans) => _buildContent(_sortedArtisans(artisans)),
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: ShimmerList(itemCount: 4, itemHeight: 200),
        ),
        error: (_, __) => ErrorState(
          message: 'تعذر تحميل الحرفيين',
          icon: Icons.person_off_rounded,
          retryLabel: 'إعادة',
          onRetry: () => ref.invalidate(artisansProvider(widget.serviceId)),
        ),
      ),
    );
  }

  Widget _buildContent(List<ArtisanModel> artisans) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          color: AppColors.bgCard,
          child: Row(
            children: [
              Text(
                '${artisans.length} حرفي متاح',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const Spacer(),
              _sortChip(Icons.trending_up_rounded, 'الأعلى تصنيفاً', _activeSort == 'rank', () => setState(() => _activeSort = 'rank')),
            ],
          ),
        ),

        // Sort chips
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _sortChip(Icons.trending_up_rounded, 'تصنيف', _activeSort == 'rank', () => setState(() => _activeSort = 'rank')),
                const SizedBox(width: 8),
                _sortChip(Icons.near_me_rounded, 'الأقرب', _activeSort == 'distance', () => setState(() => _activeSort = 'distance')),
                const SizedBox(width: 8),
                _sortChip(Icons.star_rounded, 'التقييم', _activeSort == 'rating', () => setState(() => _activeSort = 'rating')),
                const SizedBox(width: 8),
                _sortChip(Icons.monetization_on_outlined, 'السعر', _activeSort == 'price', () => setState(() => _activeSort = 'price')),
              ],
            ),
          ),
        ),

        // List
        Expanded(
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: artisans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              final a = artisans[i];
              return _buildArtisanCard(a, i);
            },
          ),
        ),
      ],
    );
  }

  Widget _sortChip(IconData icon, String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.bgCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
            width: active ? 0 : 1,
          ),
          boxShadow: active ? AppColors.cardShadow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? Colors.white : AppColors.textTertiary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArtisanCard(ArtisanModel a, int index) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: image + info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: a.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: a.imageUrl!, width: 64, height: 64,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _avatarPlaceholder(),
                          errorWidget: (_, __, ___) => _avatarPlaceholder(),
                        )
                      : _avatarPlaceholder(),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(a.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ),
                          if (a.verified) const VerifiedBadge(),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(a.profession.isNotEmpty ? a.profession : 'حرفي محترف',
                          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          AppRatingBar(rating: a.rating),
                          const SizedBox(width: 6),
                          Text('${a.rating.toStringAsFixed(1)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                          Text(' (${a.reviewCount})', style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                          if (a.rankScore > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.successLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('${(a.rankScore * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 14),

            // Details row
            Row(
              children: [
                // Price
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLighter,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on_outlined, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(a.priceRange.isNotEmpty ? a.priceRange : '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Distance
                Icon(Icons.location_on_outlined, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 3),
                Text('${a.distanceKm > 0 ? a.distanceKm.toStringAsFixed(1) : "—"} كم', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const Spacer(),
                // Response time
                Icon(Icons.access_time_rounded, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 3),
                Text(a.responseTime.isNotEmpty ? a.responseTime : '—', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),

            const SizedBox(height: 14),
            // Actions
            Row(
              children: [
                if (a.verified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, size: 12, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('موثوق', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary)),
                      ],
                    ),
                  ),
                const Spacer(),
                SizedBox(
                  width: 120, height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () => context.go('/artisan/${a.id}'),
                    icon: const Icon(Icons.person_rounded, size: 16),
                    label: const Text('الملف', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primarySurface,
                      foregroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 120, height: 40,
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_rounded, size: 16),
                    label: const Text('واتساب', style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whatsapp,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 64, height: 64,
      decoration: BoxDecoration(
        color: AppColors.primaryLighter,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.person_rounded, size: 32, color: AppColors.primary),
    );
  }
}
