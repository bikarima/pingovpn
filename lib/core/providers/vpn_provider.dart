import 'dart:async';
import 'package:flutter/foundation.dart';
import '../state/connection_state.dart';

class VpnProvider extends ChangeNotifier {
  VpnConnectionStatus _status = VpnConnectionStatus.disconnected;
  ServerModel? _selectedServer;
  Duration _connectionDuration = Duration.zero;
  Timer? _connectionTimer;
  String _accentColor = '#4A7DFF';

  // Settings toggles
  bool _proxyMode = false;
  bool _autoPingServers = true;
  bool _batteryOptimization = false;
  bool _adBlocker = false;
  bool _multiHop = false;

  VpnConnectionStatus get status => _status;
  ServerModel? get selectedServer => _selectedServer;
  Duration get connectionDuration => _connectionDuration;
  String get accentColor => _accentColor;
  bool get proxyMode => _proxyMode;
  bool get autoPingServers => _autoPingServers;
  bool get batteryOptimization => _batteryOptimization;
  bool get adBlocker => _adBlocker;
  bool get multiHop => _multiHop;

  bool get isConnected => _status == VpnConnectionStatus.connected;
  bool get isConnecting => _status == VpnConnectionStatus.connecting;
  bool get isDisconnected => _status == VpnConnectionStatus.disconnected;

  final List<ServerModel> _servers = [
    ServerModel(id: '1', name: 'FINLAND 2', countryCode: 'FI', flag: '🇫🇮', pingMs: 24),
    ServerModel(id: '2', name: 'GERMANY 1', countryCode: 'DE', flag: '🇩🇪', pingMs: 18),
    ServerModel(id: '3', name: 'USA EAST', countryCode: 'US', flag: '🇺🇸', isVip: true),
    ServerModel(id: '4', name: 'JAPAN 1', countryCode: 'JP', flag: '🇯🇵', isVip: true),
    ServerModel(id: '5', name: 'NETHERLANDS', countryCode: 'NL', flag: '🇳🇱', pingMs: 31),
    ServerModel(id: '6', name: 'FRANCE 1', countryCode: 'FR', flag: '🇫🇷', pingMs: 42),
    ServerModel(id: '7', name: 'UK LONDON', countryCode: 'GB', flag: '🇬🇧', pingMs: 55),
    ServerModel(id: '8', name: 'CANADA 1', countryCode: 'CA', flag: '🇨🇦', isVip: true),
  ];

  final List<ServerModel> _recentServers = [];

  List<ServerModel> get servers => _servers;
  List<ServerModel> get recentServers => _recentServers.isEmpty
      ? _servers.take(4).toList()
      : _recentServers;

  VpnProvider() {
    _selectedServer = _servers.first;
  }

  void toggleConnection() {
    if (_status == VpnConnectionStatus.connected) {
      _disconnect();
    } else if (_status == VpnConnectionStatus.disconnected ||
        _status == VpnConnectionStatus.error) {
      _connect();
    }
  }

  void _connect() async {
    _status = VpnConnectionStatus.connecting;
    notifyListeners();

    // Simulate connection delay
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
    _connectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _connectionDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  void _stopTimer() {
    _connectionTimer?.cancel();
    _connectionTimer = null;
  }

  void selectServer(ServerModel server) {
    if (_status == VpnConnectionStatus.connected) {
      _disconnect();
    }
    _selectedServer = server;
    notifyListeners();
  }

  String get formattedDuration {
    final h = _connectionDuration.inHours.toString().padLeft(2, '0');
    final m = (_connectionDuration.inMinutes % 60).toString().padLeft(2, '0');
    final s = (_connectionDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void setProxyMode(bool val) { _proxyMode = val; notifyListeners(); }
  void setAutoPing(bool val) { _autoPingServers = val; notifyListeners(); }
  void setBatteryOpt(bool val) { _batteryOptimization = val; notifyListeners(); }
  void setAdBlocker(bool val) { _adBlocker = val; notifyListeners(); }
  void setMultiHop(bool val) { _multiHop = val; notifyListeners(); }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
