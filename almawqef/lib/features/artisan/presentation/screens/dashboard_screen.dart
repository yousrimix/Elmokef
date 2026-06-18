import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<BottomNavItem> _navItems = const [
    BottomNavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    BottomNavItem(icon: Icons.receipt_long_rounded, label: 'الطلبات'),
    BottomNavItem(icon: Icons.star_rounded, label: 'التقييمات'),
    BottomNavItem(icon: Icons.person_rounded, label: 'حسابي'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── App Bar ───────────────────────────────────
            SliverAppBar(
              expandedHeight: 120,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.zero,
                expandedTitleScale: 1,
                title: Container(
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                      colors: [Color(0xFF059669), Color(0xFF0D9488), Color(0xFF0F766E)],
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Spacer(),
                        Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text('مرحباً حرّاث 👋', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                            ),
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.notifications_outlined, size: 22, color: Colors.white),
                                onPressed: () => context.go('/notifications'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text('لوحة التحكم — ${DateTime.now().toString().substring(0, 10)}',
                            style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ─── Stats Cards ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    _statCard(Icons.visibility_rounded, '45', 'مشاهدة', AppColors.info, 'اليوم'),
                    const SizedBox(width: 10),
                    _statCard(Icons.phone_in_talk_rounded, '12', 'اتصال', AppColors.primary, 'هذا الأسبوع'),
                    const SizedBox(width: 10),
                    _statCard(Icons.star_rounded, '4.8', 'تقييم', AppColors.starActive, 'عام'),
                  ],
                ),
              ),
            ),

            // ─── Profile Completion ─────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.accent.withValues(alpha: 0.08)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.12)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.assignment_turned_in_rounded, color: AppColors.primary, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('إكمال الملف', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: 0.7,
                                backgroundColor: AppColors.border,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                minHeight: 6,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Text('70% مكتمل', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => context.go('/wizard'),
                                  child: const Text('أكمل الآن', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Quick Actions ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    _actionChip(Icons.photo_library_outlined, 'أضف صور', () => context.go('/artisan-gallery')),
                    const SizedBox(width: 8),
                    _actionChip(Icons.share_rounded, 'شارك ملفي', () {}),
                    const SizedBox(width: 8),
                    _actionChip(Icons.bar_chart_rounded, 'الإحصائيات', () {}),
                  ],
                ),
              ),
            ),

            // ─── Alert: Pending Requests ────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.notifications_active_rounded, size: 20, color: Color(0xFF92400E)),
                          ),
                          const SizedBox(width: 10),
                          const Text('لديك طلب جديد!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.person_rounded, size: 14, color: Color(0xFF92400E)),
                          SizedBox(width: 4),
                          Text('محمد — سباكة', style: TextStyle(fontSize: 14, color: Color(0xFF92400E))),
                          Spacer(),
                          Icon(Icons.location_on_rounded, size: 14, color: Color(0xFF92400E)),
                          SizedBox(width: 4),
                          Text('2.3 كم', style: TextStyle(fontSize: 14, color: Color(0xFF92400E))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF92400E)),
                          SizedBox(width: 4),
                          Text('منذ 5 دقائق', style: TextStyle(fontSize: 12, color: Color(0xFF92400E))),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: ElevatedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.check_circle_rounded, size: 16),
                                label: const Text('قبول', style: TextStyle(fontSize: 14)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SizedBox(
                              height: 42,
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.close_rounded, size: 16),
                                label: const Text('رفض', style: TextStyle(fontSize: 14)),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.danger,
                                  side: const BorderSide(color: AppColors.danger),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── Today Requests ─────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Container(
                      width: 4, height: 20,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('طلبات اليوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.go('/artisan-requests'),
                      child: const Text('عرض الكل →', style: TextStyle(fontSize: 13, color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ),

            // Request items
            SliverToBoxAdapter(child: _requestItem('عميد', 'سباكة', '2.3 كم', 'منذ 10 د', Icons.phone_in_talk_rounded, AppColors.primary)),
            const SliverToBoxAdapter(child: Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.borderLight)),
            SliverToBoxAdapter(child: _requestItem('سعيد', 'صيانة', '3.1 كم', 'منذ 1 س', Icons.access_time_rounded, AppColors.accent)),
            const SliverToBoxAdapter(child: Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.borderLight)),

            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() => _currentIndex = i);
          if (i == 1) context.go('/artisan-requests');
          else if (i == 2) context.go('/artisan-reviews');
          else if (i == 3) context.go('/artisan-account');
        },
        items: _navItems,
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.textTertiary)),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _requestItem(String name, String service, String dist, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$name — $service', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 13, color: AppColors.textTertiary),
                    const SizedBox(width: 3),
                    Text('$dist — الدار البيضاء', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}
