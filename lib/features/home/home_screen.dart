import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/vpn_provider.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/skeleton_loader.dart';
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
            return RefreshIndicator(
              color: AppColors.accentPrimary,
              backgroundColor: AppColors.surfaceCard,
              onRefresh: () async {
                await Future.wait([
                  vpn.loadServers(),
                  vpn.loadSubscription(),
                ]);
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildHeader(context, vpn),
                        const SizedBox(height: 24),
                        _buildBranding(vpn),
                        const SizedBox(height: 16),

                        // ── No subscription banner ─────────────
                        if (!vpn.subscriptionLoading && !vpn.hasActiveSubscription)
                          _buildNoBannerSubscription(context),

                        const SizedBox(height: 16),
                        _buildServerCard(context, vpn),
                        const SizedBox(height: 28),

                        // ── Recently connected ─────────────────
                        if (vpn.recentServers.isNotEmpty)
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

                        // ── Server list ───────────────────────
                        vpn.serversLoading
                            ? _buildServerSkeleton()
                            : vpn.serversError != null && vpn.servers.isEmpty
                                ? _buildServersError(context, vpn)
                                : ServerList(
                                    servers: vpn.servers,
                                    selectedServer: vpn.selectedServer,
                                    onSelect: (server) =>
                                        vpn.selectServer(server),
                                    isLoading: vpn.serversLoading,
                                  ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, VpnProvider vpn) {
    final sub = vpn.subscription;
    final pct = sub?.dataUsagePercent ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPadding),
      child: Row(
        children: [
          AppIconButton(
            icon: const Icon(Icons.settings_rounded,
                size: 20, color: AppColors.textSecondary),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
          const SizedBox(width: 8),
          AppIconButton(
            icon: const Icon(Icons.notifications_none_rounded,
                size: 20, color: AppColors.textSecondary),
            hasNotification: false,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(
                    builder: (_) => const NotificationsScreen())),
          ),
          const Spacer(),

          // Upgrade یا data usage badge
          if (sub != null && sub.isActive)
            _DataBadge(percent: pct)
          else
            _UpgradeButton(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AccountScreen())),
            ),

          const SizedBox(width: 8),
          AppIconButton(
            icon: const Icon(Icons.person_rounded,
                size: 20, color: AppColors.textSecondary),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AccountScreen())),
          ),
        ],
      ),
    );
  }

  // ── Branding + status ────────────────────────────────────────
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
        Text(
          statusText,
          style: AppTextStyles.body
              .copyWith(fontSize: 13, color: statusColor),
        ),
      ],
    );
  }

  Widget _buildSignalLines({required bool reversed}) {
    final lines = [12.0, 8.0, 5.0];
    final ordered = reversed ? lines.reversed.toList() : lines;
    return Column(
      crossAxisAlignment:
          reversed ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: ordered.map((w) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.5),
        child: Container(
          width: w, height: 2,
          decoration: BoxDecoration(
            color: AppColors.accentPrimary,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      )).toList(),
    );
  }

  // ── No subscription banner ────────────────────────────────────
  Widget _buildNoBannerSubscription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPadding),
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AccountScreen())),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.statusConnecting.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
                color: AppColors.statusConnecting.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.statusConnecting, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No active subscription — Tap to redeem license',
                  style: AppTextStyles.caption.copyWith(
                      color: AppColors.statusConnecting, fontSize: 13),
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppColors.statusConnecting, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Server card ───────────────────────────────────────────────
  Widget _buildServerCard(BuildContext context, VpnProvider vpn) {
    if (vpn.serversLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.horizontalPadding),
        child: SkeletonLoader(
            width: double.infinity, height: 140, borderRadius: 28),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPadding),
      child: vpn.selectedServer == null
          ? const SizedBox(height: 140)
          : ServerCard(
              server: vpn.selectedServer!,
              status: vpn.status,
              timer: vpn.formattedDuration,
              onPowerTap: vpn.hasActiveSubscription
                  ? () => vpn.toggleConnection()
                  : null,
            ),
    );
  }

  // ── Servers error ─────────────────────────────────────────────
  Widget _buildServersError(BuildContext context, VpnProvider vpn) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPadding),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 36, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text('Could not load servers',
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(vpn.serversError ?? 'Check your connection',
                style: AppTextStyles.caption, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => vpn.loadServers(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text('Retry',
                    style: AppTextStyles.body
                        .copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPadding),
      child: Column(
        children: List.generate(
          4,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SkeletonLoader(
                width: double.infinity, height: 64, borderRadius: 20),
          ),
        ),
      ),
    );
  }
}

// ─── Header widgets ───────────────────────────────────────────

class _UpgradeButton extends StatelessWidget {
  final VoidCallback onTap;
  const _UpgradeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: AppColors.gradientUpgrade,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          'Upgrade',
          style: AppTextStyles.caption.copyWith(
              fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}

class _DataBadge extends StatelessWidget {
  final double percent;
  const _DataBadge({required this.percent});

  @override
  Widget build(BuildContext context) {
    final color = percent > 90
        ? AppColors.statusError
        : percent > 70
            ? AppColors.statusConnecting
            : AppColors.statusConnected;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.data_usage_rounded, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            '${percent.toStringAsFixed(0)}%',
            style: AppTextStyles.caption.copyWith(
                color: color, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class AppRadius {
  static const double full = 999.0;
  static const double lg   = 20.0;
}
