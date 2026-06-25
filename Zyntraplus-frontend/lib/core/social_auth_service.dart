import 'dart:io';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../api_services/auth_service.dart';
import 'api_config.dart';

class SocialAuthService {
  SocialAuthService._();

  static GoogleSignIn _googleSignIn() {
    return GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: ApiConfig.googleServerClientId.isEmpty
          ? null
          : ApiConfig.googleServerClientId,
    );
  }

  static Future<void> _persistLoginFlag() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
  }

  static Future<void> signInWithGoogle() async {
    final google = _googleSignIn();
    final account = await google.signIn();
    if (account == null) {
      throw Exception('Google sign-in cancelled');
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google ID token missing. Set GOOGLE_SERVER_CLIENT_ID.');
    }

    await AuthService.loginWithGoogle(idToken: idToken);
    await _persistLoginFlag();
  }

  static Future<void> signInWithApple() async {
    if (!Platform.isIOS && !Platform.isMacOS) {
      throw Exception('Apple Sign-In is available on iOS/macOS only');
    }

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final idToken = credential.identityToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Apple identity token missing');
    }

    final fullName = [
      credential.givenName,
      credential.familyName,
    ].where((part) => part != null && part.isNotEmpty).join(' ');

    await AuthService.loginWithApple(
      idToken: idToken,
      name: fullName.isEmpty ? null : fullName,
    );
    await _persistLoginFlag();
  }

  static String errorMessage(Object error) {
    if (error is Exception) return error.toString().replaceFirst('Exception: ', '');
    return AuthService.errorMessage(error);
  }
}
