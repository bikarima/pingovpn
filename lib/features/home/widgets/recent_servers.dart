import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/state/connection_state.dart';
import '../../../shared/widgets/vip_badge.dart';

class RecentServers extends StatelessWidget {
  final List<ServerModel> servers;
  final ValueChanged<ServerModel> onSelect;

  const RecentServers({
    super.key,
    required this.servers,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding),
          child: Text('RECENTLY CONNECTED', style: AppTextStyles.sectionLabel),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.horizontalPadding),
            itemCount: servers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                    right: index < servers.length - 1
                        ? AppSpacing.cardSpacing
                        : 0),
                child: _RecentServerItem(
                  server: servers[index],
                  onTap: () => onSelect(servers[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentServerItem extends StatelessWidget {
  final ServerModel server;
  final VoidCallback onTap;

  const _RecentServerItem({required this.server, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(server.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 8),
            Text(
              server.name.split(' ').first,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            server.isVip
                ? const VipBadge()
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'retry',
                      style: AppTextStyles.caption.copyWith(fontSize: 10),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
