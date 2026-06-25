import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'connectivity_service.dart';
import 'image_cache_service.dart';
import 'media_url_utils.dart';

Widget appCachedImage(
  String url, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
  Widget? placeholder,
  Widget? errorWidget,
}) {
  final resolved = MediaUrlUtils.resolveUrl(url);
  if (resolved.isEmpty) {
    return errorWidget ?? const SizedBox.shrink();
  }

  final cacheKey = MediaUrlUtils.cacheKey(resolved);

  return CachedNetworkImage(
    imageUrl: resolved,
    cacheKey: cacheKey,
    cacheManager: AppImageCacheManager.instance,
    httpHeaders: const {'ngrok-skip-browser-warning': 'true'},
    fit: fit,
    width: width,
    height: height,
    placeholder: (_, __) =>
        placeholder ??
        Container(
          color: Colors.grey.shade900,
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
    errorWidget: (_, __, ___) =>
        _MediaFallbackImage(
          url: resolved,
          cacheKey: cacheKey,
          fit: fit,
          width: width,
          height: height,
          errorWidget: errorWidget,
        ),
  );
}

ImageProvider appCachedImageProvider(String url) {
  final resolved = MediaUrlUtils.resolveUrl(url);
  return CachedNetworkImageProvider(
    resolved,
    cacheKey: MediaUrlUtils.cacheKey(resolved),
    cacheManager: AppImageCacheManager.instance,
    headers: const {'ngrok-skip-browser-warning': 'true'},
  );
}

class _MediaFallbackImage extends StatelessWidget {
  final String url;
  final String cacheKey;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? errorWidget;

  const _MediaFallbackImage({
    required this.url,
    required this.cacheKey,
    required this.fit,
    this.width,
    this.height,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List?>(
      future: ImageCacheService.readLocalBytes(url),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !ConnectivityService.isOnline) {
          return _loadingBox();
        }

        final bytes = snapshot.data;
        if (bytes != null && bytes.isNotEmpty) {
          return Image.memory(
            bytes,
            fit: fit,
            width: width,
            height: height,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) => _brokenImage(),
          );
        }

        return _brokenImage();
      },
    );
  }

  Widget _brokenImage() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: Colors.grey.shade900,
          child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
        );
  }

  Widget _loadingBox() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade900,
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// Prefetch feed/profile media after API responses.
void prefetchMediaUrls(Iterable<String> urls) {
  ImageCacheService.prefetchAll(urls);
}
