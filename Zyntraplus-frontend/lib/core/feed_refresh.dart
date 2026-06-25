import '../models/feed_post.dart';

class FeedRefreshEvent {
  final bool silent;
  final bool refresh;
  final PostModel? prepend;
  final String? patchUserId;
  final String? patchAvatarUrl;

  const FeedRefreshEvent({
    this.silent = false,
    this.refresh = true,
    this.prepend,
    this.patchUserId,
    this.patchAvatarUrl,
  });
}

typedef FeedRefreshListener = void Function(FeedRefreshEvent event);

/// Triggers home feed updates after posts change.
class FeedRefresh {
  FeedRefresh._();

  static FeedRefreshListener? _listener;

  static void register(FeedRefreshListener listener) {
    _listener = listener;
  }

  static void unregister() {
    _listener = null;
  }

  static void trigger({bool silent = true, bool refresh = true}) {
    _listener?.call(FeedRefreshEvent(silent: silent, refresh: refresh));
  }

  static void prepend(PostModel post) {
    _listener?.call(FeedRefreshEvent(silent: true, refresh: false, prepend: post));
  }

  /// Updates cached feed rows when a user's avatar changes (including removal).
  static void patchAuthorAvatar(String userId, String? avatarUrl) {
    _listener?.call(FeedRefreshEvent(
      silent: true,
      refresh: false,
      patchUserId: userId,
      patchAvatarUrl: avatarUrl,
    ));
  }
}
