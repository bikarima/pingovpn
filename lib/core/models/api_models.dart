// ─── Auth ─────────────────────────────────────────────────────
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String? displayName;
  final bool isAdmin;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    this.displayName,
    this.isAdmin = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> j) => AuthResponse(
        accessToken: j['access_token'] as String,
        refreshToken: j['refresh_token'] as String,
        userId: j['user_id'] as String,
        displayName: j['display_name'] as String?,
        isAdmin: j['is_admin'] as bool? ?? false,
      );
}

// ─── Server ───────────────────────────────────────────────────
class ServerModel {
  final String id;
  final String name;
  final String countryCode;
  final String protocol;
  final String rawLink;
  final bool isPremium;
  final int? pingMs;
  final int sortOrder;

  const ServerModel({
    required this.id,
    required this.name,
    required this.countryCode,
    required this.protocol,
    required this.rawLink,
    required this.isPremium,
    this.pingMs,
    this.sortOrder = 0,
  });

  bool get isLocked => isPremium && rawLink.isEmpty;

  // compat helpers — flag emoji از country code
  bool get isVip => isPremium;

  String get flag {
    if (countryCode.length != 2) return '🌐';
    final base = 0x1F1E6 - 0x41;
    return String.fromCharCodes(
        countryCode.toUpperCase().codeUnits.map((c) => base + c));
  }

  factory ServerModel.fromJson(Map<String, dynamic> j) => ServerModel(
        id: j['id'] as String,
        name: j['name'] as String,
        countryCode: j['country_code'] as String,
        protocol: j['protocol'] as String,
        rawLink: j['raw_link'] as String? ?? '',
        isPremium: j['is_premium'] as bool? ?? false,
        pingMs: j['ping_ms'] as int?,
        sortOrder: j['sort_order'] as int? ?? 0,
      );
}

// ─── Subscription ─────────────────────────────────────────────
class SubscriptionModel {
  final String id;
  final String planName;
  final String source;
  final double dataLimitGb;
  final double dataUsedGb;
  final double dataUsagePercent;
  final int maxDevices;
  final String status;
  final DateTime startsAt;
  final DateTime expiresAt;
  final int daysRemaining;
  final String validityLabel;
  final String dataLabel;

  const SubscriptionModel({
    required this.id,
    required this.planName,
    required this.source,
    required this.dataLimitGb,
    required this.dataUsedGb,
    required this.dataUsagePercent,
    required this.maxDevices,
    required this.status,
    required this.startsAt,
    required this.expiresAt,
    required this.daysRemaining,
    required this.validityLabel,
    required this.dataLabel,
  });

  bool get isActive => status == 'active';

  factory SubscriptionModel.fromJson(Map<String, dynamic> j) => SubscriptionModel(
        id: j['id'] as String,
        planName: j['plan_name'] as String,
        source: j['source'] as String,
        dataLimitGb: (j['data_limit_gb'] as num).toDouble(),
        dataUsedGb: (j['data_used_gb'] as num).toDouble(),
        dataUsagePercent: (j['data_usage_percent'] as num).toDouble(),
        maxDevices: j['max_devices'] as int,
        status: j['status'] as String,
        startsAt: DateTime.parse(j['starts_at'] as String),
        expiresAt: DateTime.parse(j['expires_at'] as String),
        daysRemaining: j['days_remaining'] as int,
        validityLabel: j['validity_label'] as String,
        dataLabel: j['data_label'] as String,
      );
}

// ─── Notification ─────────────────────────────────────────────
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) => NotificationModel(
        id: j['id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        type: j['type'] as String,
        isRead: j['is_read'] as bool,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}

// ─── Usage report ─────────────────────────────────────────────
class UsageReportItem {
  final String clientReportId;
  final String serverId;
  final String deviceId;
  final int bytesUp;
  final int bytesDown;
  final DateTime sessionStartedAt;

  UsageReportItem({
    required this.clientReportId,
    required this.serverId,
    required this.deviceId,
    required this.bytesUp,
    required this.bytesDown,
    required this.sessionStartedAt,
  });

  Map<String, dynamic> toJson() => {
        'client_report_id': clientReportId,
        'server_id': serverId,
        'device_id': deviceId,
        'bytes_up': bytesUp,
        'bytes_down': bytesDown,
        'session_started_at': sessionStartedAt.toUtc().toIso8601String(),
      };
}

// ─── API error ────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
