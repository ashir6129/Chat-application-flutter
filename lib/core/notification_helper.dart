import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zyntraplus/core/api_methods.dart';

import 'package:zyntraplus/core/in_app_notification.dart';
import 'package:zyntraplus/core/notification_router.dart';

void _log(String message) {
  developer.log(message);
  print("[NotificationHelper] $message");
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCM3hf3qjj_BYvLnvhMPbz57EZ_fLLTyAE',
        appId: '1:550799770194:android:d9dd30dbcd7f578f2f958b',
        messagingSenderId: '550799770194',
        projectId: 'zyntraplus-3b9df',
        storageBucket: 'zyntraplus-3b9df.firebasestorage.app',
      ),
    );
  } catch (_) {}
  _log("Handling a background message: ${message.messageId} - ${message.notification?.title}");
}

class NotificationHelper {
  NotificationHelper._();

  static FirebaseMessaging? _messaging;
  static bool _isInitialized = false;
  
  /// Global state to suppress notifications for the currently active chat
  static String? activeConversationId;

  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static Future<void> init() async {
    if (_isInitialized) return;

    // 1. Initialize local notifications and request permissions immediately on startup
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
      );
      await _localNotifications.initialize(settings: initializationSettings);

      // Create Android Notification Channel
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(_channel);

      // Prompt for notifications permission on Android 13+
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      _log("Local notifications initialized and permission requested.");
    } catch (e) {
      _log("Failed to request local notifications permission: $e");
    }

    // 2. Initialize Firebase Core + Messaging
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCM3hf3qjj_BYvLnvhMPbz57EZ_fLLTyAE',
          appId: '1:550799770194:android:d9dd30dbcd7f578f2f958b',
          messagingSenderId: '550799770194',
          projectId: 'zyntraplus-3b9df',
          storageBucket: 'zyntraplus-3b9df.firebasestorage.app',
        ),
      );
      _messaging = FirebaseMessaging.instance;

      // Set up background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      _isInitialized = true;
      _log("Firebase initialized successfully for notifications.");

      // Prompt for FCM permissions
      if (_messaging != null) {
        NotificationSettings settings = await _messaging!.requestPermission(
          alert: true,
          badge: true,
          provisional: false,
          sound: true,
        );
        _log('User granted FCM permissions: ${settings.authorizationStatus}');
      }

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _log("Foreground notification message: ${message.notification?.title}");
        
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null) {
          final type = message.data['type'] as String?;
          
          // Only suppress chat/message notifications when the conversation is active
          if (type == 'message' || type == 'chat_message') {
            final targetId = message.data['conversation_id']?.toString() ?? message.data['chat_id']?.toString();
            if (activeConversationId != null && targetId == activeConversationId) {
               _log("Suppressing notification because chat is active");
               return;
            }
          }
          
          try {
            InAppNotification.show(
              title: notification.title ?? 'Notification',
              body: notification.body ?? '',
              onTap: () {
                if (type != null) {
                  handleNotificationRouting(type: type, data: message.data);
                }
              },
            );
          } catch (e) {
            _log("Failed to show in-app banner: $e");
          }
        }

        if (notification != null && android != null) {
          _localNotifications.show(
            id: notification.hashCode,
            title: notification.title,
            body: notification.body,
            notificationDetails: NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                icon: '@mipmap/ic_launcher',
                importance: Importance.max,
                priority: Priority.high,
                playSound: true,
                enableVibration: true,
                fullScreenIntent: true,
                color: const Color(0xFF7C3AED),
                styleInformation: BigTextStyleInformation(
                  notification.body ?? '',
                  contentTitle: notification.title,
                ),
                ledColor: const Color(0xFF7C3AED),
                ledOnMs: 1000,
                ledOffMs: 1000,
              ),
            ),
            payload: message.data.toString(),
          );
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _log("Notification opened app: ${message.data}");
        final type = message.data['type'] as String?;
        if (type != null) {
          handleNotificationRouting(type: type, data: message.data);
        }
      });

      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
        if (message != null) {
          _log("Initial message opened app: ${message.data}");
          Future.delayed(const Duration(milliseconds: 1500), () {
            final type = message.data['type'] as String?;
            if (type != null) {
              handleNotificationRouting(type: type, data: message.data);
            }
          });
        }
      });
    } catch (e) {
      _log("Firebase initialization bypassed/failed (standard without JSON config): $e");
    }
  }

  static Future<void> checkAndPromptPermission(BuildContext context) async {
    try {
      final status = await Permission.notification.status;
      _log("Checking notification permission status: $status");
      if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
        if (!context.mounted) return;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('Enable Notifications'),
            content: const Text(
              'To receive real-time notifications for messages, likes, follows, and comments, please enable notifications in app settings.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogCtx);
                  await openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      _log("Error checking/prompting notification permission: $e");
    }
  }

  static Future<String?> getFcmToken() async {
    if (!_isInitialized || _messaging == null) {
      return 'fcm_mock_token_for_device';
    }
    try {
      return await _messaging!.getToken();
    } catch (e) {
      _log('Error getting FCM token: $e');
      return 'fcm_mock_token_fallback';
    }
  }

  static Future<void> registerFcmToken() async {
    try {
      final token = await getFcmToken();
      if (token == null || token.isEmpty) return;

      _log('Uploading FCM Token to API: $token');
      await ApiMethods.authorizedPut('users/me/fcm-token', {
        'fcm_token': token,
      });
    } catch (e) {
      _log('Failed to register FCM token with API: $e');
    }
  }
}
