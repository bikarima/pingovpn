import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/network/api_service.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/skeleton_loader.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  List<Map<String, dynamic>> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await ApiService.getAllSubscriptions();
      if (mounted) setState(() { _services = list; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(child: _loading ? _buildSkeleton() : _buildList()),
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
            child: Text('SERVICES',
                style: AppTextStyles.h2, textAlign: TextAlign.center),
          ),
          AppIconButton(
            icon: const Icon(Icons.refresh_rounded,
                size: 20, color: AppColors.textSecondary),
            onTap: () {
              setState(() => _loading = true);
              _load();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_services.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.confirmation_number_outlined,
                size: 48, color: AppColors.textTertiary),
            const SizedBox(height: 16),
            Text('No services found',
                style: AppTextStyles.bodyLarge),
            const SizedBox(height: 4),
            Text('Redeem a license to get started',
                style: AppTextStyles.caption),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.horizontalPadding,
          vertical: AppSpacing.md),
      itemCount: _services.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.cardSpacing),
        child: _ServiceCard(data: _services[i]),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
      child: Column(
        children: List.generate(2, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SkeletonLoader(
              width: double.infinity, height: 140, borderRadius: 20),
        )),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _ServiceCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final isActive = data['status'] == 'active';
    final planName = data['plan_name'] as String? ?? 'Plan';
    final dataUsed = (data['data_used_gb'] as num?)?.toDouble() ?? 0;
    final dataLimit = (data['data_limit_gb'] as num?)?.toDouble() ?? 1;
    final days = data['days_remaining'] as int? ?? 0;
    final pct = dataLimit > 0 ? (dataUsed / dataLimit).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: isActive
            ? Border.all(color: AppColors.accentPrimary, width: 1.5)
            : null,
        boxShadow: AppColors.shadowCard,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.statusConnected : AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 8),
              Text(planName,
                  style: AppTextStyles.monoLarge.copyWith(fontSize: 15)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.statusConnected.withValues(alpha: 0.15)
                      : AppColors.surfaceCardHover,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  isActive ? 'ACTIVE' : (data['status'] as String? ?? '').toUpperCase(),
                  style: AppTextStyles.micro.copyWith(
                    color: isActive ? AppColors.statusConnected : AppColors.textTertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 14),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  value: '${dataUsed.toStringAsFixed(1)}/${dataLimit.toStringAsFixed(0)} GB',
                  label: 'Data Used',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  value: '$days Days',
                  label: 'Remaining',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppColors.surfaceCardHover,
              valueColor: AlwaysStoppedAnimation<Color>(
                pct > 0.9 ? AppColors.statusError
                    : pct > 0.7 ? AppColors.statusConnecting
                    : AppColors.accentPrimary,
              ),
              minHeight: 4,
            ),
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
          Text(value,
              style: AppTextStyles.body.copyWith(
                  fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}


