import 'dart:async';

import 'package:flutter/foundation.dart';

import '../api_services/chat_service.dart';
import 'connectivity_service.dart';
import 'offline_cache_service.dart';

class OfflineMessageQueue {
  OfflineMessageQueue._();

  static const _storageKey = 'pending_chat_messages';
  static VoidCallback? _listener;

  static Future<void> init() async {
    _listener ??= () {
      if (ConnectivityService.isOnline) {
        flush();
      }
    };
    ConnectivityService.onlineNotifier.addListener(_listener!);
    if (ConnectivityService.isOnline) {
      await flush();
    }
  }

  static List<Map<String, dynamic>> _read() {
    return OfflineCacheService.getJsonList(_storageKey) ?? [];
  }

  static Future<void> _write(List<Map<String, dynamic>> items) async {
    await OfflineCacheService.setJson(_storageKey, items);
  }

  static Future<void> enqueue({
    required String conversationId,
    required String body,
  }) async {
    final items = _read();
    items.add({
      'conversation_id': conversationId,
      'body': body,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _write(items);
  }

  static Future<void> flush() async {
    if (!ConnectivityService.isOnline) return;

    final pending = _read();
    if (pending.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    for (final item in pending) {
      final conversationId = item['conversation_id']?.toString() ?? '';
      final body = item['body']?.toString() ?? '';
      if (conversationId.isEmpty || body.isEmpty) continue;

      try {
        await ChatService.sendMessage(conversationId, body);
      } catch (e) {
        debugPrint('Offline queue flush failed: $e');
        remaining.add(item);
      }
    }

    await _write(remaining);
  }

  static void dispose() {
    if (_listener != null) {
      ConnectivityService.onlineNotifier.removeListener(_listener!);
      _listener = null;
    }
  }
}
