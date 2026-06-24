import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'image_filter_utils.dart';

enum OverlayKind { emoji, text }

class MediaOverlay {
  final String id;
  OverlayKind kind;
  Offset position;
  double scale;
  String emoji;
  String text;
  Color textColor;
  String textStyle;

  MediaOverlay.emoji({
    required this.id,
    required this.emoji,
    this.position = const Offset(100, 100),
    this.scale = 1,
  })  : kind = OverlayKind.emoji,
        text = '',
        textColor = Colors.white,
        textStyle = 'Classic';

  MediaOverlay.text({
    required this.id,
    required this.text,
    this.position = const Offset(80, 140),
    this.scale = 1,
    this.textColor = Colors.white,
    this.textStyle = 'Classic',
  })  : kind = OverlayKind.text,
        emoji = '';

  double get fontSize => kind == OverlayKind.emoji ? 36 * scale : 22 * scale;

  TextStyle resolveTextStyle() {
    return switch (textStyle) {
      'Neon' => TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(color: textColor.withValues(alpha: 0.9), blurRadius: 12),
            Shadow(color: textColor.withValues(alpha: 0.5), blurRadius: 24),
          ],
        ),
      'Bold' => TextStyle(
          fontSize: fontSize,
          color: Colors.white,
          fontWeight: FontWeight.w900,
          backgroundColor: Colors.black.withValues(alpha: 0.55),
        ),
      'Typewriter' => TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500,
        ),
      _ => TextStyle(
          fontSize: fontSize,
          color: textColor,
          fontWeight: FontWeight.w700,
          shadows: const [
            Shadow(color: Colors.black87, blurRadius: 6, offset: Offset(1, 1)),
            Shadow(color: Colors.black54, blurRadius: 12),
          ],
        ),
    };
  }
}

class ImageCompositor {
  ImageCompositor._();

  static Future<Uint8List> renderFinal({
    required Uint8List sourceBytes,
    required ImageFilterPreset filter,
    double brightness = 0,
    double contrast = 1,
    double saturation = 1,
    List<MediaOverlay> overlays = const [],
    Size previewSize = const Size(360, 480),
  }) async {
    var bytes = sourceBytes;
    bytes = await ImageFilterUtils.applyAdjustments(
      bytes,
      brightness: brightness,
      contrast: contrast,
      saturation: saturation,
    );
    bytes = await ImageFilterUtils.applyFilter(bytes, filter);

    if (overlays.isEmpty) return bytes;

    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;
    final width = image.width;
    final height = image.height;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(image, Offset.zero, Paint());

    final scaleX = width / previewSize.width;
    final scaleY = height / previewSize.height;

    for (final overlay in overlays) {
      final displayText = overlay.kind == OverlayKind.emoji ? overlay.emoji : overlay.text;
      if (displayText.isEmpty) continue;

      final painter = TextPainter(
        text: TextSpan(text: displayText, style: overlay.resolveTextStyle()),
        textDirection: TextDirection.ltr,
      )..layout();

      final offset = Offset(
        overlay.position.dx * scaleX,
        overlay.position.dy * scaleY,
      );
      painter.paint(canvas, offset);
    }

    final picture = recorder.endRecording();
    final rendered = await picture.toImage(width, height);
    final byteData = await rendered.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    rendered.dispose();

    if (byteData == null) return bytes;
    final pngBytes = byteData.buffer.asUint8List();

    final decoded = img.decodeImage(pngBytes);
    if (decoded == null) return pngBytes;
    return Uint8List.fromList(img.encodeJpg(decoded, quality: 92));
  }
}
