import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'toggle_switch.dart';

enum SettingsRowType { navigation, toggle, valueDisplay }

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final SettingsRowType type;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final String? displayValue;
  final VoidCallback? onTap;
  final String? subtitle;

  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    required this.type,
    this.toggleValue,
    this.onToggle,
    this.displayValue,
    this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: subtitle != null ? null : 56,
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: subtitle != null ? 12 : 0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  child: Icon(icon, size: 22, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildTrailing(),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 44),
                child: Text(
                  subtitle!,
                  style: AppTextStyles.caption.copyWith(fontSize: 11),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTrailing() {
    switch (type) {
      case SettingsRowType.navigation:
        return Icon(
          Icons.chevron_right,
          size: 20,
          color: AppColors.textTertiary,
        );
      case SettingsRowType.toggle:
        return AppToggleSwitch(
          value: toggleValue ?? false,
          onChanged: onToggle ?? (_) {},
        );
      case SettingsRowType.valueDisplay:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (displayValue != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.bgSecondary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  displayValue!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: AppColors.textTertiary,
            ),
          ],
        );
    }
  }
}
