import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/state/connection_state.dart';
import 'power_button.dart';

class ServerCard extends StatelessWidget {
  final ServerModel server;
  final VpnConnectionStatus status;
  final String timer;
  final VoidCallback onPowerTap;

  const ServerCard({
    super.key,
    required this.server,
    required this.status,
    required this.timer,
    required this.onPowerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppColors.shadowCard,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: _buildServerInfo()),
          PowerButton(status: status, onTap: onPowerTap),
        ],
      ),
    );
  }

  Widget _buildServerInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Flag + ping row
        Row(
          children: [
            _buildFlag(),
            const SizedBox(width: 8),
            _buildPingBadge(),
          ],
        ),
        const SizedBox(height: 8),
        Text(server.name, style: AppTextStyles.serverName),
        const SizedBox(height: 2),
        _buildStatusText(),
      ],
    );
  }

  Widget _buildFlag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(server.flag, style: const TextStyle(fontSize: 20)),
    );
  }

  Widget _buildPingBadge() {
    final pingText = server.pingMs != null ? '${server.pingMs}ms' : 'retry';
    final isGood = server.pingMs != null && server.pingMs! < 100;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.signal_cellular_alt_rounded,
            size: 12,
            color: isGood ? AppColors.statusConnected : AppColors.textTertiary,
          ),
          const SizedBox(width: 4),
          Text(
            pingText,
            style: AppTextStyles.caption.copyWith(
              color: isGood ? AppColors.statusConnected : AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusText() {
    switch (status) {
      case VpnConnectionStatus.connected:
        return Text(
          'V2Ray • $timer',
          style: AppTextStyles.timerText,
        );
      case VpnConnectionStatus.connecting:
        return Text(
          'Connecting...',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.statusConnecting,
          ),
        );
      case VpnConnectionStatus.error:
        return Text(
          'Vulnerable network',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.statusError,
          ),
        );
      default:
        return Text(
          'Tap to connect',
          style: AppTextStyles.caption,
        );
    }
  }
}
