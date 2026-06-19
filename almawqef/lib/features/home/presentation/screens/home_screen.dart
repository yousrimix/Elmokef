import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/error_state.dart';
import '../providers/home_provider.dart';
import '../providers/services_provider.dart';
import '../../data/models/category_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showAppBar = true;

  static const _popularSearches = [
    'سباك', 'كهربائي', 'صباغ', 'نجار', 'حداد', 'مكنسي',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final show = _scrollController.offset < 80;
    if (show != _showAppBar) {
      setState(() => _showAppBar = show);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(homeIndexProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final suggestedAsync = ref.watch(suggestedArtisansProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(categoriesProvider);
            ref.invalidate(suggestedArtisansProvider);
            await Future.wait([
              ref.read(categoriesProvider.future),
              ref.read(suggestedArtisansProvider.future),
            ]);
          },
          child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // ─── Modern App Bar ─────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 160,
              collapsedHeight: 64,
              pinned: true,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.zero,
                expandedTitleScale: 1,
                title: Container(
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF059669), Color(0xFF0D9488), Color(0xFF0F766E)],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        // Top row: logo + icons
                        Row(
                          children: [
                            Container(
                              width: 36, height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Elmokef',
                              style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800,
                                color: Colors.white, letterSpacing: 1,
                              ),
                            ),
                            const Spacer(),
                            _iconBadge(Icons.notifications_outlined, null, () => context.go('/notifications')),
                            const SizedBox(width: 8),
                            _iconBadge(Icons.person_outline, null, () => context.go('/account')),
                          ],
                        ),
                        // Subtitle
                        const SizedBox(height: 4),
                        Text(
                          'احترف بجوارك',
                          style: TextStyle(
                            fontSize: 13, color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Quick action rows
                        Row(
                          children: [
                            _quickChip(Icons.flash_on_rounded, 'طلب مستعجل', AppColors.accent),
                            const SizedBox(width: 8),
                            _quickChip(Icons.map_outlined, 'على الخريطة', Colors.white70),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Content ─────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Search bar
                    _buildSearchBar(),
                    const SizedBox(height: 12),

                    // Popular searches
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _popularSearches.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (_, i) => _popularChip(_popularSearches[i]),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Stats row
                    Row(
                      children: [
                        _statCard('128+', 'حرفي', Icons.handyman_rounded),
                        const SizedBox(width: 10),
                        _statCard('245+', 'زبون', Icons.people_rounded),
                        const SizedBox(width: 10),
                        _statCard('89+', 'طلب', Icons.assignment_rounded),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Categories
                    _sectionHeader('تصفح الخدمات', 'عرض الكل →', () => context.go('/search')),
                    const SizedBox(height: 14),
                    categoriesAsync.when(
                      data: (cats) => _buildCategories(cats),
                      loading: () => const ShimmerGrid(),
                      error: (_, __) => ErrorState(
                        message: 'تعذر تحميل الخدمات',
                        icon: Icons.category_rounded,
                        retryLabel: 'إعادة',
                        onRetry: () => ref.invalidate(categoriesProvider),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Suggested artisans
                    _sectionHeader('أفضل الحرفيين قربك', 'الكل ←', () => context.go('/search')),
                    const SizedBox(height: 14),
                    suggestedAsync.when(
                      data: (arts) => arts.isEmpty
                          ? _emptySection()
                          : _buildArtisans(arts),
                      loading: () => const SizedBox(
                        height: 280,
                        child: ShimmerList(itemCount: 2, itemHeight: 260),
                      ),
                      error: (_, __) => const SizedBox(
                        height: 200,
                        child: Center(child: Text('لا توجد اقتراحات', style: TextStyle(color: AppColors.textSecondary))),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Info card
                    _infoBanner(
                      Icons.shield_rounded,
                      'جميع الحرفيين موثوقين',
                      'نضمن لك جودة الخدمة مع حرفيين تم التحقق منهم',
                      AppColors.primaryLighter,
                      AppColors.primary,
                    ),

                    const SizedBox(height: 80), // bottom nav padding
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: currentIndex,
        onTap: (i) {
            if (i == currentIndex) return;
            ref.read(homeIndexProvider.notifier).state = i;
            switch (i) {
              case 1: context.go('/search');
              case 2: context.go('/favorites');
              case 3: context.go('/account');
            }
          },
        items: const [
          BottomNavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
          BottomNavItem(icon: Icons.search_rounded, label: 'بحث'),
          BottomNavItem(icon: Icons.favorite_rounded, label: 'مفضلة'),
          BottomNavItem(icon: Icons.person_rounded, label: 'حسابي'),
        ],
      ),
    );
  }

  // ─── Widgets ─────────────────────────────────────────────────────────────

  Widget _iconBadge(IconData icon, int? count, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(icon, color: Colors.white, size: 22)),
            if (count != null && count > 0)
              Positioned(
                top: -2, right: -2,
                child: Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle,
                  ),
                  child: Center(child: Text('$count', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white))),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _quickChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        textDirection: TextDirection.rtl,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'من تبحث عنه اليوم؟ 🔍',
          hintStyle: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
          ),
        ),
        onSubmitted: (_) => _onSearch(),
      ),
    );
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      ref.read(searchQueryProvider.notifier).state = query;
      context.go('/search?q=$query');
    }
  }

  Widget _popularChip(String text) {
    return GestureDetector(
      onTap: () {
        _searchController.text = text;
        _onSearch();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryDark),
        ),
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, String action, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 4, height: 22,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          ],
        ),
        GestureDetector(
          onTap: onTap,
          child: Row(
            children: [
              Text(action, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary.withValues(alpha: 0.8))),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary.withValues(alpha: 0.8)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategories(List<CategoryModel> cats) {
    final display = cats.where((c) => c.parentId == null).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: display.length,
      itemBuilder: (_, i) {
        final cat = display[i];
        final colors = [
          [const Color(0xFFECFDF5), AppColors.primary, AppColors.primaryDark],
          [const Color(0xFFFFF7ED), AppColors.accent, AppColors.accentDark],
          [const Color(0xFFF0F9FF), AppColors.info, const Color(0xFF1E40AF)],
          [const Color(0xFFFFF1F2), AppColors.danger, const Color(0xFF991B1B)],
          [const Color(0xFFF5F3FF), const Color(0xFF8B5CF6), const Color(0xFF5B21B6)],
          [const Color(0xFFFCE7F3), const Color(0xFFEC4899), const Color(0xFF9D174D)],
        ];
        final palette = colors[i % colors.length];
        return _categoryCard(cat, palette[0], palette[1], palette[2]);
      },
    );
  }

  Widget _categoryCard(CategoryModel cat, Color bg, Color iconColor, Color textColor) {
    return InkWell(
      onTap: () => context.go('/artisans/${cat.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_iconFor(cat.nameAr), size: 22, color: iconColor),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                cat.nameAr,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
                textAlign: TextAlign.center,
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptySection() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.bgMuted,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.construction_rounded, size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            const Text('لا يوجد حرفيون متاحون حالياً',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            const Text('حاول مرة أخرى',
                style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _buildArtisans(List<ArtisanModel> artisans) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 4),
        itemCount: artisans.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final a = artisans[i];
          return _artisanCard(a, i);
        },
      ),
    );
  }

  Widget _artisanCard(ArtisanModel a, int index) {
    return Container(
      width: 210,
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image section
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                child: a.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: a.imageUrl!, height: 120, width: double.infinity,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => _cardImagePlaceholder(),
                        errorWidget: (_, __, ___) => _cardImagePlaceholder(),
                      )
                    : _cardImagePlaceholder(),
              ),
              // Rating badge
              Positioned(
                top: 8, right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.starActive),
                      const SizedBox(width: 3),
                      Text(a.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ),
              // Distance badge
              Positioned(
                top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: Colors.white70),
                      const SizedBox(width: 3),
                      Text('${a.distanceKm > 0 ? a.distanceKm.toStringAsFixed(1) : "—"} كم',
                          style: const TextStyle(fontSize: 11, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Details section
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                    if (a.verified)
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.check_rounded, size: 12, color: Colors.white),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(a.profession.isNotEmpty ? a.profession : 'حرفي محترف',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.reviews_rounded, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 3),
                        Text('${a.reviewCount} تقييم', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ],
                    ),
                    const Spacer(),
                    Text(a.priceRange.isNotEmpty ? a.priceRange : '—',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                // CTA
                SizedBox(
                  width: double.infinity, height: 36,
                  child: ElevatedButton(
                    onPressed: () => context.go('/artisan/${a.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('عرض الملف', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardImagePlaceholder() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [AppColors.primaryLighter, AppColors.primarySurface],
        ),
      ),
      child: Center(
        child: Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.person_rounded, size: 28, color: AppColors.primary),
        ),
      ),
    );
  }

  Widget _infoBanner(IconData icon, String title, String subtitle, Color bg, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: color)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.7))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String name) {
    const map = {
      'سباكة': Icons.plumbing, 'سباك': Icons.water_drop,
      'كهرباء': Icons.electric_bolt, 'كهربائي': Icons.electric_bolt,
      'صباغ': Icons.format_paint, 'صباغة': Icons.format_paint,
      'تبريد وتكييف': Icons.ac_unit, 'تكييف': Icons.ac_unit,
      'حداد': Icons.hardware, 'حدادة': Icons.hardware,
      'نجارة': Icons.carpenter, 'نجار': Icons.carpenter,
      'تنظيف': Icons.cleaning_services, 'مكنسي': Icons.cleaning_services,
      'صناعة': Icons.precision_manufacturing_rounded,
      'ميكانيك': Icons.build_circle,
    };
    return map[name] ?? Icons.work_rounded;
  }
}
