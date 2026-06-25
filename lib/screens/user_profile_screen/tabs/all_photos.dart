import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class UserAllPhotosTab extends StatelessWidget {
  const UserAllPhotosTab({super.key});

  static const List<String> _photos = [
    'https://picsum.photos/seed/k1/400/400',
    'https://picsum.photos/seed/k2/400/400',
    'https://picsum.photos/seed/k3/400/400',
    'https://picsum.photos/seed/k4/400/400',
    'https://picsum.photos/seed/k5/400/400',
    'https://picsum.photos/seed/k6/400/400',
    'https://picsum.photos/seed/k7/400/400',
    'https://picsum.photos/seed/k8/400/400',
    'https://picsum.photos/seed/k9/400/400',
  ];

  @override
  Widget build(BuildContext context) {
    if (_photos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_outlined,
                size: 48, color: AppColors.mutedText(context)),
            const SizedBox(height: 12),
            Text(
              'No photos yet',
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
      ),
      itemCount: _photos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _openPhoto(context, index),
          child: Stack(
            fit: StackFit.expand,
            children: [

              Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                _photos[index],
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.secondaryBackground(context),
                  child: Icon(Icons.broken_image_outlined,
                      color: AppColors.mutedText(context)),
                ),
              ),

              Positioned(
                top: 6,
                right: 6,
                child: Icon(
                  Icons.photo_rounded,
                  color: Colors.white.withOpacity(0.85),
                  size: 14,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPhoto(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PhotoViewer(
          photos: _photos,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Full screen photo viewer
// ─────────────────────────────────────────────────────────────────────────────
class _PhotoViewer extends StatefulWidget {
  final List<String> photos;
  final int initialIndex;

  const _PhotoViewer({
    required this.photos,
    required this.initialIndex,
  });

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
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
            itemCount: widget.photos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 1.0,
                maxScale: 4.0,
                child: Center(
                  child: Image.network(headers: const {"ngrok-skip-browser-warning": "true"}, 
                    widget.photos[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white38,
                      size: 48,
                    ),
                  ),
                ),
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
                '${_currentIndex + 1} / ${widget.photos.length}',
                style: const TextStyle(
                  color: Colors.white60,
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