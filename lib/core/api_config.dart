import 'package:flutter/foundation.dart';

/// API base URL for ZyntraPlus backend.
///
/// Production (Railway): https://zyntraplus-1-production.up.railway.app/api/v1
///
/// Local backend override:
///   flutter run --dart-define=API_BASE_URL=http://localhost:4000/api/v1
/// Android emulator + local backend:
///   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000/api/v1
class ApiConfig {
  ApiConfig._();

  static const String productionBaseUrl =
      'https://profound-friend-implosive.ngrok-free.dev/api/v1';

  static const String localBaseUrl = 'http://localhost:4000/api/v1';

  /// Phone/emulator debug: Railway when true. Chrome/web debug always uses [localBaseUrl]
  /// (browser CORS blocks localhost → Railway unless CORS_ORIGIN=* on Railway).
  static const bool debugUseProductionApi = true;

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: kReleaseMode
        ? productionBaseUrl
        : kIsWeb
            ? localBaseUrl
            : (debugUseProductionApi ? productionBaseUrl : localBaseUrl),
  );

  /// Web OAuth client ID (same as backend GOOGLE_CLIENT_ID) for ID tokens on Android.
  static const String googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '',
  );

  static String get socketOrigin {
    final uri = Uri.parse(baseUrl);
    return '${uri.scheme}://${uri.host}${uri.hasPort ? ':${uri.port}' : ''}';
  }

  static const String socketPath = '/socket.io';
}
