import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widgets.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/verified_badge.dart';
import '../../../home/presentation/providers/services_provider.dart';
import '../../../home/data/models/category_model.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late TextEditingController _searchController;
  late String _query;
  Timer? _debounce;

  static const _popularSearches = [
    'سباك', 'كهربائي', 'صباغ', 'نجار', 'حداد', 'مكنسي', 'تبريد وتكييف', 'تنظيف'
  ];

  @override
  void initState() {
    super.initState();
    _query = widget.initialQuery ?? '';
    _searchController = TextEditingController(text: _query);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        setState(() => _query = value.trim());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            textDirection: TextDirection.rtl,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '🔍  ابحث عن خدمة...',
              hintStyle: const TextStyle(fontSize: 14, color: AppColors.textTertiary),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
            onChanged: _onSearchChanged,
            onSubmitted: (value) {
              setState(() => _query = value.trim());
            },
          ),
        ),
      ),
      body: _query.isEmpty ? _buildBrowse() : _buildSearchResults(),
    );
  }

  Widget _buildBrowse() {
    final categoriesAsync = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular searches
          const Text('أكثر الخدمات طلباً', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _popularSearches.map((s) => GestureDetector(
              onTap: () {
                _searchController.text = s;
                setState(() => _query = s);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: Text(s, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.primaryDark)),
              ),
            )).toList(),
          ),

          const SizedBox(height: 28),
          const Text('جميع الخدمات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 14),

          categoriesAsync.when(
            data: (cats) => _buildCategories(cats),
            loading: () => const Padding(
              padding: EdgeInsets.only(top: 20),
              child: ShimmerList(itemCount: 5, itemHeight: 56),
            ),
            error: (_, __) => Padding(
              padding: const EdgeInsets.only(top: 40),
              child: ErrorState(
                message: 'تعذر تحميل الخدمات',
                icon: Icons.cloud_off_rounded,
                retryLabel: 'إعادة',
                onRetry: () => ref.invalidate(categoriesProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(List<CategoryModel> categories) {
    final roots = categories.where((c) => c.parentId == null).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: roots.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final cat = roots[i];
        final colors = [
          [AppColors.primaryLighter, AppColors.primary],
          [const Color(0xFFFFF7ED), AppColors.accent],
          [const Color(0xFFF0F9FF), AppColors.info],
          [const Color(0xFFFFF1F2), AppColors.danger],
          [const Color(0xFFF5F3FF), const Color(0xFF8B5CF6)],
          [const Color(0xFFFCE7F3), const Color(0xFFEC4899)],
          [const Color(0xFFECFDF5), const Color(0xFF10B981)],
        ];
        final palette = colors[i % colors.length];
        return _categoryTile(cat, palette[0], palette[1]);
      },
    );
  }

  Widget _categoryTile(CategoryModel cat, Color bg, Color accent) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.light(primary: accent),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          shape: const Border(),
          collapsedShape: const Border(),
          leading: Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_iconFor(cat.nameAr), size: 22, color: accent),
          ),
          title: Text(cat.nameAr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${cat.artisanCount} حرفي', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: accent)),
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textTertiary, size: 20),
            ],
          ),
          children: cat.children.map((child) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () => context.go('/artisans/${child.id}', extra: child.nameAr),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.bgMuted,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_ios_rounded, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(child.nameAr, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary))),
                      Text('${child.artisanCount} حرفي', style: TextStyle(fontSize: 12, color: accent, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final resultsAsync = ref.watch(textSearchProvider(_query));

    return resultsAsync.when(
      data: (artisans) => artisans.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.bgMuted,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textTertiary),
                  ),
                  const SizedBox(height: 20),
                  Text('نتائج بحث: "$_query"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  const Text('لم نجد حرفيين لهذا البحث', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('عودة للتصفح'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: artisans.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text('نتائج بحث: "$_query" (${artisans.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  );
                }
                final a = artisans[index - 1];
                return _searchResultCard(a);
              },
            ),
      loading: () => const Padding(
        padding: EdgeInsets.all(20),
        child: ShimmerList(itemCount: 3, itemHeight: 100),
      ),
      error: (err, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ErrorState(
              message: 'تعذر البحث',
              icon: Icons.cloud_off_rounded,
              retryLabel: 'إعادة',
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => setState(() => _query = ''),
              child: const Text('عودة للتصفح'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchResultCard(ArtisanModel a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => context.go('/artisan/${a.id}', extra: a.name),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryLighter,
                ),
                child: a.imageUrl != null && a.imageUrl!.isNotEmpty
                    ? Image.network(a.imageUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => _searchAvatarFallback(a))
                    : _searchAvatarFallback(a),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          a.name,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (a.verified) const VerifiedBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
                      const SizedBox(width: 4),
                      Text('${a.rating}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(width: 12),
                      Icon(Icons.work_rounded, size: 14, color: AppColors.textTertiary),
                      const SizedBox(width: 4),
                      Text(a.profession, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_left_rounded, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _searchAvatarFallback(ArtisanModel a) {
    return Center(
      child: Text(
        a.name[0],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
      ),
    );
  }

  IconData _iconFor(String name) {
    const map = {
      'سباكة': Icons.plumbing, 'كهرباء': Icons.electric_bolt,
      'صباغة': Icons.format_paint, 'صباغ': Icons.format_paint,
      'تبريد وتكييف': Icons.ac_unit, 'حدادة': Icons.hardware,
      'نجارة': Icons.carpenter, 'تنظيف': Icons.cleaning_services,
    };
    return map[name] ?? Icons.work_rounded;
  }
}
