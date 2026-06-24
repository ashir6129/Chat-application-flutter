import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';

import 'media_url_utils.dart';

class AppImageCacheManager extends CacheManager {
  static const _cacheKey = 'zyntraMediaCache';

  static final AppImageCacheManager instance = AppImageCacheManager._();

  AppImageCacheManager._()
      : super(
          Config(
            _cacheKey,
            stalePeriod: const Duration(days: 365),
            maxNrOfCacheObjects: 800,
            fileService: HttpFileService(),
          ),
        );
}

/// Persistent media cache for offline viewing (disk + cache manager).
class ImageCacheService {
  ImageCacheService._();

  static Directory? _dir;

  static Future<void> init() async {
    if (kIsWeb) return;
    final docs = await getApplicationDocumentsDirectory();
    _dir = Directory('${docs.path}/zyntra_media');
    await _dir!.create(recursive: true);
  }

  static Future<void> saveUploadBytes(String url, Uint8List bytes) async {
    final resolved = MediaUrlUtils.resolveUrl(url);
    if (resolved.isEmpty) return;

    final key = MediaUrlUtils.cacheKey(resolved);

    if (!kIsWeb && _dir != null) {
      await File('${_dir!.path}/$key').writeAsBytes(bytes, flush: true);
    }

    try {
      await AppImageCacheManager.instance.putFile(
        resolved,
        bytes,
        key: key,
      );
    } catch (_) {}
  }

  static Future<Uint8List?> readLocalBytes(String url) async {
    final resolved = MediaUrlUtils.resolveUrl(url);
    if (resolved.isEmpty) return null;

    final key = MediaUrlUtils.cacheKey(resolved);

    if (!kIsWeb && _dir != null) {
      final file = File('${_dir!.path}/$key');
      if (await file.exists()) {
        return file.readAsBytes();
      }
    }

    try {
      final cached = await AppImageCacheManager.instance.getFileFromCache(key);
      if (cached != null && await cached.file.exists()) {
        return cached.file.readAsBytes();
      }
    } catch (_) {}

    return null;
  }

  static Future<void> prefetch(String url) async {
    final resolved = MediaUrlUtils.resolveUrl(url);
    if (resolved.isEmpty || MediaUrlUtils.isVideoUrl(resolved)) return;

    try {
      await AppImageCacheManager.instance.downloadFile(
        resolved,
        key: MediaUrlUtils.cacheKey(resolved),
      );
    } catch (_) {}
  }

  static void prefetchAll(Iterable<String> urls) {
    for (final url in urls) {
      if (url.trim().isNotEmpty) {
        prefetch(url);
      }
    }
  }
}
