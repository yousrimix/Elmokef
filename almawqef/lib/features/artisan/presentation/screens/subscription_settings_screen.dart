import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class SubscriptionSettingsScreen extends StatefulWidget {
  const SubscriptionSettingsScreen({super.key});

  @override
  State<SubscriptionSettingsScreen> createState() => _SubscriptionSettingsScreenState();
}

class _SubscriptionSettingsScreenState extends State<SubscriptionSettingsScreen> {
  final String _currentPlan = 'مجاني';
  final int _remainingRequests = 8;
  final int _maxRequests = 10;
  final String _renewalDate = '15 أكتوبر 2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('إعدادات الاشتراك'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Current plan card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF0D9488)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الباقة الحالية', style: TextStyle(fontSize: 12, color: Colors.white70)),
                        Text('مجاني', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text('نشط', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1, color: Colors.white24),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded, size: 14, color: Colors.white70),
                    const SizedBox(width: 6),
                    const Text('التجديد: ', style: TextStyle(fontSize: 13, color: Colors.white70)),
                    Text(_renewalDate, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Requests tracker
          const Text('الطلبات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('الطلبات المتبقية', style: TextStyle(fontSize: 15, color: AppColors.textPrimary)),
                    Text('$_remainingRequests / $_maxRequests', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _remainingRequests / _maxRequests,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _remainingRequests > 3 ? AppColors.primary : AppColors.danger
                    ),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => context.go('/subscriptions'),
                    child: const Text('ترقية الباقة للحصول على طلبات أكثر →', style: TextStyle(fontSize: 13, color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Plan details
          const Text('تفاصيل الباقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppColors.cardShadow,
            ),
            child: Column(
              children: [
                _detailRow(Icons.workspace_premium_outlined, 'الباقة الحالية', _currentPlan, AppColors.primary),
                const Divider(height: 20, color: AppColors.borderLight),
                _detailRow(Icons.calendar_today_rounded, 'تاريخ التجديد', _renewalDate, AppColors.info),
                const Divider(height: 20, color: AppColors.borderLight),
                _detailRow(Icons.numbers_rounded, 'الطلبات المتبقية', '$_remainingRequests', AppColors.accent),
                const Divider(height: 20, color: AppColors.borderLight),
                _detailRow(Icons.monetization_on_outlined, 'السعر', '0 درهم / شهر', AppColors.textSecondary),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Actions
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => context.go('/subscriptions'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('ترقية الباقة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('إلغاء الاشتراك', style: TextStyle(fontSize: 15)),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
        ),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
