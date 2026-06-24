import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../core/app_colors.dart';
import '../../screens/home_screen/rejected_home_screen.dart';
import 'feed_action_bar.dart';
import 'feed_caption_text.dart';
import 'feed_user_avatar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PostsAuthorWidget
// ─────────────────────────────────────────────────────────────────────────────
class PostsAuthorWidget extends StatelessWidget {
  final String authorName;
  final String? authorAvatarUrl;
  final bool isVerified;
  final String createdAt;
  final String? distance; // e.g. "0.3 km away"
  final String typeBadgeLabel;
  final Color typeBadgeBg;
  final Color typeBadgeFg;
  final Color? accentColor;
  final VoidCallback onAuthorTap;
  final VoidCallback onMenuTap;

  const PostsAuthorWidget({
    super.key,
    required this.authorName,
    this.authorAvatarUrl,
    this.isVerified = false,
    required this.createdAt,
    this.distance,
    this.accentColor,
    required this.typeBadgeLabel,
    required this.typeBadgeBg,
    required this.typeBadgeFg,
    required this.onAuthorTap,
    required this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? feedAccentColorForName(authorName);
    final locColor = AppColors.buttonColor(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onAuthorTap,
            child: FeedUserAvatar(
              name: authorName,
              accentColor: accent,
              imageUrl: authorAvatarUrl,
              size: 40,
              showBorder: false,
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: GestureDetector(
              onTap: onAuthorTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          authorName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText(context),
                            height: 1.15,
                            letterSpacing: -0.2,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.verified_rounded,
                          color: AppColors.verifiedBadge(context),
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),

                  Row(
                    children: [
                      if (distance != null) ...[
                        FeedNearbyIcon(
                          size: 11,
                          color: locColor,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          formatFeedDistance(distance),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: locColor,
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
                      ],
                      Text(
                        createdAt,
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

          GestureDetector(
            onTap: onMenuTap,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PostsStatsWidget
// ─────────────────────────────────────────────────────────────────────────────
class PostsStatsWidget extends StatefulWidget {
  final int initialLikeCount;
  final int commentCount;
  final int shareCount;
  final bool initiallyLiked;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback? onTip;
  /// When set, like state is controlled by parent (e.g. home feed).
  final bool? liked;
  final int? likeCount;
  final VoidCallback? onLikeOverride;

  const PostsStatsWidget({
    super.key,
    required this.initialLikeCount,
    required this.commentCount,
    required this.shareCount,
    this.initiallyLiked = false,
    required this.onComment,
    required this.onShare,
    this.onTip,
    this.liked,
    this.likeCount,
    this.onLikeOverride,
  });

  @override
  State<PostsStatsWidget> createState() => _PostsStatsWidgetState();
}

class _PostsStatsWidgetState extends State<PostsStatsWidget>
    with SingleTickerProviderStateMixin {
  late bool _liked;
  late int _likeCount;
  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _liked = widget.initiallyLiked;
    _likeCount = widget.initialLikeCount;
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _heartScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _toggleLike() {
    if (widget.onLikeOverride != null) {
      widget.onLikeOverride!();
      if (!(widget.liked ?? _liked)) _heartCtrl.forward(from: 0);
      return;
    }
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
    if (_liked) _heartCtrl.forward(from: 0);
  }

  bool get _isLiked => widget.liked ?? _liked;
  int get _displayLikeCount => widget.likeCount ?? _likeCount;

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final inactive = FeedActionBarStyle.inactive(context);

    return FeedPostActionBar(
      likeButton: ScaleTransition(
        scale: _heartScale,
        child: FeedActionButton(
          icon: _isLiked ? Iconsax.heart5 : Iconsax.heart,
          label: _fmt(_displayLikeCount),
          color: _isLiked ? const Color(0xFFE24B4A) : inactive,
          onTap: _toggleLike,
        ),
      ),
      commentLabel: _fmt(widget.commentCount),
      onComment: widget.onComment,
      onShare: widget.onShare,
      onTip: widget.onTip,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ImageWidget
// ─────────────────────────────────────────────────────────────────────────────
class ImageWidget extends StatelessWidget {
  final PostData post;
  final VoidCallback onAuthorTap;
  final VoidCallback onMenuTap;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onTip;

  const ImageWidget({
    super.key,
    required this.post,
    required this.onAuthorTap,
    required this.onMenuTap,
    required this.onComment,
    required this.onShare,
    required this.onTip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLine(context), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostsAuthorWidget(
            authorName: post.authorName,
            authorAvatarUrl: post.authorProfileImagePath,
            isVerified: post.isAuthorVerified,
            createdAt: post.postCreatedAt,
            typeBadgeLabel: 'Photo',
            typeBadgeBg: const Color(0xFFE6F1FB),
            typeBadgeFg: const Color(0xFF185FA5),
            onAuthorTap: onAuthorTap,
            onMenuTap: onMenuTap,
            distance: post.distance,
          ),

          if (post.caption.isNotEmpty)
            _Caption(authorName: post.authorName, caption: post.caption),

          if (post.imagePath != null)
            Image.network(
              post.imagePath!,
              width: double.infinity,
              height: 280,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  _Placeholder(icon: Iconsax.image, height: 280),
            )
          else
            _Placeholder(icon: Iconsax.image, height: 280),

          PostsStatsWidget(
            initialLikeCount: post.likeCount,
            commentCount: post.commentCount,
            shareCount: post.shareCount,
            initiallyLiked: post.isLiked,
            onComment: onComment,
            onShare: onShare,
            onTip: onTip,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VideoWidget
// ─────────────────────────────────────────────────────────────────────────────
class VideoWidget extends StatelessWidget {
  final PostData post;
  final VoidCallback onAuthorTap;
  final VoidCallback onMenuTap;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onTip;
  final VoidCallback onVideoTap;

  const VideoWidget({
    super.key,
    required this.post,
    required this.onAuthorTap,
    required this.onMenuTap,
    required this.onComment,
    required this.onShare,
    required this.onTip,
    required this.onVideoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLine(context), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostsAuthorWidget(
            authorName: post.authorName,
            authorAvatarUrl: post.authorProfileImagePath,
            isVerified: post.isAuthorVerified,
            createdAt: post.postCreatedAt,
            typeBadgeLabel: 'Video',
            typeBadgeBg: const Color(0xFFFBEAF0),
            typeBadgeFg: const Color(0xFF993556),
            onAuthorTap: onAuthorTap,
            onMenuTap: onMenuTap,
            distance: post.distance,
          ),

          if (post.caption.isNotEmpty)
            _Caption(authorName: post.authorName, caption: post.caption),

          GestureDetector(
            onTap: onVideoTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                post.thumbnailPath != null
                    ? Image.network(
                  post.thumbnailPath!,
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _Placeholder(icon: Iconsax.video, height: 280),
                )
                    : _Placeholder(icon: Iconsax.video, height: 280),

                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),

                if (post.videoDuration != null)
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        post.videoDuration!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          PostsStatsWidget(
            initialLikeCount: post.likeCount,
            commentCount: post.commentCount,
            shareCount: post.shareCount,
            initiallyLiked: post.isLiked,
            onComment: onComment,
            onShare: onShare,
            onTip: onTip,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProductWidget
// ─────────────────────────────────────────────────────────────────────────────
class ProductWidget extends StatelessWidget {
  final PostData post;
  final VoidCallback onAuthorTap;
  final VoidCallback onMenuTap;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onTip;
  final VoidCallback? onBuyNow;

  const ProductWidget({
    super.key,
    required this.post,
    required this.onAuthorTap,
    required this.onMenuTap,
    required this.onComment,
    required this.onShare,
    required this.onTip,
    this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    final bool outOfStock = post.productStock != null && post.productStock == 0;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderLine(context), width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostsAuthorWidget(
            authorName: post.authorName,
            authorAvatarUrl: post.authorProfileImagePath,
            isVerified: post.isAuthorVerified,
            createdAt: post.postCreatedAt,
            typeBadgeLabel: 'Product',
            typeBadgeBg: const Color(0xFFEAF3DE),
            typeBadgeFg: const Color(0xFF3B6D11),
            onAuthorTap: onAuthorTap,
            onMenuTap: onMenuTap,
            distance: post.distance,
          ),

          if (post.caption.isNotEmpty)
            _Caption(authorName: post.authorName, caption: post.caption),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryBackground(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.borderLine(context),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12)),
                    child: post.productImagePath != null
                        ? Image.network(
                      post.productImagePath!,
                      width: double.infinity,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _Placeholder(icon: Iconsax.bag, height: 220),
                    )
                        : _Placeholder(icon: Iconsax.bag, height: 220),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.productName ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText(context),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${post.productCurrency}${post.productPrice?.toStringAsFixed(2) ?? '0.00'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.buttonColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: outOfStock ? null : onBuyNow,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: outOfStock
                                  ? AppColors.mutedText(context)
                                  : AppColors.buttonColor(context),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              outOfStock ? 'Sold Out' : 'Buy Now',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          PostsStatsWidget(
            initialLikeCount: post.likeCount,
            commentCount: post.commentCount,
            shareCount: post.shareCount,
            initiallyLiked: post.isLiked,
            onComment: onComment,
            onShare: onShare,
            onTip: onTip,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private helpers
// ─────────────────────────────────────────────────────────────────────────────
class _Caption extends StatelessWidget {
  final String authorName;
  final String caption;

  const _Caption({required this.authorName, required this.caption});

  @override
  Widget build(BuildContext context) {
    return FeedCaptionText(
      caption: caption,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final IconData icon;
  final double height;

  const _Placeholder({required this.icon, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      color: AppColors.secondaryBackground(context),
      child: Center(
        child: Icon(icon, size: 36, color: AppColors.mutedText(context)),
      ),
    );
  }
}