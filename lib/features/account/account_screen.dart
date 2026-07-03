import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_icon_button.dart';

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.horizontalPadding,
                    vertical: AppSpacing.md),
                child: Column(
                  children: [
                    _buildServiceCard(),
                    const SizedBox(height: 16),
                    _buildShowAllServices(),
                    const SizedBox(height: 16),
                    _buildInfoBox(),
                    const SizedBox(height: 16),
                    _buildPrivacyReport(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
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
            child: Text(
              'ACCOUNT',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
          ),
          AppIconButton(
            icon: const Icon(Icons.logout_rounded,
                size: 20, color: AppColors.textSecondary),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard() {
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
                  Text('Current Service', style: AppTextStyles.caption),
                  const SizedBox(height: 2),
                  Text(
                    'hXWsN4Kg',
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
                child: Text(
                  'Upgrade',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('100%', style: AppTextStyles.percentLarge),
          const SizedBox(height: 8),
          _buildSegmentedProgress(1.0),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatMiniCard(
                  value: '30 Days',
                  label: 'Validity',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatMiniCard(
                  value: '0/2 Users',
                  label: 'Users Connected',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _VipDataCard(),
        ],
      ),
    );
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
          final isFilled = i < filledBars;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.5),
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: isFilled
                  ? Colors.white
                  : Colors.white.withOpacity(0.15),
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
          Text(
            'Show all services',
            style: AppTextStyles.body.copyWith(fontSize: 15),
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.statusConnected.withOpacity(0.08),
        border: Border.all(
          color: AppColors.statusConnected.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.body.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          children: [
            TextSpan(
              text: '∞ ',
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: AppColors.statusConnected,
                fontWeight: FontWeight.w700,
              ),
            ),
            const TextSpan(
              text:
                  'Unlimited bandwidth available. Your subscription renews in 30 days.\n',
            ),
            TextSpan(
              text: '2 ',
              style: AppTextStyles.body.copyWith(
                fontSize: 13,
                color: AppColors.statusConnected,
                fontWeight: FontWeight.w700,
              ),
            ),
            const TextSpan(
              text: 'simultaneous device connections allowed.',
            ),
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
              Text(
                'Privacy Report',
                style: AppTextStyles.body.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatMiniCard(
                  value: '142 times',
                  label: 'IP Hidden',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatMiniCard(
                  value: '2.3 TB',
                  label: 'Data Secured',
                ),
              ),
            ],
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
              Text('0GB/3GB', style: AppTextStyles.statNumber),
              const Spacer(),
              Text('VIP Data Used', style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: 0.0,
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
