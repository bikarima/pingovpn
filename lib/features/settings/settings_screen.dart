import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/vpn_provider.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/toggle_switch.dart';
import '../services/services_screen.dart';
import '../referral/referral_screen.dart';
import 'reset_settings_sheet.dart';
import 'dialogs/dns_dialog.dart';
import 'dialogs/port_dialog.dart';
import 'dialogs/language_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Consumer<VpnProvider>(
          builder: (context, vpn, _) {
            return Column(
              children: [
                _SettingsHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPadding,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Group 1 ───────────────────────────
                        _GroupCard(items: [
                          _NavItem(
                            icon: Icons.call_split_rounded,
                            title: 'Split Tunneling',
                            onTap: () {},
                          ),
                          _NavItem(
                            icon: Icons.shield_outlined,
                            title: 'Guardian',
                            onTap: () {},
                          ),
                        ]),

                        const SizedBox(height: 16),

                        // ── Group 2 ───────────────────────────
                        _GroupCard(items: [
                          _ToggleItem(
                            icon: Icons.swap_horiz_rounded,
                            title: 'Proxy Mode',
                            value: vpn.proxyMode,
                            onChanged: vpn.setProxyMode,
                          ),
                          _NavItem(
                            icon: Icons.wifi_tethering_rounded,
                            title: 'Share via HotSpot',
                            onTap: () {},
                          ),
                          _ValueItem(
                            icon: Icons.settings_ethernet_rounded,
                            title: 'SOCKS5 & HTTP Port',
                            value: vpn.socksPort.toString(),
                            onTap: () => _showPortDialog(context, vpn),
                          ),
                          _DnsItem(vpn: vpn),
                          _ToggleItem(
                            icon: Icons.network_ping_rounded,
                            title: 'Auto Ping Servers',
                            value: vpn.autoPingServers,
                            onChanged: vpn.setAutoPing,
                          ),
                        ]),

                        const SizedBox(height: 16),

                        // ── Group 3 ───────────────────────────
                        _GroupCard(items: [
                          _ToggleItem(
                            icon: Icons.battery_saver_rounded,
                            title: 'Battery Optimization',
                            value: vpn.batteryOptimization,
                            onChanged: vpn.setBatteryOpt,
                          ),
                          _ValueItem(
                            icon: Icons.language_rounded,
                            title: 'Language',
                            value: vpn.language,
                            onTap: () => _showLanguageDialog(context, vpn),
                          ),
                          _NavItem(
                            icon: Icons.info_outline_rounded,
                            title: 'Version',
                            trailing: Text(
                              '2.4.15',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            onTap: () {},
                          ),
                        ]),

                        const SizedBox(height: 16),

                        // ── Group 4 ───────────────────────────
                        _GroupCard(items: [
                          _AdBlockerItem(vpn: vpn),
                          _ToggleItem(
                            icon: Icons.route_rounded,
                            title: 'Multi-hop Connection',
                            value: vpn.multiHop,
                            onChanged: vpn.setMultiHop,
                          ),
                          _NavItem(
                            icon: Icons.card_giftcard_rounded,
                            title: 'Referral & Rewards',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ReferralScreen()),
                            ),
                          ),
                          _NavItem(
                            icon: Icons.confirmation_number_outlined,
                            title: 'My Services',
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const ServicesScreen()),
                            ),
                          ),
                        ]),

                        const SizedBox(height: 24),

                        // ── Reset ─────────────────────────────
                        _ResetButton(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (_) => const ResetSettingsSheet(),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showPortDialog(BuildContext context, VpnProvider vpn) {
    showDialog(
      context: context,
      builder: (_) => PortDialog(
        currentPort: vpn.socksPort,
        onConfirm: vpn.setSocksPort,
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, VpnProvider vpn) {
    showDialog(
      context: context,
      builder: (_) => LanguageDialog(
        current: vpn.language,
        onSelect: vpn.setLanguage,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────
class _SettingsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.horizontalPadding, 12, AppSpacing.horizontalPadding, 4),
      child: Row(
        children: [
          AppIconButton(
            icon: const Icon(Icons.arrow_back_rounded,
                size: 22, color: AppColors.textPrimary),
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Text('SETTINGS', style: AppTextStyles.h2,
                textAlign: TextAlign.center),
          ),
          AppIconButton(
            icon: const Icon(Icons.headset_mic_outlined,
                size: 22, color: AppColors.textSecondary),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Group Card — مثل اسکرین: هر گروه یه container با divider داخلی
// ─────────────────────────────────────────────────────────────────
class _GroupCard extends StatelessWidget {
  final List<Widget> items;
  const _GroupCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: () {
          final result = <Widget>[];
          for (var i = 0; i < items.length; i++) {
            result.add(items[i]);
            if (i < items.length - 1) {
              result.add(const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderSubtle,
                indent: 52,
                endIndent: 0,
              ));
            }
          }
          return result;
        }(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Base row — ارتفاع ثابت 58px مثل اسکرین
// ─────────────────────────────────────────────────────────────────
class _BaseRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;

  const _BaseRow({
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 58,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // آیکون با رنگ یکنواخت مثل اسکرین
              SizedBox(
                width: 28,
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
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Nav item — شورون راست
// ─────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseRow(
      icon: icon,
      title: title,
      onTap: onTap,
      trailing: trailing ??
          const Icon(Icons.chevron_right,
              size: 22, color: AppColors.textTertiary),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Toggle item
// ─────────────────────────────────────────────────────────────────
class _ToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseRow(
      icon: icon,
      title: title,
      onTap: () => onChanged(!value),
      trailing: AppToggleSwitch(value: value, onChanged: onChanged),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Value item — مقدار + شورون
// ─────────────────────────────────────────────────────────────────
class _ValueItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _ValueItem({
    required this.icon,
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _BaseRow(
      icon: icon,
      title: title,
      onTap: onTap,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppTextStyles.body.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right,
              size: 20, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DNS item — dropdown مثل اسکرین
// ─────────────────────────────────────────────────────────────────
class _DnsItem extends StatelessWidget {
  final VpnProvider vpn;
  const _DnsItem({required this.vpn});

  @override
  Widget build(BuildContext context) {
    return _BaseRow(
      icon: Icons.dns_outlined,
      title: 'DNS',
      trailing: GestureDetector(
        onTap: () => _showDnsPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.bgSecondary,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                vpn.dnsOption.label,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded,
                  size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  void _showDnsPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => DnsDialog(
        current: vpn.dnsOption,
        onSelect: vpn.setDns,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Ad Blocker — toggle + subtitle وقتی فعاله
// ─────────────────────────────────────────────────────────────────
class _AdBlockerItem extends StatelessWidget {
  final VpnProvider vpn;
  const _AdBlockerItem({required this.vpn});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => vpn.setAdBlocker(!vpn.adBlocker),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 28,
                  child: Icon(Icons.block_rounded,
                      size: 22, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Ad & Malware Blocker',
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                AppToggleSwitch(
                  value: vpn.adBlocker,
                  onChanged: vpn.setAdBlocker,
                ),
              ],
            ),
            if (vpn.adBlocker) ...[
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Text(
                  '1,204 threats blocked this month',
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 11,
                    color: AppColors.statusConnected,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Reset Button
// ─────────────────────────────────────────────────────────────────
class _ResetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ResetButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: AppColors.statusError.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
              color: AppColors.statusError.withValues(alpha: 0.25)),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.refresh_rounded,
                size: 18, color: AppColors.statusError),
            const SizedBox(width: 8),
            Text(
              'Reset Settings',
              style: AppTextStyles.body.copyWith(
                color: AppColors.statusError,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
