import 'dart:async';
import 'package:flutter/foundation.dart';
import '../state/connection_state.dart';

enum DnsOption { system, cloudflare, google, custom }

extension DnsOptionLabel on DnsOption {
  String get label {
    switch (this) {
      case DnsOption.system:
        return 'Default';
      case DnsOption.cloudflare:
        return '1.1.1.1';
      case DnsOption.google:
        return '8.8.8.8';
      case DnsOption.custom:
        return 'Custom';
    }
  }
}

class VpnProvider extends ChangeNotifier {
  VpnConnectionStatus _status = VpnConnectionStatus.disconnected;
  ServerModel? _selectedServer;
  Duration _connectionDuration = Duration.zero;
  Timer? _connectionTimer;

  // ── Settings ──────────────────────────────────────────────────
  bool _proxyMode = false;
  bool _autoPingServers = true;
  bool _batteryOptimization = true;
  bool _adBlocker = false;
  bool _multiHop = false;

  DnsOption _dnsOption = DnsOption.system;
  int _socksPort = 10808;
  String _language = 'English';

  // ── Getters ───────────────────────────────────────────────────
  VpnConnectionStatus get status => _status;
  ServerModel? get selectedServer => _selectedServer;
  Duration get connectionDuration => _connectionDuration;

  bool get proxyMode => _proxyMode;
  bool get autoPingServers => _autoPingServers;
  bool get batteryOptimization => _batteryOptimization;
  bool get adBlocker => _adBlocker;
  bool get multiHop => _multiHop;
  DnsOption get dnsOption => _dnsOption;
  int get socksPort => _socksPort;
  String get language => _language;

  bool get isConnected => _status == VpnConnectionStatus.connected;
  bool get isConnecting => _status == VpnConnectionStatus.connecting;
  bool get isDisconnected => _status == VpnConnectionStatus.disconnected;

  // ── Servers ───────────────────────────────────────────────────
  final List<ServerModel> _servers = [
    ServerModel(id: '1', name: 'FINLAND 2',   countryCode: 'FI', flag: '🇫🇮', pingMs: 24),
    ServerModel(id: '2', name: 'GERMANY 1',   countryCode: 'DE', flag: '🇩🇪', pingMs: 18),
    ServerModel(id: '3', name: 'USA EAST',    countryCode: 'US', flag: '🇺🇸', isVip: true),
    ServerModel(id: '4', name: 'JAPAN 1',     countryCode: 'JP', flag: '🇯🇵', isVip: true),
    ServerModel(id: '5', name: 'NETHERLANDS', countryCode: 'NL', flag: '🇳🇱', pingMs: 31),
    ServerModel(id: '6', name: 'FRANCE 1',    countryCode: 'FR', flag: '🇫🇷', pingMs: 42),
    ServerModel(id: '7', name: 'UK LONDON',   countryCode: 'GB', flag: '🇬🇧', pingMs: 55),
    ServerModel(id: '8', name: 'CANADA 1',    countryCode: 'CA', flag: '🇨🇦', isVip: true),
  ];

  List<ServerModel> get servers => _servers;
  List<ServerModel> get recentServers => _servers.take(4).toList();

  VpnProvider() {
    _selectedServer = _servers.first;
  }

  // ── Connection ────────────────────────────────────────────────
  void toggleConnection() {
    if (_status == VpnConnectionStatus.connected) {
      _disconnect();
    } else if (_status == VpnConnectionStatus.disconnected ||
        _status == VpnConnectionStatus.error) {
      _connect();
    }
  }

  Future<void> _connect() async {
    _status = VpnConnectionStatus.connecting;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _status = VpnConnectionStatus.connected;
    _connectionDuration = Duration.zero;
    _startTimer();
    notifyListeners();
  }

  void _disconnect() {
    _stopTimer();
    _status = VpnConnectionStatus.disconnected;
    _connectionDuration = Duration.zero;
    notifyListeners();
  }

  void _startTimer() {
    _connectionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _connectionDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopTimer() {
    _connectionTimer?.cancel();
    _connectionTimer = null;
  }

  void selectServer(ServerModel server) {
    if (_status == VpnConnectionStatus.connected) _disconnect();
    _selectedServer = server;
    notifyListeners();
  }

  String get formattedDuration {
    final h = _connectionDuration.inHours.toString().padLeft(2, '0');
    final m = (_connectionDuration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_connectionDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  // ── Settings setters ──────────────────────────────────────────
  void setProxyMode(bool val)       { _proxyMode = val;           notifyListeners(); }
  void setAutoPing(bool val)        { _autoPingServers = val;     notifyListeners(); }
  void setBatteryOpt(bool val)      { _batteryOptimization = val; notifyListeners(); }
  void setAdBlocker(bool val)       { _adBlocker = val;           notifyListeners(); }
  void setMultiHop(bool val)        { _multiHop = val;            notifyListeners(); }
  void setDns(DnsOption val)        { _dnsOption = val;           notifyListeners(); }
  void setSocksPort(int val)        { _socksPort = val;           notifyListeners(); }
  void setLanguage(String val)      { _language = val;            notifyListeners(); }

  void resetAll() {
    _proxyMode = false;
    _autoPingServers = true;
    _batteryOptimization = true;
    _adBlocker = false;
    _multiHop = false;
    _dnsOption = DnsOption.system;
    _socksPort = 10808;
    _language = 'English';
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
