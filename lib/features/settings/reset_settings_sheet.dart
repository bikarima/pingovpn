import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../shared/widgets/bottom_sheet_handle.dart';

class ResetSettingsSheet extends StatefulWidget {
  const ResetSettingsSheet({super.key});

  @override
  State<ResetSettingsSheet> createState() => _ResetSettingsSheetState();
}

class _ResetSettingsSheetState extends State<ResetSettingsSheet> {
  String? _selected; // 'deep' or 'safe'
  bool _splitTunnelingApps = false;
  bool _splitTunnelingHosts = false;
  bool _guardianSettings = false;

  bool get _canConfirm => _selected != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: BackdropFilter(
        filter: ColorFilter.mode(
          Colors.transparent,
          BlendMode.srcOver,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BottomSheetHandle(),
              const SizedBox(height: 20),

              // Header row
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: AppColors.accentPrimary,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCardHover,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.close,
                          size: 16, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Text(
                'Choose Your Reset Type',
                style: AppTextStyles.h3.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Deep Reset card
              _RadioCard(
                title: 'Deep Reset',
                subtitle: 'Reset All settings to default',
                isSelected: _selected == 'deep',
                onTap: () => setState(() => _selected = 'deep'),
              ),
              const SizedBox(height: 10),

              // Safe Reset card with expandable checkboxes
              _RadioCard(
                title: 'Safe Reset',
                subtitle: 'Customize what should reset',
                isSelected: _selected == 'safe',
                onTap: () => setState(() => _selected = 'safe'),
                expanded: _selected == 'safe'
                    ? _buildCheckboxes()
                    : null,
              ),
              const SizedBox(height: 24),

              // Confirm button
              GestureDetector(
                onTap: _canConfirm
                    ? () {
                        Navigator.pop(context);
                      }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _canConfirm
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'CONFIRM',
                    style: AppTextStyles.body.copyWith(
                      color: _canConfirm ? Colors.black : AppColors.textTertiary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Divider(
          height: 16,
          thickness: 1,
          color: AppColors.borderSubtle,
          ),
        Text(
          'Reset All Settings plus:',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.accentPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        _CheckboxItem(
          label: 'Split Tunneling Settings (apps)',
          value: _splitTunnelingApps,
          onChanged: (v) => setState(() => _splitTunnelingApps = v),
        ),
        _CheckboxItem(
          label: 'Split Tunneling Settings (hosts)',
          value: _splitTunnelingHosts,
          onChanged: (v) => setState(() => _splitTunnelingHosts = v),
        ),
        _CheckboxItem(
          label: 'Guardian Settings',
          value: _guardianSettings,
          onChanged: (v) => setState(() => _guardianSettings = v),
        ),
      ],
    );
  }
}

class _RadioCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? expanded;

  const _RadioCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color:
                isSelected ? AppColors.accentPrimary : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.accentPrimary
                          : AppColors.textTertiary,
                      width: 2,
                    ),
                    color: isSelected
                        ? AppColors.accentPrimary
                        : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
            if (expanded != null) ...[
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                child: expanded!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CheckboxItem extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckboxItem({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: value ? AppColors.accentPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm - 4),
                border: Border.all(
                  color: value
                      ? AppColors.accentPrimary
                      : AppColors.textTertiary,
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Text(label, style: AppTextStyles.body.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
