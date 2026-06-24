import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'media_edit_settings.dart';

class ImageFilterPreset {
  final String name;
  final List<double> matrix;

  const ImageFilterPreset(this.name, this.matrix);
}

/// Instagram-style filter presets (color matrix).
class ImageFilterUtils {
  ImageFilterUtils._();

  static const original = ImageFilterPreset('Original', <double>[
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  static const presets = <ImageFilterPreset>[
    original,
    ImageFilterPreset('Clarendon', [
      1.2, 0.1, 0, 0, 20,
      0, 1.1, 0, 0, 10,
      0, 0, 0.9, 0, 10,
      0, 0, 0, 1, 0,
    ]),
    ImageFilterPreset('Gingham', [
      1.05, 0.05, 0, 0, 15,
      0, 1.05, 0, 0, 10,
      0, 0, 1.1, 0, 5,
      0, 0, 0, 1, 0,
    ]),
    ImageFilterPreset('Moon', [
      0.9, 0.1, 0.1, 0, 10,
      0.1, 0.9, 0.1, 0, 10,
      0.1, 0.1, 0.9, 0, 10,
      0, 0, 0, 1, 0,
    ]),
    ImageFilterPreset('Lark', [
      1.1, 0, 0, 0, 15,
      0, 1.05, 0, 0, 10,
      0, 0, 0.95, 0, 5,
      0, 0, 0, 1, 0,
    ]),
    ImageFilterPreset('Reyes', [
      1.05, 0.05, 0, 0, 25,
      0, 0.95, 0, 0, 20,
      0, 0, 0.9, 0, 15,
      0, 0, 0, 1, 0,
    ]),
    ImageFilterPreset('Juno', [
      1.15, 0.05, 0, 0, 5,
      0, 1.1, 0, 0, 5,
      0, 0, 0.85, 0, 0,
      0, 0, 0, 1, 0,
    ]),
    ImageFilterPreset('Slumber', [
      0.95, 0.05, 0.1, 0, 15,
      0.05, 0.9, 0.1, 0, 10,
      0.05, 0.1, 1.05, 0, 5,
      0, 0, 0, 1, 0,
    ]),
    ImageFilterPreset('Valencia', [
      1.08, 0.05, 0, 0, 20,
      0, 1.02, 0, 0, 15,
      0, 0, 0.92, 0, 10,
      0, 0, 0, 1, 0,
    ]),
    ImageFilterPreset('Hudson', [
      1.1, 0, 0, 0, 10,
      0, 1, 0.05, 0, 10,
      0, 0, 1.2, 0, 15,
      0, 0, 0, 1, 0,
    ]),
    ImageFilterPreset('Willow', [
      0.85, 0.15, 0.15, 0, 5,
      0.15, 0.85, 0.15, 0, 5,
      0.15, 0.15, 0.85, 0, 5,
      0, 0, 0, 1, 0,
    ]),
    ImageFilterPreset('Crema', [
      1.05, 0, 0, 0, 18,
      0, 1, 0, 0, 12,
      0, 0, 0.95, 0, 8,
      0, 0, 0, 1, 0,
    ]),
  ];

  static ImageFilterPreset byName(String name) {
    for (final preset in presets) {
      if (preset.name == name) return preset;
    }
    return original;
  }

  static ColorFilter settingsToColorFilter(MediaEditSettings settings) {
    return previewColorFilter(
      preset: byName(settings.filterName),
      brightness: settings.brightness,
      contrast: settings.contrast,
      saturation: settings.saturation,
    );
  }

  static ColorFilter previewColorFilter({
    required ImageFilterPreset preset,
    double brightness = 0,
    double contrast = 1,
    double saturation = 1,
  }) {
    final base = preset.matrix;
    final c = contrast.clamp(0.5, 1.8);
    final b = (brightness * 255).clamp(-100.0, 100.0);
    final t = (128 * (1 - c) + b).clamp(-255.0, 255.0);
    final s = saturation.clamp(0.0, 2.0);

    final contrastMatrix = <double>[
      c * s, 0, 0, 0, t,
      0, c * s, 0, 0, t,
      0, 0, c * s, 0, t,
      0, 0, 0, 1, 0,
    ];

    return ColorFilter.matrix(_multiplyColorMatrices(base, contrastMatrix));
  }

  static List<double> _multiplyColorMatrices(List<double> a, List<double> b) {
    final out = List<double>.filled(20, 0);
    for (var row = 0; row < 4; row++) {
      for (var col = 0; col < 5; col++) {
        if (col == 4) {
          out[row * 5 + 4] = a[row * 5 + 4] + b[row * 5 + 4];
        } else {
          out[row * 5 + col] =
              a[row * 5 + 0] * b[0 * 5 + col] +
              a[row * 5 + 1] * b[1 * 5 + col] +
              a[row * 5 + 2] * b[2 * 5 + col] +
              a[row * 5 + 3] * b[3 * 5 + col];
        }
      }
    }
    return out;
  }

  static ColorFilter colorFilterFor(ImageFilterPreset preset) {
    return previewColorFilter(preset: preset);
  }

  static final Map<String, ColorFilter> _presetOnlyCache = {};

  /// Cached preset filters for fast thumbnail strip (no adjust params).
  static ColorFilter cachedPresetFilter(ImageFilterPreset preset) {
    return _presetOnlyCache.putIfAbsent(
      preset.name,
      () => previewColorFilter(preset: preset),
    );
  }

  /// Smaller bytes for smooth in-editor preview on web/mobile.
  static Uint8List createPreviewBytes(Uint8List source, {int maxWidth = 480}) {
    final decoded = img.decodeImage(source);
    if (decoded == null) return source;
    if (decoded.width <= maxWidth) return source;
    final resized = img.copyResize(decoded, width: maxWidth);
    return Uint8List.fromList(img.encodeJpg(resized, quality: 78));
  }

  /// Web-safe resize using Flutter's codec (supports formats the editor already displays).
  static Future<Uint8List> createPreviewBytesAsync(Uint8List source, {int maxWidth = 480}) async {
    if (source.isEmpty) return source;
    try {
      final codec = await ui.instantiateImageCodec(source, targetWidth: maxWidth);
      final frame = await codec.getNextFrame();
      final data = await frame.image.toByteData(format: ui.ImageByteFormat.png);
      frame.image.dispose();
      if (data != null) {
        return data.buffer.asUint8List();
      }
    } catch (_) {
      // Fall back to original bytes — still renderable by Image.memory.
    }
    return source;
  }

  static Future<Uint8List> applyFilter(Uint8List bytes, ImageFilterPreset preset) async {
    if (preset.name == original.name) return bytes;

    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    final m = preset.matrix;
    final out = img.Image.from(decoded);

    for (var y = 0; y < out.height; y++) {
      for (var x = 0; x < out.width; x++) {
        final p = out.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();

        final nr = (r * m[0] + g * m[1] + b * m[2] + m[4]).clamp(0, 255).toInt();
        final ng = (r * m[5] + g * m[6] + b * m[7] + m[9]).clamp(0, 255).toInt();
        final nb = (r * m[10] + g * m[11] + b * m[12] + m[14]).clamp(0, 255).toInt();

        out.setPixelRgba(x, y, nr, ng, nb, p.a.toInt());
      }
    }

    return Uint8List.fromList(img.encodeJpg(out, quality: 92));
  }

  static Future<Uint8List> applyAdjustments(
    Uint8List bytes, {
    double brightness = 0,
    double contrast = 1,
    double saturation = 1,
  }) async {
    if (brightness == 0 && contrast == 1 && saturation == 1) return bytes;

    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    var out = img.adjustColor(
      decoded,
      brightness: brightness,
      contrast: contrast,
      saturation: saturation,
    );

    return Uint8List.fromList(img.encodeJpg(out, quality: 92));
  }
}
