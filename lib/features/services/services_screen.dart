import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_icon_button.dart';

class ServiceModel {
  final String code;
  final bool isActive;
  final bool isFree;
  final double? price;
  final int dataUsedGb;
  final int dataTotalGb;
  final int validityDays;
  final int connectedUsers;
  final int maxUsers;

  const ServiceModel({
    required this.code,
    this.isActive = false,
    this.isFree = false,
    this.price,
    this.dataUsedGb = 0,
    this.dataTotalGb = 3,
    this.validityDays = 30,
    this.connectedUsers = 0,
    this.maxUsers = 2,
  });
}

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const List<ServiceModel> _services = [
    ServiceModel(code: 'hXWsN4Kg', isActive: true, isFree: true),
    ServiceModel(code: 'PRO-7Fg2X', isActive: false, price: 9.99, dataUsedGb: 1, dataTotalGb: 10),
    ServiceModel(code: 'VIP-9Zt3W', isActive: false, price: 19.99, dataTotalGb: 100),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.horizontalPadding,
                  vertical: AppSpacing.md,
                ),
                itemCount: _services.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.cardSpacing),
                  child: _ServiceCard(service: _services[i]),
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
              'SERVICES',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: service.isActive
            ? Border.all(color: AppColors.accentPrimary)
            : null,
        boxShadow: AppColors.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: service.isActive
                      ? AppColors.accentPrimary
                      : Colors.transparent,
                  border: Border.all(
                    color: service.isActive
                        ? AppColors.accentPrimary
                        : AppColors.textTertiary,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(service.code, style: AppTextStyles.monoLarge),
              const Spacer(),
              service.isFree
                  ? Text(
                      'FREE',
                      style: AppTextStyles.body.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.statusConnected,
                      ),
                    )
                  : Text(
                      '\$${service.price?.toStringAsFixed(2)}/mo',
                      style: AppTextStyles.body.copyWith(fontSize: 13),
                    ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: '${service.dataUsedGb}GB/${service.dataTotalGb}GB',
                  label: 'VIP Data Used',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  value: '${service.validityDays} Days',
                  label: 'Validity',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
