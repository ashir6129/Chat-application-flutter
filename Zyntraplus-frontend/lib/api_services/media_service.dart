import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../core/access_token_manager.dart';
import '../core/api_config.dart';
import '../core/api_exception.dart';
import '../core/image_cache_service.dart';
import '../core/media_url_utils.dart';

class MediaService {
  MediaService._();

  static Future<List<String>> uploadFiles({
    required List<Uint8List> bytesList,
    required List<String> filenames,
  }) async {
    if (bytesList.isEmpty) return [];

    final token = await AccessTokenManager.getValidToken();
    if (token == null) {
      throw ApiException('Please sign in to upload media', 401);
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}/posts/media/upload');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    for (var i = 0; i < bytesList.length; i++) {
      final name = _normalizeFilename(filenames[i], i);
      request.files.add(
        http.MultipartFile.fromBytes(
          'files',
          bytesList[i],
          filename: name,
          contentType: _contentTypeFor(name),
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    Map<String, dynamic>? decoded;

    if (response.body.isNotEmpty) {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        decoded?['message']?.toString() ?? 'Upload failed (${response.statusCode})',
        response.statusCode,
      );
    }

    final files = decoded?['data']?['files'] as List<dynamic>? ?? [];
    final urls = files.map((f) => f['url'].toString()).toList();

    for (var i = 0; i < urls.length && i < bytesList.length; i++) {
      await ImageCacheService.saveUploadBytes(urls[i], bytesList[i]);
    }

    return urls.map(MediaUrlUtils.resolveUrl).toList();
  }

  static String _normalizeFilename(String name, int index) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed == 'blob' || !trimmed.contains('.')) {
      return 'upload_$index.jpg';
    }
    return trimmed;
  }

  static MediaType _contentTypeFor(String filename) {
    final lower = filename.toLowerCase();

    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.webp')) return MediaType('image', 'webp');
    if (lower.endsWith('.gif')) return MediaType('image', 'gif');
    if (lower.endsWith('.mp4')) return MediaType('video', 'mp4');
    if (lower.endsWith('.webm')) return MediaType('video', 'webm');
    if (lower.endsWith('.mov')) return MediaType('video', 'quicktime');
    if (lower.endsWith('.avi')) return MediaType('video', 'x-msvideo');

    return MediaType('image', 'jpeg');
  }
}
