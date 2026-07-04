import 'package:dio/dio.dart';
import '../models/api_models.dart';
import 'api_client.dart';
import 'api_constants.dart';

class ApiService {
  static final Dio _dio = ApiClient.instance.dio;

  // ─── Helper ───────────────────────────────────────────────
  static ApiException _handle(DioException e) {
    final msg = e.response?.data?['detail']?.toString() ??
        e.message ??
        'Network error';
    return ApiException(msg, statusCode: e.response?.statusCode);
  }

  // ─── Auth ─────────────────────────────────────────────────
  static Future<AuthResponse> login(String email, String password) async {
    try {
      final r = await _dio.post(ApiConstants.login,
          data: {'email': email, 'password': password});
      return AuthResponse.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  static Future<AuthResponse> register(
      String email, String password, String displayName) async {
    try {
      final r = await _dio.post(ApiConstants.register, data: {
        'email': email,
        'password': password,
        'display_name': displayName,
      });
      return AuthResponse.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  static Future<Map<String, dynamic>> guestLogin() async {
    try {
      final r = await _dio.post(ApiConstants.guest);
      return r.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  // ─── License ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> redeemLicense(String code) async {
    try {
      final r = await _dio.post(ApiConstants.redeemLicense,
          data: {'code': code.trim().toUpperCase()});
      return r.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  // ─── Account ──────────────────────────────────────────────
  static Future<SubscriptionModel?> getActiveSubscription() async {
    try {
      final r = await _dio.get(ApiConstants.activeSubscription);
      final data = r.data as Map<String, dynamic>;
      if (data['status'] == 'none') return null;
      return SubscriptionModel.fromJson(data);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  static Future<List<Map<String, dynamic>>> getAllSubscriptions() async {
    try {
      final r = await _dio.get(ApiConstants.allSubscriptions);
      return (r.data as List).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  // ─── Servers ──────────────────────────────────────────────
  static Future<List<ServerModel>> getServers() async {
    try {
      final r = await _dio.get(ApiConstants.servers);
      return (r.data as List)
          .map((e) => ServerModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  static Future<ServerModel> getBestServer() async {
    try {
      final r = await _dio.get(ApiConstants.bestServer);
      return ServerModel.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  // ─── Usage ────────────────────────────────────────────────
  static Future<Map<String, dynamic>> reportUsage(
      List<UsageReportItem> reports) async {
    try {
      final r = await _dio.post(ApiConstants.usageReport,
          data: {'reports': reports.map((e) => e.toJson()).toList()});
      return r.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  // ─── Device ───────────────────────────────────────────────
  static Future<String> registerDevice({
    required String fingerprint,
    required String platform,
    String? deviceName,
  }) async {
    try {
      final r = await _dio.post(ApiConstants.registerDevice, data: {
        'device_fingerprint': fingerprint,
        'platform': platform,
        'device_name': deviceName,
      });
      return (r.data as Map<String, dynamic>)['id'] as String;
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  // ─── Notifications ────────────────────────────────────────
  static Future<List<NotificationModel>> getNotifications() async {
    try {
      final r = await _dio.get(ApiConstants.notifications);
      return (r.data as List)
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  static Future<void> markNotificationRead(String id) async {
    try {
      await _dio.post('${ApiConstants.notifications}/$id/read');
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  static Future<void> markAllRead() async {
    try {
      await _dio.post(ApiConstants.readAllNotifications);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }

  static Future<void> clearNotifications() async {
    try {
      await _dio.delete(ApiConstants.notifications);
    } on DioException catch (e) {
      throw _handle(e);
    }
  }
}
