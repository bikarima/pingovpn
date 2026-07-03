import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/providers/vpn_provider.dart';
import '../../shared/widgets/app_icon_button.dart';
import '../../shared/widgets/settings_row.dart';
import '../services/services_screen.dart';
import '../referral/referral_screen.dart';
import 'reset_settings_sheet.dart';

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
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontalPadding,
                        vertical: AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group 1: Network
                        _buildGroupLabel('Network'),
                        _buildGroup([
                          SettingsRow(
                            icon: Icons.alt_route_rounded,
                            title: 'Split Tunneling',
                            type: SettingsRowType.navigation,
                            onTap: () {},
                          ),
                          SettingsRow(
                            icon: Icons.security_rounded,
                            title: 'Guardian',
                            type: SettingsRowType.navigation,
                            onTap: () {},
                          ),
                        ]),
                        const SizedBox(height: 20),

                        // Group 2: Connection
                        _buildGroupLabel('Connection'),
                        _buildGroup([
                          SettingsRow(
                            icon: Icons.swap_horiz_rounded,
                            title: 'Proxy Mode',
                            type: SettingsRowType.toggle,
                            toggleValue: vpn.proxyMode,
                            onToggle: vpn.setProxyMode,
                          ),
                          SettingsRow(
                            icon: Icons.wifi_tethering_rounded,
                            title: 'Share via HotSpot',
                            type: SettingsRowType.navigation,
                            onTap: () {},
                          ),
                          SettingsRow(
                            icon: Icons.settings_ethernet_rounded,
                            title: 'SOCKS5 & HTTP Port',
                            type: SettingsRowType.valueDisplay,
                            displayValue: '1080',
                            onTap: () {},
                          ),
                          SettingsRow(
                            icon: Icons.dns_rounded,
                            title: 'DNS',
                            type: SettingsRowType.valueDisplay,
                            displayValue: '1.1.1.1',
                            onTap: () {},
                          ),
                          SettingsRow(
                            icon: Icons.network_ping_rounded,
                            title: 'Auto Ping Servers',
                            type: SettingsRowType.toggle,
                            toggleValue: vpn.autoPingServers,
                            onToggle: vpn.setAutoPing,
                          ),
                        ]),
                        const SizedBox(height: 20),

                        // Group 3: Security
                        _buildGroupLabel('Security'),
                        _buildGroup([
                          SettingsRow(
                            icon: Icons.block_rounded,
                            title: 'Ad & Malware Blocker',
                            type: SettingsRowType.toggle,
                            toggleValue: vpn.adBlocker,
                            onToggle: vpn.setAdBlocker,
                            subtitle: vpn.adBlocker
                                ? '1,204 threats blocked this month'
                                : null,
                          ),
                          SettingsRow(
                            icon: Icons.route_rounded,
                            title: 'Multi-hop Connection',
                            type: SettingsRowType.toggle,
                            toggleValue: vpn.multiHop,
                            onToggle: vpn.setMultiHop,
                          ),
                        ]),
                        const SizedBox(height: 20),

                        // Group 4: App
                        _buildGroupLabel('App'),
                        _buildGroup([
                          SettingsRow(
                            icon: Icons.battery_saver_rounded,
                            title: 'Battery Optimization',
                            type: SettingsRowType.toggle,
                            toggleValue: vpn.batteryOptimization,
                            onToggle: vpn.setBatteryOpt,
                          ),
                          _ThemeColorRow(),
                          SettingsRow(
                            icon: Icons.apps_rounded,
                            title: 'App Icon',
                            type: SettingsRowType.navigation,
                            onTap: () {},
                          ),
                        ]),
                        const SizedBox(height: 20),

                        // Group 5: General
                        _buildGroupLabel('General'),
                        _buildGroup([
                          SettingsRow(
                            icon: Icons.language_rounded,
                            title: 'Language',
                            type: SettingsRowType.navigation,
                            onTap: () {},
                          ),
                          SettingsRow(
                            icon: Icons.card_giftcard_rounded,
                            title: 'Referral & Rewards',
                            type: SettingsRowType.navigation,
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ReferralScreen())),
                          ),
                          SettingsRow(
                            icon: Icons.storage_rounded,
                            title: 'My Services',
                            type: SettingsRowType.navigation,
                            onTap: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const ServicesScreen())),
                          ),
                          SettingsRow(
                            icon: Icons.info_outline_rounded,
                            title: 'Version',
                            type: SettingsRowType.valueDisplay,
                            displayValue: '2.4.15',
                            onTap: () {},
                          ),
                        ]),
                        const SizedBox(height: 20),

                        // Reset button
                        _buildResetButton(context),
                        const SizedBox(height: 40),
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
            child: Text(
              'SETTINGS',
              style: AppTextStyles.h2,
              textAlign: TextAlign.center,
            ),
          ),
          AppIconButton(
            icon: const Icon(Icons.headset_mic_rounded,
                size: 20, color: AppColors.textSecondary),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildGroupLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.sectionLabel.copyWith(fontSize: 11),
      ),
    );
  }

  Widget _buildGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: _buildWithDividers(children),
      ),
    );
  }

  List<Widget> _buildWithDividers(List<Widget> items) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(Divider(
          height: 1,
          thickness: 1,
          color: AppColors.borderSubtle,
          indent: 16,
          endIndent: 16,
        ));
      }
    }
    return result;
  }

  Widget _buildResetButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showResetSheet(context),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: AppColors.statusError.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
              color: AppColors.statusError.withOpacity(0.3)),
        ),
        alignment: Alignment.center,
        child: Text(
          'Reset Settings',
          style: AppTextStyles.body.copyWith(
            color: AppColors.statusError,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showResetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ResetSettingsSheet(),
    );
  }
}

class _ThemeColorRow extends StatefulWidget {
  @override
  State<_ThemeColorRow> createState() => _ThemeColorRowState();
}

class _ThemeColorRowState extends State<_ThemeColorRow> {
  int _selected = 0;

  final List<Color> _colors = [
    const Color(0xFF4A7DFF),
    const Color(0xFFA855F7),
    const Color(0xFF22C55E),
    const Color(0xFFFF8A4C),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: const Icon(Icons.palette_rounded,
                size: 22, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Theme Color',
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Row(
            children: List.generate(_colors.length, (i) {
              return GestureDetector(
                onTap: () => setState(() => _selected = i),
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _colors[i],
                    shape: BoxShape.circle,
                    border: _selected == i
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
