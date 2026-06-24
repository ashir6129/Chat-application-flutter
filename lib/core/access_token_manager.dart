import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_methods.dart';

class AccessTokenManager {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'zyntraplus_secure',
      publicKey: 'zyntraplus_auth',
    ),
  );

  static const _accessToken = 'access_token';
  static const _refreshToken = 'refresh_token';
  static const _accessExpiry = 'access_token_expiry_datetime';
  static const _refreshExpiry = 'refresh_token_expiry_datetime';

  static bool _isRefreshing = false;
  static final List<Function(String?)> _queue = [];

  static Future<String?> getValidToken() async {
    final token = await _readToken(_accessToken);
    final expiryStr = await _readToken(_accessExpiry);

    if (token == null || expiryStr == null) return null;

    final expiry = DateTime.tryParse(expiryStr);
    if (expiry == null) return null;

    if (DateTime.now().isAfter(expiry.subtract(const Duration(minutes: 2)))) {
      return _handleRefreshQueue();
    }

    return token;
  }

  static Future<String?> _readToken(String key) async {
    final secure = await _storage.read(key: key);
    if (secure != null) return secure;

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> _writeToken(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    }
  }

  static Future<String?> _handleRefreshQueue() async {
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _queue.add((token) => completer.complete(token));
      return completer.future;
    }

    _isRefreshing = true;
    final newToken = await _refreshTokenApi();
    _isRefreshing = false;

    for (final cb in _queue) {
      cb(newToken);
    }
    _queue.clear();

    return newToken;
  }

  static Future<String?> _refreshTokenApi() async {
    final refreshToken = await _readToken(_refreshToken);
    final refreshExpiryStr = await _readToken(_refreshExpiry);

    if (refreshToken == null || refreshExpiryStr == null) {
      await clear();
      return null;
    }

    final refreshExpiry = DateTime.tryParse(refreshExpiryStr);
    if (refreshExpiry == null || DateTime.now().isAfter(refreshExpiry)) {
      await clear();
      return null;
    }

    try {
      final data = await ApiMethods.unauthorizedPost('auth/refresh', {
        'refresh_token': refreshToken,
      });

      if (data['status'] == 'success') {
        await _writeToken(_accessToken, data['access_token'] as String);
        await _writeToken(
          _accessExpiry,
          data['access_token_expiry_datetime'] as String,
        );

        if (data['refresh_token_expiry_datetime'] != null) {
          await _writeToken(
            _refreshExpiry,
            data['refresh_token_expiry_datetime'] as String,
          );
        }

        return data['access_token'] as String;
      }
    } catch (_) {
      await clear();
    }

    return null;
  }

  static Future<void> clear() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessToken);
    await prefs.remove(_refreshToken);
    await prefs.remove(_accessExpiry);
    await prefs.remove(_refreshExpiry);
    await prefs.setBool('isLoggedIn', false);
  }
}
