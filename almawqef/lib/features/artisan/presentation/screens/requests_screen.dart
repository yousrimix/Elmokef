import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('الطلبات'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          tabs: const [
            Tab(text: 'جديد (2)'),
            Tab(text: 'جاري (1)'),
            Tab(text: 'مكتمل (2)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRequestsList([
            _RequestData('عميد', 'سباكة', '2.3 كم', 'منذ 10 دقائق', '+212600000001', 'pending'),
            _RequestData('سعيد', 'صيانة', '3.1 كم', 'منذ 1 ساعة', '+212600000002', 'pending'),
          ]),
          _buildRequestsList([
            _RequestData('محمد', 'تركيب وصيانة', '1.5 كم', 'منذ 3 ساعات', '+212600000003', 'accepted'),
          ]),
          _buildRequestsList([
            _RequestData('فاطمة', 'تسليك مجاري', '5.2 كم', 'منذ أمس', '+212600000004', 'completed'),
            _RequestData('خالد', 'تركيب سخانات', '2.8 كم', 'منذ يومين', '+212600000005', 'completed'),
          ]),
        ],
      ),
    );
  }

  Widget _buildRequestsList(List<_RequestData> requests) {
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppColors.bgMuted,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(Icons.inbox_rounded, size: 40, color: AppColors.textTertiary),
            ),
            const SizedBox(height: 16),
            const Text('لا توجد طلبات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            const Text('حين يصلك طلب جديد، حيظهر هنا', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _buildRequestCard(requests[i]),
    );
  }

  Widget _buildRequestCard(_RequestData req) {
    final statusColors = {
      'pending': [AppColors.accent, const Color(0xFFFEF3C7)],
      'accepted': [AppColors.primary, AppColors.primaryLight],
      'completed': [AppColors.info, const Color(0xFFF0F9FF)],
    };
    final colors = statusColors[req.status] ?? [AppColors.textSecondary, AppColors.bgMuted];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: colors[0].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(req.clientName[0], style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: colors[0])),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(req.clientName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(req.service, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors[1],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: colors[0].withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    req.status == 'pending' ? 'جديد' : req.status == 'accepted' ? 'مقبول' : 'مكتمل',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: colors[0]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on_rounded, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text('${req.distance} — الدار البيضاء', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const Spacer(),
                Icon(Icons.access_time_rounded, size: 14, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text(req.time, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
            if (req.status == 'pending') ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text('قبول', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
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
                      height: 40,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('رفض', style: TextStyle(fontSize: 13)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(color: AppColors.danger),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.whatsappLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chat_rounded, size: 18, color: AppColors.whatsapp),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ],
            if (req.status == 'completed') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 40,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.reviews_rounded, size: 16),
                  label: const Text('طلب تقييم من الزبون', style: TextStyle(fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RequestData {
  final String clientName;
  final String service;
  final String distance;
  final String time;
  final String phone;
  final String status;
  const _RequestData(this.clientName, this.service, this.distance, this.time, this.phone, this.status);
}
