import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class LanguageDialog extends StatefulWidget {
  final String current;
  final ValueChanged<String> onSelect;

  const LanguageDialog(
      {super.key, required this.current, required this.onSelect});

  @override
  State<LanguageDialog> createState() => _LanguageDialogState();
}

class _LanguageDialogState extends State<LanguageDialog> {
  late String _selected;

  static const List<Map<String, String>> _languages = [
    {'name': 'English',    'flag': '🇺🇸'},
    {'name': 'فارسی',      'flag': '🇮🇷'},
    {'name': 'العربية',    'flag': '🇸🇦'},
    {'name': 'Русский',    'flag': '🇷🇺'},
    {'name': 'Türkçe',     'flag': '🇹🇷'},
    {'name': '中文',        'flag': '🇨🇳'},
    {'name': 'Deutsch',    'flag': '🇩🇪'},
    {'name': 'Français',   'flag': '🇫🇷'},
  ];

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
                const Icon(Icons.language_rounded,
                    size: 20, color: AppColors.accentPrimary),
                const SizedBox(width: 10),
                Text('Language',
                    style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: SingleChildScrollView(
                child: Column(
                  children: _languages.map((lang) {
                    final isSelected = _selected == lang['name'];
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selected = lang['name']!);
                        widget.onSelect(lang['name']!);
                        Navigator.pop(context);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 11),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accentPrimary.withValues(alpha: 0.1)
                              : AppColors.bgSecondary,
                          borderRadius:
                              BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accentPrimary
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(lang['flag']!,
                                style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                lang['name']!,
                                style: AppTextStyles.body.copyWith(
                                  fontSize: 15,
                                  color: isSelected
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(Icons.check_rounded,
                                  size: 18,
                                  color: AppColors.accentPrimary),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel',
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
