import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/models/api_models.dart';
import '../../core/network/api_service.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/empty_state.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ApiService.getNotifications();
      if (mounted) setState(() { _notifications = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text('Clear all?',
            style: AppTextStyles.h3.copyWith(fontSize: 18)),
        content: Text('This will delete all notifications.',
            style: AppTextStyles.body
                .copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear',
                style: AppTextStyles.body
                    .copyWith(color: AppColors.statusError)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ApiService.clearNotifications();
      if (mounted) setState(() => _notifications.clear());
    } catch (_) {}
  }

  Future<void> _dismiss(int index) async {
    final notif = _notifications[index];
    setState(() => _notifications.removeAt(index));
    try {
      // mark as read روی سرور
      await ApiService.markNotificationRead(notif.id);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPadding, vertical: 12),
      child: Row(
        children: [
          AppIconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                size: 20, color: AppColors.textPrimary),
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text('Notifications',
                style: AppTextStyles.h2.copyWith(letterSpacing: 0),
                textAlign: TextAlign.center),
          ),
          AppIconButton(
            icon: const Icon(Icons.cleaning_services_rounded,
                size: 20, color: AppColors.textSecondary),
            onTap: _notifications.isEmpty ? null : _clearAll,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(
              color: AppColors.accentPrimary, strokeWidth: 2));
    }
    if (_notifications.isEmpty) {
      return const EmptyState(
        icon: Icons.notifications_none_rounded,
        title: 'No notifications',
        subtitle: 'Notification list is empty',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPadding, vertical: 8),
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
          onDismissed: (_) => _dismiss(i),
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

  static const _typeColors = {
    'expiry_warning': AppColors.statusConnecting,
    'data_warning':   AppColors.statusError,
    'promo':          AppColors.accentPrimary,
    'system':         AppColors.textSecondary,
  };

  static const _typeIcons = {
    'expiry_warning': Icons.timer_outlined,
    'data_warning':   Icons.data_usage_rounded,
    'promo':          Icons.card_giftcard_rounded,
    'system':         Icons.info_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final color = _typeColors[notif.type] ?? AppColors.accentPrimary;
    final icon  = _typeIcons[notif.type]  ?? Icons.notifications_rounded;

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
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(notif.title,
                        style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(notif.body,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(_timeAgo(notif.createdAt),
                        style: AppTextStyles.caption.copyWith(fontSize: 11)),
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

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt.toLocal());
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}


