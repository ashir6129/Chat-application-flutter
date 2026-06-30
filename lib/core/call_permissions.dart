import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'call_service.dart';

/// Thrown when mic/camera permission is denied for a call.
class CallPermissionException implements Exception {
  final String message;
  const CallPermissionException(this.message);

  @override
  String toString() => message;
}

abstract final class CallPermissions {
  static bool _hasRequestedPermissions = false;

  /// Request microphone and camera permissions upfront before a call attempt
  static Future<void> ensureForCall(CallType callType) async {
    // Request all relevant permissions on first call attempt
    if (!_hasRequestedPermissions) {
      await _requestAllPermissions();
      _hasRequestedPermissions = true;
    }

    // Check specific permissions for this call type
    final micStatus = await Permission.microphone.status;
    if (!micStatus.isGranted) {
      if (micStatus.isPermanentlyDenied) {
        throw CallPermissionException(
          'Microphone permission is permanently denied. Please enable it in device settings to make calls.',
        );
      } else {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          throw CallPermissionException(
            'Microphone permission is required to make calls. Please enable it in device settings.',
          );
        }
      }
    }

    if (callType == CallType.video) {
      final cameraStatus = await Permission.camera.status;
      if (!cameraStatus.isGranted) {
        if (cameraStatus.isPermanentlyDenied) {
          throw CallPermissionException(
            'Camera permission is permanently denied. Please enable it in device settings to make video calls.',
          );
        } else {
          final result = await Permission.camera.request();
          if (!result.isGranted) {
            throw CallPermissionException(
              'Camera permission is required for video calls. Please enable it in device settings.',
            );
          }
        }
      }
    }
  }

  /// Request all call-related permissions upfront
  static Future<void> _requestAllPermissions() async {
    final permissions = [
      Permission.microphone,
      Permission.camera,
      Permission.notification,
    ];

    final statuses = await permissions.request();
    
    // Check if any are permanently denied
    for (final permission in permissions) {
      final status = statuses[permission];
      if (status?.isPermanentlyDenied == true) {
        debugPrint('CallPermissions: ${permission.toString()} is permanently denied');
      }
    }
  }

  /// Check if notification permissions are granted for incoming call alerts
  static Future<bool> hasNotificationPermission() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  /// Request notification permissions
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Open device settings for the app
  static void openAppSettings() {
    AppSettings.openAppSettings();
  }

  /// Show a dialog directing user to settings when permission is permanently denied
  static void showPermissionDeniedDialog(BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: Text(
          '$permissionType permission is required for this feature. '
          'Please enable it in device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
