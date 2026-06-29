import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/app_colors.dart';
import '../../core/image_filter_utils.dart';
import '../../core/media_edit_settings.dart';

class FeedVideoPreview extends StatefulWidget {
  final String videoUrl;
  final MediaEditSettings? editSettings;

  const FeedVideoPreview({
    super.key,
    required this.videoUrl,
    this.editSettings,
  });

  @override
  State<FeedVideoPreview> createState() => _FeedVideoPreviewState();
}

class _FeedVideoPreviewState extends State<FeedVideoPreview> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.editSettings ?? const MediaEditSettings();
    final filter = settings.hasEffect
        ? ImageFilterUtils.settingsToColorFilter(settings)
        : const ColorFilter.mode(Colors.transparent, BlendMode.dst);

    return AspectRatio(
      aspectRatio: 9 / 16,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          if (_initialized)
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller!.value.size.width,
                height: _controller!.value.size.height,
                child: ColorFiltered(
                  colorFilter: filter,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          else
            const CircularProgressIndicator(strokeWidth: 2),
          if (_initialized)
            GestureDetector(
              onTap: () {
                setState(() {
                  _controller!.value.isPlaying
                      ? _controller!.pause()
                      : _controller!.play();
                });
              },
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70),
                ),
                child: Icon(
                  _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam_rounded, color: AppColors.buttonColor(context), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    settings.hasEffect ? 'Video · ${settings.filterName}' : 'Video',
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
