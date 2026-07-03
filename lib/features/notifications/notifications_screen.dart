import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/empty_state.dart';
class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.isRead = false,
  });
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationModel> _notifications = [
    const NotificationModel(
      id: '1',
      title: 'Connected to Finland 2',
      description: 'Your VPN connection is now active.',
      time: '2 min ago',
      icon: Icons.check_circle_rounded,
      iconColor: AppColors.statusConnected,
      isRead: false,
    ),
    const NotificationModel(
      id: '2',
      title: 'New server available',
      description: 'Japan 2 server is now available for VIP users.',
      time: '1 hour ago',
      icon: Icons.new_releases_rounded,
      iconColor: AppColors.accentPrimary,
      isRead: true,
    ),
    const NotificationModel(
      id: '3',
      title: 'Subscription renews in 7 days',
      description: 'Your plan will auto-renew on July 10, 2026.',
      time: 'Yesterday',
      icon: Icons.calendar_today_rounded,
      iconColor: AppColors.statusConnecting,
      isRead: true,
    ),
  ];

  void _clearAll() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text('Clear all?', style: AppTextStyles.h3.copyWith(fontSize: 18)),
        content: Text(
          'This will delete all notifications.',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _notifications.clear());
            },
            child: Text(
              'Clear',
              style: AppTextStyles.body.copyWith(color: AppColors.statusError),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _notifications.isEmpty
                  ? const EmptyState(
                      icon: Icons.notifications_none_rounded,
                      title: 'No notifications',
                      subtitle: 'Notification list is empty',
                    )
                  : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: const Icon(
              Icons.arrow_back_rounded,
              size: 20,
              color: AppColors.textPrimary,
            ),
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'Notifications',
              style: AppTextStyles.h2.copyWith(letterSpacing: 0),
              textAlign: TextAlign.center,
            ),
          ),
          AppIconButton(
            icon: const Icon(
              Icons.cleaning_services_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
            onTap: _clearAll,
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.horizontalPadding,
        vertical: 8,
      ),
      itemCount: _notifications.length,
      itemBuilder: (context, i) {
        final notif = _notifications[i];
        return Dismissible(
          key: Key(notif.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.statusError,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(Icons.delete_rounded, color: Colors.white),
          ),
          onDismissed: (_) => setState(() => _notifications.removeAt(i)),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _NotificationItem(notif: notif),
          ),
        );
      },
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final NotificationModel notif;

  const _NotificationItem({required this.notif});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: notif.iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(notif.icon, size: 20, color: notif.iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notif.title,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notif.description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notif.time,
                      style: AppTextStyles.caption.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!notif.isRead)
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColors.accentPrimary,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
