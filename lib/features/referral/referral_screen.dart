import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/app_icon_button.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  static const _referralCode = 'PINGO-X7K2M';
  bool _copied = false;

  static const List<_ReferralHistory> _history = [
    _ReferralHistory(
        name: 'Ali M.', date: 'Jun 28', status: 'Active', earnedGb: 1),
    _ReferralHistory(
        name: 'Sara K.', date: 'Jun 15', status: 'Active', earnedGb: 1),
    _ReferralHistory(
        name: 'Reza N.', date: 'May 30', status: 'Pending', earnedGb: 0),
  ];

  // 7-day streak: true = used, false = not
  static const List<bool> _streak = [
    true, true, true, false, true, false, false
  ];
  static const List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  void _copy() {
    Clipboard.setData(const ClipboardData(text: _referralCode));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

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
                    _buildReferralCard(),
                    const SizedBox(height: 20),
                    _buildStreakCard(),
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    const SizedBox(height: 20),
                    _buildHistorySection(),
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
              'REFERRAL',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildReferralCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E2D6E), Color(0xFF0A0A0F)],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.accentPrimary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.card_giftcard_rounded,
            size: 40,
            color: AppColors.accentPrimary,
          ),
          const SizedBox(height: 12),
          Text(
            'Invite Friends, Earn Data',
            style: AppTextStyles.h3.copyWith(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Get 1 GB for every friend who joins.',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Code display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _referralCode,
                  style: AppTextStyles.monoLarge.copyWith(
                    fontSize: 22,
                    letterSpacing: 3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _copy,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 48,
                    decoration: BoxDecoration(
                      color: _copied
                          ? AppColors.statusConnected
                          : AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _copied
                              ? Icons.check_rounded
                              : Icons.copy_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _copied ? 'Copied!' : 'Copy Code',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientUpgrade,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.share_rounded,
                            size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Share',
                          style: AppTextStyles.body.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard() {
    final streakCount = _streak.where((s) => s).length;
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
              const Text('🔥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                '$streakCount Day Streak',
                style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                'Keep it up!',
                style: AppTextStyles.caption.copyWith(
                    color: AppColors.statusConnecting),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(7, (i) {
              final isActive = _streak[i];
              return Expanded(
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? const Color(0xFFF59E0B).withValues(alpha: 0.15)
                            : AppColors.bgSecondary,
                        border: isActive
                            ? Border.all(
                                color: const Color(0xFFF59E0B),
                                width: 1.5,
                              )
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: isActive
                          ? const Text('🔥', style: TextStyle(fontSize: 16))
                          : Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.textTertiary.withValues(
                                    alpha: 0.4),
                              ),
                            ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _days[i],
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 11,
                        color: isActive
                            ? AppColors.textPrimary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatBox(
          icon: Icons.people_rounded,
          value: '${_history.where((h) => h.status == "Active").length}',
          label: 'Friends Invited',
          color: AppColors.accentPrimary,
        ),
        const SizedBox(width: 12),
        _buildStatBox(
          icon: Icons.storage_rounded,
          value:
              '${_history.fold(0, (sum, h) => sum + h.earnedGb)} GB',
          label: 'Data Earned',
          color: AppColors.statusConnected,
        ),
      ],
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.statNumber.copyWith(fontSize: 20),
                ),
                Text(label, style: AppTextStyles.caption.copyWith(fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('INVITATION HISTORY', style: AppTextStyles.sectionLabel),
        const SizedBox(height: 12),
        ..._history.map(
          (h) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _HistoryRow(history: h),
          ),
        ),
      ],
    );
  }
}

class _ReferralHistory {
  final String name;
  final String date;
  final String status;
  final int earnedGb;

  const _ReferralHistory({
    required this.name,
    required this.date,
    required this.status,
    required this.earnedGb,
  });
}

class _HistoryRow extends StatelessWidget {
  final _ReferralHistory history;
  const _HistoryRow({required this.history});

  @override
  Widget build(BuildContext context) {
    final isActive = history.status == 'Active';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              history.name[0],
              style: AppTextStyles.body.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.accentPrimary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.name,
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  history.date,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.statusConnected.withValues(alpha: 0.15)
                      : AppColors.surfaceCardHover,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  history.status,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: isActive
                        ? AppColors.statusConnected
                        : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (history.earnedGb > 0) ...[
                const SizedBox(height: 3),
                Text(
                  '+${history.earnedGb} GB',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.statusConnected,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
