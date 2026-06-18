import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/error_state.dart';
import '../providers/notification_provider.dart';
import '../../data/models/notification_model.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () {},
            tooltip: 'تحديد الكل كمقروء',
          ),
        ],
      ),
      body: async.when(
        data: (notifications) => notifications.isEmpty
            ? const EmptyState(
                icon: Icons.notifications_off_outlined,
                title: 'ما عندكش إشعارات',
                subtitle: 'حين يكون عندك نشاط جديد، حتظهر الإشعارات هنا',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) => _NotificationCard(
                  notification: notifications[i],
                  onTap: () {
                    if (!notifications[i].isRead) {
                      ref.read(markAsReadProvider(notifications[i].id));
                      ref.invalidate(notificationsProvider);
                    }
                    _handleNavigation(context, notifications[i]);
                  },
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, NotificationModel notification) {
    final type = notification.data?['type'] as String?;
    switch (type) {
      case 'review':
        context.go('/artisan-reviews');
      case 'subscription':
        context.go('/subscription-settings');
      case 'payment':
        context.go('/subscriptions');
      case 'documents':
        context.go('/artisan-account');
      default:
        break;
    }
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationCard({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final type = notification.data?['type'] as String?;
    final icon = _iconForType(type);
    final color = notification.isRead ? AppColors.textTertiary : AppColors.primary;
    final bgColor = notification.isRead ? AppColors.bgCard : AppColors.primarySurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: !notification.isRead
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.15))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM d').format(notification.createdAt.toLocal()),
                        style: const TextStyle(fontSize: 11, color: AppColors.textTertiary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                  ),
                ],
              ),
            ),
            // Unread dot
            if (!notification.isRead)
              Container(
                width: 10, height: 10, margin: const EdgeInsets.only(top: 2, right: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 6),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'review':
        return Icons.star_rate_rounded;
      case 'subscription':
        return Icons.workspace_premium_rounded;
      case 'payment':
        return Icons.payment_rounded;
      case 'documents':
        return Icons.folder_copy_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }
}
