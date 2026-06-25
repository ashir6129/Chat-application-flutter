import '../core/media_url_utils.dart';

class UserProfileStats {
  final int posts;
  final int followers;
  final int following;

  const UserProfileStats({
    this.posts = 0,
    this.followers = 0,
    this.following = 0,
  });

  factory UserProfileStats.fromApi(Map<String, dynamic>? json) {
    if (json == null) return const UserProfileStats();
    return UserProfileStats(
      posts: json['posts'] as int? ?? 0,
      followers: json['followers'] as int? ?? 0,
      following: json['following'] as int? ?? 0,
    );
  }
}

class UserProfile {
  final String id;
  final String username;
  final String? email;
  final String? avatarUrl;
  final bool isVerified;
  final bool isSpotlight;
  final String bio;
  final String? location;
  final String? website;
  final UserProfileStats stats;
  final bool isFollowing;
  final bool isOnline;
  final DateTime? lastSeenAt;
  final String? boxStatus;
  final String? boxSenderId;
  final String? boxRequestId;

  const UserProfile({
    required this.id,
    required this.username,
    this.email,
    this.avatarUrl,
    this.isVerified = false,
    this.isSpotlight = false,
    this.bio = '',
    this.location,
    this.website,
    this.stats = const UserProfileStats(),
    this.isFollowing = false,
    this.isOnline = false,
    this.lastSeenAt,
    this.boxStatus,
    this.boxSenderId,
    this.boxRequestId,
  });

  factory UserProfile.fromApi(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString(),
      avatarUrl: MediaUrlUtils.resolveUrl(json['avatar_url']?.toString()),
      isVerified: json['is_verified'] == true,
      isSpotlight: json['is_spotlight'] == true,
      bio: json['bio']?.toString() ?? '',
      location: json['location']?.toString(),
      website: json['website']?.toString(),
      stats: UserProfileStats.fromApi(json['stats'] as Map<String, dynamic>?),
      isFollowing: json['is_following'] == true,
      isOnline: json['is_online'] == true,
      lastSeenAt: DateTime.tryParse(json['last_seen_at']?.toString() ?? ''),
      boxStatus: json['box_status']?.toString(),
      boxSenderId: json['box_sender_id']?.toString(),
      boxRequestId: json['box_request_id']?.toString(),
    );
  }

  UserProfile copyWith({
    UserProfileStats? stats,
    bool? isFollowing,
    bool? isOnline,
    DateTime? lastSeenAt,
    String? boxStatus,
    String? boxSenderId,
    String? boxRequestId,
  }) {
    return UserProfile(
      id: id,
      username: username,
      email: email,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      isSpotlight: isSpotlight,
      bio: bio,
      location: location,
      website: website,
      stats: stats ?? this.stats,
      isFollowing: isFollowing ?? this.isFollowing,
      isOnline: isOnline ?? this.isOnline,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      boxStatus: boxStatus ?? this.boxStatus,
      boxSenderId: boxSenderId ?? this.boxSenderId,
      boxRequestId: boxRequestId ?? this.boxRequestId,
    );
  }

  String get displayName {
    if (username.isEmpty) return 'User';
    return username
        .split('_')
        .where((p) => p.isNotEmpty)
        .map((p) => p[0].toUpperCase() + p.substring(1))
        .join(' ');
  }

  String get initials {
    final parts = username.split('_').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
