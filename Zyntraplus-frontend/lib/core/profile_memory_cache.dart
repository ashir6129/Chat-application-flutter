import '../models/feed_post.dart';
import '../models/user_profile.dart';

/// Session cache for own profile — instant tab/profile reopen.
class ProfileMemoryCache {
  ProfileMemoryCache._();

  static UserProfile? me;
  static List<PostModel> myPosts = [];

  static void saveProfile(UserProfile profile) {
    me = profile;
  }

  static void savePosts(List<PostModel> posts) {
    myPosts = List<PostModel>.from(posts);
  }

  static void removePost(String postId) {
    myPosts.removeWhere((p) => p.id == postId);
  }

  static void updatePost(PostModel post) {
    final index = myPosts.indexWhere((p) => p.id == post.id);
    if (index >= 0) {
      myPosts[index] = post;
    }
  }

  static void prependPost(PostModel post) {
    myPosts.removeWhere((p) => p.id == post.id);
    myPosts.insert(0, post);
  }

  static void clear() {
    me = null;
    myPosts = [];
  }
}
