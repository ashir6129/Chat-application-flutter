import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:zyntraplus/core/api_methods.dart';

class NotificationHelper {
  NotificationHelper._();

  static FirebaseMessaging? _messaging;
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      // Safely attempt initialization. If configuration is missing (e.g. google-services.json),
      // it will catch the error and run in simulated/fallback mode.
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;
      _isInitialized = true;
      developer.log("Firebase initialized successfully for notifications.");

      await _requestPermissions();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log("Foreground notification message: ${message.notification?.title}");
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        developer.log("Notification opened app: ${message.data}");
      });
    } catch (e) {
      developer.log("Firebase initialization bypassed/failed (standard without JSON config): $e");
    }
  }

  static Future<void> _requestPermissions() async {
    if (_messaging == null) return;
    try {
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
      developer.log('User granted notification permissions: ${settings.authorizationStatus}');
    } catch (e) {
      developer.log('Failed to request notification permissions: $e');
    }
  }

  static Future<String?> getFcmToken() async {
    if (!_isInitialized || _messaging == null) {
      return 'fcm_mock_token_for_device';
    }
    try {
      return await _messaging!.getToken();
    } catch (e) {
      developer.log('Error getting FCM token: $e');
      return 'fcm_mock_token_fallback';
    }
  }

  static Future<void> registerFcmToken() async {
    try {
      final token = await getFcmToken();
      if (token == null || token.isEmpty) return;

      developer.log('Uploading FCM Token to API: $token');
      await ApiMethods.authorizedPut('users/me/fcm-token', {
        'fcm_token': token,
      });
    } catch (e) {
      developer.log('Failed to register FCM token with API: $e');
    }
  }
}
