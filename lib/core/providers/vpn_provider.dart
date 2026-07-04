import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/api_models.dart';
import '../network/api_service.dart';

enum VpnConnectionStatus { disconnected, connecting, connected, error }

enum DnsOption { system, cloudflare, google }

extension DnsOptionLabel on DnsOption {
  String get label {
    switch (this) {
      case DnsOption.system:   return 'Default';
      case DnsOption.cloudflare: return '1.1.1.1';
      case DnsOption.google:   return '8.8.8.8';
    }
  }
}

class VpnProvider extends ChangeNotifier {
  // ── Connection state ──────────────────────────────────────
  VpnConnectionStatus _status = VpnConnectionStatus.disconnected;
  ServerModel? _selectedServer;
  Duration _connectionDuration = Duration.zero;
  Timer? _connectionTimer;
  DateTime? _sessionStartedAt;

  // ── Server list ───────────────────────────────────────────
  List<ServerModel> _servers = [];
  bool _serversLoading = false;
  String? _serversError;

  // ── Subscription ─────────────────────────────────────────
  SubscriptionModel? _subscription;
  bool _subscriptionLoading = false;

  // ── Settings ─────────────────────────────────────────────
  bool _proxyMode = false;
  bool _autoPingServers = true;
  bool _batteryOptimization = true;
  bool _adBlocker = false;
  bool _multiHop = false;
  DnsOption _dnsOption = DnsOption.system;
  int _socksPort = 10808;
  String _language = 'English';

  // ── Device tracking ───────────────────────────────────────
  String? _deviceId;
  final _uuid = const Uuid();
  final List<UsageReportItem> _pendingReports = [];
  Timer? _usageTimer;

  // ── Getters ───────────────────────────────────────────────
  VpnConnectionStatus get status => _status;
  ServerModel? get selectedServer => _selectedServer;
  Duration get connectionDuration => _connectionDuration;
  List<ServerModel> get servers => _servers;
  List<ServerModel> get recentServers => _servers.take(4).toList();
  bool get serversLoading => _serversLoading;
  String? get serversError => _serversError;
  SubscriptionModel? get subscription => _subscription;
  bool get subscriptionLoading => _subscriptionLoading;
  bool get hasActiveSubscription => _subscription?.isActive ?? false;

  bool get isConnected   => _status == VpnConnectionStatus.connected;
  bool get isConnecting  => _status == VpnConnectionStatus.connecting;
  bool get isDisconnected => _status == VpnConnectionStatus.disconnected;

  bool get proxyMode => _proxyMode;
  bool get autoPingServers => _autoPingServers;
  bool get batteryOptimization => _batteryOptimization;
  bool get adBlocker => _adBlocker;
  bool get multiHop => _multiHop;
  DnsOption get dnsOption => _dnsOption;
  int get socksPort => _socksPort;
  String get language => _language;

  String get formattedDuration {
    final h = _connectionDuration.inHours.toString().padLeft(2, '0');
    final m = (_connectionDuration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_connectionDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ── Init ──────────────────────────────────────────────────
  Future<void> init() async {
    await Future.wait([
      loadServers(),
      loadSubscription(),
    ]);
  }

  // ── Load servers from API ─────────────────────────────────
  Future<void> loadServers() async {
    _serversLoading = true;
    _serversError = null;
    notifyListeners();
    try {
      _servers = await ApiService.getServers();
      if (_servers.isNotEmpty && _selectedServer == null) {
        _selectedServer = _servers.firstWhere(
          (s) => !s.isPremium && !s.isLocked,
          orElse: () => _servers.first,
        );
      }
    } on ApiException catch (e) {
      _serversError = e.message;
      // fallback: نگه داشتن سرورهای قبلی
    } catch (_) {
      _serversError = 'Failed to load servers';
    }
    _serversLoading = false;
    notifyListeners();
  }

  // ── Load subscription ─────────────────────────────────────
  Future<void> loadSubscription() async {
    _subscriptionLoading = true;
    notifyListeners();
    try {
      _subscription = await ApiService.getActiveSubscription();
    } catch (_) {}
    _subscriptionLoading = false;
    notifyListeners();
  }

  // ── Connection ────────────────────────────────────────────
  void toggleConnection() {
    if (_status == VpnConnectionStatus.connected) {
      _disconnect();
    } else if (_status == VpnConnectionStatus.disconnected ||
        _status == VpnConnectionStatus.error) {
      _connect();
    }
  }

  Future<void> _connect() async {
    if (_selectedServer == null || _selectedServer!.isLocked) return;
    _status = VpnConnectionStatus.connecting;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));

    _status = VpnConnectionStatus.connected;
    _connectionDuration = Duration.zero;
    _sessionStartedAt = DateTime.now().toUtc();
    _startConnectionTimer();
    _startUsageTimer();
    notifyListeners();
  }

  void _disconnect() {
    _stopConnectionTimer();
    _stopUsageTimer();
    _flushUsageReports();
    _status = VpnConnectionStatus.disconnected;
    _connectionDuration = Duration.zero;
    notifyListeners();
  }

  void _startConnectionTimer() {
    _connectionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _connectionDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopConnectionTimer() {
    _connectionTimer?.cancel();
    _connectionTimer = null;
  }

  // ── Usage reporting ───────────────────────────────────────
  void _startUsageTimer() {
    // هر ۳ دقیقه usage رو گزارش می‌ده
    _usageTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      _addFakeUsageReport();
      _flushUsageReports();
    });
  }

  void _stopUsageTimer() {
    _usageTimer?.cancel();
    _usageTimer = null;
  }

  void _addFakeUsageReport() {
    // در اپ واقعی این اطلاعات از Xray core SDK میاد
    if (_selectedServer == null || _deviceId == null) return;
    _pendingReports.add(UsageReportItem(
      clientReportId: _uuid.v4(),
      serverId: _selectedServer!.id,
      deviceId: _deviceId!,
      bytesUp: 1024 * 1024 * 5,   // 5 MB (fake)
      bytesDown: 1024 * 1024 * 20, // 20 MB (fake)
      sessionStartedAt: _sessionStartedAt ?? DateTime.now().toUtc(),
    ));
  }

  Future<void> _flushUsageReports() async {
    if (_pendingReports.isEmpty) return;
    final reports = List<UsageReportItem>.from(_pendingReports);
    _pendingReports.clear();
    try {
      final result = await ApiService.reportUsage(reports);
      // اگه اشتراک تموم شد قطع می‌کنیم
      final subStatus = result['subscription_status'] as String?;
      if (subStatus == 'data_exhausted' || subStatus == 'expired') {
        _disconnect();
        await loadSubscription();
      }
    } catch (_) {
      // برگردوندن به pending در صورت خطا
      _pendingReports.insertAll(0, reports);
    }
  }

  // ── Server selection ──────────────────────────────────────
  void selectServer(ServerModel server) {
    if (server.isLocked) return; // VIP قفل
    if (_status == VpnConnectionStatus.connected) _disconnect();
    _selectedServer = server;
    notifyListeners();
  }

  void setDeviceId(String id) {
    _deviceId = id;
  }

  // ── Settings ─────────────────────────────────────────────
  void setProxyMode(bool v)    { _proxyMode = v;           notifyListeners(); }
  void setAutoPing(bool v)     { _autoPingServers = v;     notifyListeners(); }
  void setBatteryOpt(bool v)   { _batteryOptimization = v; notifyListeners(); }
  void setAdBlocker(bool v)    { _adBlocker = v;           notifyListeners(); }
  void setMultiHop(bool v)     { _multiHop = v;            notifyListeners(); }
  void setDns(DnsOption v)     { _dnsOption = v;           notifyListeners(); }
  void setSocksPort(int v)     { _socksPort = v;           notifyListeners(); }
  void setLanguage(String v)   { _language = v;            notifyListeners(); }

  void resetAll() {
    _proxyMode = false; _autoPingServers = true;
    _batteryOptimization = true; _adBlocker = false;
    _multiHop = false; _dnsOption = DnsOption.system;
    _socksPort = 10808; _language = 'English';
    notifyListeners();
  }

  @override
  void dispose() {
    _stopConnectionTimer();
    _stopUsageTimer();
    super.dispose();
  }
}
