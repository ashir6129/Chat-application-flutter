import '../core/api_exception.dart';
import '../core/api_methods.dart';

class NotificationService {
  NotificationService._();

  static Future<Map<String, dynamic>> getNotifications({int page = 1, int limit = 20}) async {
    final response = await ApiMethods.authorizedGet('notifications?page=$page&limit=$limit');
    return {
      'notifications': List<Map<String, dynamic>>.from(response['notifications'] ?? []),
      'unread_count': response['unread_count'] ?? 0,
    };
  }

  static Future<void> markAllRead() async {
    await ApiMethods.authorizedPut('notifications/read-all', {});
  }

  static Future<void> markRead(String notificationId) async {
    await ApiMethods.authorizedPut('notifications/$notificationId/read', {});
  }

  static Future<void> deleteNotification(String notificationId) async {
    await ApiMethods.authorizedDelete('notifications/$notificationId');
  }

  static String errorMessage(Object error) {
    if (error is ApiException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
