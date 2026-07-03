import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class PortDialog extends StatefulWidget {
  final int currentPort;
  final ValueChanged<int> onConfirm;

  const PortDialog(
      {super.key, required this.currentPort, required this.onConfirm});

  @override
  State<PortDialog> createState() => _PortDialogState();
}

class _PortDialogState extends State<PortDialog> {
  late TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentPort.toString());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final val = int.tryParse(_ctrl.text.trim());
    if (val == null || val < 1024 || val > 65535) {
      setState(() => _error = 'Enter a valid port (1024–65535)');
      return;
    }
    widget.onConfirm(val);
    Navigator.pop(context);
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
                const Icon(Icons.settings_ethernet_rounded,
                    size: 20, color: AppColors.accentPrimary),
                const SizedBox(width: 10),
                Text('SOCKS5 & HTTP Port',
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700, fontSize: 15)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: _error != null
                      ? AppColors.statusError
                      : AppColors.borderSubtle,
                ),
              ),
              child: TextField(
                controller: _ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: AppTextStyles.monoLarge.copyWith(fontSize: 18),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '10808',
                  hintStyle: AppTextStyles.body
                      .copyWith(color: AppColors.textTertiary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                ),
                onChanged: (_) => setState(() => _error = null),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 6),
              Text(_error!,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.statusError)),
            ],
            const SizedBox(height: 6),
            Text(
              'Default: 10808  •  Range: 1024–65535',
              style:
                  AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
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
                    onPressed: _confirm,
                    child: Text('Save',
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
