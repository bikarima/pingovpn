import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'api_constants.dart';
import 'token_storage.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Auth interceptor — اضافه کردن Bearer token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // 401 → refresh token
          if (error.response?.statusCode == 401) {
            final refreshed = await _tryRefresh();
            if (refreshed) {
              // retry اصلی request
              final token = await TokenStorage.getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final retryResp = await _dio.fetch(error.requestOptions);
              return handler.resolve(retryResp);
            }
            // refresh هم fail شد → logout
            await TokenStorage.clear();
          }
          handler.next(error);
        },
      ),
    );

    // Logger فقط در debug
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: true,
        responseBody: true,
        error: true,
        compact: true,
      ),
    );
  }

  static ApiClient get instance {
    _instance ??= ApiClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  Future<bool> _tryRefresh() async {
    try {
      final refresh = await TokenStorage.getRefreshToken();
      if (refresh == null) return false;

      final resp = await Dio().post(
        '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
        data: {'refresh_token': refresh},
      );
      if (resp.statusCode == 200) {
        await TokenStorage.save(
          accessToken: resp.data['access_token'],
          refreshToken: resp.data['refresh_token'],
          userId: resp.data['user_id'],
          displayName: resp.data['display_name'],
        );
        return true;
      }
    } catch (_) {}
    return false;
  }
}
