import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/cached_image.dart';
import '../../core/image_filter_utils.dart';
import '../../core/media_edit_settings.dart';
import '../../core/media_url_utils.dart';
import 'feed_photo_viewer.dart';
import 'feed_video_preview.dart';

/// Portrait multi-image layouts — bounded to [feedMediaHeight] like APK post media.
class FeedImageGrid extends StatelessWidget {
  final List<String> images;
  final FeedPhotoViewerPost? postInfo;
  final List<MediaEditSettings> mediaMeta;

  const FeedImageGrid({
    super.key,
    required this.images,
    this.postInfo,
    this.mediaMeta = const [],
  });

  /// Same bold height as [ImageWidget] / [VideoWidget] in post_widget.dart.
  static const double feedMediaHeight = 280;

  static const double _gap = 4;

  void _openViewer(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FeedPhotoViewer(
          photos: images,
          initialIndex: index,
          post: postInfo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: feedMediaHeight,
      child: ClipRect(
        child: _buildLayout(context, images.length),
      ),
    );
  }

  Widget _buildLayout(BuildContext context, int count) {
    return switch (count) {
      1 => _cell(context, 0),
      2 => _twoImages(context),
      3 => _threeImages(context),
      4 => _fourImages(context),
      _ => _fivePlusImages(context, count),
    };
  }

  Widget _twoImages(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _cell(context, 0)),
        const SizedBox(width: _gap),
        Expanded(child: _cell(context, 1)),
      ],
    );
  }

  Widget _threeImages(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _cell(context, 0)),
        const SizedBox(width: _gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _cell(context, 1)),
              const SizedBox(height: _gap),
              Expanded(child: _cell(context, 2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fourImages(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _cell(context, 0)),
        const SizedBox(width: _gap),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _cell(context, 1)),
              const SizedBox(height: _gap),
              Expanded(child: _cell(context, 2)),
              const SizedBox(height: _gap),
              Expanded(child: _cell(context, 3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _fivePlusImages(BuildContext context, int count) {
    final overlay = count > 5 ? '+${count - 5}' : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _cell(context, 0)),
              const SizedBox(width: _gap),
              Expanded(child: _cell(context, 1)),
            ],
          ),
        ),
        const SizedBox(height: _gap),
        Expanded(
          flex: 3,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _cell(context, 2)),
              const SizedBox(width: _gap),
              Expanded(child: _cell(context, 3)),
              const SizedBox(width: _gap),
              Expanded(child: _cell(context, 4, overlay: overlay)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _cell(BuildContext context, int index, {String? overlay}) {
    final settings = index < mediaMeta.length ? mediaMeta[index] : const MediaEditSettings();
    return _FeedMediaCell(
      url: images[index],
      onTap: () => _openViewer(context, index),
      overlay: overlay,
      editSettings: settings,
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
