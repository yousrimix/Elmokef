import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/rating_bar.dart';
import '../../../../core/widgets/verified_badge.dart';

class ArtisanProfileScreen extends StatelessWidget {
  final String artisanId;
  const ArtisanProfileScreen({super.key, required this.artisanId});

  Future<void> _callPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _openWhatsApp(String phone, String message) async {
    final uri = Uri.parse('whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final webUri = Uri.parse('https://wa.me/$phone?text=${Uri.encodeComponent(message)}');
      if (await canLaunchUrl(webUri)) await launchUrl(webUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── Cover + AppBar ───────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Cover gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF059669), Color(0xFF047857), Color(0xFF065F46)],
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    top: -40, right: -40,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -30, left: -30,
                    child: Container(
                      width: 140, height: 140,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Avatar
                  Positioned(
                    bottom: AppSpacing.xl,
                    right: AppSpacing.xl,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(Icons.person_rounded, size: 44, color: Colors.white),
                    ),
                  ),
                  // Online badge
                  Positioned(
                    bottom: AppSpacing.xl + 56,
                    right: AppSpacing.xl + 50,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.white),
                          SizedBox(width: 4),
                          Text('متصل', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border_rounded, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),

          // ─── Content ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + Rating
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('يوسف العلوي',
                                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                const SizedBox(width: 8),
                                const VerifiedBadge(fontSize: 14),
                              ],
                            ),
                            const SizedBox(height: 4),
                            const Row(
                              children: [
                                Icon(Icons.location_on_rounded, size: 16, color: AppColors.textTertiary),
                                SizedBox(width: 4),
                                Text('الدار البيضاء', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accentLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star_rounded, size: 18, color: AppColors.starActive),
                            SizedBox(width: 4),
                            Text('4.8', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('سباك محترف • 12 سنة خبرة',
                      style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),

                  const SizedBox(height: 20),

                  // Quick stats
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _QuickStat(icon: Icons.location_on_outlined, value: '2.3 كم', label: 'المسافة'),
                        _QuickStat(icon: Icons.monetization_on_outlined, value: '150-300 DH', label: 'السعر'),
                        _QuickStat(icon: Icons.access_time_rounded, value: '5 د', label: 'الرد'),
                        _QuickStat(icon: Icons.assignment_rounded, value: '32', label: 'الطلبات'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Bio
                  _sectionTitle('عن الحرفي'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: const Text(
                      'سباك عندي 12 سنة خبرة في إصلاح جميع مشاكل السباكة، تركيب وصيانة. أشتغل ف الدار البيضاء والمناطق القريبة. نظافة ودقة في المواعيد.',
                      style: TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Services
                  _sectionTitle('الخدمات والأسعار'),
                  const SizedBox(height: 10),
                  _serviceCard('🔧 إصلاح انسدادات', '150 DH', 'تسليك مجاري وشفط بيارات'),
                  const SizedBox(height: 8),
                  _serviceCard('🔧 تركيب حنفيات', '200 DH', 'تركيب حنفيات مطابخ ودورات مياه'),
                  const SizedBox(height: 8),
                  _serviceCard('🔧 صيانة عامة', '250 DH', 'صيانة كاملة لشبكة المياه'),
                  const SizedBox(height: 8),
                  _serviceCard('🔧 تركيب سخانات', '300 DH', 'تركيب سخانات كهربائية وغاز'),

                  const SizedBox(height: 24),

                  // Portfolio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle('معرض الأعمال'),
                      TextButton(
                        onPressed: () => context.go('/artisan-gallery'),
                        child: const Text('الكل →', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 6,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (_, i) => Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft, end: Alignment.bottomRight,
                            colors: [
                              [AppColors.primaryLighter, AppColors.primarySurface],
                              [const Color(0xFFFFF7ED), const Color(0xFFFFFBEB)],
                              [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE)],
                            ][i % 3],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.image_outlined, color: AppColors.textTertiary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Ratings
                  _buildRatingSummary(),

                  const SizedBox(height: 24),

                  // Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _sectionTitle('التقييمات (32)'),
                      TextButton(
                        onPressed: () => context.go('/artisan-reviews', extra: artisanId),
                        child: const Text('عرض الكل →', style: TextStyle(fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _reviewCard('عميد', 5, 'منذ 3 أيام', 'خدمة ممتازة وصل فالوقت، سعر معقول ونظيف'),
                  const SizedBox(height: 8),
                  _reviewCard('سعيد', 4, 'منذ أسبوع', 'خدمة جيدة لكن تأخر شويا فالموعد'),
                  const SizedBox(height: 8),
                  _reviewCard('محمد', 5, 'منذ أسبوعين', 'سباك محترم ونظيف، رجع زاد نضف'),

                  const SizedBox(height: 20),

                  // Complaint
                  Center(
                    child: TextButton.icon(
                      onPressed: () => context.go('/complaint/$artisanId', extra: 'يوسف العلوي'),
                      icon: const Icon(Icons.flag_outlined, size: 16, color: AppColors.textTertiary),
                      label: const Text('تقديم شكوى', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),

      // ─── Bottom CTA ───────────────────────────────────────
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 12,
          top: 12,
          left: 20,
          right: 20,
        ),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Call
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => _callPhone('+212600000000'),
                  icon: const Icon(Icons.phone_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 12),
              // WhatsApp
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp('+212600000000', 'مرحباً يوسف، أنا مهتم بخدماتك'),
                    icon: const Icon(Icons.chat_rounded, size: 18),
                    label: const Text('واتساب', style: TextStyle(fontSize: 15)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whatsapp,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Favorite
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: AppColors.dangerLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border_rounded, color: AppColors.danger),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4, height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _serviceCard(String title, String price, String desc) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(
        children: [
          // Left: big rating number
          Column(
            children: [
              const Text('4.8', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const Row(
                children: [
                  Icon(Icons.star, size: 18, color: AppColors.starActive),
                  Icon(Icons.star, size: 18, color: AppColors.starActive),
                  Icon(Icons.star, size: 18, color: AppColors.starActive),
                  Icon(Icons.star, size: 18, color: AppColors.starActive),
                  Icon(Icons.star_half, size: 18, color: AppColors.starActive),
                ],
              ),
              const SizedBox(height: 2),
              const Text('32 تقييماً', style: TextStyle(fontSize: 12, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(width: 24),
          // Right: distribution bars
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final dist = [70.0, 20.0, 6.0, 3.0, 1.0];
                final label = ['5', '4', '3', '2', '1'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: Text(label[i], style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                      ),
                      const Icon(Icons.star, size: 12, color: AppColors.starActive),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: dist[i] / 100,
                            backgroundColor: AppColors.border,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.starActive),
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 30,
                        child: Text('${dist[i].toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewCard(String name, int rating, String time, String comment) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(name[0], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 10),
              Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const Spacer(),
              AppRatingBar(rating: rating.toDouble(), size: 14),
              const SizedBox(width: 6),
              Text(rating.toString(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4)),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _QuickStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
