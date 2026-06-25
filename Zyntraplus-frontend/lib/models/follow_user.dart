import '../core/media_url_utils.dart';

class FollowUser {
  final String id;
  final String username;
  final String? avatarUrl;
  final bool isVerified;
  final bool isFollowing;
  final bool followsViewer;
  final String? bio;

  const FollowUser({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.isVerified = false,
    this.isFollowing = false,
    this.followsViewer = false,
    this.bio,
  });

  factory FollowUser.fromApi(Map<String, dynamic> json) {
    return FollowUser(
      id: json['id']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
      avatarUrl: MediaUrlUtils.resolveUrl(json['avatar_url']?.toString()),
      isVerified: json['is_verified'] == true,
      isFollowing: json['is_following'] == true,
      followsViewer: json['follows_viewer'] == true,
      bio: json['bio']?.toString(),
    );
  }

  FollowUser copyWith({bool? isFollowing}) {
    return FollowUser(
      id: id,
      username: username,
      avatarUrl: avatarUrl,
      isVerified: isVerified,
      isFollowing: isFollowing ?? this.isFollowing,
      followsViewer: followsViewer,
      bio: bio,
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
