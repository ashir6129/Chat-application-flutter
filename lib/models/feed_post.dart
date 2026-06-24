import 'package:flutter/material.dart';

import '../core/media_edit_settings.dart';
import '../core/media_url_utils.dart';
import '../widgets/feed/feed_user_avatar.dart';
import 'poll_data.dart';

class FeedProductInfo {
  final String name;
  final double price;
  final String imageUrl;
  final String currency;
  final int? stock;

  const FeedProductInfo({
    required this.name,
    required this.price,
    required this.imageUrl,
    this.currency = '₦',
    this.stock,
  });
}

class FeedBannerInfo {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final String ctaLabel;

  const FeedBannerInfo({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.ctaLabel = 'Learn more',
  });
}

class PostModel {
  final String id;
  final String userId;
  final String user;
  final String dist;
  final String time;
  final String caption;
  final String postType;
  final List<String> images;
  final int likes;
  final int comments;
  final int shareCount;
  final bool liked;
  final Color color;
  final String? authorAvatarUrl;
  final FeedProductInfo? product;
  final FeedBannerInfo? banner;
  final List<MediaEditSettings> mediaMeta;
  final PollData? poll;
  final bool isArchived;

  const PostModel({
    required this.id,
    required this.userId,
    required this.user,
    required this.dist,
    required this.time,
    required this.caption,
    this.postType = 'text',
    required this.images,
    required this.likes,
    required this.comments,
    this.shareCount = 0,
    required this.liked,
    required this.color,
    this.authorAvatarUrl,
    this.product,
    this.banner,
    this.mediaMeta = const [],
    this.poll,
    this.isArchived = false,
  });

  bool get isPollPost => poll != null;

  String get displayCaption {
    if (poll == null) return caption;
    if (PollData.parseLegacyCaption(caption) != null) return '';
    return caption;
  }

  bool get isMixedMedia => postType == 'mixed';

  bool get isVideo => postType == 'video' || postType == 'reel';

  PostModel copyWith({
    int? likes,
    bool? liked,
    int? comments,
    String? caption,
    PollData? poll,
    bool? isArchived,
    String? authorAvatarUrl,
  }) {
    return PostModel(
      id: id,
      userId: userId,
      user: user,
      dist: dist,
      time: time,
      caption: caption ?? this.caption,
      postType: postType,
      images: images,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      shareCount: shareCount,
      liked: liked ?? this.liked,
      color: color,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      product: product,
      banner: banner,
      mediaMeta: mediaMeta,
      poll: poll ?? this.poll,
      isArchived: isArchived ?? this.isArchived,
    );
  }

  /// Sets [authorAvatarUrl], including `null` to clear the photo.
  PostModel withAuthorAvatar(String? avatarUrl) {
    return PostModel(
      id: id,
      userId: userId,
      user: user,
      dist: dist,
      time: time,
      caption: caption,
      postType: postType,
      images: images,
      likes: likes,
      comments: comments,
      shareCount: shareCount,
      liked: liked,
      color: color,
      authorAvatarUrl: avatarUrl,
      product: product,
      banner: banner,
      mediaMeta: mediaMeta,
      poll: poll,
      isArchived: isArchived,
    );
  }

  static PostModel fromApi(Map<String, dynamic> json) {
    final author = json['author'] as Map<String, dynamic>? ?? {};
    final username = author['username']?.toString() ?? 'User';
    final displayName = username.replaceAll('_', ' ');

    final media = (json['media_urls'] as List<dynamic>? ?? [])
        .map((e) => MediaUrlUtils.resolveUrl(e.toString()))
        .toList();

    final mediaMeta = (json['media_meta'] as List<dynamic>? ?? [])
        .map((e) => MediaEditSettings.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    final postMeta = json['post_meta'] as Map<String, dynamic>?;
    final poll = PollData.fromJson(postMeta?['poll'] as Map<String, dynamic>?)
        ?? PollData.parseLegacyCaption(json['caption']?.toString() ?? '');

    return PostModel(
      id: json['id']?.toString() ?? '',
      userId: author['id']?.toString() ?? json['user_id']?.toString() ?? '',
      user: displayName,
      dist: json['location']?.toString() ?? 'Nearby',
      time: json['time_ago']?.toString() ?? 'Just now',
      caption: json['caption']?.toString() ?? '',
      postType: json['post_type']?.toString() ?? 'text',
      images: media,
      likes: json['like_count'] as int? ?? 0,
      comments: json['comment_count'] as int? ?? 0,
      shareCount: json['share_count'] as int? ?? 0,
      liked: json['liked'] == true,
      color: _colorFromName(displayName),
      authorAvatarUrl: MediaUrlUtils.resolveUrl(author['avatar_url']?.toString()),
      mediaMeta: mediaMeta,
      poll: poll,
      isArchived: json['is_archived'] == true,
    );
  }

  static Color _colorFromName(String name) {
    return feedAccentColorForName(name);
  }
}
