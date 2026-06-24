import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../core/app_colors.dart';
import '../../core/media_url_utils.dart';
import 'feed_action_bar.dart';
import 'feed_sheets.dart';
import 'feed_video_preview.dart';

class FeedPhotoViewerProduct {
  final String name;
  final double price;
  final String imageUrl;
  final String currency;

  const FeedPhotoViewerProduct({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.currency = '₹',
  });
}

class FeedPhotoViewerPost {
  final String postId;
  final String authorName;
  final String? authorId;
  final Color authorColor;
  final String? authorAvatarUrl;
  final String caption;
  final String distance;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool liked;
  final FeedPhotoViewerProduct? product;

  const FeedPhotoViewerPost({
    required this.postId,
    required this.authorName,
    this.authorId,
    required this.authorColor,
    this.authorAvatarUrl,
    required this.caption,
    required this.distance,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.liked,
    this.product,
  });
}

/// Full-screen swipeable photo viewer with post details pinned below the image.
class FeedPhotoViewer extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;
  final FeedPhotoViewerPost? post;

  const FeedPhotoViewer({
    super.key,
    required this.photos,
    required this.initialIndex,
    this.post,
  });

  @override
  State<FeedPhotoViewer> createState() => _FeedPhotoViewerState();
}

class _FeedPhotoViewerState extends State<FeedPhotoViewer> {
  late final PageController _pageController;
  late int _currentIndex;
  late bool _liked;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _liked = widget.post?.liked ?? false;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  String _formatPrice(double price, String currency) {
    final whole = price.round().toString();
    if (whole.length <= 3) return '$currency $whole';
    final last3 = whole.substring(whole.length - 3);
    var rest = whole.substring(0, whole.length - 3);
    final groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    return '$currency ${groups.join(',')},$last3';
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  int _displayLikeCount(FeedPhotoViewerPost post) {
    if (_liked && !post.liked) return post.likeCount + 1;
    if (!_liked && post.liked) return (post.likeCount - 1).clamp(0, 999999999);
    return post.likeCount;
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final accent = AppColors.buttonColor(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 24),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                  ),
                  const Spacer(),
                  if (widget.photos.length > 1)
                    Text(
                      '${_currentIndex + 1} / ${widget.photos.length}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.photos.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (context, index) {
                  final url = widget.photos[index];
                  if (MediaUrlUtils.isVideoUrl(url)) {
                    return Center(
                      child: FeedVideoPreview(videoUrl: url),
                    );
                  }
                  return InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 3.5,
                    child: Image.network(
                      widget.photos[index],
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white38,
                        size: 48,
                      ),
                    ),
                  );
                },
              ),
            ),

            if (post != null) _buildDetailsPanel(context, post, accent),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsPanel(
    BuildContext context,
    FeedPhotoViewerPost post,
    Color accent,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondaryBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: post.authorColor.withOpacity(0.18),
                  backgroundImage: post.authorAvatarUrl != null
                      ? NetworkImage(post.authorAvatarUrl!)
                      : null,
                  child: post.authorAvatarUrl == null
                      ? Text(
                          _initials(post.authorName),
                          style: TextStyle(
                            color: post.authorColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    post.authorName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryText(context),
                    ),
                  ),
                ),
              ],
            ),

            if (post.caption.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                post.caption,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.secondaryText(context),
                ),
              ),
            ],

            const SizedBox(height: 12),
            FeedPostActionBar(
              likeButton: FeedActionButton(
                icon: _liked ? Iconsax.heart5 : Iconsax.heart,
                label: _formatCount(_displayLikeCount(post)),
                color: _liked
                    ? const Color(0xFFE24B4A)
                    : FeedActionBarStyle.inactive(context),
                onTap: () => setState(() => _liked = !_liked),
              ),
              commentLabel: _formatCount(post.commentCount),
              onComment: () => showFeedCommentsSheet(
                context,
                postUid: post.postId,
                authorName: post.authorName,
              ),
              onShare: () => showFeedShareSheet(
                context,
                postUid: post.postId,
                authorName: post.authorName,
              ),
              onTip: post.authorId == null
                  ? null
                  : () => showFeedTipSheet(
                        context,
                        recipientId: post.authorId!,
                        authorName: post.authorName,
                        postId: post.postId,
                      ),
            ),

            if (post.product != null) ...[
              const SizedBox(height: 14),
              _buildProductCard(context, post, accent),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    FeedPhotoViewerPost post,
    Color accent,
  ) {
    final product = post.product!;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.primaryBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.borderLine(context).withOpacity(0.6),
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.imageUrl,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52,
                height: 52,
                color: AppColors.secondaryBackground(context),
                child: Icon(Iconsax.bag, color: AppColors.mutedText(context), size: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText(context),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_formatPrice(product.price, product.currency)} • ${post.distance} away',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'Buy',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
