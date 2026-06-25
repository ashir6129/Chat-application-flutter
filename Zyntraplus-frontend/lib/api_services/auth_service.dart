import 'package:shared_preferences/shared_preferences.dart';

import '../core/api_exception.dart';
import '../core/api_methods.dart';
import '../core/secure_storage_service.dart';

class AuthService {
  AuthService._();

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    return ApiMethods.unauthorizedPost('auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiMethods.unauthorizedPost('auth/login', {
      'email': email,
      'password': password,
    });

    await _persistSession(data);
    return data;
  }

  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    return ApiMethods.unauthorizedPost('auth/forgot-password', {
      'email': email,
    });
  }

  static Future<Map<String, dynamic>> verifyRegistration({
    required String email,
    required String otp,
    required String resetToken,
  }) async {
    final data = await ApiMethods.unauthorizedPost('auth/verify-registration', {
      'email': email,
      'otp': otp,
      'reset_token': resetToken,
    });
    await _persistSession(data);
    return data;
  }

  static Future<Map<String, dynamic>> resendOtp({
    required String email,
    required String resetToken,
  }) async {
    return ApiMethods.unauthorizedPost('auth/resend-otp', {
      'email': email,
      'reset_token': resetToken,
    });
  }

  static Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
    required String resetToken,
  }) async {
    return ApiMethods.unauthorizedPost('auth/verify-otp', {
      'email': email,
      'otp': otp,
      'reset_token': resetToken,
    });
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    return ApiMethods.unauthorizedPost('auth/reset-password', {
      'email': email,
      'otp': otp,
      'reset_token': resetToken,
      'new_password': newPassword,
      'confirm_password': confirmPassword,
    });
  }

  static Future<void> _persistSession(Map<String, dynamic> data) async {
    final accessToken = data['access_token']?.toString();
    final refreshToken = data['refresh_token']?.toString();
    final accessExpiry = data['access_token_expiry_datetime']?.toString();
    final refreshExpiry = data['refresh_token_expiry_datetime']?.toString();
    final userUid = data['user_uid']?.toString();

    if (accessToken == null ||
        refreshToken == null ||
        accessExpiry == null ||
        refreshExpiry == null ||
        userUid == null) {
      throw ApiException('Invalid login response from server');
    }

    try {
      await SecureStorageService.saveLoginData(
        accessToken: accessToken,
        refreshToken: refreshToken,
        accessTokenExpiryDateTime: accessExpiry,
        refreshTokenExpiryDateTime: refreshExpiry,
        userUid: userUid,
      );
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', accessToken);
      await prefs.setString('refresh_token', refreshToken);
      await prefs.setString('access_token_expiry_datetime', accessExpiry);
      await prefs.setString('refresh_token_expiry_datetime', refreshExpiry);
      await prefs.setString('user_uid', userUid);
      await prefs.setBool('isLoggedIn', true);
    }
  }

  static Future<Map<String, dynamic>> loginWithGoogle({required String idToken}) async {
    final data = await ApiMethods.unauthorizedPost('auth/google', {'id_token': idToken});
    await _persistSession(data);
    return data;
  }

  static Future<Map<String, dynamic>> loginWithApple({
    required String idToken,
    String? name,
  }) async {
    final data = await ApiMethods.unauthorizedPost('auth/apple', {
      'id_token': idToken,
      if (name != null) 'name': name,
    });
    await _persistSession(data);
    return data;
  }

  static String? readMockOtp(Map<String, dynamic> data) {
    return data['mock_otp']?.toString();
  }

  static int readResendSeconds(Map<String, dynamic> data) {
    final value = data['resend_after_seconds'];
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 60;
  }

  static String? readResetToken(Map<String, dynamic> data) {
    final token = data['reset_token'];
    if (token == null || token.toString().isEmpty) return null;
    return token.toString();
  }

  static String errorMessage(Object error) {
    if (error is ApiException) return error.message;

    final text = error.toString().toLowerCase();
    if (text.contains('clientexception') ||
        text.contains('failed to fetch') ||
        text.contains('connection refused') ||
        text.contains('network')) {
      return 'Cannot connect to API. Start backend: cd backend && npm run dev';
    }

    return 'Something went wrong. Please try again.';
  }
}
