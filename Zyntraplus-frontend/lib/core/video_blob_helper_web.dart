import 'dart:html' as html;
import 'dart:typed_data';

import 'package:video_player/video_player.dart';

Future<VideoPlayerController?> createPlatformVideoController(
  Uint8List bytes,
  String filename,
) async {
  final mime = filename.toLowerCase().endsWith('.mov') ? 'video/quicktime' : 'video/mp4';
  final blob = html.Blob([bytes], mime);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final controller = VideoPlayerController.networkUrl(Uri.parse(url));
  await controller.initialize();
  await controller.setLooping(true);
  return controller;
}
