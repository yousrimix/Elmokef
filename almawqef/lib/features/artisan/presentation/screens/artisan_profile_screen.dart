import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/buttons/primary_button.dart';

class ArtisanProfileViewScreen extends StatelessWidget {
  const ArtisanProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملفي الشخصي'),
        actions: [
          TextButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.visibility_rounded, size: 18),
            label: const Text('شوف كيفاش باين'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            const SizedBox(height: AppSpacing.md),
            _buildInfoRow(),
            const SizedBox(height: AppSpacing.lg),
            _buildSection('وصفي', 'سباك محترف عندي 12 سنة خبرة في مجال السباكة. كنسرج فجميع أنواع الإصلاحات والتركيبات.',
                onEdit: () {}),
            const SizedBox(height: AppSpacing.lg),
            _buildServicesSection(),
            const SizedBox(height: AppSpacing.lg),
            _buildGallerySection(context),
            const SizedBox(height: AppSpacing.xl),
            _buildCompletionCard(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: Container(
                  width: 120, height: 120,
                  decoration: const BoxDecoration(color: AppColors.border, shape: BoxShape.circle),
                  child: const Center(child: Icon(Icons.person, size: 60, color: Colors.white)),
                ),
              ),
              Positioned(
                bottom: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('حرّاث بنعلي', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('سباك محترف — فاس', style: TextStyle(fontSize: 15, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoChip(Icons.star_rounded, '4.8', '32 تقييماً'),
          _buildInfoChip(Icons.location_on_outlined, '2.3 كم', 'منك'),
          _buildInfoChip(Icons.monetization_on_outlined, '150 DH', 'للزيارة'),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildSection(String title, String content, {VoidCallback? onEdit}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: const Text('تعديل', style: TextStyle(fontSize: 14, color: AppColors.primary)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(content, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    final services = [
      {'name': 'إصلاح انسدادات', 'price': '150'},
      {'name': 'تركيب حنفيات', 'price': '200'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('خدماتي', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () {},
                child: const Text('تعديل', style: TextStyle(fontSize: 14, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...services.map((s) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                const Icon(Icons.build_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(s['name']!, style: const TextStyle(fontSize: 14))),
                Text('${s['price']} درهم', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildGallerySection(BuildContext context) {
    final images = <String>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('معرض الأعمال', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              GestureDetector(
                onTap: () => context.go('/artisan-gallery'),
                child: const Text('إدارة', style: TextStyle(fontSize: 14, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              ...images.take(3).map((url) => Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(imageUrl: url, width: 80, height: 80, fit: BoxFit.cover),
                ),
              )),
              GestureDetector(
                onTap: () => context.go('/artisan-gallery'),
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_outlined, size: 28, color: AppColors.textSecondary),
                      const SizedBox(height: 2),
                      const Text('أضف', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: const Color(0xFFF0FDF9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('اكتمال الملف:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: AppSpacing.sm),
                const Text('70%', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                value: 0.7,
                backgroundColor: Color(0xFFE5E7EB),
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text('أضف صور أعمالك لترفع النسبة وتظهر أكثر للزبائن',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            const SizedBox(height: AppSpacing.md),
            PrimaryButton(
              text: 'أكمل ملفي',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
