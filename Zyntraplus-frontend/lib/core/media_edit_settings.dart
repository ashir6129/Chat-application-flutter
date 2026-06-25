import 'package:flutter/material.dart';

/// Saved edit settings for image/video (filters applied at display time for video).
class MediaEditSettings {
  final String filterName;
  final double brightness;
  final double contrast;
  final double saturation;

  const MediaEditSettings({
    this.filterName = 'Original',
    this.brightness = 0,
    this.contrast = 1,
    this.saturation = 1,
  });

  bool get hasEffect =>
      filterName != 'Original' || brightness != 0 || contrast != 1 || saturation != 1;

  Map<String, dynamic> toJson() => {
        'filter': filterName,
        'brightness': brightness,
        'contrast': contrast,
        'saturation': saturation,
      };

  factory MediaEditSettings.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MediaEditSettings();
    return MediaEditSettings(
      filterName: json['filter']?.toString() ?? 'Original',
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0,
      contrast: (json['contrast'] as num?)?.toDouble() ?? 1,
      saturation: (json['saturation'] as num?)?.toDouble() ?? 1,
    );
  }

  MediaEditSettings copyWith({
    String? filterName,
    double? brightness,
    double? contrast,
    double? saturation,
  }) {
    return MediaEditSettings(
      filterName: filterName ?? this.filterName,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
    );
  }
}
