import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/vpn_provider.dart';
import '../../shared/widgets/app_icon_button.dart';

enum _UsagePeriod { daily, weekly, monthly }

class DataUsageScreen extends StatefulWidget {
  const DataUsageScreen({super.key});

  @override
  State<DataUsageScreen> createState() => _DataUsageScreenState();
}

class _DataUsageScreenState extends State<DataUsageScreen> {
  _UsagePeriod _period = _UsagePeriod.weekly;
  int? _hoveredIndex;

  // در اپ واقعی این داده‌ها از API میاد
  // فعلاً بر اساس اشتراک واقعی محاسبه می‌شه
  List<_UsageData> _buildData(double totalGb) {
    // تقسیم مصرف واقعی به بازه‌های زمانی (تقریبی)
    final rng = math.Random(totalGb.toInt());
    switch (_period) {
      case _UsagePeriod.daily:
        return List.generate(24, (i) => _UsageData(
          label: '${i}h',
          value: i < 12
              ? (totalGb / 24) * (0.5 + rng.nextDouble())
              : (totalGb / 24) * rng.nextDouble(),
        ));
      case _UsagePeriod.weekly:
        final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        return List.generate(7, (i) => _UsageData(
          label: days[i],
          value: (totalGb / 7) * (0.5 + rng.nextDouble()),
        ));
      case _UsagePeriod.monthly:
        return List.generate(30, (i) => _UsageData(
          label: '${i + 1}',
          value: (totalGb / 30) * (0.5 + rng.nextDouble()),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VpnProvider>(
      builder: (context, vpn, _) {
        final sub = vpn.subscription;
        final used = sub?.dataUsedGb ?? 0.0;
        final data = _buildData(used);
        final totalUsage = data.fold(0.0, (s, d) => s + d.value);

        return Scaffold(
          backgroundColor: AppColors.bgPrimary,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontalPadding,
                        vertical: AppSpacing.md),
                    child: Column(
                      children: [
                        // ── Subscription overview card ─────────
                        if (sub != null) _buildOverviewCard(sub.dataUsedGb, sub.dataLimitGb),
                        const SizedBox(height: 20),
                        _buildPeriodTabs(),
                        const SizedBox(height: 20),
                        _buildChart(data),
                        const SizedBox(height: 20),
                        _buildSummaryCard(totalUsage),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
            child: Text('DATA USAGE',
                style: AppTextStyles.h2, textAlign: TextAlign.center),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(double used, double limit) {
    final pct = limit > 0 ? (used / limit).clamp(0.0, 1.0) : 0.0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPrimary.withValues(alpha: 0.15),
            AppColors.accentPrimaryDark.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
            color: AppColors.accentPrimary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.data_usage_rounded,
                  size: 20, color: AppColors.accentPrimary),
              const SizedBox(width: 10),
              Text('${used.toStringAsFixed(2)} GB used',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Text('of ${limit.toStringAsFixed(0)} GB',
                  style: AppTextStyles.caption),
            ],
          ),
          const SizedBox(height: 10),
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
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        children: _UsagePeriod.values.map((p) {
          final isActive = _period == p;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _period = p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 36,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.accentPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                alignment: Alignment.center,
                child: Text(
                  p.name[0].toUpperCase() + p.name.substring(1),
                  style: AppTextStyles.caption.copyWith(
                    color: isActive ? Colors.white : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChart(List<_UsageData> data) {
    final maxVal = data.map((d) => d.value).reduce(math.max);
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Expanded(
            child: LayoutBuilder(builder: (context, constraints) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(data.length, (i) {
                  final h = maxVal > 0
                      ? (data[i].value / maxVal).clamp(0.02, 1.0)
                      : 0.02;
                  final isHov = _hoveredIndex == i;
                  return Expanded(
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _hoveredIndex = i),
                      onTapUp: (_) => setState(() => _hoveredIndex = null),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Stack(
                          alignment: Alignment.topCenter,
                          clipBehavior: Clip.none,
                          children: [
                            if (isHov)
                              Positioned(
                                top: -26,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentPrimary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${data[i].value.toStringAsFixed(2)}GB',
                                    style: AppTextStyles.caption.copyWith(
                                        fontSize: 10, color: Colors.white),
                                  ),
                                ),
                              ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: constraints.maxHeight * h,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    AppColors.accentPrimary,
                                    AppColors.accentPrimary.withValues(alpha: 0.3),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
          const SizedBox(height: 6),
          // X-axis labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data.first.label,
                    style: AppTextStyles.caption.copyWith(fontSize: 10)),
                Text(data[data.length ~/ 2].label,
                    style: AppTextStyles.caption.copyWith(fontSize: 10)),
                Text(data.last.label,
                    style: AppTextStyles.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double totalUsage) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        children: [
          const Icon(Icons.bar_chart_rounded,
              size: 24, color: AppColors.accentPrimary),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('~${totalUsage.toStringAsFixed(2)} GB',
                  style: AppTextStyles.statNumber.copyWith(fontSize: 20)),
              Text('Estimated usage this ${_period.name}',
                  style: AppTextStyles.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageData {
  final String label;
  final double value;
  const _UsageData({required this.label, required this.value});
}


