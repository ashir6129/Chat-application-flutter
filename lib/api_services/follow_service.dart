import '../core/api_exception.dart';
import '../core/api_methods.dart';

class FollowService {
  FollowService._();

  static Future<bool> follow(String userId) async {
    final data = await ApiMethods.authorizedPost('users/$userId/follow', {});
    return data['data']?['following'] == true;
  }

  static Future<bool> unfollow(String userId) async {
    final data = await ApiMethods.authorizedDelete('users/$userId/follow');
    return data['data']?['following'] != true;
  }

  static String errorMessage(Object error) {
    if (error is ApiException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
