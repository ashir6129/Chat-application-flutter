import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:zyntraplus/screens/user_profile_screen/user_profile_screen.dart';
import '../../api_services/post_services.dart';
import '../../api_services/follow_service.dart';
import '../../api_services/user_service.dart';
import '../../core/app_colors.dart';
import '../../core/connectivity_service.dart';
import '../../core/feed_memory_cache.dart';
import '../../core/profile_memory_cache.dart';
import '../../core/feed_refresh.dart';
import '../../core/profile_refresh.dart';
import '../../core/secure_storage_service.dart';
import '../../models/feed_post.dart';
import '../../models/follow_user.dart';
import '../../widgets/feed/feed_caption_text.dart';
import '../../widgets/feed/feed_attachments.dart';
import '../../widgets/feed/feed_image_grid.dart';
import '../../widgets/feed/feed_photo_viewer.dart';
import '../../widgets/feed/feed_poll_card.dart';
import '../../widgets/feed/feed_sheets.dart';
import '../../widgets/feed/feed_video_preview.dart';
import '../../widgets/feed/menu_bottom_sheet.dart';
import '../../core/cached_image.dart';
import '../../widgets/feed/feed_user_avatar.dart';
import '../../widgets/feed/post_widget.dart';
import '../../widgets/profile/user_suggestions_strip.dart';
import '../../core/media_url_utils.dart';

export '../../models/feed_post.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => FeedState();
}

class FeedState extends State<Feed> {
  List<PostModel> _posts = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 1;
  bool _showingCachedFeed = false;
  Set<String> _followed = {};
  String? _currentUserId;
  List<FollowUser> _suggestions = [];

  static const int _suggestionsEveryNPosts = 5;

  @override
  void initState() {
    super.initState();
    FeedRefresh.register(_onFeedRefresh);
    _restoreFromMemory();
    _hydrateFromDiskCache();
    _loadCurrentUser(silent: true);
    _loadSuggestions();
    _loadPosts(silent: _posts.isNotEmpty);
  }

  void _restoreFromMemory() {
    if (!FeedMemoryCache.hydrated) return;
    _posts = List<PostModel>.from(FeedMemoryCache.posts);
    _followed = Set<String>.from(FeedMemoryCache.followedIds);
    _currentUserId = FeedMemoryCache.currentUserId;
    _loading = _posts.isEmpty;
  }

  void _hydrateFromDiskCache() {
    if (_posts.isNotEmpty) return;
    final cached = PostsService.readFeedCache();
    if (cached == null || cached.isEmpty) return;
    _posts = cached;
    _loading = false;
    _showingCachedFeed = !ConnectivityService.isOnline;
  }

  void _persistMemory() {
    FeedMemoryCache.save(
      posts: _posts,
      followed: _followed,
      userId: _currentUserId,
    );
  }

  void _onFeedRefresh(FeedRefreshEvent event) {
    if (event.patchUserId != null) {
      setState(() {
        _posts = _posts
            .map((p) => p.userId == event.patchUserId
                ? p.withAuthorAvatar(event.patchAvatarUrl)
                : p)
            .toList();
        _loading = false;
      });
      _persistMemory();
      return;
    }

    if (event.prepend != null) {
      final post = event.prepend!;
      setState(() {
        _posts.removeWhere((p) => p.id == post.id);
        _posts.insert(0, post);
        _loading = false;
      });
      _persistMemory();
      ProfileMemoryCache.prependPost(post);
      prefetchMediaUrls([
        ...post.images,
        if (post.authorAvatarUrl != null && post.authorAvatarUrl!.isNotEmpty)
          post.authorAvatarUrl!,
      ]);
      return;
    }
    _loadPosts(refresh: event.refresh, silent: event.silent);
  }

  Future<void> _loadSuggestions() async {
    try {
      final users = await UserService.getSuggestions(limit: 12);
      if (!mounted) return;
      setState(() => _suggestions = users);
    } catch (_) {}
  }

  Widget _buildSuggestionsStrip() {
    if (_suggestions.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Column(
        children: [
          Divider(color: AppColors.borderLine(context), height: 1, thickness: 0.5),
          UserSuggestionsStrip(
            users: _suggestions,
            onUsersUpdated: (users) => setState(() => _suggestions = users),
          ),
        ],
      ),
    );
  }

  Future<void> _loadCurrentUser({bool silent = false}) async {
    try {
      final profile = await UserService.getMe();
      final following = await UserService.getFollowing(profile.id);
      if (!mounted) return;
      setState(() {
        _currentUserId = profile.id;
        _followed = following.map((u) => u.id).toSet();
      });
      _persistMemory();
    } catch (_) {
      final uid = await SecureStorageService.getUserUid();
      if (!mounted) return;
      setState(() => _currentUserId = uid);
    }
  }

  @override
  void dispose() {
    FeedRefresh.unregister();
    super.dispose();
  }

  Future<void> reload() async {
    await _loadSuggestions();
    await _loadPosts(refresh: true, silent: _posts.isNotEmpty);
  }

  Future<void> _loadPosts({bool refresh = false, bool silent = false}) async {
    Future<void>? userFuture;
    if (refresh) {
      _page = 1;
      _hasMore = true;
      if (!silent) userFuture = _loadCurrentUser(silent: true);
    }

    final showBlockingLoader = !silent && _posts.isEmpty;
    if (showBlockingLoader) {
      setState(() {
        _loading = true;
        _error = null;
        if (refresh) _showingCachedFeed = false;
      });
    } else if (refresh) {
      setState(() {
        _error = null;
        if (refresh) _showingCachedFeed = false;
      });
    }

    try {
      final feedFuture = PostsService.getFeed(page: _page, limit: 20);
      final results = await Future.wait([
        feedFuture,
        if (userFuture != null) userFuture,
      ]);
      final items = results[0] as List<PostModel>;

      setState(() {
        if (refresh || _page == 1) {
          _posts = items;
        } else {
          _posts = [..._posts, ...items];
        }
        _hasMore = items.length >= 20;
        _loading = false;
        _loadingMore = false;
        _showingCachedFeed = !ConnectivityService.isOnline;
      });
      _persistMemory();
      _prefetchPostMedia(_posts);
    } catch (e) {
      setState(() {
        _loading = false;
        _loadingMore = false;
        if (_posts.isEmpty) {
          _error = PostsService.errorMessage(e);
        }
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasMore || _loading) return;

    setState(() => _loadingMore = true);
    _page += 1;
    await _loadPosts();
  }

  void _prefetchPostMedia(List<PostModel> posts) {
    final urls = <String>[];
    for (final post in posts) {
      urls.addAll(post.images);
      final avatar = post.authorAvatarUrl;
      if (avatar != null && avatar.isNotEmpty) urls.add(avatar);
    }
    prefetchMediaUrls(urls);
  }

  Future<void> _toggleLike(int index) async {
    final post = _posts[index];
    final optimistic = post.copyWith(
      liked: !post.liked,
      likes: post.likes + (post.liked ? -1 : 1),
    );

    setState(() => _posts[index] = optimistic);

    try {
      final data = await PostsService.toggleLike(post.id);
      final liked = data['data']?['liked'] == true;
      final count = data['data']?['like_count'] as int? ?? optimistic.likes;

      setState(() {
        _posts[index] = post.copyWith(liked: liked, likes: count);
      });
    } catch (_) {
      setState(() => _posts[index] = post);
    }
  }

  void _toggleFollow(int index) async {
    final post = _posts[index];
    final isFollowing = _followed.contains(post.userId);

    setState(() {
      if (isFollowing) {
        _followed.remove(post.userId);
        _posts.removeWhere((p) => p.userId == post.userId);
      } else {
        _followed.add(post.userId);
      }
    });

    try {
      if (isFollowing) {
        await FollowService.unfollow(post.userId);
      } else {
        await FollowService.follow(post.userId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (isFollowing) {
          _followed.add(post.userId);
        } else {
          _followed.remove(post.userId);
        }
      });
      await _loadPosts(refresh: true);
    }
  }

  Future<void> _deletePost(int index) async {
    final post = _posts[index];
    try {
      await PostsService.deletePost(post.id);
      if (!mounted) return;
      setState(() => _posts.removeAt(index));
      FeedMemoryCache.removePost(post.id);
      ProfileRefresh.trigger(silent: true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post deleted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PostsService.errorMessage(e))),
      );
    }
  }

  Future<void> _archivePost(int index) async {
    final post = _posts[index];
    try {
      await PostsService.archivePost(post.id);
      ProfileRefresh.trigger(silent: true);
      if (!mounted) return;
      setState(() => _posts.removeAt(index));
      FeedMemoryCache.removePost(post.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post archived — view in Settings → Archived Posts')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PostsService.errorMessage(e))),
      );
    }
  }

  Future<void> _editPost(int index) async {
    final post = _posts[index];
    final ctrl = TextEditingController(text: post.displayCaption);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondaryBackground(context),
        title: Text('Edit caption', style: TextStyle(color: AppColors.primaryText(context))),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          style: TextStyle(color: AppColors.primaryText(context)),
          decoration: InputDecoration(
            hintText: 'Write a caption...',
            hintStyle: TextStyle(color: AppColors.mutedText(context)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved != true || !mounted) {
      ctrl.dispose();
      return;
    }

    try {
      await PostsService.updatePost(post.id, caption: ctrl.text.trim());
      if (!mounted) return;
      setState(() => _posts[index] = post.copyWith(caption: ctrl.text.trim()));
      _persistMemory();
      ProfileRefresh.trigger(silent: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PostsService.errorMessage(e))),
      );
    } finally {
      ctrl.dispose();
    }
  }

  Future<void> _votePoll(int index, int optionIndex) async {
    final post = _posts[index];
    if (post.poll == null) return;

    try {
      final updated = await PostsService.votePoll(post.id, optionIndex);
      if (!mounted) return;
      setState(() => _posts[index] = post.copyWith(poll: updated));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PostsService.errorMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    if (_error != null && _posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.cloud_off_outlined, size: 40, color: AppColors.mutedText(context)),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText(context), fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _loadPosts,
              child: Text('Retry', style: TextStyle(color: AppColors.buttonColor(context))),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Iconsax.document_text, size: 42, color: AppColors.mutedText(context)),
            const SizedBox(height: 12),
            Text(
              'Your feed is empty',
              style: TextStyle(
                color: AppColors.primaryText(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Follow people to see their posts here, or create your own post above.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.secondaryText(context), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (_showingCachedFeed)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Showing saved feed — pull to refresh when back online',
              style: TextStyle(color: AppColors.secondaryText(context), fontSize: 12),
            ),
          ),
        ...List.generate(_posts.length, (i) {
          final post = _posts[i];
          return Column(
            children: [
              if (i == 0) const SizedBox(height: 12),
              if (i > 0) const SizedBox(height: 12),
              _FeedCard(
                post: post,
                liked: post.liked,
                likeCount: post.likes,
                followed: _followed.contains(post.userId),
                isOwnPost: _currentUserId != null && post.userId == _currentUserId,
                onLike: () => _toggleLike(i),
                onFollow: () => _toggleFollow(i),
                onPollVote: (optionIndex) => _votePoll(i, optionIndex),
                onDelete: () => _deletePost(i),
                onArchive: () => _archivePost(i),
                onEdit: () => _editPost(i),
                onCommentCountUpdated: (count) => setState(() {
                  _posts[i] = _posts[i].copyWith(comments: count);
                }),
              ),
              if ((i + 1) % _suggestionsEveryNPosts == 0) _buildSuggestionsStrip(),
            ],
          );
        }),
        if (_hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: _loadingMore
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: _loadMore,
                    child: Text(
                      'Load more',
                      style: TextStyle(color: AppColors.buttonColor(context)),
                    ),
                  ),
          ),
      ],
    );
  }
}

class _FeedCard extends StatelessWidget {
  final PostModel post;
  final bool liked;
  final int likeCount;
  final bool followed;
  final bool isOwnPost;
  final VoidCallback onLike;
  final VoidCallback onFollow;
  final ValueChanged<int>? onCommentCountUpdated;
  final ValueChanged<int>? onPollVote;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onEdit;

  const _FeedCard({
    required this.post,
    required this.liked,
    required this.likeCount,
    required this.followed,
    this.isOwnPost = false,
    required this.onLike,
    required this.onFollow,
    this.onCommentCountUpdated,
    this.onPollVote,
    this.onDelete,
    this.onArchive,
    this.onEdit,
  });

  void _goToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(userId: post.userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        border: Border(
          bottom: BorderSide(color: AppColors.borderLine(context), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _goToProfile(context),
                  child: FeedUserAvatar(
                    name: post.user,
                    accentColor: post.color,
                    imageUrl: post.authorAvatarUrl,
                    size: 42,
                    showBorder: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _goToProfile(context),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.user,
                          style: TextStyle(
                            color: AppColors.primaryText(context),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            height: 1.15,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            FeedNearbyIcon(
                              size: 11,
                              color: AppColors.buttonColor(context),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              formatFeedDistance(post.dist),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.buttonColor(context),
                                height: 1.2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: Text(
                                '·',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedText(context),
                                  height: 1.2,
                                ),
                              ),
                            ),
                            Text(
                              post.time,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.mutedText(context),
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isOwnPost) ...[
                  GestureDetector(
                    onTap: onFollow,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: followed
                            ? Colors.transparent
                            : AppColors.buttonColor(context),
                        borderRadius: BorderRadius.circular(18),
                        border: followed
                            ? Border.all(color: AppColors.borderLine(context))
                            : null,
                      ),
                      child: Text(
                        followed ? 'Following' : 'Follow',
                        style: TextStyle(
                          color: followed
                              ? AppColors.primaryText(context)
                              : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                GestureDetector(
                  onTap: () => showPostMenuBottomSheet(
                    context,
                    authorName: post.user,
                    isOwnPost: isOwnPost,
                    isArchived: post.isArchived,
                    onDelete: onDelete,
                    onArchive: onArchive,
                    onEdit: onEdit,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.more_vert,
                      color: AppColors.mutedText(context),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (post.poll != null)
            FeedPollCard(
              poll: post.poll!,
              onVote: onPollVote,
              isOwner: isOwnPost,
            ),
          if (post.displayCaption.isNotEmpty)
            FeedCaptionText(caption: post.displayCaption),
          if (post.images.isEmpty)
            const SizedBox.shrink()
          else if (post.images.length == 1 &&
              (post.isVideo || MediaUrlUtils.isVideoUrl(post.images.first)))
            FeedVideoPreview(
              videoUrl: post.images.first,
              editSettings: post.mediaMeta.isNotEmpty ? post.mediaMeta.first : null,
            )
          else if (post.images.isNotEmpty)
            FeedImageGrid(
              images: post.images,
              mediaMeta: post.mediaMeta,
                postInfo: FeedPhotoViewerPost(
                  postId: post.id,
                  authorName: post.user,
                  authorId: post.userId,
                  authorColor: post.color,
                caption: post.displayCaption,
                distance: post.dist,
                likeCount: likeCount,
                commentCount: post.comments,
                shareCount: post.shareCount,
                liked: liked,
                product: post.product != null
                    ? FeedPhotoViewerProduct(
                        name: post.product!.name,
                        price: post.product!.price,
                        imageUrl: post.product!.imageUrl,
                        currency: post.product!.currency,
                      )
                    : null,
              ),
            ),
          if (post.images.isNotEmpty || post.displayCaption.isNotEmpty || post.poll != null)
            PostsStatsWidget(
              initialLikeCount: likeCount,
              commentCount: post.comments,
              shareCount: post.shareCount,
              initiallyLiked: liked,
              liked: liked,
              likeCount: likeCount,
              onLikeOverride: onLike,
              onComment: () => showFeedCommentsSheet(
                context,
                postUid: post.id,
                authorName: post.user,
                onCommentCountChanged: onCommentCountUpdated,
              ),
              onShare: () => showFeedShareSheet(
                context,
                postUid: post.id,
                authorName: post.user,
              ),
              onTip: isOwnPost
                  ? null
                  : () => showFeedTipSheet(
                        context,
                        recipientId: post.userId,
                        authorName: post.user,
                        postId: post.id,
                      ),
            ),
          if (post.product != null)
            FeedProductAttachmentCard(
              name: post.product!.name,
              price: post.product!.price,
              imageUrl: post.product!.imageUrl,
              currency: post.product!.currency,
              stock: post.product!.stock,
              onBuyNow: () {},
            ),
          if (post.banner != null)
            FeedBannerAdCard(
              title: post.banner!.title,
              subtitle: post.banner!.subtitle,
              imageUrl: post.banner!.imageUrl,
              ctaLabel: post.banner!.ctaLabel,
            ),
        ],
      ),
    );
  }
}
