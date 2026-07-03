enum VpnConnectionStatus {
  disconnected,
  connecting,
  connected,
  error,
}

class ServerModel {
  final String id;
  final String name;
  final String countryCode;
  final String flag;
  final bool isVip;
  final int? pingMs;
  final bool isSelected;

  const ServerModel({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.flag,
    this.isVip = false,
    this.pingMs,
    this.isSelected = false,
  });

  ServerModel copyWith({
    String? id,
    String? name,
    String? countryCode,
    String? flag,
    bool? isVip,
    int? pingMs,
    bool? isSelected,
  }) {
    return ServerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      countryCode: countryCode ?? this.countryCode,
      flag: flag ?? this.flag,
      isVip: isVip ?? this.isVip,
      pingMs: pingMs ?? this.pingMs,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
