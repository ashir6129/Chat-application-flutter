import 'package:flutter/material.dart';
import '../../api_services/post_services.dart';
import '../../api_services/user_service.dart';
import '../../core/app_colors.dart';
import '../../core/cached_image.dart';
import '../../core/media_url_utils.dart';
import '../../core/profile_memory_cache.dart';
import '../../core/profile_refresh.dart';
import '../../models/feed_post.dart';
import '../../widgets/feed/feed_caption_text.dart';
import '../../widgets/feed/feed_image_grid.dart';
import '../../widgets/feed/feed_photo_viewer.dart';
import '../../widgets/feed/feed_poll_card.dart';
import '../../widgets/feed/feed_sheets.dart';
import '../../widgets/feed/feed_video_preview.dart';
import '../../widgets/feed/feed_attachments.dart';
import '../../widgets/feed/menu_bottom_sheet.dart';
import '../../widgets/feed/post_widget.dart';

class ProfilePostsList extends StatefulWidget {
  final String type;
  final String? username;
  final bool readOnly;
  final bool managed;
  final List<PostModel>? posts;
  final bool loading;
  final ValueChanged<List<PostModel>>? onPostsChanged;

  const ProfilePostsList({
    super.key,
    this.type = 'all',
    this.username,
    this.readOnly = false,
    this.managed = false,
    this.posts,
    this.loading = false,
    this.onPostsChanged,
  });

  static List<PostModel> filterByType(List<PostModel> posts, String type) {
    switch (type) {
      case 'photos':
        return posts
            .where(
              (p) => p.images.any(
                (url) => url.isNotEmpty && !p.isVideo && MediaUrlUtils.isImageUrl(url),
              ),
            )
            .toList();
      case 'reels':
        return posts.where((p) => p.isVideo).toList();
      default:
        return posts;
    }
  }

  @override
  State<ProfilePostsList> createState() => _ProfilePostsListState();
}

class _ProfilePostsListState extends State<ProfilePostsList> {
  List<PostModel> _posts = [];
  bool _loading = true;
  String? _error;
  ProfileRefreshListener? _profileRefreshListener;

  bool get _isManaged => widget.managed && widget.posts != null;

  List<PostModel> get _visiblePosts {
    if (_isManaged) {
      return ProfilePostsList.filterByType(widget.posts!, widget.type);
    }
    return _posts;
  }

  bool get _showLoading {
    if (_isManaged) return widget.loading && _visiblePosts.isEmpty;
    return _loading;
  }

  @override
  void initState() {
    super.initState();
    if (_isManaged) return;

    _profileRefreshListener = ({bool silent = false}) => _load(silent: silent);
    ProfileRefresh.register(_profileRefreshListener!);

    if (widget.username == null && ProfileMemoryCache.myPosts.isNotEmpty) {
      _posts = ProfilePostsList.filterByType(ProfileMemoryCache.myPosts, widget.type);
      _loading = false;
    }

    _load(silent: _posts.isNotEmpty);
  }

  @override
  void dispose() {
    if (_profileRefreshListener != null) {
      ProfileRefresh.unregister(_profileRefreshListener);
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProfilePostsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isManaged) return;
    if (oldWidget.type != widget.type ||
        oldWidget.username != widget.username) {
      _load(silent: _posts.isNotEmpty);
    }
  }

  Future<void> _load({bool silent = false}) async {
    if (_isManaged) return;

    if (_posts.isEmpty && !silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final posts = widget.username != null
          ? await UserService.getUserPosts(widget.username!, type: widget.type, limit: 50)
          : await UserService.getMyPosts(type: widget.type, limit: 50);
      if (!mounted) return;
      if (widget.username == null && widget.type == 'all') {
        ProfileMemoryCache.savePosts(posts);
      }
      setState(() {
        _posts = posts;
        _loading = false;
      });
      prefetchMediaUrls(posts.expand((p) => p.images));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_posts.isEmpty) _error = UserService.errorMessage(e);
      });
    }
  }

  void _replaceAllPosts(List<PostModel> posts) {
    if (_isManaged) {
      widget.onPostsChanged?.call(posts);
      return;
    }
    setState(() => _posts = posts);
  }

  void _updatePostAt(int visibleIndex, PostModel updated) {
    if (_isManaged) {
      final all = List<PostModel>.from(widget.posts!);
      final id = _visiblePosts[visibleIndex].id;
      final i = all.indexWhere((p) => p.id == id);
      if (i >= 0) all[i] = updated;
      widget.onPostsChanged?.call(all);
      return;
    }
    setState(() => _posts[visibleIndex] = updated);
  }

  void _removePostAt(int visibleIndex) {
    if (_isManaged) {
      final all = List<PostModel>.from(widget.posts!);
      all.removeWhere((p) => p.id == _visiblePosts[visibleIndex].id);
      widget.onPostsChanged?.call(all);
      return;
    }
    setState(() => _posts.removeAt(visibleIndex));
  }

  Future<void> _deletePost(int index) async {
    final post = _visiblePosts[index];
    try {
      await PostsService.deletePost(post.id);
      ProfileMemoryCache.removePost(post.id);
      if (!mounted) return;
      _removePostAt(index);
      ProfileRefresh.trigger(silent: true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PostsService.errorMessage(e))),
      );
    }
  }

  Future<void> _archivePost(int index, {required bool archived}) async {
    final post = _visiblePosts[index];
    try {
      await PostsService.archivePost(post.id, archived: archived);
      if (!mounted) return;
      if (archived) {
        ProfileMemoryCache.removePost(post.id);
        _removePostAt(index);
      } else {
        _updatePostAt(index, post.copyWith(isArchived: archived));
      }
      ProfileRefresh.trigger(silent: true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            archived ? 'Post archived — view in Settings → Archived Posts' : 'Post restored',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PostsService.errorMessage(e))),
      );
    }
  }

  Future<void> _editPost(int index) async {
    final post = _visiblePosts[index];
    final ctrl = TextEditingController(text: post.displayCaption);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit caption'),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Write a caption...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved != true || !mounted) return;

    try {
      await PostsService.updatePost(post.id, caption: ctrl.text.trim());
      final updated = post.copyWith(caption: ctrl.text.trim());
      ProfileMemoryCache.updatePost(updated);
      _updatePostAt(index, updated);
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
    final post = _visiblePosts[index];
    if (post.poll == null) return;

    try {
      final updatedPoll = await PostsService.votePoll(post.id, optionIndex);
      if (!mounted) return;
      _updatePostAt(index, post.copyWith(poll: updatedPoll));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(PostsService.errorMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final posts = _visiblePosts;

    if (_showLoading) {
      return Center(child: CircularProgressIndicator(color: AppColors.buttonColor(context)));
    }

    if (_error != null && posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: AppColors.secondaryText(context))),
              const SizedBox(height: 12),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.post_add_outlined, size: 48, color: AppColors.mutedText(context)),
            const SizedBox(height: 12),
            Text(
              'No posts yet',
              style: TextStyle(color: AppColors.secondaryText(context), fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    if (widget.type == 'photos') return _PhotoGrid(posts: posts);
    if (widget.type == 'reels') return _ReelGrid(posts: posts);

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return _ProfilePostCard(
          post: post,
          readOnly: widget.readOnly,
          onLike: () => _toggleLike(index),
          onCommentCountUpdated: (count) {
            _updatePostAt(index, post.copyWith(comments: count));
          },
          onPollVote: (optionIndex) => _votePoll(index, optionIndex),
          onDelete: widget.readOnly ? null : () => _deletePost(index),
          onArchive: widget.readOnly ? null : () => _archivePost(index, archived: true),
          onEdit: widget.readOnly ? null : () => _editPost(index),
        );
      },
    );
  }

  Future<void> _toggleLike(int index) async {
    final post = _visiblePosts[index];
    final optimistic = post.copyWith(
      liked: !post.liked,
      likes: post.likes + (post.liked ? -1 : 1),
    );
    _updatePostAt(index, optimistic);

    try {
      final data = await PostsService.toggleLike(post.id);
      final liked = data['data']?['liked'] == true;
      final count = data['data']?['like_count'] as int? ?? optimistic.likes;
      if (!mounted) return;
      _updatePostAt(index, post.copyWith(liked: liked, likes: count));
    } catch (_) {
      if (!mounted) return;
      _updatePostAt(index, post);
    }
  }
}

class _ProfilePostCard extends StatelessWidget {
  final PostModel post;
  final bool readOnly;
  final VoidCallback onLike;
  final ValueChanged<int>? onCommentCountUpdated;
  final ValueChanged<int>? onPollVote;
  final VoidCallback? onDelete;
  final VoidCallback? onArchive;
  final VoidCallback? onEdit;

  const _ProfilePostCard({
    required this.post,
    this.readOnly = false,
    required this.onLike,
    this.onCommentCountUpdated,
    this.onPollVote,
    this.onDelete,
    this.onArchive,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.buttonColor(context);
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        border: Border(bottom: BorderSide(color: AppColors.borderLine(context), width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 4),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: accent.withValues(alpha: 0.15),
                  backgroundImage: post.authorAvatarUrl != null && post.authorAvatarUrl!.isNotEmpty
                      ? NetworkImage(post.authorAvatarUrl!)
                      : null,
                  child: (post.authorAvatarUrl == null || post.authorAvatarUrl!.isEmpty)
                      ? Text(
                          post.user.isNotEmpty ? post.user[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: accent,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.user.isNotEmpty ? post.user : 'You',
                        style: TextStyle(
                          color: AppColors.primaryText(context),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      if (post.time.isNotEmpty)
                        Text(
                          post.time,
                          style: TextStyle(
                            color: AppColors.secondaryText(context),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                if (post.isArchived)
                  Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBackground(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Archived',
                      style: TextStyle(color: AppColors.mutedText(context), fontSize: 10),
                    ),
                  ),
                if (!readOnly)
                  IconButton(
                    icon: Icon(Icons.more_horiz, color: AppColors.secondaryText(context), size: 20),
                    onPressed: () => showPostMenuBottomSheet(
                      context,
                      authorName: post.user,
                      isOwnPost: true,
                      isArchived: post.isArchived,
                      onDelete: onDelete,
                      onEdit: onEdit,
                      onArchive: onArchive,
                    ),
                  ),
              ],
            ),
          ),
          // ── Post content ───────────────────────────────────────────
          if (post.poll != null)
            FeedPollCard(
              poll: post.poll!,
              onVote: onPollVote,
              isOwner: !readOnly,
            ),
          if (post.displayCaption.isNotEmpty)
            FeedCaptionText(
              caption: post.displayCaption,
              hasMedia: post.images.isNotEmpty,
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
            ),
          if (post.images.isNotEmpty)
            if (post.images.length == 1 &&
                (post.isVideo || MediaUrlUtils.isVideoUrl(post.images.first)))
              FeedVideoPreview(
                videoUrl: post.images.first,
                editSettings: post.mediaMeta.isNotEmpty ? post.mediaMeta.first : null,
              )
            else
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
                  likeCount: post.likes,
                  commentCount: post.comments,
                  shareCount: post.shareCount,
                  liked: post.liked,
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
          if (post.product != null)
            FeedProductAttachmentCard(
              name: post.product!.name,
              price: post.product!.price,
              imageUrl: post.product!.imageUrl,
              currency: post.product!.currency,
              stock: post.product!.stock,
              onBuyNow: () {},
            ),
          PostsStatsWidget(
            initialLikeCount: post.likes,
            commentCount: post.comments,
            shareCount: post.shareCount,
            initiallyLiked: post.liked,
            liked: post.liked,
            likeCount: post.likes,
            onLikeOverride: onLike,
            onComment: () => showFeedCommentsSheet(
              context,
              postUid: post.id,
              authorName: post.user,
              onCommentCountChanged: onCommentCountUpdated,
            ),
            onShare: () => showFeedShareSheet(context, postUid: post.id, authorName: post.user),
          ),
        ],
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List<PostModel> posts;
  const _PhotoGrid({required this.posts});

  List<String> get _urls {
    final urls = <String>[];
    for (final post in posts) {
      for (final url in post.images) {
        if (url.isNotEmpty && !post.isVideo && MediaUrlUtils.isImageUrl(url)) urls.add(url);
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;
    if (urls.isEmpty) {
      return Center(child: Text('No photos yet', style: TextStyle(color: AppColors.secondaryText(context))));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 1.5, mainAxisSpacing: 1.5),
      itemCount: urls.length,
      itemBuilder: (_, i) => appCachedImage(urls[i], fit: BoxFit.cover),
    );
  }
}

class _ReelGrid extends StatelessWidget {
  final List<PostModel> posts;
  const _ReelGrid({required this.posts});

  @override
  Widget build(BuildContext context) {
    final reels = posts.where((p) => p.isVideo).toList();
    if (reels.isEmpty) {
      return Center(child: Text('No reels yet', style: TextStyle(color: AppColors.secondaryText(context))));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
        childAspectRatio: 0.6,
      ),
      itemCount: reels.length,
      itemBuilder: (_, i) {
        final thumb = reels[i].images.isNotEmpty ? reels[i].images.first : '';
        return Stack(
          fit: StackFit.expand,
          children: [
            if (thumb.isNotEmpty && MediaUrlUtils.isVideoUrl(thumb))
              ColoredBox(
                color: AppColors.secondaryBackground(context),
                child: Icon(Icons.videocam_rounded, color: AppColors.mutedText(context), size: 32),
              )
            else if (thumb.isNotEmpty)
              appCachedImage(thumb, fit: BoxFit.cover)
            else
              ColoredBox(color: AppColors.secondaryBackground(context)),
            const Positioned(top: 6, right: 6, child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18)),
          ],
        );
      },
    );
  }
}
