import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/cached_image.dart';

/// Initial avatar: teal ring + dark fill + teal initial (matches feed/profile UI).
class FeedUserAvatar extends StatelessWidget {
  final String name;
  final Color accentColor;
  final String? imageUrl;
  final String? initials;
  final double size;
  final bool showBorder;
  final Color? borderColor;

  const FeedUserAvatar({
    super.key,
    required this.name,
    required this.accentColor,
    this.imageUrl,
    this.initials,
    this.size = 38,
    this.showBorder = true,
    this.borderColor,
  });

  String get _initial {
    if (initials != null && initials!.trim().isNotEmpty) {
      return initials!.trim();
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ringColor = borderColor ?? accentColor.withValues(alpha: 0.55);
    final hasPhoto = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final photoBorder =
        showBorder ? Border.all(color: ringColor, width: 1.5) : null;
    final placeholderBorder =
        showBorder ? Border.all(color: ringColor, width: 1.5) : null;

    if (hasPhoto) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, border: photoBorder),
        child: ClipOval(
          child: appCachedImage(
            imageUrl!,
            fit: BoxFit.cover,
            width: size,
            height: size,
            errorWidget: _placeholder(context, placeholderBorder),
          ),
        ),
      );
    }

    return _placeholder(context, placeholderBorder);
  }

  Widget _placeholder(BuildContext context, Border? border) {
    final ringColor = borderColor ?? accentColor.withValues(alpha: 0.55);
    final effectiveBorder = border ?? Border.all(color: ringColor, width: 1.5);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: effectiveBorder,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.25),
            accentColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        _initial,
        style: TextStyle(
          color: accentColor,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String formatFeedDistance(String? dist) {
  final value = dist?.trim() ?? '';
  if (value.isEmpty || value.toLowerCase() == 'nearby') return 'Nearby';
  if (value.toLowerCase().contains('away')) return value;
  return '$value away';
}

Color feedAccentColorForName(String name) {
  const palette = [
    Color(0xFFFF9800),
    Color(0xFF00A884),
    Color(0xFF3D9BFF),
    Color(0xFFFF6584),
    Color(0xFF9B59FF),
    Color(0xFF26C6DA),
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
  ];
  return palette[name.hashCode.abs() % palette.length];
}

/// Teal navigation arrow used for post distance / nearby labels.
class FeedNearbyIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const FeedNearbyIcon({
    super.key,
    this.size = 12,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.near_me_rounded,
      size: size,
      color: color ?? AppColors.buttonColor(context),
    );
  }
}
