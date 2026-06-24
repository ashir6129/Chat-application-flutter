import '../core/api_config.dart';

/// Helpers for distinguishing image vs video media URLs from the API.
class MediaUrlUtils {
  MediaUrlUtils._();

  static String get _mediaOrigin => ApiConfig.socketOrigin;

  static bool isVideoUrl(String url) {
    final resolved = resolveUrl(url);
    if (resolved.isEmpty) return false;
    final path = resolved.toLowerCase().split('?').first;
    return path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.webm') ||
        path.endsWith('.mkv') ||
        path.endsWith('.m4v');
  }

  static bool isImageUrl(String url) {
    final resolved = resolveUrl(url);
    return resolved.isNotEmpty && !isVideoUrl(resolved);
  }

  /// Fix localhost/dev URLs and relative `/uploads/...` paths for the active API host.
  static String resolveUrl(String? url) {
    if (url == null) return '';
    final trimmed = url.trim();
    if (trimmed.isEmpty) return '';

    if (trimmed.startsWith('/uploads/')) {
      return '$_mediaOrigin$trimmed';
    }

    if (trimmed.startsWith('uploads/')) {
      return '$_mediaOrigin/$trimmed';
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      if (uri.path.startsWith('/uploads/') && _isLocalHost(uri.host)) {
        return '$_mediaOrigin${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';
      }
      return trimmed;
    }

    return trimmed;
  }

  /// Stable cache key based on upload path (host changes do not bust cache).
  static String cacheKey(String url) {
    final resolved = resolveUrl(url);
    final uri = Uri.tryParse(resolved);
    if (uri != null && uri.path.startsWith('/uploads/')) {
      return uri.path.replaceAll('/', '_');
    }
    return resolved;
  }

  static bool _isLocalHost(String host) {
    const local = {'localhost', '127.0.0.1', '10.0.2.2', '0.0.0.0'};
    return local.contains(host.toLowerCase());
  }
}
