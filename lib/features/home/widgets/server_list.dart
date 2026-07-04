import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/state/connection_state.dart';
import '../../../core/providers/vpn_provider.dart';
import '../../../shared/widgets/vip_badge.dart';
import '../../../shared/widgets/skeleton_loader.dart';

class ServerList extends StatefulWidget {
  final List<ServerModel> servers;
  final ServerModel? selectedServer;
  final ValueChanged<ServerModel> onSelect;
  final bool isLoading;

  const ServerList({
    super.key,
    required this.servers,
    this.selectedServer,
    required this.onSelect,
    this.isLoading = false,
  });

  @override
  State<ServerList> createState() => _ServerListState();
}

class _ServerListState extends State<ServerList> {
  String _selectedFilter = 'All';
  bool _showSearch = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  final List<String> _filters = ['All', 'Free', 'VIP'];

  // کشورهای گیمینگ (کم‌پینگ) و استریمینگ (پرمیوم)
  static const _gamingCodes  = {'DE', 'NL', 'FR', 'GB', 'FI', 'TR'};    // ignore: unused_field
  static const _streamingCodes = {'US', 'JP', 'CA', 'SG'};               // ignore: unused_field

  List<ServerModel> get _filteredServers {
    var list = widget.servers;

    // فیلتر tab
    switch (_selectedFilter) {
      case 'Free':
        list = list.where((s) => !s.isPremium).toList();
        break;
      case 'VIP':
        list = list.where((s) => s.isPremium).toList();
        break;
    }

    // فیلتر search
    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      list = list
          .where((s) =>
              s.name.toLowerCase().contains(q) ||
              s.countryCode.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter + Search row
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding),
          child: Row(
            children: [
              // Filter tabs
              ..._filters.map((f) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterTab(
                      label: f,
                      isActive: _selectedFilter == f,
                      onTap: () => setState(() => _selectedFilter = f),
                    ),
                  )),
              const Spacer(),
              // Search icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _showSearch ? 160 : 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: _showSearch
                    ? Row(
                        children: [
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              autofocus: true,
                              style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textPrimary),
                              decoration: InputDecoration(
                                hintText: 'Search...',
                                hintStyle: AppTextStyles.caption,
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (v) => setState(() => _query = v),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() {
                              _showSearch = false;
                              _query = '';
                              _searchCtrl.clear();
                            }),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(Icons.close,
                                  size: 16,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      )
                    : IconButton(
                        icon: const Icon(Icons.search_rounded,
                            size: 20, color: AppColors.textSecondary),
                        onPressed: () => setState(() => _showSearch = true),
                        padding: EdgeInsets.zero,
                      ),
              ),
              const SizedBox(width: 8),
              // Filter icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: const Icon(Icons.tune_rounded,
                    size: 20, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Best Location
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding),
          child: _BestLocationRow(),
        ),
        const SizedBox(height: 16),

        // Server list
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding),
          child: widget.isLoading
              ? _buildSkeleton()
              : _buildServerRows(),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: List.generate(
        4,
        (i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: const ServerRowSkeleton(),
        ),
      ),
    );
  }

  Widget _buildServerRows() {
    final servers = _filteredServers;
    return Column(
      children: List.generate(servers.length, (i) {
        final server = servers[i];
        final isSelected = widget.selectedServer?.id == server.id;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _ServerRow(
            server: server,
            isSelected: isSelected,
            onTap: () => widget.onSelect(server),
          ),
        );
      }),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.surfaceCard : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _BestLocationRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vpn = context.read<VpnProvider>();
    return GestureDetector(
      onTap: () async {
        try {
          final best = await vpn.getBestServer();
          if (context.mounted && best != null) vpn.selectServer(best);
        } catch (_) {}
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: AppColors.accentPrimary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.rocket_launch_rounded,
                size: 20, color: AppColors.accentPrimary),
            const SizedBox(width: 12),
            Text(
              'Best Location',
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

class _ServerRow extends StatelessWidget {
  final ServerModel server;
  final bool isSelected;
  final VoidCallback onTap;

  const _ServerRow(
      {required this.server, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surfaceCardHover
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: isSelected
              ? Border.all(color: AppColors.accentPrimary, width: 2)
              : Border.all(color: Colors.transparent, width: 2),
        ),
        child: Row(
          children: [
            Text(server.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Text(
              server.name,
              style: AppTextStyles.body.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            server.isVip
                ? const VipBadge()
                : Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.bgSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.signal_cellular_alt_1_bar_rounded,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          server.pingMs != null
                              ? '${server.pingMs}ms'
                              : 'retry',
                          style:
                              AppTextStyles.caption.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
