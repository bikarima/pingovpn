import 'package:flutter/foundation.dart';
import '../models/api_models.dart';
import '../network/api_service.dart';
import '../network/token_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.unknown;
  String? _userId;
  String? _displayName;
  bool _isAdmin = false;
  String? _error;

  AuthStatus get status => _status;
  String? get userId => _userId;
  String? get displayName => _displayName;
  bool get isAdmin => _isAdmin;
  String? get error => _error;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  // ── Boot: check stored token ──────────────────────────────
  Future<void> init() async {
    final hasToken = await TokenStorage.hasToken();
    if (hasToken) {
      _userId = await TokenStorage.getUserId();
      _displayName = await TokenStorage.getDisplayName();
      _isAdmin = await TokenStorage.isAdmin();
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Login ─────────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _error = null;
    try {
      final resp = await ApiService.login(email, password);
      await _saveAndUpdate(resp);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Register ──────────────────────────────────────────────
  Future<bool> register(String email, String password, String name) async {
    _error = null;
    try {
      final resp = await ApiService.register(email, password, name);
      await _saveAndUpdate(resp);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Guest login ───────────────────────────────────────────
  Future<bool> loginAsGuest() async {
    _error = null;
    try {
      final data = await ApiService.guestLogin();
      await TokenStorage.save(
        accessToken: data['access_token'] as String,
        refreshToken: '',
        userId: data['user_id'] as String,
        displayName: 'Guest',
      );
      _userId = data['user_id'] as String;
      _displayName = 'Guest';
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  // ── Redeem license ────────────────────────────────────────
  Future<Map<String, dynamic>?> redeemLicense(String code) async {
    _error = null;
    try {
      return await ApiService.redeemLicense(code);
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return null;
    }
  }

  // ── Logout ────────────────────────────────────────────────
  Future<void> logout() async {
    await TokenStorage.clear();
    _userId = null;
    _displayName = null;
    _isAdmin = false;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _saveAndUpdate(AuthResponse resp) async {
    await TokenStorage.save(
      accessToken: resp.accessToken,
      refreshToken: resp.refreshToken,
      userId: resp.userId,
      displayName: resp.displayName,
      isAdmin: resp.isAdmin,
    );
    _userId = resp.userId;
    _displayName = resp.displayName;
    _isAdmin = resp.isAdmin;
    _status = AuthStatus.authenticated;
    notifyListeners();
  }
}
