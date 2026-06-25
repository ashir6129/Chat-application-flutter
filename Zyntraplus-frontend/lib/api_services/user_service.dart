import '../core/api_exception.dart';
import '../core/api_methods.dart';
import '../models/feed_post.dart';
import '../models/follow_user.dart';
import '../models/user_profile.dart';

class UserService {
  UserService._();

  static Future<UserProfile> getMe() async {
    final data = await ApiMethods.authorizedGet('users/me');
    final profile = data['data']?['profile'] as Map<String, dynamic>?;
    if (profile == null) throw ApiException('Profile not found');
    return UserProfile.fromApi(profile);
  }

  static Future<UserProfile> getByUsername(String username) async {
    final data = await ApiMethods.authorizedGet('users/$username');
    final profile = data['data']?['profile'] as Map<String, dynamic>?;
    if (profile == null) throw ApiException('Profile not found');
    return UserProfile.fromApi(profile);
  }

  static Future<UserProfile> getById(String userId) async {
    final data = await ApiMethods.authorizedGet('users/id/$userId');
    final profile = data['data']?['profile'] as Map<String, dynamic>?;
    if (profile == null) throw ApiException('Profile not found');
    return UserProfile.fromApi(profile);
  }

  static Future<List<FollowUser>> getFollowers(String userId, {int page = 1}) async {
    final data = await ApiMethods.authorizedGet(
      'users/$userId/followers?page=$page&limit=50',
    );
    final users = data['data']?['users'] as List<dynamic>? ?? [];
    return users
        .map((u) => FollowUser.fromApi(Map<String, dynamic>.from(u as Map)))
        .toList();
  }

  static Future<List<FollowUser>> getFollowing(String userId, {int page = 1}) async {
    final data = await ApiMethods.authorizedGet(
      'users/$userId/following?page=$page&limit=50',
    );
    final users = data['data']?['users'] as List<dynamic>? ?? [];
    return users
        .map((u) => FollowUser.fromApi(Map<String, dynamic>.from(u as Map)))
        .toList();
  }

  static Future<List<PostModel>> getUserPosts(
    String username, {
    int page = 1,
    int limit = 20,
    String type = 'all',
  }) async {
    final data = await ApiMethods.authorizedGet(
      'users/$username/posts?page=$page&limit=$limit&type=$type',
    );
    final posts = data['data']?['posts'] as List<dynamic>? ?? [];
    return posts
        .map((p) => PostModel.fromApi(Map<String, dynamic>.from(p as Map)))
        .toList();
  }

  static Future<UserProfile> updateMe({
    String? bio,
    String? location,
    String? website,
    String? username,
  }) async {
    final data = await ApiMethods.authorizedPut('users/me', {
      if (bio != null) 'bio': bio,
      if (location != null) 'location': location,
      if (website != null) 'website': website,
      if (username != null) 'username': username.trim().toLowerCase(),
    });
    final profile = data['data']?['profile'] as Map<String, dynamic>?;
    if (profile == null) throw ApiException('Profile update failed');
    return UserProfile.fromApi(profile);
  }

  static Future<UserProfile> updateAvatar(String? avatarUrl) async {
    final data = await ApiMethods.authorizedPatch('users/me/avatar', {
      'avatar_url': avatarUrl,
    });
    final profile = data['data']?['profile'] as Map<String, dynamic>?;
    if (profile == null) throw ApiException('Avatar update failed');
    return UserProfile.fromApi(profile);
  }

  static Future<void> deleteMe() async {
    await ApiMethods.authorizedDelete('users/me');
  }

  static Future<List<FollowUser>> getSuggestions({int page = 1, int limit = 20}) async {
    final data = await ApiMethods.authorizedGet(
      'users/suggestions?page=$page&limit=$limit',
    );
    final users = data['data']?['users'] as List<dynamic>? ?? [];
    return users
        .map((u) => FollowUser.fromApi(Map<String, dynamic>.from(u as Map)))
        .toList();
  }

  static Future<List<FollowUser>> browseUsers({int page = 1, int limit = 30}) async {
    final data = await ApiMethods.authorizedGet('users?page=$page&limit=$limit');
    final users = data['data']?['users'] as List<dynamic>? ?? [];
    return users
        .map((u) => FollowUser.fromApi(Map<String, dynamic>.from(u as Map)))
        .toList();
  }

  static Future<List<FollowUser>> searchUsers(String query, {int page = 1}) async {
    final data = await ApiMethods.authorizedGet(
      'users/search?q=${Uri.encodeComponent(query)}&page=$page&limit=30',
    );
    final users = data['data']?['users'] as List<dynamic>? ?? [];
    return users
        .map((u) => FollowUser.fromApi(Map<String, dynamic>.from(u as Map)))
        .toList();
  }

  static Future<List<PostModel>> getMyPosts({
    int page = 1,
    int limit = 20,
    String type = 'all',
  }) async {
    final data = await ApiMethods.authorizedGet(
      'users/me/posts?page=$page&limit=$limit&type=$type',
    );
    final posts = data['data']?['posts'] as List<dynamic>? ?? [];
    return posts
        .map((p) => PostModel.fromApi(Map<String, dynamic>.from(p as Map)))
        .toList();
  }

  static String errorMessage(Object error) {
    if (error is ApiException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
