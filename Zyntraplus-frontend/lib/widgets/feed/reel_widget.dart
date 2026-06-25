import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ReelData model
// ─────────────────────────────────────────────────────────────────────────────
class ReelData {
  final String reelUid;
  final String authorUserId;
  final String authorName;
  final String? authorAvatarUrl;
  final bool isAuthorVerified;
  final bool isFollowing;
  final bool isOwnPost;
  final String videoUrl;
  final String? thumbnailUrl;
  final String caption;
  final String? musicTitle;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final bool isLiked;
  final String? productName;
  final String? productPrice;
  final String? productImage;
  final String? earnAmount;
  final String? bannerTitle;
  final String? bannerSubtitle;
  final String? bannerImage;

  const ReelData({
    required this.reelUid,
    required this.authorUserId,
    required this.authorName,
    this.authorAvatarUrl,
    this.isAuthorVerified = false,
    this.isFollowing = false,
    this.isOwnPost = false,
    required this.videoUrl,
    this.thumbnailUrl,
    this.caption = '',
    this.musicTitle,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.isLiked = false,
    this.productName,
    this.productPrice,
    this.productImage,
    this.earnAmount,
    this.bannerTitle,
    this.bannerSubtitle,
    this.bannerImage,
  });

  bool get hasProduct =>
      productName != null && productPrice != null && productImage != null;
}

// ─────────────────────────────────────────────────────────────────────────────
// ReelAuthorWidget
// ─────────────────────────────────────────────────────────────────────────────
class ReelAuthorWidget extends StatelessWidget {
  final String authorName;
  final String? authorAvatarUrl;
  final bool isAuthorVerified;
  final bool isFollowing;
  final VoidCallback onAuthorTap;
  final VoidCallback onFollowTap;

  const ReelAuthorWidget({
    super.key,
    required this.authorName,
    this.authorAvatarUrl,
    this.isAuthorVerified = false,
    this.isFollowing = false,
    required this.onAuthorTap,
    required this.onFollowTap,
  });

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAuthorTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          CircleAvatar(
            radius: 17,
            backgroundImage: authorAvatarUrl != null
                ? NetworkImage(authorAvatarUrl!)
                : null,
            backgroundColor: Colors.white24,
            child: authorAvatarUrl == null
                ? Text(
              _initials(authorName),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            )
                : null,
          ),
          const SizedBox(width: 8),

          // Name + verified
          Text(
            authorName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isAuthorVerified) ...[
            const SizedBox(width: 4),
            const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
          ],
          const SizedBox(width: 10),

          // Follow / Following button
          if (!isFollowing)
            GestureDetector(
              onTap: onFollowTap,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white70),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Follow',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ReelSidebarWidget  (right-side action column)
// ─────────────────────────────────────────────────────────────────────────────
class ReelSidebarWidget extends StatefulWidget {
  final int initialLikeCount;
  final int commentCount;
  final int shareCount;
  final bool initiallyLiked;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onMenu;

  const ReelSidebarWidget({
    super.key,
    required this.initialLikeCount,
    required this.commentCount,
    required this.shareCount,
    this.initiallyLiked = false,
    required this.onComment,
    required this.onShare,
    required this.onMenu,
  });

  @override
  State<ReelSidebarWidget> createState() => _ReelSidebarWidgetState();
}

class _ReelSidebarWidgetState extends State<ReelSidebarWidget>
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
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _heartCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _liked = !_liked;
      _likeCount += _liked ? 1 : -1;
    });
    if (_liked) _heartCtrl.forward(from: 0);
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Like
        ScaleTransition(
          scale: _heartScale,
          child: _SidebarAction(
            icon: _liked ? Iconsax.heart5 : Iconsax.heart,
            label: _fmt(_likeCount),
            color: _liked ? const Color(0xFFE24B4A) : Colors.white,
            onTap: _toggleLike,
          ),
        ),
        const SizedBox(height: 20),

        // Comment
        _SidebarAction(
          icon: Iconsax.message,
          label: _fmt(widget.commentCount),
          color: Colors.white,
          onTap: widget.onComment,
        ),
        const SizedBox(height: 20),

        // Share
        _SidebarAction(
          icon: Iconsax.export_3,
          label: _fmt(widget.shareCount),
          color: Colors.white,
          onTap: widget.onShare,
        ),
        const SizedBox(height: 20),

        // 3-dot menu
        _SidebarAction(
          icon: Icons.more_vert,
          label: '',
          color: Colors.white,
          onTap: widget.onMenu,
        ),
      ],
    );
  }
}

class _SidebarAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SidebarAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ReelCaptionWidget  (bottom-left text block)
// ─────────────────────────────────────────────────────────────────────────────
class ReelCaptionWidget extends StatefulWidget {
  final String authorName;
  final String caption;
  final String? musicTitle;

  const ReelCaptionWidget({
    super.key,
    required this.authorName,
    required this.caption,
    this.musicTitle,
  });

  @override
  State<ReelCaptionWidget> createState() => _ReelCaptionWidgetState();
}

class _ReelCaptionWidgetState extends State<ReelCaptionWidget> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.caption.isNotEmpty)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.authorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.45,
                  ),
                ),

                Text(
                  widget.caption,
                  maxLines: _expanded ? null : 2,
                  overflow: _expanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),

        if (widget.musicTitle != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Iconsax.music,
                  color: Colors.white70, size: 13),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.musicTitle!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}