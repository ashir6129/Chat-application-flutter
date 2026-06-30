import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';
import '../../../../api_services/user_service.dart';
import '../../../../api_services/post_services.dart';
import '../../../../models/feed_post.dart';

class UserAllReelsTab extends StatefulWidget {
  final String? username;
  final bool isOwnProfile;

  const UserAllReelsTab({
    super.key,
    this.username,
    this.isOwnProfile = false,
  });

  @override
  State<UserAllReelsTab> createState() => _UserAllReelsTabState();
}

class _UserAllReelsTabState extends State<UserAllReelsTab> {
  List<PostModel> _reels = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReels();
  }

  Future<void> _loadReels() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final posts = widget.isOwnProfile
          ? await UserService.getMyPosts(type: 'reels', limit: 50)
          : await UserService.getUserPosts(widget.username!, type: 'reels', limit: 50);

      if (!mounted) return;
      setState(() {
        _reels = posts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Failed to load reels';
      });
    }
  }

  Future<void> _deleteReel(int index) async {
    final post = _reels[index];
    try {
      await PostsService.deletePost(post.id);
      if (!mounted) return;
      setState(() {
        _reels.removeAt(index);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete reel')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: TextStyle(color: AppColors.mutedText(context))),
            const SizedBox(height: 12),
            TextButton(onPressed: _loadReels, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_reels.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_outline_rounded,
              size: 48,
              color: AppColors.mutedText(context),
            ),
            const SizedBox(height: 12),
            Text(
              'No reels yet',
              style: TextStyle(
                color: AppColors.secondaryText(context),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1.5,
        mainAxisSpacing: 1.5,
        childAspectRatio: 0.6,
      ),
      itemCount: _reels.length,
      itemBuilder: (context, index) {
        final reel = _reels[index];
        final thumbnailUrl = reel.images.isNotEmpty ? reel.images.first : '';
        return GestureDetector(
          onTap: () => _openReel(context, index),
          onLongPress: widget.isOwnProfile ? () => _showDeleteDialog(index) : null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              thumbnailUrl.isNotEmpty
                  ? Image.network(
                      headers: const {"ngrok-skip-browser-warning": "true"},
                      thumbnailUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.secondaryBackground(context),
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.mutedText(context),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.secondaryBackground(context),
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.mutedText(context),
                      ),
                    ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 56,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black54],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Iconsax.play5,
                  color: Colors.white.withOpacity(0.9),
                  size: 16,
                ),
              ),

              Positioned(
                bottom: 6,
                left: 6,
                child: Row(
                  children: [
                    const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${reel.likes}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              if (widget.isOwnProfile)
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: () => _showDeleteDialog(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reel'),
        content: const Text('Are you sure you want to delete this reel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteReel(index);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openReel(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ReelViewer(
          reels: _reels,
          initialIndex: initialIndex,
          isOwnProfile: widget.isOwnProfile,
          onDelete: widget.isOwnProfile ? (index) => _deleteReel(index) : null,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full screen reel viewer — vertical swipe
// ─────────────────────────────────────────────────────────────────────────────
class _ReelViewer extends StatefulWidget {
  final List<PostModel> reels;
  final int initialIndex;
  final bool isOwnProfile;
  final Function(int)? onDelete;

  const _ReelViewer({
    required this.reels,
    required this.initialIndex,
    this.isOwnProfile = false,
    this.onDelete,
  });

  @override
  State<_ReelViewer> createState() => _ReelViewerState();
}

class _ReelViewerState extends State<_ReelViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.reels.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              final reel = widget.reels[index];
              final thumbnailUrl = reel.images.isNotEmpty ? reel.images.first : '';
              return Stack(
                fit: StackFit.expand,
                children: [
                  thumbnailUrl.isNotEmpty
                      ? Image.network(
                          headers: const {"ngrok-skip-browser-warning": "true"},
                          thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const ColoredBox(
                            color: Colors.black,
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white24,
                              size: 48,
                            ),
                          ),
                        )
                      : const ColoredBox(
                          color: Colors.black,
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white24,
                            size: 48,
                          ),
                        ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 200,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.transparent, Colors.black87],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: bottomPadding - 40,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reel.user,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          reel.caption,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${reel.likes}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    right: 12,
                    bottom: bottomPadding - 40,
                    child: Column(
                      children: [
                        _ReelAction(
                            icon: Iconsax.heart, label: '${reel.likes}'),
                        const SizedBox(height: 20),
                        _ReelAction(
                            icon: Iconsax.message, label: '${reel.comments}'),
                        const SizedBox(height: 20),
                        _ReelAction(
                            icon: Iconsax.share, label: 'Share'),
                        const SizedBox(height: 20),
                        if (widget.isOwnProfile && widget.onDelete != null)
                          GestureDetector(
                            onTap: () => _showDeleteDialog(index),
                            child: const Icon(
                              Icons.delete_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 14,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '${_currentIndex + 1} / ${widget.reels.length}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Reel'),
        content: const Text('Are you sure you want to delete this reel?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete?.call(index);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Right side action button in viewer
// ─────────────────────────────────────────────────────────────────────────────
class _ReelAction extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ReelAction({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}