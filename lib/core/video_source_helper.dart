import 'dart:typed_data';

import 'package:video_player/video_player.dart';

import 'video_blob_helper_stub.dart'
    if (dart.library.html) 'video_blob_helper_web.dart'
    if (dart.library.io) 'video_blob_helper_io.dart';

class VideoSourceHelper {
  VideoSourceHelper._();

  static Future<VideoPlayerController?> createController(
    Uint8List bytes,
    String filename,
  ) {
    return createPlatformVideoController(bytes, filename);
  }
}
