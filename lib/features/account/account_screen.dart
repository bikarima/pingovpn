import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/vpn_provider.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/skeleton_loader.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Consumer<VpnProvider>(
                builder: (context, vpn, _) {
                  if (vpn.subscriptionLoading) {
                    return _buildSkeleton();
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontalPadding,
                        vertical: AppSpacing.md),
                    child: Column(
                      children: [
                        _buildServiceCard(context, vpn),
                        const SizedBox(height: 16),
                        _buildShowAllServices(),
                        const SizedBox(height: 16),
                        _buildInfoBox(vpn),
                        const SizedBox(height: 16),
                        _buildPrivacyReport(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final auth = context.read<AuthProvider>();
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
            child: Text('ACCOUNT',
                style: AppTextStyles.h2, textAlign: TextAlign.center),
          ),
          AppIconButton(
            icon: const Icon(Icons.logout_rounded,
                size: 20, color: AppColors.textSecondary),
            onTap: () => _confirmLogout(context, auth),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, AuthProvider auth) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text('Logout?',
            style: AppTextStyles.h3.copyWith(fontSize: 18)),
        content: Text('You will need to login again.',
            style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Logout',
                style: AppTextStyles.body.copyWith(color: AppColors.statusError)),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await auth.logout();
    }
  }

  Widget _buildServiceCard(BuildContext context, VpnProvider vpn) {
    final sub = vpn.subscription;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppColors.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Service',
                      style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    sub?.planName ?? 'No Plan',
                    style: AppTextStyles.monoLarge,
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientUpgrade,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text('Upgrade',
                    style: AppTextStyles.caption.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sub == null)
            _NoSubscriptionBanner(onRedeemTap: () => _showRedeemDialog(context))
          else ...[
            Text(
              '${sub.dataUsagePercent.toStringAsFixed(0)}%',
              style: AppTextStyles.percentLarge,
            ),
            const SizedBox(height: 8),
            _buildSegmentedProgress(sub.dataUsagePercent / 100),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _StatMiniCard(
                        value: sub.validityLabel, label: 'Validity')),
                const SizedBox(width: 12),
                Expanded(
                    child: _StatMiniCard(
                        value: '0/${sub.maxDevices} Users',
                        label: 'Users Connected')),
              ],
            ),
            const SizedBox(height: 12),
            _VipDataCard(
              used: sub.dataUsedGb,
              total: sub.dataLimitGb,
              percent: sub.dataUsagePercent / 100,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _showRedeemDialog(BuildContext context) async {
    final ctrl = TextEditingController();
    final auth = context.read<AuthProvider>();
    final vpn  = context.read<VpnProvider>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceCard,
        title: Text('Redeem License',
            style: AppTextStyles.h3.copyWith(fontSize: 18)),
        content: TextField(
          controller: ctrl,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Enter license code',
            hintStyle: AppTextStyles.caption,
            filled: true,
            fillColor: AppColors.bgSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: AppTextStyles.body.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full)),
            ),
            onPressed: () async {
              final result = await auth.redeemLicense(ctrl.text);
              if (result != null && ctx.mounted) {
                Navigator.pop(ctx);
                await vpn.loadSubscription();
              }
            },
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  Widget _buildSegmentedProgress(double percent) {
    const totalBars = 20;
    final filledBars = (totalBars * percent).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalBars, (i) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: i < filledBars
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildShowAllServices() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_outlined,
              size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Text('Show all services',
              style: AppTextStyles.body.copyWith(fontSize: 15)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildInfoBox(VpnProvider vpn) {
    final sub = vpn.subscription;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.statusConnected.withValues(alpha: 0.08),
        border: Border.all(
            color: AppColors.statusConnected.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.body.copyWith(
              fontSize: 13, color: AppColors.textSecondary, height: 1.6),
          children: [
            TextSpan(
              text: sub != null ? '${sub.daysRemaining} days ' : '0 days ',
              style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: AppColors.statusConnected,
                  fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: 'remaining in your subscription.\n'),
            TextSpan(
              text: '${sub?.maxDevices ?? 0} ',
              style: AppTextStyles.body.copyWith(
                  fontSize: 13,
                  color: AppColors.statusConnected,
                  fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: 'simultaneous device connections allowed.'),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyReport() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_rounded,
                  size: 18, color: AppColors.accentPrimary),
              const SizedBox(width: 8),
              Text('Privacy Report',
                  style: AppTextStyles.body
                      .copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: _StatMiniCard(value: '142 times', label: 'IP Hidden')),
              const SizedBox(width: 12),
              Expanded(
                  child: _StatMiniCard(value: '2.3 TB', label: 'Data Secured')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
      child: Column(
        children: [
          SkeletonLoader(
              width: double.infinity, height: 200, borderRadius: AppRadius.xl),
          const SizedBox(height: 16),
          SkeletonLoader(
              width: double.infinity, height: 56, borderRadius: AppRadius.lg),
          const SizedBox(height: 16),
          SkeletonLoader(
              width: double.infinity, height: 100, borderRadius: AppRadius.lg),
        ],
      ),
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────

class _NoSubscriptionBanner extends StatelessWidget {
  final VoidCallback onRedeemTap;
  const _NoSubscriptionBanner({required this.onRedeemTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentPrimary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
            color: AppColors.accentPrimary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppColors.accentPrimary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text('No active subscription',
                style: AppTextStyles.body.copyWith(fontSize: 14)),
          ),
          GestureDetector(
            onTap: onRedeemTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary,
                borderRadius: BorderRadius.circular(AppRadius.full),
              ),
              child: Text('Redeem',
                  style: AppTextStyles.caption.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatMiniCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatMiniCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(value, style: AppTextStyles.statNumber),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _VipDataCard extends StatelessWidget {
  final double used;
  final double total;
  final double percent;
  const _VipDataCard(
      {required this.used, required this.total, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${used.toStringAsFixed(1)}GB / ${total.toStringAsFixed(0)}GB',
                  style: AppTextStyles.statNumber.copyWith(fontSize: 15)),
              const Spacer(),
              Text('VIP Data Used', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: percent.clamp(0.0, 1.0),
              backgroundColor: AppColors.surfaceCardHover,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.accentPrimary),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}


