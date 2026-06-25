import 'package:flutter/material.dart';
import 'package:zyntraplus/screens/home_screen/whats_on_your_mind.dart';
import 'package:zyntraplus/screens/user_profile_screen/user_profile_screen.dart';
import 'package:zyntraplus/widgets/feed/post_widget.dart';
import '../../../../core/app_colors.dart';
import '../../widgets/feed/feed_sheets.dart';
import 'rejected_story_widget.dart';
import '../../widgets/feed/menu_bottom_sheet.dart';
enum PostType { image, video, product }

class PostData {
  final String postUid;
  final PostType postType;
  final String postCreatedAt;

  // Author info
  final String authorName;
  final String? authorId;
  final String? authorProfileImagePath;
  final bool isAuthorVerified;
  final bool isFollowing;
  final bool isOwnPost;

  // Post text
  final String caption;

  // Engagement data
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;

  // Media
  final String? imagePath;
  final String? videoPath;
  final String? thumbnailPath;
  final String? videoDuration;

  // Product
  final String? productName;
  final double? productPrice;
  final String? productImagePath;
  final String productCurrency;
  final int? productStock;
  final String? distance;

  const PostData({
    required this.postUid,
    required this.postType,
    required this.postCreatedAt,
    required this.authorName,
    this.authorId,
    this.authorProfileImagePath,
    this.isAuthorVerified = false,
    this.isFollowing = false,
    this.isOwnPost = false,
    this.caption = '',
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.imagePath,
    this.videoPath,
    this.thumbnailPath,
    this.videoDuration,
    this.productName,
    this.productPrice,
    this.productImagePath,
    this.productCurrency = '₹',
    this.productStock,
    this.distance,
  });

  bool get isImage => postType == PostType.image;
  bool get isVideo => postType == PostType.video;
  bool get isProduct => postType == PostType.product;
}

class RejectedHomeScreen extends StatefulWidget {
  const RejectedHomeScreen({super.key});

  @override
  State<RejectedHomeScreen> createState() => _RejectedHomeScreenState();
}

class _RejectedHomeScreenState extends State<RejectedHomeScreen> {
  final List<StoryModel> _stories = const [
    StoryModel(uid: '1', name: 'Aman', seen: false),
    StoryModel(uid: '2', name: 'Riya', seen: false),
    StoryModel(uid: '3', name: 'Rahul', seen: true),
    StoryModel(uid: '4', name: 'Priya', seen: false),
    StoryModel(uid: '5', name: 'Dev', seen: true),
    StoryModel(uid: '6', name: 'Sara', seen: false),
  ];

  final List<PostData> _posts = const [
    PostData(
      postUid: 'p1',
      postType: PostType.image,
      authorName: 'Sara R',
      isAuthorVerified: false,
      postCreatedAt: '2 minutes ago',
      imagePath: 'https://picsum.photos/seed/z1/600/400',
      caption: 'Beautiful sunset at the ghats today!',
      likeCount: 248,
      commentCount: 34,
      shareCount: 12,
      isLiked: true,
      authorProfileImagePath: 'https://i.pinimg.com/736x/92/ee/20/92ee20d33b262d046946cf886ff9b569.jpg',
      distance: '0.3 km away',
    ),
    PostData(
      postUid: 'p2',
      postType: PostType.video,
      authorName: 'Aman K',
      postCreatedAt: '15 minutes ago',
      thumbnailPath: 'https://picsum.photos/seed/z2/600/400',
      videoDuration: '2:34',
      caption: 'Caught the whole sunset on cam 🎥 watch till the end!',
      likeCount: 512,
      commentCount: 78,
      shareCount: 31,
      authorProfileImagePath: 'https://i.pinimg.com/736x/92/ee/20/92ee20d33b262d046946cf886ff9b569.jpg',
    ),
    PostData(
      postUid: 'p3',
      postType: PostType.product,
      authorName: 'Priya M',
      isAuthorVerified: true,
      postCreatedAt: '1 hour ago',
      productName: 'Handcrafted Bamboo Lamp — Natural Edition',
      productPrice: 1299.00,
      productImagePath: 'https://picsum.photos/seed/z3/600/400',
      productStock: 5,
      caption: 'Made these by hand! Perfect for your desk 🌿',
      likeCount: 91,
      commentCount: 14,
      shareCount: 7,
      authorProfileImagePath: 'https://i.pinimg.com/736x/92/ee/20/92ee20d33b262d046946cf886ff9b569.jpg',
    ),
  ];

  // ─────────────────────────────────────────────
  // Handlers
  // ─────────────────────────────────────────────

  void _onAuthorTap(PostData post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserProfileScreen(userId: '',),
      ),
    );
  }

  void _onMenuTap(PostData post) {
    showPostMenuBottomSheet(
      context,
      authorName: post.authorName,
      isOwnPost: post.isOwnPost,
      onDelete: () {
        debugPrint('Delete ${post.postUid}');
      },
    );
  }

  void _onComment(PostData post) {
    showFeedCommentsSheet(
      context,
      postUid: post.postUid,
      authorName: post.authorName,
    );
  }

  void _onShare(PostData post) {
    showFeedShareSheet(
      context,
      postUid: post.postUid,
      authorName: post.authorName,
    );
  }

  void _onTip(PostData post) {
    if (post.authorId == null || post.authorId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tips work on live feed posts with real creators')),
      );
      return;
    }
    showFeedTipSheet(
      context,
      recipientId: post.authorId!,
      authorName: post.authorName,
      postId: post.postUid,
    );
  }

  void _onVideoTap(PostData post) {
    debugPrint('Play video ${post.postUid}');
  }

  void _onBuyNow(PostData post) {
    debugPrint('Buy ${post.productName}');
  }

  // ─────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground(context),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.buttonColor(context),
        child: ListView(
          children: [
            StoryWidget(stories: _stories),
            WhatsOnYourMind(),
            Divider(height: 2, thickness: 1, color: AppColors.borderLine(context)),
            ..._posts.map(_buildPostItem),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildPostItem(PostData post) {
    switch (post.postType) {
      case PostType.image:
        return ImageWidget(
          key: ValueKey(post.postUid),
          post: post,
          onAuthorTap: () => _onAuthorTap(post),
          onMenuTap: () => _onMenuTap(post), // ✅ added
          onComment: () => _onComment(post),
          onShare: () => _onShare(post),
          onTip: () => _onTip(post),
        );

      case PostType.video:
        return VideoWidget(
          key: ValueKey(post.postUid),
          post: post,
          onAuthorTap: () => _onAuthorTap(post),
          onMenuTap: () => _onMenuTap(post), // ✅ added
          onComment: () => _onComment(post),
          onShare: () => _onShare(post),
          onTip: () => _onTip(post),
          onVideoTap: () => _onVideoTap(post),
        );

      case PostType.product:
        return ProductWidget(
          key: ValueKey(post.postUid),
          post: post,
          onAuthorTap: () => _onAuthorTap(post),
          onMenuTap: () => _onMenuTap(post), // ✅ added
          onComment: () => _onComment(post),
          onShare: () => _onShare(post),
          onTip: () => _onTip(post),
          onBuyNow: () => _onBuyNow(post),
        );
    }
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}