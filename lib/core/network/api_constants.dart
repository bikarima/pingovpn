class ApiConstants {
  // مستقیم به uvicorn بدون nginx (برای رفع مشکل emulator)
  static const String baseUrl = 'http://83.228.229.103:8000';
  static const String apiPrefix = '/api/v1';

  // Endpoints
  static const String login = '$apiPrefix/auth/login';
  static const String register = '$apiPrefix/auth/register';
  static const String guest = '$apiPrefix/auth/guest';
  static const String googleAuth = '$apiPrefix/auth/google';
  static const String refreshToken = '$apiPrefix/auth/refresh';
  static const String me = '$apiPrefix/auth/me';

  static const String redeemLicense = '$apiPrefix/license/redeem';

  static const String accountMe = '$apiPrefix/account/me';
  static const String activeSubscription = '$apiPrefix/account/subscriptions/active';
  static const String allSubscriptions = '$apiPrefix/account/subscriptions';

  static const String servers = '$apiPrefix/servers';
  static const String bestServer = '$apiPrefix/servers/best';

  static const String usageReport = '$apiPrefix/usage/report';

  static const String devices = '$apiPrefix/devices';
  static const String registerDevice = '$apiPrefix/devices/register';

  static const String notifications = '$apiPrefix/notifications';
  static const String readAllNotifications = '$apiPrefix/notifications/read-all';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
