import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

Future<VideoPlayerController?> createPlatformVideoController(
  Uint8List bytes,
  String filename,
) async {
  final dir = await getTemporaryDirectory();
  final safeName = filename.contains('.') ? filename : '$filename.mp4';
  final file = File('${dir.path}/edit_$safeName');
  await file.writeAsBytes(bytes, flush: true);
  final controller = VideoPlayerController.file(file);
  await controller.initialize();
  await controller.setLooping(true);
  return controller;
}
