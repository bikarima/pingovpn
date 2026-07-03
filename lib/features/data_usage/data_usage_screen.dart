import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
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

  final Map<_UsagePeriod, List<_UsageData>> _data = {
    _UsagePeriod.daily: List.generate(
      24,
      (i) => _UsageData(
        label: '${i}h',
        value: math.Random(i * 7).nextDouble() * 3,
      ),
    ),
    _UsagePeriod.weekly: [
      _UsageData(label: 'Mon', value: 1.2),
      _UsageData(label: 'Tue', value: 2.5),
      _UsageData(label: 'Wed', value: 0.8),
      _UsageData(label: 'Thu', value: 3.1),
      _UsageData(label: 'Fri', value: 1.9),
      _UsageData(label: 'Sat', value: 4.2),
      _UsageData(label: 'Sun', value: 2.7),
    ],
    _UsagePeriod.monthly: List.generate(
      30,
      (i) => _UsageData(
        label: '${i + 1}',
        value: math.Random(i * 13).nextDouble() * 5,
      ),
    ),
  };

  List<_UsageData> get _currentData => _data[_period]!;

  double get _totalUsage =>
      _currentData.fold(0, (sum, d) => sum + d.value);

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
                  vertical: AppSpacing.md,
                ),
                child: Column(
                  children: [
                    _buildPeriodTabs(),
                    const SizedBox(height: 24),
                    _buildChart(),
                    const SizedBox(height: 24),
                    _buildSummaryCard(),
                    const SizedBox(height: 24),
                    _buildBreakdown(),
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
        horizontal: AppSpacing.horizontalPadding,
        vertical: 12,
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                size: 20, color: AppColors.textPrimary),
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text(
              'DATA USAGE',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
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
                    color: isActive
                        ? Colors.white
                        : AppColors.textSecondary,
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

  Widget _buildChart() {
    final data = _currentData;
    final maxVal = data.map((d) => d.value).reduce(math.max);
    final showAll = data.length <= 10;

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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final barWidth = constraints.maxWidth / data.length - 4;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(data.length, (i) {
                    final heightPercent = maxVal > 0
                        ? (data[i].value / maxVal).clamp(0.02, 1.0)
                        : 0.02;
                    final isHovered = _hoveredIndex == i;

                    return Expanded(
                      child: GestureDetector(
                        onTapDown: (_) =>
                            setState(() => _hoveredIndex = i),
                        onTapUp: (_) =>
                            setState(() => _hoveredIndex = null),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            clipBehavior: Clip.none,
                            children: [
                              // Tooltip
                              if (isHovered)
                                Positioned(
                                  top: -32,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.accentPrimary,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${data[i].value.toStringAsFixed(1)} GB',
                                      style: AppTextStyles.caption.copyWith(
                                        fontSize: 10,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              // Bar
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                height: constraints.maxHeight * heightPercent,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.accentPrimary,
                                      AppColors.accentPrimary
                                          .withValues(alpha: 0.3),
                                    ],
                                  ),
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(4),
                                  ),
                                  boxShadow: isHovered
                                      ? AppColors.glowAccent
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // X-axis labels (show only some for dense data)
          if (showAll)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Row(
                children: data
                    .map(
                      (d) => Expanded(
                        child: Text(
                          d.label,
                          style: AppTextStyles.caption.copyWith(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                    .toList(),
              ),
            )
          else
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

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPrimary.withValues(alpha: 0.15),
            AppColors.accentPrimaryDark.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.data_usage_rounded,
              size: 28, color: AppColors.accentPrimary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_totalUsage.toStringAsFixed(2)} GB',
                style: AppTextStyles.statNumber.copyWith(fontSize: 22),
              ),
              Text(
                'Total usage this ${_period.name}',
                style: AppTextStyles.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown() {
    final sorted = List.of(_currentData)
      ..sort((a, b) => b.value.compareTo(a.value));
    final top5 = sorted.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TOP USAGE', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 12),
        ...top5.map(
          (d) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _UsageRow(
              label: d.label,
              value: d.value,
              maxValue: top5.first.value,
            ),
          ),
        ),
      ],
    );
  }
}

class _UsageData {
  final String label;
  final double value;
  const _UsageData({required this.label, required this.value});
}

class _UsageRow extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;

  const _UsageRow({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final percent = maxValue > 0 ? value / maxValue : 0.0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: AppColors.surfaceCardHover,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accentPrimary),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${value.toStringAsFixed(1)} GB',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
