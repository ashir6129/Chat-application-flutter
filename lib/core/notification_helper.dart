import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:zyntraplus/core/api_methods.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
  developer.log("Handling a background message: ${message.messageId} - ${message.notification?.title}");
}

class NotificationHelper {
  NotificationHelper._();

  static FirebaseMessaging? _messaging;
  static bool _isInitialized = false;
  
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      // Safely attempt initialization. If configuration is missing (e.g. google-services.json),
      // it will catch the error and run in simulated/fallback mode.
      await Firebase.initializeApp();
      _messaging = FirebaseMessaging.instance;

      // Set up background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Setup Local Notifications
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await _localNotifications.initialize(initializationSettings);

      // Create Android Notification Channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      _isInitialized = true;
      developer.log("Firebase initialized successfully for notifications.");

      await _requestPermissions();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        developer.log("Foreground notification message: ${message.notification?.title}");
        
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _localNotifications.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                icon: '@mipmap/ic_launcher',
              ),
            ),
            payload: message.data.toString(),
          );
        }
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
      
      // Request permission for local notifications on Android 13+
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
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
