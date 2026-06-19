import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final List<Map<String, dynamic>> _favorites = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoad();
  }

  void _simulateLoad() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('المفضلة'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.bgMuted,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Icon(Icons.favorite_rounded, size: 50, color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: 20),
                        const Text('لا توجد مفضلة بعد',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        const Text('أضف الحرفيين إلى مفضلتك\nلتجدهم بسرعة لاحقاً',
                            style: TextStyle(fontSize: 14, color: AppColors.textSecondary), textAlign: TextAlign.center),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: () => context.go('/search'),
                            icon: const Icon(Icons.search_rounded),
                            label: const Text('ابحث عن حرفيين', style: TextStyle(fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) => AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    onTap: () {},
                    child: Row(
                      children: [
                        const Icon(Icons.person_rounded, size: 40, color: AppColors.primaryDark),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_favorites[index]['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(_favorites[index]['profession'] ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite, color: AppColors.danger),
                          onPressed: () => setState(() => _favorites.removeAt(index)),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
