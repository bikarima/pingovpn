import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _displayNameKey = 'display_name';
  static const _isAdminKey = 'is_admin';

  static Future<void> save({
    required String accessToken,
    required String refreshToken,
    required String userId,
    String? displayName,
    bool isAdmin = false,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
      _storage.write(key: _userIdKey, value: userId),
      _storage.write(key: _displayNameKey, value: displayName ?? ''),
      _storage.write(key: _isAdminKey, value: isAdmin.toString()),
    ]);
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: _accessKey);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshKey);

  static Future<String?> getUserId() =>
      _storage.read(key: _userIdKey);

  static Future<String?> getDisplayName() =>
      _storage.read(key: _displayNameKey);

  static Future<bool> isAdmin() async {
    final val = await _storage.read(key: _isAdminKey);
    return val == 'true';
  }

  static Future<bool> hasToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clear() => _storage.deleteAll();
}
