import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/providers/vpn_provider.dart';

class DnsDialog extends StatefulWidget {
  final DnsOption current;
  final ValueChanged<DnsOption> onSelect;

  const DnsDialog({super.key, required this.current, required this.onSelect});

  @override
  State<DnsDialog> createState() => _DnsDialogState();
}

class _DnsDialogState extends State<DnsDialog> {
  late DnsOption _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.current;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.dns_outlined,
                    size: 20, color: AppColors.accentPrimary),
                const SizedBox(width: 10),
                Text('Select DNS',
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 16),
            ...DnsOption.values.map((opt) => _DnsOption(
                  option: opt,
                  isSelected: _selected == opt,
                  onTap: () => setState(() => _selected = opt),
                )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.full)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      widget.onSelect(_selected);
                      Navigator.pop(context);
                    },
                    child: Text('Apply',
                        style: AppTextStyles.body.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DnsOption extends StatelessWidget {
  final DnsOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _DnsOption(
      {required this.option,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentPrimary.withValues(alpha: 0.1)
              : AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.accentPrimary
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 18,
              height: 18,
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
                  ? const Icon(Icons.check, size: 11,
                      color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option.label,
                  style: AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                if (option != DnsOption.system &&
                    option != DnsOption.custom)
                  Text(
                    option == DnsOption.cloudflare
                        ? 'Cloudflare · Fast & Private'
                        : 'Google · Reliable',
                    style: AppTextStyles.caption
                        .copyWith(fontSize: 11),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
