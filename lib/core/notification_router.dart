import 'package:flutter/material.dart';
import '../api_services/post_services.dart';
import '../boxes/box_requests_screen.dart';
import '../screens/user_profile_screen/user_profile_screen.dart';
import '../screens/message_screen/main_message_screen/personal_chat_screen.dart';
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

  // Post-related notifications
  if (type == 'like' || type == 'comment' || type == 'comment_like' || 
      type == 'mention' || type == 'tag' || type == 'post_share' || 
      type == 'new_post_from_following' || type == 'trending_post') {
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
  } 
  // Follow-related notifications
  else if (type == 'follow' || type == 'follow_request') {
    final followerId = data['follower_id'] ?? data['followerId'] ?? data['actor_id'];
    if (followerId != null) {
      navState.push(
        MaterialPageRoute(
          builder: (_) => UserProfileScreen(userId: followerId.toString()),
        ),
      );
    }
  } 
  // Message-related notifications
  else if (type == 'message' || type == 'group_message' || 
           type == 'message_voice' || type == 'message_photo' || 
           type == 'message_video' || type == 'message_reel' || 
           type == 'message_mention' || type == 'message_reply' || 
           type == 'message_reaction') {
    final conversationId = data['conversation_id'] ?? data['chat_id'];
    if (conversationId != null) {
      navState.push(
        MaterialPageRoute(
          builder: (_) => PersonalChatScreen(
            conversationId: conversationId.toString(),
          ),
        ),
      );
    }
  }
  // Call-related notifications
  else if (type == 'voice_call' || type == 'video_call' || type == 'missed_call') {
    final callerId = data['caller_id'] ?? data['actor_id'];
    if (callerId != null) {
      // Navigate to chat with the caller
      navState.push(
        MaterialPageRoute(
          builder: (_) => PersonalChatScreen(
            userId: callerId.toString(),
          ),
        ),
      );
    }
  }
  // Box-related notifications
  else if (type == 'box_request') {
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
