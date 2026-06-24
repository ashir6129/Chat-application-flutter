import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/cached_image.dart';
import '../../core/image_filter_utils.dart';
import '../../core/media_edit_settings.dart';
import '../../core/media_url_utils.dart';
import 'feed_photo_viewer.dart';
import 'feed_video_preview.dart';

class FeedImageGrid extends StatefulWidget {
  final List<String> images;
  final FeedPhotoViewerPost? postInfo;
  final List<MediaEditSettings> mediaMeta;

  const FeedImageGrid({
    super.key,
    required this.images,
    this.postInfo,
    this.mediaMeta = const [],
  });

  @override
  State<FeedImageGrid> createState() => _FeedImageGridState();
}

class _FeedImageGridState extends State<FeedImageGrid> {
  late final PageController _pageController;
  int _currentPage = 0;
  double _aspectRatio = 1.0; // Default to square (1:1)

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _resolveFirstImageAspectRatio();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _resolveFirstImageAspectRatio() {
    if (widget.images.isEmpty) return;
    final url = widget.images.first;
    final resolvedUrl = MediaUrlUtils.resolveUrl(url);
    if (resolvedUrl.isEmpty) return;

    try {
      final imageProvider = appCachedImageProvider(url);
      final stream = imageProvider.resolve(const ImageConfiguration());
      stream.addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          if (!mounted) return;
          final w = info.image.width;
          final h = info.image.height;
          if (w > 0 && h > 0) {
            setState(() {
              // Instagram limits aspect ratio to between 0.8 (4:5 portrait) and 1.91 (landscape)
              final ratio = w / h;
              _aspectRatio = ratio.clamp(0.8, 1.91);
            });
          }
        }),
      );
    } catch (_) {}
  }

  void _openViewer(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedPhotoViewer(
          photos: widget.images,
          initialIndex: index,
          post: widget.postInfo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return const SizedBox.shrink();

    // Single image is displayed fully (uncropped, fit width)
    if (widget.images.length == 1) {
      return _singleImage(context);
    }

    // Multiple images displayed in an Instagram-style PageView carousel
    // with dynamic aspect ratio based on the first image
    return AspectRatio(
      aspectRatio: _aspectRatio,
      child: _buildCarousel(context),
    );
  }

  Widget _singleImage(BuildContext context) {
    final settings = widget.mediaMeta.isNotEmpty ? widget.mediaMeta[0] : const MediaEditSettings();
    return GestureDetector(
      onTap: () => _openViewer(context, 0),
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(
        color: AppColors.secondaryBackground(context),
        child: ColorFiltered(
          colorFilter: settings.hasEffect
              ? ImageFilterUtils.settingsToColorFilter(settings)
              : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
          child: appCachedImage(
            widget.images[0],
            fit: BoxFit.fitWidth,
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _buildCarousel(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: widget.images.length,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          itemBuilder: (context, index) {
            final settings = index < widget.mediaMeta.length
                ? widget.mediaMeta[index]
                : const MediaEditSettings();
            return _FeedMediaCell(
              url: widget.images[index],
              onTap: () => _openViewer(context, index),
              editSettings: settings,
            );
          },
        ),
        // Page index indicator in top right corner: "1 / X"
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.65),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_currentPage + 1} / ${widget.images.length}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        // Dots indicator at the bottom center
        Positioned(
          bottom: 12,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: isActive ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _FeedMediaCell extends StatelessWidget {
  final String url;
  final VoidCallback onTap;
  final String? overlay;
  final MediaEditSettings editSettings;

  const _FeedMediaCell({
    required this.url,
    required this.onTap,
    this.overlay,
    this.editSettings = const MediaEditSettings(),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(
        color: AppColors.secondaryBackground(context),
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            if (MediaUrlUtils.isVideoUrl(url))
              FeedVideoPreview(videoUrl: url, editSettings: editSettings)
            else
              ColorFiltered(
                colorFilter: editSettings.hasEffect
                    ? ImageFilterUtils.settingsToColorFilter(editSettings)
                    : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: appCachedImage(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            if (overlay != null)
              ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: Text(
                    overlay!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
