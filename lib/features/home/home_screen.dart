import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/vpn_provider.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../settings/settings_screen.dart';
import '../account/account_screen.dart';
import '../notifications/notifications_screen.dart';
import 'widgets/server_card.dart';
import 'widgets/recent_servers.dart';
import 'widgets/server_list.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Consumer<VpnProvider>(
          builder: (context, vpn, _) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _buildHeader(context, vpn),
                      const SizedBox(height: 24),
                      _buildBranding(vpn),
                      const SizedBox(height: 32),
                      _buildServerCard(context, vpn),
                      const SizedBox(height: 28),
                      RecentServers(
                        servers: vpn.recentServers,
                        onSelect: (server) => vpn.selectServer(server),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.horizontalPadding,
                            vertical: 20),
                        child: Divider(
                            color: AppColors.borderSubtle, thickness: 1),
                      ),
                      ServerList(
                        servers: vpn.servers,
                        selectedServer: vpn.selectedServer,
                        onSelect: (server) => vpn.selectServer(server),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VpnProvider vpn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: Row(
        children: [
          AppIconButton(
            icon: const Icon(Icons.settings_rounded,
                size: 20, color: AppColors.textSecondary),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SettingsScreen()),
            ),
          ),
          const SizedBox(width: 8),
          AppIconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                size: 20, color: AppColors.textSecondary),
            hasNotification: true,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const NotificationsScreen()),
            ),
          ),
          const Spacer(),
          // Upgrade button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.gradientUpgrade,
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              'Upgrade',
              style: AppTextStyles.caption.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          AppIconButton(
            icon: const Icon(Icons.person_rounded,
                size: 20, color: AppColors.textSecondary),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranding(VpnProvider vpn) {
    final statusText = vpn.isConnected
        ? 'is Connected'
        : vpn.isConnecting
            ? 'is Connecting...'
            : 'is Disconnected';

    final statusColor = vpn.isConnected
        ? AppColors.statusConnected
        : vpn.isConnecting
            ? AppColors.statusConnecting
            : AppColors.textSecondary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSignalLines(reversed: true),
            const SizedBox(width: 8),
            Text('PINGO', style: AppTextStyles.brandName),
            const SizedBox(width: 8),
            _buildSignalLines(reversed: false),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              statusText,
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: statusColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSignalLines({required bool reversed}) {
    final lines = [12.0, 8.0, 5.0];
    final orderedLines = reversed ? lines.reversed.toList() : lines;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: reversed ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: orderedLines
          .map(
            (w) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: Container(
                width: w,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildServerCard(BuildContext context, VpnProvider vpn) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.horizontalPadding),
      child: vpn.selectedServer == null
          ? const SizedBox(height: 140)
          : ServerCard(
              server: vpn.selectedServer!,
              status: vpn.status,
              timer: vpn.formattedDuration,
              onPowerTap: () => vpn.toggleConnection(),
            ),
    );
  }
}
