import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions(
      dbName: 'zyntraplus_secure',
      publicKey: 'zyntraplus_auth',
    ),
  );

  static Future<void> saveLoginData({
    required String accessToken,
    required String refreshToken,
    required String accessTokenExpiryDateTime,
    required String refreshTokenExpiryDateTime,
    required String userUid,
  }) async {

    await _storage.write(key: "access_token", value: accessToken);
    await _storage.write(key: "refresh_token", value: refreshToken);

    /// NEW
    await _storage.write(key: "access_token_expiry_datetime", value: accessTokenExpiryDateTime);
    await _storage.write(key: "refresh_token_expiry_datetime", value: refreshTokenExpiryDateTime);

    await _storage.write(key: "user_uid", value: userUid);

    await _storage.write(key: "is_logged_in", value: "true");
  }

  /// Check login status
  static Future<bool> isLoggedIn() async {

    String? value = await _storage.read(key: "is_logged_in");

    return value == "true";
  }

  /// Get token
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: "access_token");
  }

  /// Get user UID
  static Future<String?> getUserUid() async {
    return await _storage.read(key: "user_uid");
  }

  /// Logout
  static Future<void> logout() async {
    await _storage.deleteAll();
  }
}