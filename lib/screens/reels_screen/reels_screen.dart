import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';
import 'package:zyntraplus/api_services/follow_service.dart';
import 'package:zyntraplus/api_services/post_services.dart';
import 'package:zyntraplus/api_services/user_service.dart';
import 'package:zyntraplus/models/feed_post.dart';
import 'package:zyntraplus/screens/reels_screen/new_reel_review_screen.dart';
import 'package:zyntraplus/screens/user_profile_screen/user_profile_screen.dart';
import '../../core/media_url_utils.dart';
import '../../core/offline_cache_service.dart';
import '../../widgets/feed/reel_product_overlay.dart';
import '../../widgets/feed/reel_widget.dart';
import '../../widgets/feed/comment_bottom_sheet.dart';
import '../../widgets/feed/menu_bottom_sheet.dart';

class ReelsScreen extends StatefulWidget {
  final bool isActive;

  const ReelsScreen({super.key, required this.isActive});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  int _feedTab = 1;
  List<ReelData> _reels = [];
  bool _loading = true;
  String? _error;
  String? _currentUserId;
  final Set<String> _followedAuthors = {};

  @override
  void initState() {
    super.initState();
    _hydrateFromCache();
    _loadReels(silent: _reels.isNotEmpty);
  }

  void _hydrateFromCache() {
    final cached = OfflineCacheService.getJsonList('reels_p1_l20');
    if (cached == null || cached.isEmpty) return;
    _reels = cached
        .map((p) => _postToReel(PostModel.fromApi(p)))
        .where((r) => r.videoUrl.isNotEmpty)
        .toList();
    _loading = _reels.isEmpty;
  }

  Future<void> _loadReels({bool silent = false}) async {
    if (!silent || _reels.isEmpty) {
      if (_reels.isEmpty) {
        setState(() {
          _loading = true;
          _error = null;
        });
      }
    }
    try {
      final me = await UserService.getMe();
      final posts = await PostsService.getReels(limit: 20);
      if (!mounted) return;
      setState(() {
        _currentUserId = me.id;
        _reels = posts.map(_postToReel).where((r) => r.videoUrl.isNotEmpty).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        if (_reels.isEmpty) _error = PostsService.errorMessage(e);
      });
    }
  }

  ReelData _postToReel(PostModel post) {
    final videoUrl = post.images.isNotEmpty ? post.images.first : '';
    return ReelData(
      reelUid: post.id,
      authorUserId: post.userId,
      authorName: post.user,
      isAuthorVerified: false,
      isOwnPost: _currentUserId != null && post.userId == _currentUserId,
      isFollowing: _followedAuthors.contains(post.userId),
      videoUrl: videoUrl,
      thumbnailUrl: videoUrl,
      caption: post.displayCaption,
      likeCount: post.likes,
      commentCount: post.comments,
      shareCount: post.shareCount,
      isLiked: post.liked,
    );
  }

  void _onAuthorTap(ReelData reel) {
    if (reel.authorUserId.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(userId: reel.authorUserId),
      ),
    );
  }

  Future<void> _onFollow(ReelData reel) async {
    if (reel.authorUserId.isEmpty) return;
    final isFollowing = _followedAuthors.contains(reel.authorUserId);
    setState(() {
      if (isFollowing) {
        _followedAuthors.remove(reel.authorUserId);
      } else {
        _followedAuthors.add(reel.authorUserId);
      }
    });
    try {
      if (isFollowing) {
        await FollowService.unfollow(reel.authorUserId);
      } else {
        await FollowService.follow(reel.authorUserId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        if (isFollowing) {
          _followedAuthors.add(reel.authorUserId);
        } else {
          _followedAuthors.remove(reel.authorUserId);
        }
      });
    }
  }

  void _onComment(ReelData reel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsBottomSheet(
        postUid: reel.reelUid,
        authorName: reel.authorName,
      ),
    );
  }

  void _onShare(ReelData reel) {
    debugPrint('Share: ${reel.reelUid}');
  }

  void _onMenu(ReelData reel) {
    showPostMenuBottomSheet(
      context,
      authorName: reel.authorName,
      isOwnPost: reel.isOwnPost,
      onDelete: () => debugPrint('Delete ${reel.reelUid}'),
    );
  }

  void _openNewReel() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NewReelReviewScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _feedTabButton('Following', 0),
            const SizedBox(width: 24),
            _feedTabButton('For You', 1),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.camera, color: Colors.white),
            onPressed: _openNewReel,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 12),
                      TextButton(onPressed: _loadReels, child: const Text('Retry')),
                    ],
                  ),
                )
              : _reels.isEmpty
                  ? const Center(
                      child: Text(
                        'No reels yet',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    )
                  : PageView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: _reels.length,
                      itemBuilder: (context, index) {
                        final reel = _reels[index];
                        return SingleReelPage(
                          key: ValueKey(reel.reelUid),
                          reel: reel,
                          isActive: widget.isActive,
                          onAuthorTap: () => _onAuthorTap(reel),
                          onFollow: () => _onFollow(reel),
                          onComment: () => _onComment(reel),
                          onShare: () => _onShare(reel),
                          onMenu: () => _onMenu(reel),
                        );
                      },
                    ),
    );
  }

  Widget _feedTabButton(String label, int index) {
    final selected = _feedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _feedTab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white54,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 28,
            color: selected ? Colors.white : Colors.transparent,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SingleReelPage  —  one full-screen reel
// ─────────────────────────────────────────────────────────────────────────────
class SingleReelPage extends StatefulWidget {
  final ReelData reel;
  final bool isActive;
  final VoidCallback onAuthorTap;
  final VoidCallback onFollow;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onMenu;

  const SingleReelPage({
    super.key,
    required this.reel,
    required this.isActive,
    required this.onAuthorTap,
    required this.onFollow,
    required this.onComment,
    required this.onShare,
    required this.onMenu,
  });

  @override
  State<SingleReelPage> createState() => _SingleReelPageState();
}

class _SingleReelPageState extends State<SingleReelPage> {
  late VideoPlayerController _ctrl;
  bool _initialized = false;
  bool _showPlayIcon = false;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(
      Uri.parse(widget.reel.videoUrl),
    )..initialize().then((_) {
        if (!mounted) return;
        setState(() => _initialized = true);
        if (widget.isActive) {
          _ctrl.play();
          _ctrl.setLooping(true);
        }
      });
  }

  @override
  void didUpdateWidget(SingleReelPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_initialized) return;

    if (!widget.isActive && _ctrl.value.isPlaying) {
      _ctrl.pause();
    } else if (widget.isActive && !_ctrl.value.isPlaying && !_isPaused) {
      _ctrl.play();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_initialized) return;
    setState(() {
      if (_ctrl.value.isPlaying) {
        _ctrl.pause();
        _isPaused = true;
        _showPlayIcon = true;
      } else {
        _ctrl.play();
        _isPaused = false;
        _showPlayIcon = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) setState(() => _showPlayIcon = false);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reel = widget.reel;
    final bottomInset = reel.hasProduct || reel.bannerTitle != null ? 88.0 : 24.0;

    return GestureDetector(
      onTap: _togglePlay,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _initialized
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _ctrl.value.aspectRatio,
                    child: VideoPlayer(_ctrl),
                  ),
                )
              : (reel.thumbnailUrl != null && MediaUrlUtils.isImageUrl(reel.thumbnailUrl!)
                  ? Image.network(reel.thumbnailUrl!, fit: BoxFit.cover)
                  : const ColoredBox(color: Colors.black)),

          if (!_initialized)
            const Center(
              child: CircularProgressIndicator(color: Colors.white54),
            ),

          if (_isPaused)
            Center(
              child: AnimatedOpacity(
                opacity: _isPaused ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Color(0xBB000000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.55, 1.0],
                ),
              ),
            ),
          ),

          Positioned(
            right: 12,
            bottom: bottomInset + 56,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: ReelSidebarWidget(
                initialLikeCount: reel.likeCount,
                commentCount: reel.commentCount,
                shareCount: reel.shareCount,
                initiallyLiked: reel.isLiked,
                onComment: widget.onComment,
                onShare: widget.onShare,
                onMenu: widget.onMenu,
              ),
            ),
          ),

          Positioned(
            bottom: bottomInset,
            left: 14,
            right: 72,
            child: GestureDetector(
              onTap: () {},
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ReelAuthorWidget(
                    authorName: reel.authorName,
                    authorAvatarUrl: reel.authorAvatarUrl,
                    isAuthorVerified: reel.isAuthorVerified,
                    isFollowing: reel.isFollowing,
                    onAuthorTap: widget.onAuthorTap,
                    onFollowTap: widget.onFollow,
                  ),
                  const SizedBox(height: 10),
                  ReelCaptionWidget(
                    authorName: reel.authorName,
                    caption: reel.caption,
                    musicTitle: reel.musicTitle,
                  ),
                ],
              ),
            ),
          ),

          if (reel.hasProduct)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: ReelProductOverlay.product(
                productName: reel.productName!,
                productPrice: reel.productPrice!,
                productImage: reel.productImage!,
                earnAmount: reel.earnAmount,
                onBuyNow: () {},
              ),
            )
          else if (reel.bannerTitle != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: ReelProductOverlay.banner(
                bannerTitle: reel.bannerTitle!,
                bannerSubtitle: reel.bannerSubtitle ?? '',
                bannerImage: reel.bannerImage,
                onBannerTap: () {},
              ),
            ),

          if (_initialized)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                _ctrl,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Colors.white,
                  bufferedColor: Colors.white38,
                  backgroundColor: Colors.white12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
