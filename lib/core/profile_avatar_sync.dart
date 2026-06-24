import '../models/user_profile.dart';
import 'feed_memory_cache.dart';
import 'feed_refresh.dart';
import 'profile_memory_cache.dart';
import 'profile_refresh.dart';

/// Keeps avatar changes in sync across profile, feed, and home UI.
class ProfileAvatarSync {
  ProfileAvatarSync._();

  static void apply(UserProfile profile) {
    ProfileMemoryCache.saveProfile(profile);
    _patchPosts(profile.id, profile.avatarUrl);
    FeedRefresh.patchAuthorAvatar(profile.id, profile.avatarUrl);
    ProfileRefresh.trigger(silent: true);
  }

  static void _patchPosts(String userId, String? avatarUrl) {
    ProfileMemoryCache.myPosts = ProfileMemoryCache.myPosts
        .map((p) => p.userId == userId ? p.withAuthorAvatar(avatarUrl) : p)
        .toList();
    FeedMemoryCache.patchAuthorAvatar(userId, avatarUrl);
  }
}
