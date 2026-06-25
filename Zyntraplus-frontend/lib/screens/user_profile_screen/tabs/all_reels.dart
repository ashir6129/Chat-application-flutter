import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../core/app_colors.dart';

class UserAllReelsTab extends StatelessWidget {
  const UserAllReelsTab({super.key});

  static const List<_ReelData> _reels = [
    _ReelData(
      thumbnail: 'https://picsum.photos/seed/r1/400/600',
      views: '12.4K',
      duration: '0:32',
    ),
    _ReelData(
      thumbnail: 'https://picsum.photos/seed/r2/400/600',
      views: '8.1K',
      duration: '1:04',
    ),
    _ReelData(
      thumbnail: 'https://picsum.photos/seed/r3/400/600',
      views: '3.7K',
      duration: '0:18',
    ),
    _ReelData(
      thumbnail: 'https://picsum.photos/seed/r4/400/600',
      views: '21.9K',
      duration: '0:45',
    ),
    _ReelData(
      thumbnail: 'https://picsum.photos/seed/r5/400/600',
      views: '5.2K',
      duration: '1:12',
    ),
    _ReelData(
      thumbnail: 'https://picsum.photos/seed/r6/400/600',
      views: '9.8K',
      duration: '0:27',
    ),
    _ReelData(
      thumbnail: 'https://picsum.photos/seed/r7/400/600',
      views: '1.3K',
      duration: '0:55',
    ),
    _ReelData(
      thumbnail: 'https://picsum.photos/seed/r8/400/600',
      views: '44.6K',
      duration: '0:14',
    ),
    _ReelData(
      thumbnail: 'https://picsum.photos/seed/r9/400/600',
      views: '7.0K',
      duration: '1:30',
    ),
  ];

  @override
  Widget build(BuildContext context) {
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
        childAspectRatio: 0.6, // portrait ratio for reels
      ),
      itemCount: _reels.length,
      itemBuilder: (context, index) {
        final reel = _reels[index];
        return GestureDetector(
          onTap: () => _openReel(context, index),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                reel.thumbnail,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.secondaryBackground(context),
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.mutedText(context),
                  ),
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
                      reel.views,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 6,
                right: 6,
                child: Text(
                  reel.duration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openReel(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ReelViewer(
          reels: _reels,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reel data model
// ─────────────────────────────────────────────────────────────────────────────
class _ReelData {
  final String thumbnail;
  final String views;
  final String duration;

  const _ReelData({
    required this.thumbnail,
    required this.views,
    required this.duration,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Full screen reel viewer — vertical swipe
// ─────────────────────────────────────────────────────────────────────────────
class _ReelViewer extends StatefulWidget {
  final List<_ReelData> reels;
  final int initialIndex;

  const _ReelViewer({
    required this.reels,
    required this.initialIndex,
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
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    reel.thumbnail,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const ColoredBox(
                      color: Colors.black,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white24,
                        size: 48,
                      ),
                    ),
                  ),

                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 180,
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
                    bottom: 32,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              reel.views,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.timer_outlined,
                                color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              reel.duration,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    right: 12,
                    bottom: 80,
                    child: Column(
                      children: [
                        _ReelAction(
                            icon: Iconsax.heart, label: '248'),
                        const SizedBox(height: 20),
                        _ReelAction(
                            icon: Iconsax.message, label: '34'),
                        const SizedBox(height: 20),
                        _ReelAction(
                            icon: Iconsax.send_2, label: 'Share'),
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