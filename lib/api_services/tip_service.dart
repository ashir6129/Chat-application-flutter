import '../core/api_exception.dart';
import '../core/api_methods.dart';

class TipService {
  TipService._();

  static Future<int> getBalance() async {
    final data = await ApiMethods.authorizedGet('tips/wallet');
    return data['data']?['wallet']?['balance_credits'] as int? ?? 0;
  }

  static Future<Map<String, dynamic>> sendTip({
    required String recipientId,
    String? postId,
    required String tipType,
    required int amount,
  }) async {
    return ApiMethods.authorizedPost('tips/send', {
      'recipient_id': recipientId,
      'tip_type': tipType,
      'amount': amount,
      if (postId != null && postId.isNotEmpty) 'post_id': postId,
    });
  }

  static String errorMessage(Object error) {
    if (error is ApiException) return error.message;
    return 'Could not send tip. Please try again.';
  }
}
