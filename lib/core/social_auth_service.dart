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
      // serverClientId is the Web OAuth 2.0 Client ID from Google Cloud Console.
      // Without it, idToken will be null on Android.
      // Set via: flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<your-web-client-id>
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

    // Sign out first to avoid stale/cached accounts with missing idToken.
    await google.signOut();

    final account = await google.signIn();
    if (account == null) {
      throw Exception('Google sign-in cancelled');
    }

    final auth = await account.authentication;
    final idToken = auth.idToken;

    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Google ID token is missing.\n\n'
        'You must add a Web OAuth 2.0 Client ID as serverClientId.\n'
        '1. Go to console.cloud.google.com → APIs & Services → Credentials\n'
        '2. Create an OAuth 2.0 Client ID (type: Web application)\n'
        '3. Copy the Client ID and run:\n'
        '   flutter run --dart-define=GOOGLE_SERVER_CLIENT_ID=<your-web-client-id>\n'
        '4. Also add it to your backend .env as GOOGLE_CLIENT_ID',
      );
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
