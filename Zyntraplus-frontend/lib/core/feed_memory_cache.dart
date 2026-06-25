import '../models/feed_post.dart';

/// In-memory feed snapshot so tab switches stay instant within a session.
class FeedMemoryCache {
  FeedMemoryCache._();

  static List<PostModel> posts = [];
  static Set<String> followedIds = {};
  static String? currentUserId;
  static bool hydrated = false;

  static void save({
    required List<PostModel> posts,
    required Set<String> followed,
    String? userId,
  }) {
    FeedMemoryCache.posts = List<PostModel>.from(posts);
    followedIds = Set<String>.from(followed);
    currentUserId = userId;
    hydrated = posts.isNotEmpty;
  }

  static void prepend(PostModel post) {
    posts.removeWhere((p) => p.id == post.id);
    posts.insert(0, post);
    hydrated = true;
  }

  static void removePost(String postId) {
    posts.removeWhere((p) => p.id == postId);
  }

  static void patchAuthorAvatar(String userId, String? avatarUrl) {
    if (posts.isEmpty) return;
    posts = posts
        .map((p) => p.userId == userId ? p.withAuthorAvatar(avatarUrl) : p)
        .toList();
  }
}
