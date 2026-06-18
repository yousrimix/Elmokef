import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  int _selectedPlan = 1; // Default to Pro

  final List<_PlanData> _plans = [
    _PlanData(
      id: 'free', name: 'مجاني', price: '0', period: 'شهر',
      color: AppColors.textSecondary, popular: false,
      features: [
        _Feature('ظهور محدود في نتائج البحث', true),
        _Feature('10 طلبات / شهر', true),
        _Feature('إحصائيات أساسية', false),
        _Feature('دعم فني', false),
        _Feature('بطاقة حرفي أساسية', true),
      ],
    ),
    _PlanData(
      id: 'pro', name: 'احترافي', price: '99', period: 'شهر',
      color: AppColors.primary, popular: true,
      features: [
        _Feature('ظهور أعلى في النتائج', true),
        _Feature('طلبات غير محدودة', true),
        _Feature('إحصائيات المشاهدات', true),
        _Feature('دعم فني', true),
        _Feature('بطاقة حرفي موسعة', true),
      ],
    ),
    _PlanData(
      id: 'premium', name: 'مميز', price: '199', period: 'شهر',
      color: AppColors.accent, popular: false,
      features: [
        _Feature('أولوية في الترتيب', true),
        _Feature('طلبات غير محدودة', true),
        _Feature('تقرير أسبوعي', true),
        _Feature('دعم فني فوري', true),
        _Feature('مساح إعلاني', true),
        _Feature('شارة مميز', true),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('الاشتراكات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),

          // Current plan badge
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF059669), Color(0xFF0D9488)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6)),
              ],
            ),
            child: const Row(
              children: [
                Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 32),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('خطتك الحالية', style: TextStyle(fontSize: 12, color: Colors.white70)),
                      Text('مجاني', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('تمتع بمزايا أكثر مع الباقة الاحترافية', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const Text('اختر باقتك', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),

          ...List.generate(_plans.length, (i) {
            final plan = _plans[i];
            final isSelected = _selectedPlan == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedPlan = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.bgCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? plan.color : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected ? [
                      BoxShadow(color: plan.color.withValues(alpha: 0.1), blurRadius: 12, offset: const Offset(0, 4)),
                    ] : AppColors.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          // Radio
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 24, height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? plan.color : AppColors.textTertiary,
                                width: isSelected ? 6 : 2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(plan.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                    const SizedBox(width: 8),
                                    if (plan.popular)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: plan.color.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text('الأكثر طلباً', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: plan.color)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('${plan.price} درهم', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: plan.color)),
                                    const SizedBox(width: 4),
                                    Text('/ ${plan.period}', style: const TextStyle(fontSize: 13, color: AppColors.textTertiary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.borderLight),
                      const SizedBox(height: 16),
                      // Features
                      ...plan.features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Icon(
                              f.included ? Icons.check_circle_rounded : Icons.cancel_outlined,
                              size: 20,
                              color: f.included ? AppColors.primary : AppColors.textTertiary,
                            ),
                            const SizedBox(width: 10),
                            Text(f.label, style: TextStyle(
                              fontSize: 14,
                              color: f.included ? AppColors.textPrimary : AppColors.textTertiary,
                              fontWeight: f.included ? FontWeight.w500 : FontWeight.normal,
                            )),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // CTA
          SizedBox(
            width: double.infinity, height: 54,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: _plans[_selectedPlan].color,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text(
                _selectedPlan == 0 ? 'خطتك الحالية' : 'اشترك الآن — ${_plans[_selectedPlan].price} درهم/${_plans[_selectedPlan].period}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 16),
          const Center(
            child: Text('يمكنك إلغاء الاشتراك في أي وقت', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _PlanData {
  final String id, name, price, period;
  final Color color;
  final bool popular;
  final List<_Feature> features;
  const _PlanData({required this.id, required this.name, required this.price, required this.period, required this.color, required this.popular, required this.features});
}

class _Feature {
  final String label;
  final bool included;
  const _Feature(this.label, this.included);
}
