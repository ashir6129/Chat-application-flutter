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

  Widget _buildImageCell(BuildContext context, int index, {String? overlayText}) {
    final url = widget.images[index];
    final settings = index < widget.mediaMeta.length
        ? widget.mediaMeta[index]
        : const MediaEditSettings();

    return GestureDetector(
      onTap: () => _openViewer(context, index),
      behavior: HitTestBehavior.opaque,
      child: ColoredBox(
        color: AppColors.secondaryBackground(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (MediaUrlUtils.isVideoUrl(url))
              FeedVideoPreview(videoUrl: url, editSettings: settings)
            else
              ColorFiltered(
                colorFilter: settings.hasEffect
                    ? ImageFilterUtils.settingsToColorFilter(settings)
                    : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: appCachedImage(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            if (overlayText != null)
              Container(
                color: Colors.black.withOpacity(0.55),
                alignment: Alignment.center,
                child: Text(
                  overlayText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.images.length;
    if (count == 0) return const SizedBox.shrink();

    if (count == 1) {
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

    if (count == 2) {
      return AspectRatio(
        aspectRatio: 1.5,
        child: Row(
          children: [
            Expanded(child: _buildImageCell(context, 0)),
            const SizedBox(width: 8),
            Expanded(child: _buildImageCell(context, 1)),
          ],
        ),
      );
    }

    if (count == 3) {
      return AspectRatio(
        aspectRatio: 1.0,
        child: Row(
          children: [
            Expanded(child: _buildImageCell(context, 0)),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: _buildImageCell(context, 1)),
                  const SizedBox(height: 8),
                  Expanded(child: _buildImageCell(context, 2)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // 4 or more images
    final hasOverlay = count > 4;
    final remainingCount = count - 3; // e.g. 5 images -> shows +2 on the 4th box

    return AspectRatio(
      aspectRatio: 1.0,
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImageCell(context, 0)),
                const SizedBox(width: 8),
                Expanded(child: _buildImageCell(context, 1)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _buildImageCell(context, 2)),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildImageCell(
                    context,
                    3,
                    overlayText: hasOverlay ? '+$remainingCount' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
