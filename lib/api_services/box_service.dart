import '../core/api_methods.dart';

class BoxService {
  BoxService._();

  static Future<Map<String, dynamic>> sendBoxRequest({
    required String receiverId,
    required int coins,
    String? note,
  }) async {
    final response = await ApiMethods.authorizedPost('boxes', {
      'receiver_id': receiverId,
      'coins': coins,
      'note': note ?? '',
    });
    return response;
  }

  static Future<List<Map<String, dynamic>>> getReceivedBoxRequests() async {
    final response = await ApiMethods.authorizedGet('boxes/received');
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  static Future<List<Map<String, dynamic>>> getSentBoxRequests() async {
    final response = await ApiMethods.authorizedGet('boxes/sent');
    final list = response['data'] as List<dynamic>? ?? [];
    return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  static Future<Map<String, dynamic>> updateBoxRequestStatus(
    String requestId,
    String status,
  ) async {
    final response = await ApiMethods.authorizedPut('boxes/$requestId/status', {
      'status': status,
    });
    return response;
  }

  static Future<Map<String, dynamic>> getWalletBalance() async {
    final response = await ApiMethods.authorizedGet('boxes/wallet');
    return Map<String, dynamic>.from(response['data'] as Map? ?? {});
  }
}
