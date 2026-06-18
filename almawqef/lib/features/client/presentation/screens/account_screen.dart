import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Profile Header ───────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF059669), Color(0xFF0D9488), Color(0xFF0F766E)],
                      ),
                    ),
                  ),
                  // Decorative
                  Positioned(
                    top: -50, right: -50,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -40, left: -40,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.04),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Profile info
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 72, height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(Icons.person_rounded, size: 38, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        // Name + info
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('عميد', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.phone_rounded, size: 14, color: Colors.white70),
                                  SizedBox(width: 6),
                                  Text('+212 6XX XX XX XX', style: TextStyle(fontSize: 14, color: Colors.white70)),
                                ],
                              ),
                              SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.location_on_rounded, size: 14, color: Colors.white70),
                                  SizedBox(width: 6),
                                  Text('الدار البيضاء، المغرب', style: TextStyle(fontSize: 14, color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Edit
                        Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.edit_rounded, size: 20, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Stats ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                children: [
                  _statCard(Icons.receipt_long, '12', 'طلبات', AppColors.primary),
                  const SizedBox(width: 10),
                  _statCard(Icons.favorite, '8', 'مفضلة', AppColors.danger),
                  const SizedBox(width: 10),
                  _statCard(Icons.star_rounded, '4.8', 'تقييمي', AppColors.starActive),
                ],
              ),
            ),
          ),

          // ─── Menu ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('حسابي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _menuCard([
                    _MenuItemData(Icons.assignment_outlined, 'طلباتي السابقة', Colors.indigo, () => context.go('/my-orders')),
                    _MenuItemData(Icons.favorite_outline, 'مفضلتي', AppColors.danger, () => context.go('/favorites')),
                    _MenuItemData(Icons.reviews_outlined, 'تقييماتي', AppColors.starActive, () => context.go('/my-reviews')),
                    _MenuItemData(Icons.map_outlined, 'الحرفيون على الخريطة', AppColors.info, () => context.go('/map')),
                  ]),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الإعدادات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _menuCard([
                    _MenuItemData(Icons.settings_outlined, 'الإعدادات العامة', AppColors.textSecondary, () {}),
                    _MenuItemData(Icons.language_outlined, 'اللغة: العربية', AppColors.textSecondary, () {}),
                    _MenuItemData(Icons.notifications_outlined, 'الإشعارات', AppColors.textSecondary, () {}),
                    _MenuItemData(Icons.lock_outlined, 'الخصوصية والأمان', AppColors.textSecondary, () {}),
                  ]),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الدعم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _menuCard([
                    _MenuItemData(Icons.headset_mic_outlined, 'مساعدة ودعم', AppColors.textSecondary, () {}),
                    _MenuItemData(Icons.privacy_tip_outlined, 'سياسة الخصوصية', AppColors.textSecondary, () {}),
                    _MenuItemData(Icons.description_outlined, 'شروط الاستخدام', AppColors.textSecondary, () {}),
                    _MenuItemData(Icons.info_outline, 'حول التطبيق', AppColors.textSecondary, () {}),
                  ]),
                ],
              ),
            ),
          ),

          // ─── Switch to Artisan Mode ──────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withValues(alpha: 0.08), AppColors.accent.withValues(alpha: 0.08)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.handyman_rounded, color: AppColors.primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('وضع الحرفي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          SizedBox(height: 2),
                          Text('بدّل لحساب الحرفي لإدارة خدماتك وطلباتك', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_back_ios_rounded, color: AppColors.primary, size: 18),
                  ],
                ),
              ),
            ),
          ),

          // ─── Logout ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text('تسجيل الخروج'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String value, String label, Color color) {
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
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(List<_MenuItemData> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: items.map((item) {
          final isLast = items.indexOf(item) == items.length - 1;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, size: 20, color: item.color),
                ),
                title: Text(item.label, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.textTertiary, size: 20),
                onTap: item.onTap,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              if (!isLast)
                const Padding(
                  padding: EdgeInsets.only(left: 16, right: 52),
                  child: Divider(height: 1, color: AppColors.borderLight),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _MenuItemData(this.icon, this.label, this.color, this.onTap);
}
