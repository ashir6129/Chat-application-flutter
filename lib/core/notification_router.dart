import 'package:flutter/material.dart';
import '../api_services/post_services.dart';
import '../boxes/box_requests_screen.dart';
import '../screens/user_profile_screen/user_profile_screen.dart';
import '../widgets/feed/feed_photo_viewer.dart';
import '../widgets/feed/feed_sheets.dart';
import 'app_navigator.dart';

void handleNotificationRouting({
  required String type,
  required Map<String, dynamic> data,
}) async {
  final context = rootNavigatorKey.currentContext;
  final navState = rootNavigatorKey.currentState;
  if (navState == null || context == null) return;

  if (type == 'like' || type == 'comment' || type == 'comment_like') {
    final postId = data['post_id'] ?? data['postId'];
    if (postId == null) return;

    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0F6E56)),
        ),
      ),
    );

    try {
      final post = await PostsService.getPost(postId.toString());
      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading dialog
      }

      if (post.images.isNotEmpty) {
        navState.push(
          MaterialPageRoute(
            builder: (_) => FeedPhotoViewer(
              photos: post.images,
              initialIndex: 0,
              post: FeedPhotoViewerPost(
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
          ),
        );
      } else {
        if (context.mounted) {
          showFeedCommentsSheet(
            context,
            postUid: post.id,
            authorName: post.user,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load post: $e')),
        );
      }
    }
  } else if (type == 'follow') {
    final followerId = data['follower_id'] ?? data['followerId'];
    if (followerId != null) {
      navState.push(
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(userId: followerId.toString()),
        ),
      );
    }
  } else if (type == 'box_request') {
    navState.push(
      MaterialPageRoute(
        builder: (_) => const BoxRequestsScreen(initialTab: 0),
      ),
    );
  } else if (type == 'box_status') {
    navState.push(
      MaterialPageRoute(
        builder: (_) => const BoxRequestsScreen(initialTab: 1),
      ),
    );
  }
}
