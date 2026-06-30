import '../core/api_exception.dart';
import '../core/api_methods.dart';
import '../core/offline_cache_service.dart';
import '../models/feed_post.dart';
import '../models/poll_data.dart';

class PostsService {
  PostsService._();

  static String _feedCacheKey(int page, int limit) => 'feed_p${page}_l$limit';
  static String _reelsCacheKey(int page, int limit) => 'reels_p${page}_l$limit';

  static List<PostModel>? readFeedCache({int page = 1, int limit = 20}) {
    final cached = OfflineCacheService.getJsonList(_feedCacheKey(page, limit));
    if (cached == null || cached.isEmpty) return null;
    return cached.map((p) => PostModel.fromApi(p)).toList();
  }

  static Future<List<PostModel>> getFeed({int page = 1, int limit = 20}) async {
    final cacheKey = _feedCacheKey(page, limit);
    try {
      final data = await ApiMethods.authorizedGet('posts/feed?page=$page&limit=$limit');
      final posts = data['data']?['posts'] as List<dynamic>? ?? [];
      await OfflineCacheService.setJson(cacheKey, posts);
      return posts
          .map((p) => PostModel.fromApi(Map<String, dynamic>.from(p as Map)))
          .toList();
    } catch (e) {
      final cached = OfflineCacheService.getJsonList(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached.map((p) => PostModel.fromApi(p)).toList();
      }
      rethrow;
    }
  }

  static Future<PostModel> createPost({
    required String caption,
    required String postType,
    List<String> mediaUrls = const [],
    String? location,
    List<Map<String, dynamic>> mediaMeta = const [],
    Map<String, dynamic>? postMeta,
  }) async {
    final data = await ApiMethods.authorizedPost('posts', {
      'caption': caption,
      'post_type': postType,
      'media_urls': mediaUrls,
      if (location != null && location.isNotEmpty) 'location': location,
      if (mediaMeta.isNotEmpty) 'media_meta': mediaMeta,
      if (postMeta != null && postMeta.isNotEmpty) 'post_meta': postMeta,
    });
    final postJson = data['data']?['post'] as Map<String, dynamic>?;
    if (postJson == null) throw ApiException('Post create failed');
    return PostModel.fromApi(postJson);
  }

  static Future<void> deletePost(String postId) async {
    await ApiMethods.authorizedDelete('posts/$postId');
  }

  static Future<Map<String, dynamic>> updatePost(String postId, {required String caption}) async {
    return ApiMethods.authorizedPut('posts/$postId', {'caption': caption});
  }

  static Future<Map<String, dynamic>> archivePost(String postId, {bool archived = true}) async {
    return ApiMethods.authorizedPatch('posts/$postId/archive', {'archived': archived});
  }

  static Future<PollData> votePoll(String postId, int optionIndex) async {
    final data = await ApiMethods.authorizedPost('posts/$postId/poll/vote', {
      'option_index': optionIndex,
    });
    final pollJson = data['data']?['poll'] as Map<String, dynamic>?;
    if (pollJson == null) throw ApiException('Vote failed');
    return PollData.fromJson(pollJson)!;
  }

  static Future<Map<String, dynamic>> toggleLike(String postId) async {
    return ApiMethods.authorizedPost('posts/$postId/like', {});
  }

  static Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final data = await ApiMethods.authorizedGet('posts/$postId/comments');
    final comments = data['data']?['comments'] as List<dynamic>? ?? [];
    return comments.map((c) => Map<String, dynamic>.from(c as Map)).toList();
  }

  static Future<int> addComment(
    String postId, {
    required String body,
    String? parentId,
  }) async {
    final data = await ApiMethods.authorizedPost('posts/$postId/comments', {
      'body': body,
      if (parentId != null) 'parent_id': parentId,
    });
    return data['data']?['comment_count'] as int? ?? 0;
  }

  static Future<void> updateComment(
    String postId,
    String commentId, {
    required String body,
  }) async {
    await ApiMethods.authorizedPut('posts/$postId/comments/$commentId', {
      'body': body,
    });
  }

  static Future<int> deleteComment(String postId, String commentId) async {
    final data = await ApiMethods.authorizedDelete('posts/$postId/comments/$commentId');
    return data['data']?['comment_count'] as int? ?? 0;
  }

  static Future<List<Map<String, dynamic>>> reactComment(
    String postId,
    String commentId,
    String emoji,
  ) async {
    final data = await ApiMethods.authorizedPost(
      'posts/$postId/comments/$commentId/react',
      {'emoji': emoji},
    );
    final reactions = data['data']?['reactions'] as List<dynamic>? ?? [];
    return reactions.map((r) => Map<String, dynamic>.from(r as Map)).toList();
  }

  static Future<void> reportComment(
    String postId,
    String commentId, {
    String? reason,
  }) async {
    await ApiMethods.authorizedPost('posts/$postId/comments/$commentId/report', {
      if (reason != null) 'reason': reason,
    });
  }

  static Future<List<PostModel>> getReels({int page = 1, int limit = 10}) async {
    final cacheKey = _reelsCacheKey(page, limit);
    try {
      final data = await ApiMethods.authorizedGet('posts/reels?page=$page&limit=$limit');
      final reels = data['data']?['reels'] as List<dynamic>? ?? [];
      await OfflineCacheService.setJson(cacheKey, reels);
      return reels
          .map((p) => PostModel.fromApi(Map<String, dynamic>.from(p as Map)))
          .toList();
    } catch (e) {
      final cached = OfflineCacheService.getJsonList(cacheKey);
      if (cached != null && cached.isNotEmpty) {
        return cached.map((p) => PostModel.fromApi(p)).toList();
      }
      rethrow;
    }
  }

  static Future<PostModel> getPost(String postId) async {
    final data = await ApiMethods.authorizedGet('posts/$postId');
    final postJson = data['data']?['post'] as Map<String, dynamic>?;
    if (postJson == null) throw ApiException('Post not found');
    return PostModel.fromApi(postJson);
  }

  static String errorMessage(Object error) {
    if (error is ApiException) return error.message;
    return 'Something went wrong. Please try again.';
  }
}
